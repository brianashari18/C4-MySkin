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

// MARK: - Rich Structured Item Models for Wireframe Sections

struct KeyIngredientItem: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let description: String
}

struct BenefitItem: Identifiable, Hashable {
    var id: String { title + description }
    let title: String
    let description: String
}

struct ConcernItem: Identifiable, Hashable {
    var id: String { title + description }
    let title: String
    let description: String
}

struct IngredientCheckItem: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let isPresent: Bool
}

// MARK: - Validation Result Model
struct ValidationResult {
    let productName: String
    let brand: String
    let imageURL: String?
    let price: String
    let review: String
    
    // Insight Section
    let brandReputation: String
    let reviewSummary: String
    let priceSummary: String
    let ingredientsMatchSummary: String

    // Sections
    let ingredientChecks: [IngredientCheckItem]
    let keyIngredientItems: [KeyIngredientItem]
    let bestForSummary: String
    let benefitItems: [BenefitItem]
    let concernItems: [ConcernItem]
    let isSuited: Bool

    // Legacy Fallbacks
    let ingredients: [String]
    let keyIngredients: [String]
    let benefits: [String]
    let sideEffects: [String]

    init(
        productName: String,
        brand: String,
        imageURL: String?,
        price: String,
        review: String,
        brandReputation: String = "",
        reviewSummary: String = "",
        priceSummary: String = "",
        ingredientsMatchSummary: String = "",
        ingredientChecks: [IngredientCheckItem] = [],
        keyIngredientItems: [KeyIngredientItem] = [],
        bestForSummary: String = "",
        benefitItems: [BenefitItem] = [],
        concernItems: [ConcernItem] = [],
        ingredients: [String] = [],
        keyIngredients: [String] = [],
        benefits: [String] = [],
        sideEffects: [String] = [],
        isSuited: Bool = false
    ) {
        self.productName = productName
        self.brand = brand
        self.imageURL = imageURL
        self.price = price
        self.review = review
        self.brandReputation = brandReputation
        self.reviewSummary = reviewSummary
        self.priceSummary = priceSummary
        self.ingredientsMatchSummary = ingredientsMatchSummary
        self.ingredientChecks = ingredientChecks
        self.keyIngredientItems = keyIngredientItems
        self.bestForSummary = bestForSummary
        self.benefitItems = benefitItems
        self.concernItems = concernItems
        self.ingredients = ingredients.isEmpty ? ingredientChecks.map(\.name) : ingredients
        self.keyIngredients = keyIngredients.isEmpty ? keyIngredientItems.map(\.name) : keyIngredients
        self.benefits = benefits.isEmpty ? benefitItems.map(\.title) : benefits
        self.sideEffects = sideEffects.isEmpty ? concernItems.map(\.title) : sideEffects
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

        let keyIngs = dossier.product.keyIngredients.map {
            KeyIngredientItem(
                name: $0.name,
                description: $0.benefits.joined(separator: ", ").capitalized.ifEmpty("Supports skin health.")
            )
        }

        let ings = dossier.product.ingredients.map {
            IngredientCheckItem(name: $0.name, isPresent: true)
        }

        let brandRepText = dossier.brandReputation?.narrative ?? "\(dossier.product.brand) is an established skincare brand known for targeted formulations."
        let reviewSumText = averageRating != nil ? "Rated \(reviewText). User reviews highlight effective performance and positive skin feel." : "No user reviews yet for this formulation."
        let priceSumText = dossier.price?.value != nil ? "Priced at \(priceText) for regular daily routine use." : "Standard price point in category."

        let keyIngNames = keyIngs.prefix(3).map(\.name).joined(separator: ", ")
        let ingMatchText = keyIngs.isEmpty ? "Formulated with balanced cosmetic ingredients." : "Features key actives: \(keyIngNames)."

        let bItems: [BenefitItem]
        if !dossier.product.keyIngredients.isEmpty {
            bItems = Array(dossier.product.keyIngredients.prefix(3)).map {
                BenefitItem(
                    title: $0.name,
                    description: $0.benefits.joined(separator: ", ").capitalized.ifEmpty("Supports skin health and function.")
                )
            }
        } else {
            bItems = Array((dossier.product.whatItDoes.isEmpty ? dossier.product.highlights : dossier.product.whatItDoes).prefix(3)).map {
                BenefitItem(title: $0.capitalized, description: "Supports healthy skin texture and hydration.")
            }
        }

        let cItems: [ConcernItem]
        if let concerns = dossier.concerns, !concerns.isEmpty {
            // Prioritize MODERATE / HIGH severity concerns or non-zero incidence
            let relevantConcerns = concerns.filter { c in
                let sev = (c.severity ?? "").uppercased()
                let inc = c.incidence ?? ""
                return sev == "MODERATE" || sev == "HIGH" || (inc != "0.0%" && inc != "0%")
            }
            let listToUse = relevantConcerns.isEmpty ? concerns : relevantConcerns

            cItems = Array(listToUse.prefix(3)).map { c in
                let ingList = c.ingredients?.prefix(3).joined(separator: ", ") ?? ""
                let detail = ingList.isEmpty ? "Severity: \(c.severity?.capitalized ?? "Mild") (\(c.incidence ?? "N/A"))." : "Severity: \(c.severity?.capitalized ?? "Mild") (\(c.incidence ?? "N/A")). Key triggers: \(ingList)."
                return ConcernItem(title: c.name, description: detail)
            }
        } else {
            cItems = Array(dossier.ingredientProfiles.flatMap(\.sideEffects).prefix(3)).map {
                ConcernItem(title: $0.capitalized, description: "Potential mild reaction for sensitive skin types.")
            }
        }

        let bestForText = dossier.product.description ?? "Daily skincare routine suited for targeted skin care."

        self.init(
            productName: dossier.product.name,
            brand: dossier.product.brand,
            imageURL: dossier.product.imageURL,
            price: priceText,
            review: reviewText,
            brandReputation: brandRepText,
            reviewSummary: reviewSumText,
            priceSummary: priceSumText,
            ingredientsMatchSummary: ingMatchText,
            ingredientChecks: ings,
            keyIngredientItems: keyIngs,
            bestForSummary: bestForText,
            benefitItems: bItems,
            concernItems: cItems,
            isSuited: !keyIngs.isEmpty
        )
    }

    /// Convenience array used by comparison cards for the Insight section
    var insightItems: [String] {
        ["Price: \(price)", "Brand: \(brand)", "Review: \(review)"]
    }

    // MARK: - Stubs matching wireframe reference
    static let stub = ValidationResult(
        productName: "Acno Fight Anti Pimple Face Wash",
        brand: "Garnier",
        imageURL: nil,
        price: "Price",
        review: "Review",
        brandReputation: "Established skincare brand with strong recognition and a long history among acne-care users.",
        reviewSummary: "Users often report reduced oiliness and fewer breakouts, though some mention a drying feeling after use.",
        priceSummary: "Affordable option for users looking for an acne-focused cleanser.",
        ingredientsMatchSummary: "Contains acne-targeting ingredients that help remove excess oil and support blemish control.",
        ingredientChecks: [
            IngredientCheckItem(name: "Salicylic Acid", isPresent: true),
            IngredientCheckItem(name: "Glycerin", isPresent: true),
            IngredientCheckItem(name: "Niacinamide", isPresent: false),
            IngredientCheckItem(name: "Tea Tree Extract", isPresent: false),
            IngredientCheckItem(name: "Mineral Clay", isPresent: true),
            IngredientCheckItem(name: "Fragrance", isPresent: true),
            IngredientCheckItem(name: "Alcohol", isPresent: false),
            IngredientCheckItem(name: "Cocamidopropyl Betaine", isPresent: true)
        ],
        keyIngredientItems: [
            KeyIngredientItem(name: "Salicylic Acid (BHA)", description: "Targets clogged pores and excess oil."),
            KeyIngredientItem(name: "Mineral Clay", description: "Helps absorb sebum."),
            KeyIngredientItem(name: "Glycerin", description: "Supports skin hydration.")
        ],
        bestForSummary: "Acne concerns needing stronger oil control.",
        benefitItems: [
            BenefitItem(title: "Hydrating", description: "Boosts hydration and relieves dry, tight skin."),
            BenefitItem(title: "Barrier Repair", description: "Strengthen and restore your skin's natural barrier."),
            BenefitItem(title: "Hydrating", description: "Boosts hydration and relieves dry, tight skin."),
            BenefitItem(title: "Barrier Repair", description: "Strengthen and restore your skin's natural barrier.")
        ],
        concernItems: [
            ConcernItem(title: "May Worsen Seborrheic Dermatitis", description: "May feed the yeast involved in seborrheic dermatitis."),
            ConcernItem(title: "May Worsen Seborrheic Dermatitis", description: "Targets clogged pores and excess oil.")
        ],
        isSuited: false
    )

    static let stub2 = ValidationResult(
        productName: "Oil and Acne Care Face Wash",
        brand: "Kahf",
        imageURL: nil,
        price: "Price",
        review: "Review",
        brandReputation: "Growing local skincare brand with increasing popularity among male skincare users.",
        reviewSummary: "Users appreciate its refreshing feel and cleansing performance, while acne improvement varies by skin condition.",
        priceSummary: "Higher price point compared to other acne cleansers in the same category.",
        ingredientsMatchSummary: "Focuses on oil control and cleansing, suitable for combination skin with acne concerns.",
        ingredientChecks: [
            IngredientCheckItem(name: "Salicylic Acid", isPresent: true),
            IngredientCheckItem(name: "Glycerin", isPresent: true),
            IngredientCheckItem(name: "Niacinamide", isPresent: true),
            IngredientCheckItem(name: "Tea Tree Extract", isPresent: true),
            IngredientCheckItem(name: "Mineral Clay", isPresent: false),
            IngredientCheckItem(name: "Fragrance", isPresent: false),
            IngredientCheckItem(name: "Alcohol", isPresent: true),
            IngredientCheckItem(name: "Cocamidopropyl Betaine", isPresent: true)
        ],
        keyIngredientItems: [
            KeyIngredientItem(name: "Salicylic Acid", description: "Helps control acne-causing buildup."),
            KeyIngredientItem(name: "Tea Tree Extract", description: "Supports acne-prone skin."),
            KeyIngredientItem(name: "Niacinamide", description: "Helps maintain skin balance.")
        ],
        bestForSummary: "Combination skin needing balanced cleansing.",
        benefitItems: [
            BenefitItem(title: "Hydrating", description: "Boosts hydration and relieves dry, tight skin."),
            BenefitItem(title: "Barrier Repair", description: "Strengthen and restore your skin's natural barrier."),
            BenefitItem(title: "Hydrating", description: "Boosts hydration and relieves dry, tight skin."),
            BenefitItem(title: "Barrier Repair", description: "Strengthen and restore your skin's natural barrier.")
        ],
        concernItems: [
            ConcernItem(title: "May Worsen Seborrheic Dermatitis", description: "May feed the yeast involved in seborrheic dermatitis."),
            ConcernItem(title: "May Worsen Seborrheic Dermatitis", description: "Targets clogged pores and excess oil.")
        ],
        isSuited: false
    )
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }
}
