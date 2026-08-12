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
    case dry = "Kering"
    case normal = "Normal"
    case oily = "Berminyak"
    case combination = "Kombinasi"
    case notSureYet = "Belum Yakin"

    var id: String { rawValue }

    static let assessmentConfirmationCases: [SkinType] = [.dry, .normal, .oily, .combination]
}

enum SkinSensitivity: String, CaseIterable, Identifiable {
    case normalResistant = "Normal / Resistant"
    case slightlySensitive = "Agak sensitif"
    case sensitive = "Sensitif"
    case verySensitive = "Sangat sensitif"
    case notSureYet = "Belum Yakin"

    var id: String { rawValue }
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
            .peekHead
        case .skinSensitivity, .mainPage:
            nil
        }
    }
}
