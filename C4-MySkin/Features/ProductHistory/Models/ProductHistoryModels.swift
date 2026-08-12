//
//  ProductHistoryModels.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import Foundation

// MARK: - History Tab Segment
enum HistoryTab: String, CaseIterable, Identifiable {
    case picked = "Picked Product"
    case compare = "Compare History"

    var id: String { rawValue }
}

// MARK: - Picked Product Item Model
struct PickedProductItem: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let brand: String
    let imageURL: String?
    let pickedAt: Date

    init(id: UUID = UUID(), name: String, brand: String, imageURL: String? = nil, pickedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.brand = brand
        self.imageURL = imageURL
        self.pickedAt = pickedAt
    }
}

// MARK: - Comparison History Item Model
struct ComparisonHistoryItem: Identifiable, Hashable, Codable {
    let id: UUID
    let product1: PickedProductItem
    let product2: PickedProductItem
    let comparedAt: Date

    init(id: UUID = UUID(), product1: PickedProductItem, product2: PickedProductItem, comparedAt: Date = Date()) {
        self.id = id
        self.product1 = product1
        self.product2 = product2
        self.comparedAt = comparedAt
    }
}

// MARK: - Sample Stubs
extension PickedProductItem {
    static let sampleList: [PickedProductItem] = [
        PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
        PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
        PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
        PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
        PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
        PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf")
    ]
}

extension ComparisonHistoryItem {
    static let sampleList: [ComparisonHistoryItem] = [
        ComparisonHistoryItem(
            product1: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
            product2: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf")
        ),
        ComparisonHistoryItem(
            product1: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
            product2: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf")
        ),
        ComparisonHistoryItem(
            product1: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
            product2: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf")
        ),
        ComparisonHistoryItem(
            product1: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf"),
            product2: PickedProductItem(name: "Oil and Acne Care Face Wash", brand: "Kahf")
        )
    ]
}
