//
//  ProductSearchView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 5 — Product Search / "Other…"
/// Search bar + 2-column grid of product thumbnails.
struct ProductSearchView: View {

    @ObservedObject var viewModel: ProductValidationViewModel

    // Stub product list
    private let stubProducts: [String] = Array(repeating: "Product name", count: 8)

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.App.backgroundGray
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                HStack {
                    Button {
                        viewModel.currentStep = .imagePicker
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

                // MARK: - Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.App.mediumBlue.opacity(0.6))
                        .font(.system(size: 16))

                    TextField("Search", text: $viewModel.searchText)
                        .font(Font.App.nunitoRounded(size: 16))
                        .foregroundStyle(Color.App.textDark)

                    Button {
                        // Voice search stub
                    } label: {
                        Image(systemName: "mic")
                            .foregroundStyle(Color.App.mediumBlue.opacity(0.6))
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .shadow(color: Color.App.mediumBlue.opacity(0.1), radius: 8, x: 0, y: 3)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // MARK: - Product Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(stubProducts.enumerated()), id: \.offset) { _, name in
                            ProductGridItemView(productName: name)
                                .onTapGesture {
                                    // Stub: select product and move to review
                                    viewModel.currentStep = .review
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProductSearchView(viewModel: ProductValidationViewModel())
}
