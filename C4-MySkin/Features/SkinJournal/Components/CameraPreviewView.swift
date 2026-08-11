//
//  CameraPreviewView.swift
//  C4-MySkin
//

import SwiftUI
import AVFoundation
import Vision

/// UIView container yang otomatis menjaga frame preview layer mengikuti bounds.
/// Mengatasi preview hitam karena frame layer pernah 0 / tertunda saat layout.
/// Menampilkan indikator "Menyiapkan kamera…" selama session belum berjalan.
private final class CameraContainerView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let preparingLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        preparingLabel.text = "Menyiapkan kamera…"
        preparingLabel.textColor = .white
        preparingLabel.font = .systemFont(ofSize: 13, weight: .medium)
        preparingLabel.textAlignment = .center
        preparingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        addSubview(preparingLabel)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -16),
            preparingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            preparingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 8)
        ])
        spinner.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    /// Tampilkan/sembunyikan indikator "menyiapkan kamera".
    func setPreparing(_ preparing: Bool) {
        if preparing {
            spinner.startAnimating()
            preparingLabel.isHidden = false
        } else {
            spinner.stopAnimating()
            preparingLabel.isHidden = true
        }
    }
}

/// Live camera preview (UIViewRepresentable).
///
/// Session kamera dipegang `CameraSessionManager` (pre-warm saat "Add Photos"
/// ditekan) — representable ini hanya: (1) attach preview layer ke session
/// yang sudah berjalan, (2) deteksi wajah Vision terhadap `guideRect`,
/// (3) capture frame saat `captureRequest` naik.
struct CameraPreviewView: UIViewRepresentable {
    @Binding var isFaceCentered: Bool
    @Binding var captureRequest: Int

    /// Area guide muka dalam koordinat ternormalisasi (origin kiri-atas).
    var guideRect: CGRect = CGRect(x: 0.12, y: 0.10, width: 0.76, height: 0.80)

    let onCapture: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator {
        var parent: CameraPreviewView
        var previewLayer: AVCaptureVideoPreviewLayer?

        private var lastRequest = 0
        private var stableState = false
        private var stableCount = 0
        private let stableThreshold = 5

        init(parent: CameraPreviewView) {
            self.parent = parent
            #if !targetEnvironment(simulator)
            // Daftarkan handler frame deteksi wajah ke proxy session shared.
            CameraOutputProxy.shared.setHandler { [weak self] buffer in
                self?.processFrame(buffer)
            }
            #endif
        }

        // MARK: - Frame processing (Vision face detection)

        func processFrame(_ pixelBuffer: CVPixelBuffer) {
            let request = VNDetectFaceRectanglesRequest { [weak self] req, _ in
                guard let self else { return }
                let faces = (req.results as? [VNFaceObservation]) ?? []
                let largest = faces.max {
                    $0.boundingBox.width * $0.boundingBox.height
                        < $1.boundingBox.width * $1.boundingBox.height
                }

                let isCentered: Bool
                if let face = largest {
                    // Vision bbox: normalized, origin kiri-bawah → ubah ke kiri-atas
                    let b = face.boundingBox
                    let rect = CGRect(x: b.minX, y: 1 - b.maxY, width: b.width, height: b.height)
                    let guide = self.parent.guideRect

                    let centerOK = abs(rect.midX - guide.midX) < 0.09
                        && abs(rect.midY - guide.midY) < 0.10
                    // Ukuran wajah: minimum diturunkan (0.25x guide) supaya bisa
                    // terdeteksi dari jarak lebih jauh; maksimum tetap dibatasi.
                    let sizeOK = rect.width > guide.width * 0.25
                        && rect.width < guide.width * 1.15
                        && rect.height > guide.height * 0.22
                        && rect.height < guide.height * 1.20

                    isCentered = centerOK && sizeOK
                } else {
                    isCentered = false
                }

                // Hysteresis: publish hanya setelah state stabil beberapa frame
                if isCentered == self.stableState {
                    self.stableCount += 1
                } else {
                    self.stableState = isCentered
                    self.stableCount = 1
                }
                guard self.stableCount >= self.stableThreshold else { return }

                DispatchQueue.main.async {
                    if self.parent.isFaceCentered != self.stableState {
                        self.parent.isFaceCentered = self.stableState
                    }
                }
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
            try? handler.perform([request])
        }

        // MARK: - Capture

        func handleCaptureRequest() {
            guard let pixelBuffer = CameraOutputProxy.shared.take() else { return }

            // Selfie mirror + orientasi portrait, sama seperti yang terlihat di preview
            let ci = CIImage(cvPixelBuffer: pixelBuffer).oriented(.leftMirrored)
            let extent = ci.extent

            // Crop 1:1 bagian tengah — area yang terlihat di preview (aspectFill)
            let side = min(extent.width, extent.height)
            let cropRect = CGRect(
                x: (extent.width - side) / 2,
                y: (extent.height - side) / 2,
                width: side,
                height: side
            )

            let context = CIContext()
            guard let cgImage = context.createCGImage(ci.cropped(to: cropRect), from: cropRect) else { return }
            parent.onCapture(UIImage(cgImage: cgImage))
        }

        func processCaptureRequestChange() {
            let request = parent.captureRequest
            guard request > lastRequest else { return }
            lastRequest = request

            #if targetEnvironment(simulator)
            // Simulator tidak punya frame kamera → placeholder
            if let placeholder = UIImage(named: "FaceOutline") {
                parent.onCapture(placeholder)
            }
            #else
            handleCaptureRequest()
            #endif
        }
    }

    func makeUIView(context: Context) -> UIView {
        let view = CameraContainerView(frame: .zero)
        view.backgroundColor = .black

        #if targetEnvironment(simulator)
        // Simulator: tanpa kamera → langsung tampilkan label, sembunyikan spinner
        view.setPreparing(false)
        let label = UILabel()
        label.text = "📷 Live Camera Preview (1:1)"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Simulasi wajah terdeteksi di tengah (untuk testing simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isFaceCentered = true
        }
        #else
        attachPreviewLayerIfPossible(to: view, coordinator: context.coordinator)
        syncPreparingState(to: view)
        #endif

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // PENTING: sinkronkan parent (struktur terbaru) ke coordinator —
        // tanpa ini binding (captureRequest, guideRect) terbaca stale.
        context.coordinator.parent = self
        if let previewLayer = context.coordinator.previewLayer {
            previewLayer.frame = uiView.bounds
        }
        #if !targetEnvironment(simulator)
        attachPreviewLayerIfPossible(to: uiView, coordinator: context.coordinator)
        syncPreparingState(to: uiView)
        #endif
        context.coordinator.processCaptureRequestChange()
    }

    // MARK: - Helpers

    /// Attach preview layer ke session shared (sekali saja), kalau session
    /// sudah tersedia. Dipanggil dari makeUIView & updateUIView (main thread).
    private func attachPreviewLayerIfPossible(to view: UIView, coordinator: Coordinator) {
        guard coordinator.previewLayer == nil,
              let session = CameraSessionManager.shared.session else { return }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        // Preview SELALU mirror (selfie view) — eksplisit, supaya tampilan
        // user selalu cocok dengan hasil foto capture.
        // PENTING: nonaktifkan automaticallyAdjustsVideoMirroring dulu —
        // kalau YES (default kamera depan), set isVideoMirrored = CRASH.
        if let connection = previewLayer.connection, connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        view.layer.addSublayer(previewLayer)
        coordinator.previewLayer = previewLayer
        (view as? CameraContainerView)?.previewLayer = previewLayer
    }

    /// Spinner tampil hanya selama kamera masih disiapkan (bukan running/
    /// failed/denied) — supaya tidak pernah stuck selamanya.
    private func syncPreparingState(to view: UIView) {
        let state = CameraSessionManager.shared.stateModel.state
        let preparing = (state == .idle || state == .preparing)
        (view as? CameraContainerView)?.setPreparing(preparing)
    }
}
