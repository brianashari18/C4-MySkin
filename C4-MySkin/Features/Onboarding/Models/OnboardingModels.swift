//
//  OnboardingModels.swift
//  C4-MySkin
//
//  Created by Codex on 10/08/26.
//

import Foundation

struct OnboardingPersonalization {
    var name: String = ""
    var skinType: SkinType?
    var skinSensitivity: SkinSensitivity?
}

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case introduction
    case skincareHelp
    case getNamePrompt
    case inputName
    case personalizationIntro
    case skinType
    case skinSensitivity
    case mainPage
}

enum SkinType: String, CaseIterable, Identifiable {
    case dry = "Dry"
    case normal = "Normal"
    case oily = "Oily"
    case combination = "Combination"
    case notSureYet = "Not Sure Yet"

    var id: String { rawValue }

    static let assessmentConfirmationCases: [SkinType] = [.dry, .normal, .oily, .combination]

    var apiQueryValue: String? {
        switch self {
        case .dry: return "dry"
        case .normal: return "normal"
        case .oily: return "oily"
        case .combination: return "combination"
        case .notSureYet: return nil
        }
    }

    static func apiValue(from rawValue: String?) -> String? {
        guard let rawValue, !rawValue.isEmpty else { return nil }
        let lower = rawValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if lower == "dry" || lower == "kering" { return "dry" }
        if lower == "normal" { return "normal" }
        if lower == "oily" || lower == "berminyak" { return "oily" }
        if lower == "combination" || lower == "kombinasi" { return "combination" }
        return nil
    }
}

enum SkinSensitivity: String, CaseIterable, Identifiable {
    case normalResistant = "Normal / Resistant"
    case slightlySensitive = "Slightly Sensitive"
    case sensitive = "Sensitive"
    case verySensitive = "Very Sensitive"
    case notSureYet = "Not Sure Yet"

    var id: String { rawValue }

    var apiQueryValue: String? {
        switch self {
        case .normalResistant: return "normal/resistant"
        case .slightlySensitive: return "slightly sensitive"
        case .sensitive: return "sensitive"
        case .verySensitive: return "very sensitive"
        case .notSureYet: return nil
        }
    }

    static func apiValue(from rawValue: String?) -> String? {
        guard let rawValue, !rawValue.isEmpty else { return nil }
        let lower = rawValue.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if lower.contains("resistant") || lower == "normal / resistant" || lower == "normal/resistant" {
            return "normal/resistant"
        }
        if lower.contains("agak") || lower == "slightly sensitive" {
            return "slightly sensitive"
        }
        if lower.contains("sangat") || lower == "very sensitive" {
            return "very sensitive"
        }
        if lower.contains("sensitif") || lower == "sensitive" {
            return "sensitive"
        }
        return nil
    }
}

enum MascotAnimation: String, CaseIterable {
    case idle = "MascotIdle"
    case wave = "MascotWave"
    case pointing = "MascotPointing"
    case peekHead = "MascotPeekHead"
    case head = "MascotHead"
}

extension OnboardingStep {
    var nextStep: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    var mascotAnimation: MascotAnimation? {
        switch self {
        case .welcome:
            .wave
        case .introduction, .skincareHelp, .personalizationIntro, .skinType:
            .idle
        case .getNamePrompt:
            .pointing
        case .inputName:
            .head
        case .skinSensitivity, .mainPage:
            nil
        }
    }

    var advancesOnTap: Bool {
        switch self {
        case .welcome, .introduction, .skincareHelp, .getNamePrompt:
            true
        case .inputName, .personalizationIntro, .skinType, .skinSensitivity, .mainPage:
            false
        }
    }

    var usesConversationTransition: Bool {
        switch self {
        case .welcome, .introduction, .skincareHelp, .getNamePrompt, .personalizationIntro:
            true
        case .inputName, .skinType, .skinSensitivity, .mainPage:
            false
        }
    }
}
