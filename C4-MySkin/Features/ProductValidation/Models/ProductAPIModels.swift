//
//  ProductAPIModels.swift
//  C4-MySkin
//
//  Created by Hermes Agent on 10/08/26.
//

import Foundation

struct ProductSearchResponse: Decodable {
    let query: String
    let results: [ProductSearchItem]
}

struct ProductSearchItem: Decodable, Identifiable, Hashable {
    let name: String
    let brand: String?
    let url: String
    let imageURL: String?
    let highlights: [String]

    var id: String { url }

    var fullName: String {
        guard let brand, !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return name
        }
        if name.lowercased().hasPrefix(brand.lowercased()) {
            return name
        }
        return "\(brand) \(name)"
    }

    var slug: String? {
        URL(string: url)?.pathComponents.last
    }

    enum CodingKeys: String, CodingKey {
        case name
        case brand
        case url
        case imageURL = "image_url"
        case highlights
    }

    init(name: String, brand: String? = nil, url: String, imageURL: String?, highlights: [String] = []) {
        self.name = name
        self.brand = brand
        self.url = url
        self.imageURL = imageURL
        self.highlights = highlights
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        url = try container.decode(String.self, forKey: .url)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        highlights = try container.decodeIfPresent([String].self, forKey: .highlights) ?? []
    }
}

// MARK: - Product Resolve Models (GET /api/products/resolve)
struct ProductResolveResponse: Decodable {
    let query: String
    let strategy: String?
    let product: ProductResolvedItem?
    let collectedAt: String?

    enum CodingKeys: String, CodingKey {
        case query
        case strategy
        case product
        case collectedAt = "collected_at"
    }
}

struct ProductResolvedItem: Decodable, Identifiable, Hashable {
    let name: String
    let brand: String?
    let url: String
    let imageURL: String?

    var id: String { url }

    var slug: String? {
        URL(string: url)?.pathComponents.last
    }

    var fullName: String {
        guard let brand, !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return name
        }
        if name.lowercased().hasPrefix(brand.lowercased()) {
            return name
        }
        return "\(brand) \(name)"
    }

    enum CodingKeys: String, CodingKey {
        case name
        case brand
        case url
        case imageURL = "image_url"
    }
}

struct ProductDossierResponse: Decodable {
    let product: ProductPayload
    let price: ProductPricePayload?
    let reviews: ProductReviewsPayload?
    let ingredientProfiles: [IngredientProfileSummary]

    enum CodingKeys: String, CodingKey {
        case product
        case price
        case reviews
        case ingredientProfiles = "ingredient_profiles"
    }
}

struct ProductPayload: Decodable {
    let name: String
    let brand: String
    let description: String?
    let imageURL: String?
    let url: String
    let highlights: [String]
    let ingredients: [ProductIngredientPayload]
    let keyIngredients: [KeyIngredientPayload]
    let whatItDoes: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case brand
        case description
        case imageURL = "image_url"
        case url
        case highlights
        case ingredients
        case keyIngredients = "key_ingredients"
        case whatItDoes = "what_it_does"
    }
}

struct ProductIngredientPayload: Decodable, Hashable {
    let name: String
    let url: String?
    let rating: String?
    let functions: [String]
    let irritancy: Int?
    let comedogenicity: Int?
}

struct KeyIngredientPayload: Decodable, Hashable {
    let name: String
    let concentration: String?
    let benefits: [String]
    let rating: String?
}

struct ProductPricePayload: Decodable {
    let value: Int?
    let note: String?
}

struct ProductReviewsPayload: Decodable {
    let observed: ProductReviewObservedPayload
}

struct ProductReviewObservedPayload: Decodable {
    let averageRating: Double?
    let totalReviewCount: Int?

    enum CodingKeys: String, CodingKey {
        case averageRating = "average_rating"
        case totalReviewCount = "total_review_count"
    }
}

struct IngredientProfileSummary: Decodable, Hashable {
    let name: String
    let slug: String
    let overview: String?
    let benefits: [IngredientBenefit]
    let sideEffects: [String]
    let expectedTime: String?
    let tolerability: String?

    enum CodingKeys: String, CodingKey {
        case name
        case slug
        case overview
        case benefits
        case sideEffects = "side_effects"
        case expectedTime = "expected_time"
        case tolerability
    }
}

struct IngredientSearchResponse: Decodable {
    let query: String
    let results: [IngredientSearchResult]
}

struct IngredientSearchResult: Decodable, Hashable, Identifiable {
    let name: String
    let slug: String

    var id: String { slug }
}

struct IngredientDetailResponse: Decodable {
    let name: String
    let overview: String?
    let benefits: [IngredientBenefit]
    let expectedTime: String?
    let sideEffects: [String]
    let tolerability: String?
    let whatTheResearchSays: String?
    let summary: String?
    let evidence: IngredientEvidence?
    let researchSections: [IngredientResearchSection]
    let sourceURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case overview
        case benefits
        case expectedTime = "expected_time"
        case sideEffects = "side_effects"
        case tolerability
        case whatTheResearchSays = "what_the_research_says"
        case summary
        case evidence
        case researchSections = "research_sections"
        case sourceURL = "source_url"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        benefits = try container.decodeIfPresent([IngredientBenefit].self, forKey: .benefits) ?? []
        expectedTime = try container.decodeIfPresent(String.self, forKey: .expectedTime)
        sideEffects = try container.decodeIfPresent([String].self, forKey: .sideEffects) ?? []
        tolerability = try container.decodeIfPresent(String.self, forKey: .tolerability)
        whatTheResearchSays = try container.decodeIfPresent(String.self, forKey: .whatTheResearchSays)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        evidence = try container.decodeIfPresent(IngredientEvidence.self, forKey: .evidence)
        researchSections = try container.decodeIfPresent([IngredientResearchSection].self, forKey: .researchSections) ?? []
        sourceURL = try container.decodeIfPresent(String.self, forKey: .sourceURL)
    }
}

struct IngredientBenefit: Decodable, Hashable {
    let name: String
    let score: String
}

struct IngredientEvidence: Decodable, Hashable {
    let studiesCount: Int
    let source: String

    enum CodingKeys: String, CodingKey {
        case studiesCount = "studies_count"
        case source
    }
}

struct IngredientResearchSection: Decodable, Hashable {
    let heading: String
    let paragraphs: [String]
}
