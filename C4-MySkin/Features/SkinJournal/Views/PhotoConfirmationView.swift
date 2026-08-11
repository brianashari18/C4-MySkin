//
//  PhotoConfirmationView.swift
//  C4-MySkin
//

import SwiftUI

struct PhotoConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    let capturedImage: UIImage?
    let onRetake: () -> Void
    let onUsePhoto: () -> Void

    init(
        capturedImage: UIImage? = nil,
        onRetake: @escaping () -> Void,
        onUsePhoto: @escaping () -> Void
    ) {
        self.capturedImage = capturedImage
        self.onRetake = onRetake
        self.onUsePhoto = onUsePhoto
    }

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
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Title
                Text("Nicely captured!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                    .padding(.top, 16)

                Spacer(minLength: 16)

                // 1:1 Square Captured Photo Result Frame (full-width layar)
                ZStack {
                    if let capturedImage = capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                    } else {
                        Color.white
                            .overlay(
                                FaceOutline()
                                    .padding(24)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 0))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(red: 0.38, green: 0.61, blue: 0.93), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 0)

                Spacer(minLength: 16)

                // Action Buttons
                HStack(spacing: 16) {
                    // Retake Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onRetake()
                    }) {
                        HStack(spacing: 6) {
                            Text("Retake")
                                .font(.system(size: 16, weight: .bold))
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Retake photo")

                    // Use This Photo Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onUsePhoto()
                    }) {
                        Text("Use This Photo")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                            .clipShape(Capsule())
                            .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Use this photo")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PhotoConfirmationView(capturedImage: nil, onRetake: {}, onUsePhoto: {})
}


