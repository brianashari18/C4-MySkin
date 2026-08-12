//
//  SkinConcern.swift
//  C4-MySkin
//

import Foundation

/// Represents a skin concern the user wants to address.
/// Kept for legacy decoding; onboarding flow has been removed.
enum SkinConcernCategory: String, CaseIterable, Identifiable, Codable {
    case acnePores = "Acne & Pore Congestion"
    case skinTone = "Skin Tone"
    case sunDamage = "Sun Damage"
    case dullness = "Dull-looking Skin"

    var id: String { rawValue }
}

struct SkinConcern: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let category: SkinConcernCategory
}

extension SkinConcern {
    static let allConcerns: [SkinConcern] = [
        SkinConcern(id: "blackheads", title: "Blackheads", category: .acnePores),
        SkinConcern(id: "whiteheads", title: "Whiteheads", category: .acnePores),
        SkinConcern(id: "red-acne", title: "Red Acne", category: .acnePores),
        SkinConcern(id: "pus-acne", title: "Pus-filled Acne", category: .acnePores),
        SkinConcern(id: "deep-acne", title: "Deep Acne", category: .acnePores),
        SkinConcern(id: "dark-acne-marks", title: "Dark Acne Marks", category: .skinTone),
        SkinConcern(id: "redness", title: "Redness", category: .skinTone),
        SkinConcern(id: "dark-spots", title: "Dark Spots", category: .skinTone),
        SkinConcern(id: "melasma", title: "Melasma", category: .skinTone),
        SkinConcern(id: "sun-damage", title: "Sun Damage", category: .sunDamage),
        SkinConcern(id: "sun-spots", title: "Sun Spots", category: .sunDamage),
        SkinConcern(id: "uneven-tone", title: "Uneven Tone", category: .sunDamage),
        SkinConcern(id: "dull-skin", title: "Dull-looking Skin", category: .dullness)
    ]

    static func concerns(for category: SkinConcernCategory) -> [SkinConcern] {
        allConcerns.filter { $0.category == category }
    }
}
