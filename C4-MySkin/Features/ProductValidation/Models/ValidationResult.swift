//
//  ValidationResult.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import Foundation

// MARK: - Validation Step Enum
enum ValidationStep {
    case imagePicker
    case camera
    case review
    case result
    case search
}

// MARK: - Validation Result Model
struct ValidationResult {
    let productName: String
    let brand: String
    let price: String
    let review: String
    let ingredients: [String]
    let suitedIngredients: [String]
    let isSuited: Bool

    /// Convenience array used by comparison cards for the Insight section
    var insightItems: [String] {
        ["Price: \(price)", "Brand: \(brand)", "Review: \(review)"]
    }

    // MARK: - Stubs
    static let stub = ValidationResult(
        productName: "Product Name",
        brand: "Brand Name",
        price: "Rp 120.000",
        review: "4.5 / 5",
        ingredients: ["Niacinamide", "Hyaluronic Acid", "Glycerin"],
        suitedIngredients: ["Niacinamide", "Centella Asiatica", "Ceramide"],
        isSuited: false
    )

    static let stub2 = ValidationResult(
        productName: "Product 2",
        brand: "Another Brand",
        price: "Rp 85.000",
        review: "4.2 / 5",
        ingredients: ["Salicylic Acid", "Zinc", "Aloe Vera"],
        suitedIngredients: ["Salicylic Acid", "Tea Tree Oil", "Niacinamide"],
        isSuited: false
    )
}
