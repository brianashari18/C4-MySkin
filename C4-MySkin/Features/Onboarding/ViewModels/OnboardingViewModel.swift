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
        MascotLottieCache.prepare(nextStep.mascotAnimation)
        currentStep = nextStep
        isPreparingNextStep = false
    }

    func submitName() {
        guard canSubmitName else { return }
        personalization.name = trimmedName
        advance()
    }

    func completePersonalization(_ personalization: OnboardingPersonalization) {
        self.personalization.skinType = personalization.skinType
        self.personalization.skinSensitivity = personalization.skinSensitivity
        self.personalization.skinConcerns = personalization.skinConcerns
        currentStep = .mainPage
    }
}
