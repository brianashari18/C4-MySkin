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
    var imageURL: String?
    var slug: String?
    var highlights: [String]

    /// "Brand Name" — used for display where brand + name should read naturally.
    var fullName: String {
        let trimmedBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBrand.isEmpty else { return name }
        if name.lowercased().hasPrefix(trimmedBrand.lowercased()) {
            return name
        }
        return "\(trimmedBrand) \(name)"
    }

    init(
        id: String,
        brand: String,
        name: String,
        category: String,
        iconName: String? = nil,
        imageURL: String? = nil,
        slug: String? = nil,
        highlights: [String] = []
    ) {
        self.id = id
        self.brand = brand
        self.name = name
        self.category = category
        self.iconName = iconName
        self.imageURL = imageURL
        self.slug = slug
        self.highlights = highlights
    }

    enum CodingKeys: String, CodingKey {
        case id, brand, name, category, iconName, imageURL, slug, highlights
    }

    /// Decodes both the original 5-field shape and the extended shape, so
    /// existing journeys persisted in UserDefaults keep loading.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        brand = try container.decode(String.self, forKey: .brand)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        highlights = try container.decodeIfPresent([String].self, forKey: .highlights) ?? []
    }
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
