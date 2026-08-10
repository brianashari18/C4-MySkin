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

    // MARK: - Preview / Stub
    static let stub = ValidationResult(
        productName: "Product Name",
        brand: "Brand Name",
        price: "Rp 120.000",
        review: "4.5 / 5",
        ingredients: ["Niacinamide", "Hyaluronic Acid", "Glycerin"],
        suitedIngredients: ["Niacinamide", "Centella Asiatica", "Ceramide"],
        isSuited: false
    )
}
