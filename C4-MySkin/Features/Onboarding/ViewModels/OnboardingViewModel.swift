//
//  OnboardingViewModel.swift
//  C4-MySkin
//
//  Created by Codex on 10/08/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var personalization = OnboardingPersonalization()
    var isPreparingNextStep: Bool = false
    var isConversationContentVisible: Bool = true
    var isMascotDroppingToQuiz: Bool = false

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
        AppDataService.shared.updateOnboarding(
            name: trimmedName,
            skinType: personalization.skinType,
            skinSensitivity: personalization.skinSensitivity
        )
        currentStep = .mainPage
    }

    func advanceConversation() {
        guard currentStep.usesConversationTransition else {
            advance()
            return
        }

        guard let nextStep = currentStep.nextStep, !isPreparingNextStep else { return }
        isPreparingNextStep = true

        let isEnteringQuiz = currentStep == .personalizationIntro && nextStep == .skinType

        withAnimation(.easeInOut(duration: 0.18)) {
            isConversationContentVisible = false
        }

        if isEnteringQuiz {
            withAnimation(.easeOut(duration: 0.20)) {
                isMascotDroppingToQuiz = true
            }
        }

        let delay = isEnteringQuiz ? 0.20 : 0.18
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            OnboardingMascotLottieCache.prepare(nextStep.mascotAnimation)
            self.currentStep = nextStep
            self.isMascotDroppingToQuiz = false

            withAnimation(.easeInOut(duration: 0.24)) {
                self.isConversationContentVisible = true
            }

            self.isPreparingNextStep = false
        }
    }

    func submitNameWithConversationTransition() {
        guard canSubmitName else { return }
        personalization.name = trimmedName
        advanceConversation()
    }
}
