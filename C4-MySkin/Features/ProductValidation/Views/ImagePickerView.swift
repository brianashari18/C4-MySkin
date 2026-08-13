//
//  ImagePickerView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 1 — Image Picker
/// Entry point for the product validation flow matching reference design.
struct ImagePickerView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductValidationViewModel

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
                // MARK: - Navigation Bar
                HStack {
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        PickedProductButton {
                            viewModel.openPickedHistory()
                        }
                        ComparisonHistoryButton {
                            viewModel.openComparisonHistory()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer(minLength: 16)

                // MARK: - Large Camera Placeholder Card
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    viewModel.openCamera()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(red: 0.84, green: 0.84, blue: 0.85))

                        Image(systemName: "camera")
                            .font(.system(size: 48, weight: .regular))
                            .foregroundStyle(Color(red: 0.15, green: 0.20, blue: 0.25))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 410)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)

                Spacer()

                // MARK: - "Atau" Label
                Text("Or")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.20, green: 0.38, blue: 0.58))
                
                Spacer()

                // MARK: - "Pencarian produk" Bottom CTA Button
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    viewModel.openOther()
                } label: {
                    Text("Search Products")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Action Buttons for Top Bar

struct PickedProductButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: "suit.heart")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .stroke(Color(red: 0.11, green: 0.27, blue: 0.42), lineWidth: 1.8)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Picked Product History")
    }
}

struct ComparisonHistoryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .stroke(Color(red: 0.11, green: 0.27, blue: 0.42), lineWidth: 1.8)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Comparison History")
    }
}

// MARK: - Preview
#Preview {
    ImagePickerView(viewModel: ProductValidationViewModel())
}
