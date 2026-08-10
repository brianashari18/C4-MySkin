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
    let imageURL: String?
    let price: String
    let review: String
    let ingredients: [String]
    let suitedIngredients: [String]
    let isSuited: Bool

    init(
        productName: String,
        brand: String,
        imageURL: String?,
        price: String,
        review: String,
        ingredients: [String],
        suitedIngredients: [String],
        isSuited: Bool
    ) {
        self.productName = productName
        self.brand = brand
        self.imageURL = imageURL
        self.price = price
        self.review = review
        self.ingredients = ingredients
        self.suitedIngredients = suitedIngredients
        self.isSuited = isSuited
    }

    init(dossier: ProductDossierResponse) {
        let priceText: String
        if let value = dossier.price?.value {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            priceText = "Rp \(formatter.string(from: NSNumber(value: value)) ?? "\(value)")"
        } else {
            priceText = "Price unavailable"
        }

        let averageRating = dossier.reviews?.observed.averageRating
        let totalReviewCount = dossier.reviews?.observed.totalReviewCount
        let reviewText: String
        if let averageRating {
            if let totalReviewCount {
                reviewText = String(format: "%.1f / 5 (%d reviews)", averageRating, totalReviewCount)
            } else {
                reviewText = String(format: "%.1f / 5", averageRating)
            }
        } else {
            reviewText = "No reviews"
        }

        self.init(
            productName: dossier.product.name,
            brand: dossier.product.brand,
            imageURL: dossier.product.imageURL,
            price: priceText,
            review: reviewText,
            ingredients: dossier.product.ingredients.map(\.name),
            suitedIngredients: dossier.product.keyIngredients.map(\.name),
            isSuited: !dossier.product.keyIngredients.isEmpty
        )
    }

    /// Convenience array used by comparison cards for the Insight section
    var insightItems: [String] {
        ["Price: \(price)", "Brand: \(brand)", "Review: \(review)"]
    }

    // MARK: - Stubs
    static let stub = ValidationResult(
        productName: "Product Name",
        brand: "Brand Name",
        imageURL: nil,
        price: "Rp 120.000",
        review: "4.5 / 5",
        ingredients: ["Niacinamide", "Hyaluronic Acid", "Glycerin"],
        suitedIngredients: ["Niacinamide", "Centella Asiatica", "Ceramide"],
        isSuited: false
    )

    static let stub2 = ValidationResult(
        productName: "Product 2",
        brand: "Another Brand",
        imageURL: nil,
        price: "Rp 85.000",
        review: "4.2 / 5",
        ingredients: ["Salicylic Acid", "Zinc", "Aloe Vera"],
        suitedIngredients: ["Salicylic Acid", "Tea Tree Oil", "Niacinamide"],
        isSuited: false
    )
}
