//
//  ValidationResultView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI
import PhotosUI

/// Screen 4 — Validation Result
/// Scrollable result screen with Insight card, Ingredient card, Suited-Ingredients card,
/// and a "+" menu in the nav bar to add another product image.
struct ValidationResultView: View {

    @ObservedObject var viewModel: ProductValidationViewModel

    @State private var showAddMenu: Bool = false

    private let result: ValidationResult

    init(viewModel: ProductValidationViewModel, result: ValidationResult) {
        self.viewModel = viewModel
        self.result = result
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.App.backgroundGray
                .ignoresSafeArea()

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

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAddMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(Font.App.nunitoRounded(size: 18, weight: .semibold))
                            .foregroundStyle(Color.App.textDark)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.85)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // MARK: - Scrollable Content
                ScrollView {
                    VStack(spacing: 20) {

                        // Product image placeholder
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.App.lightBlue.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.App.lightBlue.opacity(0.5), lineWidth: 1.5)
                                )
                                .frame(height: 160)

                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .frame(height: 160)
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundStyle(Color.App.mediumBlue.opacity(0.5))
                            }
                        }

                        // Insight card
                        ValidationCardView(
                            title: "Insight",
                            items: [
                                "Price: \(result.price)",
                                "Brand: \(result.brand)",
                                "Review: \(result.review)"
                            ]
                        )

                        // Ingredient card
                        ValidationCardView(
                            title: "Ingredient",
                            items: result.ingredients
                        )

                        // Suited Ingredients card — blurred if no profile
                        suitedCard

                        Spacer().frame(height: 90) // room for Finish button
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                // MARK: - Finish Button (pinned)
                Button {
                    viewModel.finish()
                } label: {
                    Text("Finish")
                        .font(Font.App.nunitoRounded(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.App.mediumBlue)
                                .shadow(color: Color.App.mediumBlue.opacity(0.45), radius: 12, x: 0, y: 5)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(Color.App.backgroundGray)
            }

            // MARK: - "+" Popup Menu
            if showAddMenu {
                addPopupMenu
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                    .transition(.scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showAddMenu)
        .contentShape(Rectangle())
        .onTapGesture {
            if showAddMenu { withAnimation { showAddMenu = false } }
        }
    }

    // MARK: - Suited-Ingredients Card
    @ViewBuilder
    private var suitedCard: some View {
        ZStack {
            // Yellow background card
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.App.sunnyYellow.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.App.sunnyYellow.opacity(0.6), lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("Ingredients that suited for you")
                    .font(Font.App.nunitoRounded(size: 13, weight: .semibold))
                    .foregroundStyle(Color.App.darkBlue)
                    .padding(.top, 12)

                ForEach(result.suitedIngredients, id: \.self) { item in
                    HStack(spacing: 6) {
                        Text("–")
                            .foregroundStyle(Color.App.darkBlue)
                        Text(item)
                            .foregroundStyle(Color.App.darkBlue)
                    }
                    .font(Font.App.nunitoRounded(size: 15))
                }

                Spacer().frame(height: 8)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Blur overlay if user hasn't completed quiz
            if !result.isSuited {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Text("Complete personalise quiz")
                            .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(Color.App.mediumBlue)
                            )
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Add (+) Popup Menu
    @ViewBuilder
    private var addPopupMenu: some View {
        VStack(spacing: 0) {
            Button {
                showAddMenu = false
                viewModel.openCamera()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera")
                        .font(.system(size: 15))
                    Text("Camera")
                        .font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            Divider()

            PhotosPicker(
                selection: $viewModel.photoPickerItem,
                matching: .images
            ) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                    Text("Other...")
                        .font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .onChange(of: viewModel.photoPickerItem) { _, _ in
                showAddMenu = false
            }
        }
        .frame(width: 190)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.97))
                .shadow(color: Color.App.darkBlue.opacity(0.15), radius: 12, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Preview
#Preview {
    let vm = ProductValidationViewModel()
    ValidationResultView(viewModel: vm, result: ValidationResult.stub)
}
