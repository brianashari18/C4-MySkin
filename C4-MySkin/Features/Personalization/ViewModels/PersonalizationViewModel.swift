//
//  PersonalizationViewModel.swift
//  C4-MySkin
//
//  Rule-based skin type & sensitivity scoring.
//  Reference: KERAMEAN - Research Mufid 2.0
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
    private var skinTypeScores: [SkinTypeQuestionGroup: Int] = [:]
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

    var mascotNoteText: String {
        guard phase == .skinTypeAssessment || phase == .skinTypeConfirmation || phase == .skinSensitivityAssessment || phase == .skinConcern else {
            return "Gapapa kok kalau belum yakin"
        }

        if phase == .skinConcern {
            return "Kamu bisa pilih lebih dari satu loh!"
        }

        if phase == .skinTypeConfirmation {
            return "Pertanyaan terakhir. Let's go!!"
        }

        if phase == .skinSensitivityAssessment {
            let questionNumber = sensitivityQuestionIndex + 1
            switch questionNumber {
            case 1...4:
                return "Pertanyaan \(questionNumber) dari 10. Let's go!!"
            case 5:
                return "Kamu udah setengah jalan. Let's go!!"
            case 6:
                return "Sisa 5 pertanyaan lagi. Let's go!!"
            case 7:
                return "Sisa 4 pertanyaan lagi. Let's go!!"
            case 8:
                return "Sisa 3 pertanyaan lagi. Let's go!!"
            case 9:
                return "Sisa 2 pertanyaan lagi. Let's go!!"
            default:
                return "Pertanyaan terakhir. Let's go!!"
            }
        }

        let questionNumber = skinTypeQuestionIndex + 1
        let totalQuestions = 7

        switch questionNumber {
        case 1, 2, 3:
            return "Pertanyaan \(questionNumber) dari \(totalQuestions). Let's go!!"
        case 4:
            return "Kamu udah setengah jalan. Let's go!!"
        case 5:
            return "Sisa 3 pertanyaan lagi. Let's go!!"
        case 6:
            return "Sisa 2 pertanyaan lagi. Let's go!!"
        default:
            return "Pertanyaan \(questionNumber) dari \(totalQuestions). Let's go!!"
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

    var assessmentProgressText: String {
        switch phase {
        case .skinTypeAssessment:
            return "Pertanyaan \(skinTypeQuestionIndex + 1) dari \(PersonalizationContent.skinTypeQuestions.count)"
        case .skinSensitivityAssessment:
            return "Pertanyaan \(sensitivityQuestionIndex + 1) dari \(PersonalizationContent.sensitivityQuestions.count)"
        default:
            return ""
        }
    }

    var result: OnboardingPersonalization {
        var personalization = OnboardingPersonalization()
        personalization.skinType = selectedSkinType
        personalization.skinSensitivity = selectedSkinSensitivity
        return personalization
    }

    // MARK: - Navigation

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
    }

    func selectConfirmedSkinType(_ skinType: SkinType) {
        selectedSkinType = skinType
        phase = .skinTypeResult
    }

    // MARK: - Skin Type Assessment (Rule-Based)

    func continueSkinTypeAssessment() {
        guard let selectedSkinTypeOption else { return }

        // Store score keyed by question group
        let group = PersonalizationContent.skinTypeQuestions[skinTypeQuestionIndex].group
        skinTypeScores[group] = selectedSkinTypeOption.score
        self.selectedSkinTypeOption = nil

        if skinTypeQuestionIndex < PersonalizationContent.skinTypeQuestions.count - 1 {
            skinTypeQuestionIndex += 1
        } else {
            // All 7 questions answered — calculate result
            selectedSkinType = calculateSkinType()
            phase = .skinTypeConfirmation
        }
    }

    private func calculateSkinType() -> SkinType {
        // Unpack scores: Q1..Q5 (Q3 split into 3.1, 3.2, 3.2.1)
        let q1   = skinTypeScores[.q1] ?? 1
        let q2   = skinTypeScores[.q2] ?? 1
        let q3_1 = skinTypeScores[.q3_1] ?? 1
        let q3_2 = skinTypeScores[.q3_2] ?? 1
        let q3_2_1 = skinTypeScores[.q3_2_1] ?? 1
        let q4   = skinTypeScores[.q4] ?? 1
        let q5   = skinTypeScores[.q5] ?? 1

        let total = q1 + q2 + q3_1 + q3_2 + q3_2_1 + q4 + q5
        let gap = q3_2 - q3_1

        // Rule-based logic
        if gap >= 1 {
            return .combination
        } else if total <= 16 {
            return .dry
        } else if total >= 21 {
            return .oily
        } else {
            // total 17-20
            return .normal
        }
    }

    func acceptSkinTypeResult() {
        phase = .skinSensitivitySelection
    }

    // MARK: - Skin Sensitivity Assessment (Rule-Based)

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

    private func calculateSkinSensitivity() -> SkinSensitivity {
        let total = sensitivityAnswers.reduce(0, +)

        switch total {
        case 0...5:
            return .normalResistant
        case 6...13:
            return .slightlySensitive
        case 14...35:
            return .sensitive
        default: // 36-100
            return .verySensitive
        }
    }

    func acceptSensitivityResult() {
        concernPageIndex = 0
        phase = .skinConcern
    }

    // MARK: - Skin Concerns

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

    // MARK: - Back Navigation

    func goBack() {
        switch phase {
        case .skinTypeSelection:
            break
        case .skinTypeAssessment:
            if skinTypeQuestionIndex > 0 {
                skinTypeQuestionIndex -= 1
                let group = PersonalizationContent.skinTypeQuestions[skinTypeQuestionIndex].group
                selectedSkinTypeOption = skinTypeScores[group].map { PersonalizationOption(title: "", score: $0) }
            } else {
                phase = .skinTypeSelection
                selectedSkinTypeOption = nil
                skinTypeScores.removeAll()
            }
        case .skinTypeConfirmation:
            phase = .skinTypeAssessment
            skinTypeQuestionIndex = PersonalizationContent.skinTypeQuestions.count - 1
            let group = PersonalizationContent.skinTypeQuestions[skinTypeQuestionIndex].group
            selectedSkinTypeOption = skinTypeScores[group].map { PersonalizationOption(title: "", score: $0) }
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
        skinTypeScores.removeAll()
        selectedSkinTypeOption = nil
        phase = .skinTypeAssessment
    }

    private func startSkinSensitivityAssessment() {
        sensitivityQuestionIndex = 0
        sensitivityAnswers.removeAll()
        sensitivityValue = 0
        phase = .skinSensitivityAssessment
    }
}
