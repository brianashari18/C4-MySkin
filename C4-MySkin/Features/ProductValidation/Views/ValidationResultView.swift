//
//  ValidationResultView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 4 — Validation Result
/// Shows single product result OR a side-by-side comparison when
/// a second product has been scanned via the "+" button.
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
            Color.App.backgroundGray.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                HStack {
                    Button { viewModel.reset() } label: {
                        Image(systemName: "chevron.left")
                            .font(Font.App.nunitoRounded(size: 18, weight: .semibold))
                            .foregroundStyle(Color.App.textDark)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.85)))
                    }

                    Spacer()

                    // Show "+" only when not yet in comparison mode
                    if !viewModel.isComparisonMode {
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // MARK: - Scrollable Content
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isComparisonMode, let secondResult = viewModel.secondValidationResult {
                            // ── Comparison layout ──
                            comparisonProductCards
                            comparisonDataCard(
                                title: "Insight",
                                items1: result.insightItems,
                                items2: secondResult.insightItems
                            )
                            comparisonDataCard(
                                title: "Ingredient",
                                items1: result.ingredients,
                                items2: secondResult.ingredients
                            )
                            suitedCard(result: result)
                        } else {
                            // ── Single product layout ──
                            singleProductImage
                            ValidationCardView(title: "Insight", items: result.insightItems)
                            ValidationCardView(title: "Ingredient", items: result.ingredients)
                            suitedCard(result: result)
                        }

                        Spacer().frame(height: 90) // room for Finish button
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                // MARK: - Finish Button (pinned)
                Button { viewModel.finish() } label: {
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
        .animation(.easeInOut(duration: 0.3), value: viewModel.isComparisonMode)
        .contentShape(Rectangle())
        .onTapGesture {
            if showAddMenu { withAnimation { showAddMenu = false } }
        }
    }

    // MARK: - Single Product Image

    @ViewBuilder
    private var singleProductImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.App.lightBlue.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.App.lightBlue.opacity(0.5), lineWidth: 1.5)
                )
                .frame(height: 160)

            if let image = viewModel.firstSelectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else if let imageURL = result.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                placeholderImage
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .clipped()
    }

    // MARK: - Comparison: Two Product Cards

    @ViewBuilder
    private var comparisonProductCards: some View {
        HStack(spacing: 12) {
            productCard(image: viewModel.firstSelectedImage, name: result.productName)
            if let second = viewModel.secondValidationResult {
                productCard(image: viewModel.secondSelectedImage, name: second.productName)
            }
        }
    }

    @ViewBuilder
    private func productCard(image: UIImage?, name: String) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Image area
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.App.lightBlue.opacity(0.15))

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else if let imageURL = comparisonImageURL(for: name), let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure, .empty:
                                comparisonPlaceholder
                            @unknown default:
                                comparisonPlaceholder
                            }
                        }
                    } else {
                        comparisonPlaceholder
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.App.sunnyYellow, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Heart icon
                Image(systemName: "heart")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.App.mediumBlue.opacity(0.7))
                    .padding(6)
            }

            Text(name)
                .font(Font.App.nunitoRounded(size: 12, weight: .semibold))
                .foregroundStyle(Color.App.darkBlue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .font(.system(size: 40, weight: .light))
            .foregroundStyle(Color.App.mediumBlue.opacity(0.5))
    }

    private var comparisonPlaceholder: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.App.mediumBlue.opacity(0.3))
                .frame(width: 50, height: 20)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.9))
                .frame(width: 70, height: 52)
                .offset(y: -3)
        }
    }

    private func comparisonImageURL(for name: String) -> String? {
        if result.productName == name {
            return result.imageURL
        }

        if viewModel.secondValidationResult?.productName == name {
            return viewModel.secondValidationResult?.imageURL
        }

        return nil
    }

    // MARK: - Comparison Data Card (two columns)

    @ViewBuilder
    private func comparisonDataCard(title: String, items1: [String], items2: [String]) -> some View {
        ZStack(alignment: .top) {
            // White card body
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.App.sunnyYellow.opacity(0.55), lineWidth: 1.5)
                )
                .shadow(color: Color.App.mediumBlue.opacity(0.07), radius: 8, x: 0, y: 3)

            HStack(alignment: .top, spacing: 0) {
                // Left column — product 1
                VStack(alignment: .leading, spacing: 8) {
                    Spacer().frame(height: 20)
                    ForEach(items1, id: \.self) { item in
                        comparisonRow(item: item)
                    }
                    Spacer().frame(height: 4)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Vertical divider
                Rectangle()
                    .fill(Color.App.sunnyYellow.opacity(0.6))
                    .frame(width: 1.5)
                    .padding(.vertical, 30)

                // Right column — product 2
                VStack(alignment: .leading, spacing: 8) {
                    Spacer().frame(height: 20)
                    ForEach(items2, id: \.self) { item in
                        comparisonRow(item: item)
                    }
                    Spacer().frame(height: 4)
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 12)

            // Yellow pill header
            Text(title)
                .font(Font.App.nunitoRounded(size: 15, weight: .bold))
                .foregroundStyle(Color.App.darkBlue)
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.App.sunnyYellow))
                .offset(y: -18)
        }
        .padding(.top, 18)
    }

    @ViewBuilder
    private func comparisonRow(item: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.App.lightBlue.opacity(0.5))
                .frame(width: 12, height: 12)
            Text(item)
                .font(Font.App.nunitoRounded(size: 12, weight: .regular))
                .foregroundStyle(Color.App.darkBlue)
                .lineLimit(2)
        }
    }

    // MARK: - Suited-Ingredients Card

    @ViewBuilder
    private func suitedCard(result: ValidationResult) -> some View {
        ZStack {
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
                        Text("–").foregroundStyle(Color.App.darkBlue)
                        Text(item).foregroundStyle(Color.App.darkBlue)
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
                            .background(Capsule().fill(Color.App.mediumBlue))
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - "+" Add Popup Menu

    @ViewBuilder
    private var addPopupMenu: some View {
        VStack(spacing: 0) {
            Button {
                showAddMenu = false
                viewModel.openCamera()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera").font(.system(size: 15))
                    Text("Camera").font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            Divider()

            Button {
                showAddMenu = false
                viewModel.openOther()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").font(.system(size: 15))
                    Text("Other...").font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
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
#Preview("Single") {
    let vm = ProductValidationViewModel()
    ValidationResultView(viewModel: vm, result: ValidationResult.stub)
}

#Preview("Comparison") {
    let vm = ProductValidationViewModel()
    vm.secondValidationResult = ValidationResult.stub2
    return ValidationResultView(viewModel: vm, result: ValidationResult.stub)
}
