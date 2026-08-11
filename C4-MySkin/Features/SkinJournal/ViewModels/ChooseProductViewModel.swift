//
//  ChooseProductViewModel.swift
//  C4-MySkin
//

import Observation
import Foundation

@MainActor
@Observable
final class ChooseProductViewModel {
    var searchQuery: String = ""
    var selectedProduct: SkincareProduct?
    var products: [SkincareProduct] = SkincareProduct.samples

    var filteredProducts: [SkincareProduct] {
        guard !searchQuery.isEmpty else { return products }
        return products.filter {
            $0.brand.localizedCaseInsensitiveContains(searchQuery) ||
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.category.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var canContinue: Bool {
        selectedProduct != nil
    }

    func selectProduct(_ product: SkincareProduct) {
        selectedProduct = product
    }
}
