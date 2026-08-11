//
//  SkincareProduct.swift
//  C4-MySkin
//

import Foundation

/// A skincare product the user can choose and track in a journey.
struct SkincareProduct: Identifiable, Hashable, Codable {
    let id: String
    let brand: String
    let name: String
    let category: String
    let iconName: String?
}

extension SkincareProduct {
    /// Sample products shown in the "Choose your product" screen.
    static let samples: [SkincareProduct] = [
        SkincareProduct(id: "brand-a", brand: "brand A", name: "detail", category: "Moisturizer", iconName: nil),
        SkincareProduct(id: "brand-b", brand: "brand B", name: "detail", category: "Serum", iconName: nil),
        SkincareProduct(id: "brand-c", brand: "brand C", name: "detail", category: "Cleanser", iconName: nil),
        SkincareProduct(id: "brand-d", brand: "brand D", name: "detail", category: "Sunscreen", iconName: nil)
    ]
}
