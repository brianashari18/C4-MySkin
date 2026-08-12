//
//  ProductHistoryStore.swift
//  C4-MySkin
//
//  Storage manager for Picked Product history and Comparison History.
//

import Foundation
import Combine

@MainActor
final class ProductHistoryStore: ObservableObject {

    static let shared = ProductHistoryStore()

    @Published private(set) var pickedProducts: [PickedProductItem] = []
    @Published private(set) var comparisonHistory: [ComparisonHistoryItem] = []

    private let pickedProductsKey = "MySkin_PickedProducts_v1"
    private let comparisonHistoryKey = "MySkin_ComparisonHistory_v1"

    private init() {
        loadData()
    }

    // MARK: - Save Picked Product
    func savePickedProduct(_ item: PickedProductItem) {
        // Prevent duplicate consecutive entries
        if let first = pickedProducts.first, first.name == item.name && first.brand == item.brand {
            return
        }
        pickedProducts.insert(item, at: 0)
        persistPickedProducts()
    }

    // MARK: - Save Comparison Item
    func saveComparison(product1: PickedProductItem, product2: PickedProductItem) {
        let item = ComparisonHistoryItem(product1: product1, product2: product2)
        comparisonHistory.insert(item, at: 0)
        persistComparisonHistory()

        // Also save both to picked history
        savePickedProduct(product1)
        savePickedProduct(product2)
    }

    // MARK: - Persistence
    private func loadData() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: pickedProductsKey),
           let decoded = try? JSONDecoder().decode([PickedProductItem].self, from: data) {
            pickedProducts = decoded
        } else {
            pickedProducts = []
        }

        if let data = defaults.data(forKey: comparisonHistoryKey),
           let decoded = try? JSONDecoder().decode([ComparisonHistoryItem].self, from: data) {
            comparisonHistory = decoded
        } else {
            comparisonHistory = []
        }
    }

    private func persistPickedProducts() {
        if let encoded = try? JSONEncoder().encode(pickedProducts) {
            UserDefaults.standard.set(encoded, forKey: pickedProductsKey)
        }
    }

    private func persistComparisonHistory() {
        if let encoded = try? JSONEncoder().encode(comparisonHistory) {
            UserDefaults.standard.set(encoded, forKey: comparisonHistoryKey)
        }
    }
}
