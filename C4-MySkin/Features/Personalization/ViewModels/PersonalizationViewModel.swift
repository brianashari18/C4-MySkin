//
//  PersonalizationViewModel.swift
//  C4-MySkin
//
//  Created by Codex on 11/08/26.
//

import Foundation
import Observation

@Observable
final class PersonalizationViewModel {
    var phase: PersonalizationPhase = .skinTypeSelection
    var selectedSkinType: SkinType?
    var selectedSkinSensitivity: SkinSensitivity?
    var selectedConcerns: Set<SkinConcernTag> = []
    var skinTypeQuestionIndex = 0
    var sensitivityQuestionIndex = 0
    var concernPageIndex = 0
    var selectedSkinTypeOption: PersonalizationOption?
    var sensitivityValue: Double = 0

    private let allowsSkinTypeAssessment: Bool
    private let allowsSensitivityAssessment: Bool
    private let stopsAtSensitivitySelection: Bool
    private var skinTypeAnswers: [PersonalizationOption] = []
    private var sensitivityAnswers: [Double] = []
    private var noConcernPageIndexes: Set<Int> = []

    init(
        initialPersonalization: OnboardingPersonalization = OnboardingPersonalization(),
        allowsAssessment: Bool = true,
        allowsSkinTypeAssessment: Bool? = nil,
        allowsSensitivityAssessment: Bool? = nil,
        stopsAtSensitivitySelection: Bool = false
    ) {
        self.allowsSkinTypeAssessment = allowsSkinTypeAssessment ?? allowsAssessment
        self.allowsSensitivityAssessment = allowsSensitivityAssessment ?? allowsAssessment
        self.stopsAtSensitivitySelection = stopsAtSensitivitySelection
        selectedSkinType = initialPersonalization.skinType
        selectedSkinSensitivity = initialPersonalization.skinSensitivity
        selectedConcerns = []
    }

    var skinTypeQuestion: SkinTypeAssessmentQuestion {
        PersonalizationContent.skinTypeQuestions[skinTypeQuestionIndex]
    }

    var sensitivityQuestion: SkinSensitivityAssessmentQuestion {
        PersonalizationContent.sensitivityQuestions[sensitivityQuestionIndex]
    }

    var concernPage: SkinConcernTagPage {
        PersonalizationContent.concernPages[concernPageIndex]
    }

    var isNoConcernSelectedForCurrentPage: Bool {
        noConcernPageIndexes.contains(concernPageIndex)
    }

    var assessmentProgressText: String {
        switch phase {
        case .skinTypeAssessment:
            ""
        case .skinSensitivityAssessment:
            ""
        default:
            ""
        }
    }

    var mascotNoteText: String {
        guard phase == .skinTypeAssessment || phase == .skinTypeConfirmation || phase == .skinSensitivityAssessment || phase == .skinConcern else {
            return "Gapapa kok kalau belum yakin"
        }

        if phase == .skinConcern {
            return "Kamu bisa pilih lebih dari satu loh!"
        }

        if phase == .skinTypeConfirmation {
            return "Pertanyaan terakhir. Let’s go!!"
        }

        if phase == .skinSensitivityAssessment {
            let questionNumber = sensitivityQuestionIndex + 1
            switch questionNumber {
            case 1...4:
                return "Pertanyaan \(questionNumber) dari 10. Let’s go!!"
            case 5:
                return "Kamu udah setengah jalan. Let’s go!!"
            case 6:
                return "Sisa 5 pertanyaan lagi. Let’s go!!"
            case 7:
                return "Sisa 4 pertanyaan lagi. Let’s go!!"
            case 8:
                return "Sisa 3 pertanyaan lagi. Let’s go!!"
            case 9:
                return "Sisa 2 pertanyaan lagi. Let’s go!!"
            default:
                return "Pertanyaan terakhir. Let’s go!!"
            }
        }

        let questionNumber = skinTypeQuestionIndex + 1
        let totalQuestions = 7

        switch questionNumber {
        case 1, 2, 3:
            return "Pertanyaan \(questionNumber) dari \(totalQuestions). Let’s go!!"
        case 4:
            return "Kamu udah setengah jalan. Let’s go!!"
        case 5:
            return "Sisa 3 pertanyaan lagi. Let’s go!!"
        case 6:
            return "Sisa 2 pertanyaan lagi. Let’s go!!"
        default:
            return "Pertanyaan \(questionNumber) dari \(totalQuestions). Let’s go!!"
        }
    }

    var canContinueSkinTypeAssessment: Bool {
        selectedSkinTypeOption != nil
    }

    var canAdvance: Bool {
        switch phase {
        case .skinTypeSelection:
            selectedSkinType != nil
        case .skinTypeAssessment:
            canContinueSkinTypeAssessment
        case .skinTypeConfirmation:
            selectedSkinType != nil
        case .skinTypeResult, .skinSensitivityAssessment, .skinSensitivityResult, .skinConcern, .summary:
            true
        case .skinSensitivitySelection:
            selectedSkinSensitivity != nil
        }
    }

    var result: OnboardingPersonalization {
        var personalization = OnboardingPersonalization()
        personalization.skinType = selectedSkinType
        personalization.skinSensitivity = selectedSkinSensitivity
        return personalization
    }

    func advanceFromCurrentPhase() {
        switch phase {
        case .skinTypeSelection:
            guard selectedSkinType != nil else { return }
            phase = .skinSensitivitySelection
        case .skinTypeAssessment:
            continueSkinTypeAssessment()
        case .skinTypeConfirmation:
            guard selectedSkinType != nil else { return }
            phase = .skinTypeResult
        case .skinTypeResult:
            acceptSkinTypeResult()
        case .skinSensitivitySelection:
            guard selectedSkinSensitivity != nil else { return }
            phase = .skinConcern
        case .skinSensitivityAssessment:
            continueSensitivityAssessment()
        case .skinSensitivityResult:
            acceptSensitivityResult()
        case .skinConcern:
            advanceConcernPage()
        case .summary:
            break
        }
    }

    func selectSkinType(_ skinType: SkinType) {
        if skinType == .notSureYet, allowsSkinTypeAssessment {
            startSkinTypeAssessment()
            return
        }

        selectedSkinType = skinType
        phase = .skinSensitivitySelection
    }

    func selectSkinSensitivity(_ skinSensitivity: SkinSensitivity) {
        if skinSensitivity == .notSureYet, allowsSensitivityAssessment {
            startSkinSensitivityAssessment()
            return
        }

        selectedSkinSensitivity = skinSensitivity
        if stopsAtSensitivitySelection {
            phase = .skinSensitivitySelection
            return
        }
        concernPageIndex = 0
        phase = .skinConcern
    }

    func selectSkinTypeOption(_ option: PersonalizationOption) {
        selectedSkinTypeOption = option
        continueSkinTypeAssessment()
    }

    func selectConfirmedSkinType(_ skinType: SkinType) {
        selectedSkinType = skinType
        phase = .skinTypeResult
    }

    func continueSkinTypeAssessment() {
        guard let selectedSkinTypeOption else { return }
        skinTypeAnswers.append(selectedSkinTypeOption)
        self.selectedSkinTypeOption = nil

        if skinTypeQuestionIndex < PersonalizationContent.skinTypeQuestions.count - 1 {
            skinTypeQuestionIndex += 1
        } else {
            selectedSkinType = nil
            phase = .skinTypeConfirmation
        }
    }

    func acceptSkinTypeResult() {
        phase = .skinSensitivitySelection
    }

    func continueSensitivityAssessment() {
        sensitivityAnswers.append(sensitivityValue)
        sensitivityValue = 0

        if sensitivityQuestionIndex < PersonalizationContent.sensitivityQuestions.count - 1 {
            sensitivityQuestionIndex += 1
        } else {
            selectedSkinSensitivity = calculateSkinSensitivity()
            phase = .skinSensitivityResult
        }
    }

    func acceptSensitivityResult() {
        concernPageIndex = 0
        phase = .skinConcern
    }

    func toggleConcern(_ concern: SkinConcernTag) {
        noConcernPageIndexes.remove(concernPageIndex)

        if selectedConcerns.contains(concern) {
            selectedConcerns.remove(concern)
        } else {
            selectedConcerns.insert(concern)
        }
    }

    func selectNoConcernForCurrentPage() {
        for concern in concernPage.concerns {
            selectedConcerns.remove(concern)
        }

        noConcernPageIndexes.insert(concernPageIndex)
        advanceConcernPage()
    }

    func finishConcern() {
        phase = .summary
    }

    func goBack() {
        switch phase {
        case .skinTypeSelection:
            break
        case .skinTypeAssessment:
            if skinTypeQuestionIndex > 0 {
                skinTypeQuestionIndex -= 1
                selectedSkinTypeOption = skinTypeAnswers.popLast()
            } else {
                phase = .skinTypeSelection
                selectedSkinTypeOption = nil
                skinTypeAnswers.removeAll()
            }
        case .skinTypeConfirmation:
            phase = .skinTypeAssessment
            skinTypeQuestionIndex = PersonalizationContent.skinTypeQuestions.count - 1
            selectedSkinTypeOption = skinTypeAnswers.popLast()
        case .skinTypeResult:
            phase = .skinTypeConfirmation
        case .skinSensitivitySelection:
            phase = .skinTypeSelection
        case .skinSensitivityAssessment:
            if sensitivityQuestionIndex > 0 {
                sensitivityQuestionIndex -= 1
                sensitivityValue = sensitivityAnswers.popLast() ?? 0
            } else {
                phase = .skinSensitivitySelection
                sensitivityValue = 0
                sensitivityAnswers.removeAll()
            }
        case .skinSensitivityResult:
            phase = .skinSensitivityAssessment
            sensitivityQuestionIndex = PersonalizationContent.sensitivityQuestions.count - 1
            sensitivityValue = sensitivityAnswers.popLast() ?? 0
        case .skinConcern:
            if concernPageIndex > 0 {
                concernPageIndex -= 1
            } else if selectedSkinSensitivity == .notSureYet {
                phase = .skinSensitivitySelection
            }
        case .summary:
            concernPageIndex = PersonalizationContent.concernPages.count - 1
            phase = .skinConcern
        }
    }

    private func advanceConcernPage() {
        if concernPageIndex < PersonalizationContent.concernPages.count - 1 {
            concernPageIndex += 1
        } else {
            finishConcern()
        }
    }

    private func startSkinTypeAssessment() {
        skinTypeQuestionIndex = 0
        skinTypeAnswers.removeAll()
        selectedSkinTypeOption = nil
        phase = .skinTypeAssessment
    }

    private func startSkinSensitivityAssessment() {
        sensitivityQuestionIndex = 0
        sensitivityAnswers.removeAll()
        sensitivityValue = 0
        phase = .skinSensitivityAssessment
    }

    private func calculateSkinType() -> SkinType {
        let scoredAnswers = skinTypeAnswers.compactMap(\.skinTypeScore)
        let groupedScores = Dictionary(grouping: scoredAnswers, by: { $0 }).mapValues(\.count)

        if groupedScores[.combination, default: 0] >= 2 {
            return .combination
        }

        return groupedScores.max { lhs, rhs in
            if lhs.value == rhs.value {
                return lhs.key.priority < rhs.key.priority
            }

            return lhs.value < rhs.value
        }?.key ?? .normal
    }

    private func calculateSkinSensitivity() -> SkinSensitivity {
        let average = sensitivityAnswers.reduce(0, +) / Double(max(sensitivityAnswers.count, 1))

        switch average {
        case ..<2.5:
            return .normalResistant
        case ..<5:
            return .slightlySensitive
        case ..<7.5:
            return .sensitive
        default:
            return .verySensitive
        }
    }
}

private extension SkinType {
    var priority: Int {
        switch self {
        case .normal:
            0
        case .dry:
            1
        case .oily:
            2
        case .combination:
            3
        case .notSureYet:
            -1
        }
    }
}
