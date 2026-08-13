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
    private let guideRect = CGRect(x: 0.15, y: 0.05, width: 0.68, height: 0.85)

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
                Text("Position your face\nin the frame")
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

                    // Visual area alignment dari repo referensi. Mekanik deteksi
                    // tetap memakai implementasi lama di CameraPreviewView.
                    FaceAlignmentGuideOverlay(
                        guideRect: guideRect,
                        isAligned: isFaceCentered
                    )
                    .allowsHitTesting(false)

                    // Status Overlay Indicator
                    VStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: isFaceCentered ? "checkmark.circle.fill" : "person.crop.artframe")
                                .font(.system(size: 14, weight: .bold))
                            Text(isFaceCentered ? "Face Centered ✓" : "Center Your Face")
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
                                Text("Camera access denied")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Allow camera access in Settings → C4-MySkin")
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
                                    Text("Try Again")
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

                    Text("Position your face right in the center of the frame")
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

/// Overlay visual untuk membantu user menempatkan wajah secara konsisten.
/// Hanya mengubah tampilan; tidak ikut menentukan hasil deteksi wajah.
private struct FaceAlignmentGuideOverlay: View {
    let guideRect: CGRect
    let isAligned: Bool

    private var outlineColor: Color {
        isAligned
            ? Color(red: 0.25, green: 0.82, blue: 0.43)
            : Color(red: 1.00, green: 0.80, blue: 0.05)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let targetRect = CGRect(
                x: size.width * guideRect.minX,
                y: size.height * guideRect.minY,
                width: size.width * guideRect.width,
                height: size.height * guideRect.height
            )

            ZStack {
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: size))
                    path.addPath(facePath(in: targetRect))
                }
                .fill(Color.black.opacity(0.34), style: FillStyle(eoFill: true))

                Path { path in
                    path.move(to: CGPoint(x: targetRect.midX, y: 0))
                    path.addLine(to: CGPoint(x: targetRect.midX, y: size.height))
                    path.move(to: CGPoint(x: 0, y: targetRect.midY))
                    path.addLine(to: CGPoint(x: size.width, y: targetRect.midY))
                }
                .stroke(
                    Color.white.opacity(0.72),
                    style: StrokeStyle(lineWidth: 1.2, dash: [8, 8])
                )

                facePath(in: targetRect)
                    .stroke(outlineColor, lineWidth: 3.5)
                    .shadow(color: outlineColor.opacity(0.25), radius: 3)
                    .animation(.easeInOut(duration: 0.2), value: isAligned)
            }
        }
        .accessibilityHidden(true)
    }

    private func facePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        return Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + height * 0.38),
                control1: CGPoint(x: rect.midX + width * 0.28, y: rect.minY),
                control2: CGPoint(x: rect.maxX, y: rect.minY + height * 0.14)
            )
            path.addCurve(
                to: CGPoint(x: rect.midX, y: rect.maxY),
                control1: CGPoint(x: rect.maxX, y: rect.minY + height * 0.78),
                control2: CGPoint(x: rect.midX + width * 0.27, y: rect.maxY)
            )
            path.addCurve(
                to: CGPoint(x: rect.minX, y: rect.minY + height * 0.38),
                control1: CGPoint(x: rect.midX - width * 0.27, y: rect.maxY),
                control2: CGPoint(x: rect.minX, y: rect.minY + height * 0.78)
            )
            path.addCurve(
                to: CGPoint(x: rect.midX, y: rect.minY),
                control1: CGPoint(x: rect.minX, y: rect.minY + height * 0.14),
                control2: CGPoint(x: rect.midX - width * 0.28, y: rect.minY)
            )
            path.closeSubpath()
        }
    }
}

#Preview {
    CameraGuideView(
        isFaceCentered: .constant(true),
        onTakePhoto: { _ in },
        onBack: {}
    )
}
