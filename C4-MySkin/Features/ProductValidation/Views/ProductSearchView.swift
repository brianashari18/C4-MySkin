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
                        viewModel.leaveSearch()
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

                    TextField("Cari produk...", text: $viewModel.searchText)
                        .font(Font.App.nunitoRounded(size: 16))
                        .foregroundStyle(Color.App.textDark)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    if viewModel.isSearching && !viewModel.searchResults.isEmpty {
                        ProgressView()
                            .scaleEffect(0.85)
                            .tint(Color.App.mediumBlue)
                    } else {
                        Button {
                            Task { await viewModel.searchProducts() }
                        } label: {
                            Image(systemName: "mic")
                                .foregroundStyle(Color.App.mediumBlue.opacity(0.6))
                                .font(.system(size: 16))
                        }
                        .accessibilityLabel("Cari produk")
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
                    VStack(alignment: .leading, spacing: 16) {
                        if let searchErrorMessage = viewModel.searchErrorMessage {
                            Text(searchErrorMessage)
                                .font(Font.App.nunitoRounded(size: 13, weight: .medium))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if viewModel.isSearching && viewModel.searchResults.isEmpty {
                            // Skeleton loader grid during initial search/load
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(0..<6, id: \.self) { _ in
                                    ProductSkeletonCardView()
                                }
                            }
                        } else if !viewModel.searchResults.isEmpty {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.searchResults) { product in
                                    Button {
                                        Task { await viewModel.selectProduct(product) }
                                    } label: {
                                        ProductGridItemView(
                                            productName: product.fullName,
                                            imageURL: product.imageURL,
                                            badgeText: product.brand ?? product.highlights.first,
                                            isLoading: viewModel.loadingProductID == product.id
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(viewModel.isLoadingResult)
                                }
                            }
                            .opacity(viewModel.isSearching ? 0.6 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.isSearching)
                        } else if !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !viewModel.isSearching {
                            Text("Produk tidak ditemukan.")
                                .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                                .foregroundStyle(Color.App.darkBlue)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        } else {
                            Text("Jelajahi produk di bawah atau ketik untuk mencari.")
                                .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                                .foregroundStyle(Color.App.darkBlue.opacity(0.75))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .task(id: viewModel.searchText) {
            let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !query.isEmpty else {
                await viewModel.searchProducts()
                return
            }

            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await viewModel.searchProducts()
        }
        .task {
            await viewModel.loadBrowseProducts()
        }
    }
}

// MARK: - Preview
#Preview {
    ProductSearchView(viewModel: ProductValidationViewModel())
}
