//
//  OnboardingViewModel.swift
//  C4-MySkin
//
//  Created by Codex on 10/08/26.
//

import Foundation
import Observation

@Observable
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var personalization = OnboardingPersonalization()
    var isPreparingNextStep: Bool = false

    var trimmedName: String {
        personalization.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSubmitName: Bool {
        !trimmedName.isEmpty
    }

    func advance() {
        guard currentStep != .mainPage, !isPreparingNextStep else { return }

        let nextStep = currentStep.nextStep ?? .mainPage
        isPreparingNextStep = true
        OnboardingMascotLottieCache.prepare(nextStep.mascotAnimation)
        currentStep = nextStep
        isPreparingNextStep = false
    }

    func submitName() {
        guard canSubmitName else { return }
        personalization.name = trimmedName
        advance()
    }

    func selectSkinType(_ skinType: SkinType) {
        personalization.skinType = skinType
        advance()
    }

    func selectSkinSensitivity(_ skinSensitivity: SkinSensitivity) {
        personalization.skinSensitivity = skinSensitivity
    }

    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        currentStep = .mainPage
    }
}
