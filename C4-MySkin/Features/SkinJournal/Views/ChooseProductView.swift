//
//  ChooseProductView.swift
//  C4-MySkin
//

import SwiftUI

struct ChooseProductView: View {
    @State private var viewModel = ChooseProductViewModel()
    @Binding var selectedProduct: SkincareProduct?
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BackButton {
                // handled by navigation
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your product")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color(.label))

                Text("Pick a product you want to track")
                    .font(.body)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)

            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(.secondaryLabel))

                TextField("Search", text: $viewModel.searchQuery)
                    .font(.body)

                Image(systemName: "mic.fill")
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.top, 24)

            Text("Your skincare routine")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 16)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredProducts) { product in
                        ProductCard(
                            product: product,
                            isSelected: viewModel.selectedProduct?.id == product.id
                        ) {
                            viewModel.selectProduct(product)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            PillButton(
                title: "Continue",
                isEnabled: viewModel.canContinue
            ) {
                if let product = viewModel.selectedProduct {
                    selectedProduct = product
                    onContinue()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    ChooseProductView(selectedProduct: .constant(nil), onContinue: {})
}
