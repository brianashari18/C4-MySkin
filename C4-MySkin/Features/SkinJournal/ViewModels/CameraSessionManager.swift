//
//  CameraSessionManager.swift
//  C4-MySkin
//

@preconcurrency import AVFoundation
import Observation

/// Proxy delegate video output (NON-isolated) — dipanggil dari video queue.
/// Menyimpan frame terbaru + meneruskan frame ke handler deteksi wajah.
final class CameraOutputProxy: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = CameraOutputProxy()

    private let frameLock = NSLock()
    nonisolated(unsafe) private var latestBuffer: CVPixelBuffer?

    private let handlerLock = NSLock()
    nonisolated(unsafe) private var frameHandler: ((CVPixelBuffer) -> Void)?

    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        frameLock.lock()
        latestBuffer = pixelBuffer
        frameLock.unlock()
        handlerLock.lock()
        let handler = frameHandler
        handlerLock.unlock()
        handler?(pixelBuffer)
    }

    /// Ambil frame terbaru untuk capture.
    func take() -> CVPixelBuffer? {
        frameLock.lock()
        defer { frameLock.unlock() }
        return latestBuffer
    }

    /// Pasang handler per-frame (dipasang oleh CameraPreviewView.Coordinator).
    func setHandler(_ handler: ((CVPixelBuffer) -> Void)?) {
        handlerLock.lock()
        frameHandler = handler
        handlerLock.unlock()
    }
}

/// State kamera yang diamati SwiftUI (di-update dari main thread).
@Observable
final class CameraStateModel {
    var state: CameraSessionManager.State = .idle
}

/// Session kamera SHARED — dibuat & distart LEBIH AWAL (saat user mengetuk
/// "Add Photos"), sebelum halaman kamera muncul, sehingga preview langsung
/// tampil tanpa menunggu warm-up yang lama.
final class CameraSessionManager {
    static let shared = CameraSessionManager()

    enum State: Equatable {
        case idle
        case preparing
        case running
        case denied
        case failed(String)
    }

    /// State yang diamati SwiftUI (selalu di-update dari main thread).
    let stateModel = CameraStateModel()

    private let lock = NSLock()
    private var _session: AVCaptureSession?
    private var timeoutWork: DispatchWorkItem?

    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    private init() {}

    var session: AVCaptureSession? {
        lock.lock()
        defer { lock.unlock() }
        return _session
    }

    // MARK: - Public

    /// Siapkan kamera (idempotent). Panggil SEBELUM halaman kamera muncul.
    func prepare() {
        #if targetEnvironment(simulator)
        return  // simulator tanpa kamera — pakai jalur simulasi CameraPreviewView
        #else
        switch stateModel.state {
        case .running, .preparing:
            return
        case .denied, .failed:
            stateModel.state = .preparing  // izin mungkin baru diubah — coba lagi
        case .idle:
            stateModel.state = .preparing
        }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            buildAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.buildAndStart()
                    } else {
                        self.stateModel.state = .denied
                    }
                }
            }
        default:
            stateModel.state = .denied
        }
        #endif
    }

    /// Lepas kamera (saat halaman kamera ditutup) — cegah session menumpuk.
    func stop() {
        timeoutWork?.cancel()
        timeoutWork = nil
        lock.lock()
        let session = _session
        _session = nil
        lock.unlock()
        session?.stopRunning()
        if stateModel.state == .running || stateModel.state == .preparing {
            stateModel.state = .idle
        }
    }

    // MARK: - Private

    private func buildAndStart() {
        // Timeout pengaman: spinner "menyiapkan kamera" tidak pernah selamanya.
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            if self.stateModel.state == .preparing {
                self.stateModel.state = .failed("Kamera lambat merespons — coba lagi")
            }
        }
        timeoutWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: work)

        // Discovery device + setup session di background (berat — jangan
        // blokir main thread).
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let session = AVCaptureSession()
            // .high (bukan .photo): preset .photo tidak kompatibel dengan
            // AVCaptureVideoDataOutput di banyak device → session gagal start.
            session.sessionPreset = .high
            session.beginConfiguration()

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                    ?? AVCaptureDevice.default(for: .video),
                let input = try? AVCaptureDeviceInput(device: device),
                session.canAddInput(input)
            else {
                session.commitConfiguration()
                DispatchQueue.main.async {
                    self.stateModel.state = .failed("Camera unavailable")
                }
                return
            }
            session.addInput(input)

            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(CameraOutputProxy.shared, queue: DispatchQueue(label: "camera.video.queue"))
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            // Buffer TIDAK di-mirror (raw sensor) — mirror diterapkan SATU KALI
            // via .oriented(.leftMirrored) saat capture, sehingga hasil foto
            // sama persis dengan preview (selfie mirror).
            // PENTING: nonaktifkan automaticallyAdjustsVideoMirroring dulu —
            // kalau YES (default kamera depan), set isVideoMirrored = CRASH.
            if let connection = output.connection(with: .video), connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = false
            }
            session.commitConfiguration()

            self.lock.lock()
            self._session = session
            self.lock.unlock()

            self.sessionQueue.async { [weak self] in
                session.startRunning()
                let running = session.isRunning
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.timeoutWork?.cancel()
                    self.stateModel.state = running ? .running : .failed("Camera failed to start")
                }
            }
        }
    }
}
