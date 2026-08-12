//
//  CameraGuideView.swift
//  C4-MySkin
//

import SwiftUI

struct CameraGuideView: View {
    @Binding var isFaceCentered: Bool
    @State private var captureRequest = 0
    @State private var cameraState = CameraSessionManager.shared.stateModel
    let onTakePhoto: (UIImage) -> Void
    let onBack: () -> Void

    /// Area guide muka (ternormalisasi, kiri-atas) — sama dengan yang dipakai
    /// deteksi wajah di CameraPreviewView.
    private let guideRect = CGRect(x: 0.12, y: 0.10, width: 0.76, height: 0.80)

    var body: some View {
        ZStack {
            // Soft ice blue background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    BackButton(action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Title
                Text("Posisikan wajahmu\npada frame")
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                    .padding(.top, 12)

                Spacer(minLength: 12)

                // Live Camera 1:1 full-width layar
                ZStack {
                    CameraPreviewView(
                        isFaceCentered: $isFaceCentered,
                        captureRequest: $captureRequest,
                        guideRect: guideRect,
                        onCapture: onTakePhoto
                    )

                    // Guide muka — diposisikan persis di guideRect (sama dengan deteksi)
                    GeometryReader { geometry in
                        FaceOutline()
                            .frame(
                                width: geometry.size.width * guideRect.width,
                                height: geometry.size.height * guideRect.height
                            )
                            .position(
                                x: geometry.size.width * guideRect.midX,
                                y: geometry.size.height * guideRect.midY
                            )
                    }
                    .opacity(0.35)
                    .allowsHitTesting(false)

                    // Status Overlay Indicator
                    VStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: isFaceCentered ? "checkmark.circle.fill" : "person.crop.artframe")
                                .font(.system(size: 14, weight: .bold))
                            Text(isFaceCentered ? "Wajah Pas di Tengah ✓" : "Posisikan Wajah di Tengah")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(isFaceCentered ? Color(red: 0.20, green: 0.65, blue: 0.32) : Color(red: 0.20, green: 0.38, blue: 0.56))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Capsule())
                        .padding(.bottom, 12)
                    }

                    // Overlay error / permission ditolak — di atas preview
                    Group {
                        if cameraState.state == .denied {
                            VStack(spacing: 10) {
                                Image(systemName: "video.slash.fill")
                                    .font(.system(size: 30))
                                Text("Akses kamera ditolak")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Izinkan kamera di Settings → C4-MySkin")
                                    .font(.system(size: 13))
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.white)
                            .padding(20)
                            .background(Color.black.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                        } else if case .failed(let message) = cameraState.state {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 28))
                                Text(message)
                                    .font(.system(size: 14, weight: .medium))
                                    .multilineTextAlignment(.center)
                                Button {
                                    CameraSessionManager.shared.prepare()
                                } label: {
                                    Text("Coba Lagi")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                            .foregroundStyle(.white)
                            .padding(20)
                            .background(Color.black.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)

                Text("Make sure you're in a proper light\ncondition for best results")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(red: 0.20, green: 0.38, blue: 0.56))
                    .padding(.top, 20)

                Spacer(minLength: 12)

                // Capture Button: aktif HANYA ketika wajah sudah di tengah
                VStack(spacing: 8) {
                    Button(action: {
                        guard isFaceCentered else { return }
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        captureRequest += 1
                    }) {
                        Text("Take Photo")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(width: 240, height: 50)
                            .background(
                                isFaceCentered
                                ? Color(red: 0.38, green: 0.61, blue: 0.93)
                                : Color(red: 0.70, green: 0.78, blue: 0.88)
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: isFaceCentered
                                ? Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3)
                                : Color.clear,
                                radius: 6, x: 0, y: 3
                            )
                    }
                    .disabled(!isFaceCentered)
                    .buttonStyle(.plain)
                    .accessibilityLabel("Take Photo")

                    Text("Posisikan wajah tepat di tengah frame")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.60, green: 0.68, blue: 0.78))
                        .frame(height: 18)
                        .opacity(isFaceCentered ? 0 : 1)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CameraGuideView(
        isFaceCentered: .constant(true),
        onTakePhoto: { _ in },
        onBack: {}
    )
}
