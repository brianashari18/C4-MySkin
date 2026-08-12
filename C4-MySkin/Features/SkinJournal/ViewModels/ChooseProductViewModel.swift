//
//  ChooseProductViewModel.swift
//  C4-MySkin
//

import Observation
import Foundation

@MainActor
@Observable
final class ChooseProductViewModel {
    private let apiClient = SkincareAPIClient()
    private let browseQueries = ["cleanser", "serum", "sunscreen", "toner", "moisturizer", "kahf", "wardah"]

    var searchQuery: String = ""
    var products: [SkincareProduct] = []
    var selectedProduct: SkincareProduct?
    var isLoading: Bool = false
    var errorMessage: String?
    private var hasLoadedBrowse: Bool = false

    var canContinue: Bool {
        selectedProduct != nil
    }

    func selectProduct(_ product: SkincareProduct) {
        selectedProduct = product
    }

    /// Loads a browsable product list on first appear (mirrors ProductValidation browse).
    func loadBrowseProducts(forceReload: Bool = false) async {
        guard forceReload || !hasLoadedBrowse else { return }

        isLoading = true
        errorMessage = nil

        do {
            var seenIDs = Set<String>()
            var results: [SkincareProduct] = []

            for query in browseQueries {
                let response = try await apiClient.searchProducts(query: query)
                for item in response.results {
                    let product = Self.makeProduct(from: item)
                    guard seenIDs.insert(product.id).inserted else { continue }
                    results.append(product)
                }
            }

            products = results
            hasLoadedBrowse = true
        } catch {
            products = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Searches the API for the given query and replaces the visible list.
    func searchProducts(for query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            await loadBrowseProducts()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.searchProducts(query: trimmed)
            var seenIDs = Set<String>()
            products = response.results.compactMap { item in
                let product = Self.makeProduct(from: item)
                return seenIDs.insert(product.id).inserted ? product : nil
            }
        } catch {
            products = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Retries based on the current query state.
    func retry() async {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            await loadBrowseProducts(forceReload: true)
        } else {
            await searchProducts(for: trimmed)
        }
    }

    private static func makeProduct(from item: ProductSearchItem) -> SkincareProduct {
        SkincareProduct(
            id: item.url,
            brand: item.brand ?? "",
            name: item.name,
            category: "",
            iconName: nil,
            imageURL: item.imageURL,
            slug: item.slug,
            highlights: item.highlights
        )
    }
}
