//
//  PhotoReviewView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 3 — Photo Review
/// Shows the captured/picked image with "Validate" and "Retake" buttons.
struct PhotoReviewView: View {

    @ObservedObject var viewModel: ProductValidationViewModel

    var body: some View {
        ZStack {
            // Background
            Color.App.backgroundGray
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // MARK: - Navigation Bar
                    HStack {
                        Button {
                            viewModel.retake()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(Font.App.nunitoRounded(size: 18, weight: .semibold))
                                .foregroundStyle(Color.App.textDark)
                                .padding(10)
                                .background(Circle().fill(Color.white.opacity(0.85)))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // MARK: - Product Image Preview
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.App.lightBlue.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.App.lightBlue.opacity(0.5), lineWidth: 1.5)
                            )

                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        } else {
                            // Placeholder product shape matching the mockup
                            VStack(spacing: 0) {
                                // Product cap
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.App.mediumBlue.opacity(0.4))
                                    .frame(width: 130, height: 55)

                                // Product body
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .frame(width: 180, height: 140)
                                    .offset(y: -6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.60)
                    .padding(.horizontal, 20)

                    Spacer()

                    // MARK: - Action Buttons
                    HStack(spacing: 16) {
                        // Validasi — filled primary
                        Button {
                            viewModel.validate()
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Validasi")
                                        .font(Font.App.nunitoRounded(size: 17, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                Capsule()
                                    .fill(Color.App.mediumBlue)
                                    .shadow(color: Color.App.mediumBlue.opacity(0.45), radius: 10, x: 0, y: 5)
                            )
                        }
                        .disabled(viewModel.isLoading)

                        // Ulangi — outlined secondary
                        Button {
                            viewModel.retake()
                        } label: {
                            Text("Ulangi")
                                .font(Font.App.nunitoRounded(size: 17, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    Capsule()
                                        .fill(Color.App.mediumBlue.opacity(0.1))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.App.mediumBlue, lineWidth: 1.5)
                                )
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
            }

            // MARK: - Product Not Found Modal
            if viewModel.showProductNotFoundModal {
                ProductNotFoundModalView {
                    viewModel.scanAnotherProduct()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.showProductNotFoundModal)
    }
}

// MARK: - Preview
#Preview {
    PhotoReviewView(viewModel: ProductValidationViewModel())
}
