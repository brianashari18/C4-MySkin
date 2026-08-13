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

    // MARK: - Check & Toggle Picked Product
    func isPicked(name: String, brand: String) -> Bool {
        pickedProducts.contains(where: { $0.name == name && $0.brand == brand })
    }

    func togglePickedProduct(_ item: PickedProductItem) {
        if let index = pickedProducts.firstIndex(where: { $0.name == item.name && $0.brand == item.brand }) {
            pickedProducts.remove(at: index)
        } else {
            pickedProducts.insert(item, at: 0)
        }
        persistPickedProducts()
    }

    func removePickedProduct(name: String, brand: String) {
        pickedProducts.removeAll(where: { $0.name == name && $0.brand == brand })
        persistPickedProducts()
    }

    // MARK: - Save Picked Product
    func savePickedProduct(_ item: PickedProductItem) {
        // Prevent duplicate entries
        if isPicked(name: item.name, brand: item.brand) {
            return
        }
        pickedProducts.insert(item, at: 0)
        persistPickedProducts()
    }

    // MARK: - Save Comparison Item
    func isComparisonSaved(product1: PickedProductItem, product2: PickedProductItem) -> Bool {
        comparisonHistory.contains { item in
            (item.product1.name == product1.name && item.product1.brand == product1.brand &&
             item.product2.name == product2.name && item.product2.brand == product2.brand) ||
            (item.product1.name == product2.name && item.product1.brand == product2.brand &&
             item.product2.name == product1.name && item.product2.brand == product1.brand)
        }
    }

    func saveComparison(product1: PickedProductItem, product2: PickedProductItem) {
        // Prevent duplicate comparison entries
        if isComparisonSaved(product1: product1, product2: product2) {
            return
        }
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
