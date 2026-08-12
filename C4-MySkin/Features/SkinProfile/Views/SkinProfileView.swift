//
//  SkinProfileView.swift
//  C4-MySkin
//

import SwiftUI

/// Fitur Baru: Skin Profile — Layar Ringkasan Profil Kulit Pengguna.
/// Menampilkan "Skin Profile Summary", gambar bentuk wajah dengan tag nama "POLO",
/// detail tipe kulit, sensitivitas, skin concern, dan tombol "Retake the test".
struct SkinProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let userName: String
    let skinType: String
    let sensitivity: String
    let skinConcern: String
    let onRetakeTest: () -> Void

    init(
        userName: String = "POLO",
        skinType: String = "Dry",
        sensitivity: String = "Moderate",
        skinConcern: String = "_",
        onRetakeTest: @escaping () -> Void = {}
    ) {
        self.userName = userName
        self.skinType = skinType
        self.sensitivity = sensitivity
        self.skinConcern = skinConcern
        self.onRetakeTest = onRetakeTest
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
                // Top Bar Header with Back Button
                HStack {
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // Title Header
                        Text("Skin Profile Summary")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .padding(.top, 16)

                        // Center Face Frame Card with "POLO" Tag Badge Overlay
                        ZStack(alignment: .bottomTrailing) {
                            // Face Card Frame
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .frame(width: 290, height: 290)
                                .overlay(
                                    FaceOutline()
                                        .padding(24)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(red: 0.38, green: 0.61, blue: 0.93), lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)

                            // Yellow Spiral Name Tag Badge with Mascot
                            ZStack(alignment: .topTrailing) {
                                SpiralNameTagBadge(name: userName)

                                // Mascot Graphic Overlay
                                MascotLottieView(width: 95)
                                    .accessibilityHidden(true)
                                    .offset(x: 18, y: -22)
                            }
                            .offset(x: 20, y: 28)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                        // Skin Profile Details List
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(spacing: 6) {
                                Text("Skin Type :")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

                                Text(skinType)
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            }

                            HStack(spacing: 6) {
                                Text("Sensitivity :")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

                                Text(sensitivity)
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            }

                            HStack(spacing: 6) {
                                Text("Skin Concern :")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

                                Text(skinConcern)
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        Spacer(minLength: 40)

                        // Bottom Action CTA Button: Retake the test
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            onRetakeTest()
                        }) {
                            Text("Retake the test")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                                .clipShape(Capsule())
                                .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Yellow Spiral Name Tag Badge Component
private struct SpiralNameTagBadge: View {
    let name: String

    var body: some View {
        HStack(spacing: 8) {
            // Spiral Binder Rings
            VStack(spacing: 6) {
                Circle().fill(Color(red: 0.55, green: 0.42, blue: 0.22)).frame(width: 7, height: 7)
                Circle().fill(Color(red: 0.55, green: 0.42, blue: 0.22)).frame(width: 7, height: 7)
                Circle().fill(Color(red: 0.55, green: 0.42, blue: 0.22)).frame(width: 7, height: 7)
            }
            .padding(.leading, 6)

            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                Rectangle()
                    .fill(Color(red: 0.78, green: 0.65, blue: 0.38).opacity(0.6))
                    .frame(height: 3)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 2, y: 3)
        )
        .rotationEffect(.degrees(12))
    }
}

#Preview {
    SkinProfileView()
}
