//
//  ChooseProductView.swift
//  C4-MySkin
//

import SwiftUI

struct ChooseProductView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ChooseProductViewModel()
    @Binding var selectedProduct: SkincareProduct?
    let onContinue: () -> Void

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
                // Top bar with Back button
                HStack {
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)

                // Header Titles
                VStack(alignment: .leading, spacing: 6) {
                    Text("Choose your product")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                    Text("Pick a product you want to track")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 0.35, green: 0.58, blue: 0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                    TextField("", text: $viewModel.searchQuery, prompt: Text("Search").foregroundColor(Color(red: 0.35, green: 0.58, blue: 0.85)))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                        .autocorrectionDisabled(true)

                    if viewModel.isLoading && !viewModel.products.isEmpty {
                        ProgressView()
                            .tint(Color(red: 0.35, green: 0.58, blue: 0.85))
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 1.5)
                )
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Section Header
                Text("Your skincare routine")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                // Product List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        if let errorMessage = viewModel.errorMessage {
                            errorBanner(message: errorMessage)
                        }

                        if viewModel.isLoading && viewModel.products.isEmpty {
                            ForEach(0..<5, id: \.self) { _ in
                                ProductCardSkeleton()
                            }
                        } else if !viewModel.products.isEmpty {
                            ForEach(viewModel.products) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: viewModel.selectedProduct?.id == product.id
                                ) {
                                    viewModel.selectProduct(product)
                                }
                            }
                        } else if viewModel.errorMessage == nil {
                            Text("No products yet. Try searching above.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(red: 0.45, green: 0.55, blue: 0.65))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }

                Spacer(minLength: 16)

                // Bottom CTA Button
                PillButton(
                    title: "Continue",
                    isEnabled: viewModel.canContinue
                ) {
                    if let product = viewModel.selectedProduct {
                        selectedProduct = product
                        onContinue()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadBrowseProducts()
        }
        .task(id: viewModel.searchQuery) {
            let query = viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else {
                await viewModel.loadBrowseProducts()
                return
            }
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await viewModel.searchProducts(for: query)
        }
    }

    private func errorBanner(message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.30))
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(red: 0.55, green: 0.20, blue: 0.18))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                Task { await viewModel.retry() }
            } label: {
                Text("Coba Lagi")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.29, green: 0.56, blue: 0.89))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.99, green: 0.94, blue: 0.93))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.85, green: 0.55, blue: 0.50), lineWidth: 1)
        )
    }
}

#Preview {
    ChooseProductView(selectedProduct: .constant(nil), onContinue: {})
}
