//
//  PersonalizationModels.swift
//  C4-MySkin
//
//  Rule-based skin type & sensitivity scoring.
//  Reference: KERAMEAN - Research Mufid 2.0
//

import Foundation

// MARK: - Assessment Option

struct PersonalizationOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let score: Int  // 1-5 (a=1, b=2, c=3, d=4, e=5)
}

// MARK: - Skin Type Assessment

struct SkinTypeAssessmentQuestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let group: SkinTypeQuestionGroup
    let options: [PersonalizationOption]
}

enum SkinTypeQuestionGroup: Int {
    case q1 = 1   // Washing frequency
    case q2 = 2   // Post-wash feel
    case q3_1 = 3 // Cheek oiliness
    case q3_2 = 4 // T-zone oiliness
    case q3_2_1 = 5 // T-zone oiliness speed
    case q4 = 6   // Clogged pores
    case q5 = 7   // Self-assessment
}

// MARK: - Skin Sensitivity Assessment

struct SkinSensitivityAssessmentQuestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let lowLabel: String
    let highLabel: String
}

// MARK: - Skin Concerns

struct SkinConcernTagPage: Identifiable, Hashable {
    let id = UUID()
    let subtitle: String
    let concerns: [SkinConcernTag]
}

enum SkinConcernTag: String, CaseIterable, Identifiable {
    case blackheads = "Komedo hitam"
    case whiteheads = "Komedo putih"
    case acne = "Jerawat merah"
    case inflamedAcne = "Jerawat bernanah"
    case deepAcne = "Jerawat dalam"
    case darkSpots = "Bekas jerawat gelap"
    case redness = "Kemerahan"
    case flecks = "Flek"
    case freckles = "Bercak coklat atau keabu-abuan"
    case sunSpots = "Flek karena matahari"
    case unevenTone = "Warna tidak merata"
    case dullSkin = "Kulit Tampak Kusam"

    var id: String { rawValue }
}

// MARK: - Phases & Sections

enum PersonalizationSection: Int, CaseIterable {
    case skinType
    case skinSensitivity
    case skinConcern
    case summary
}

enum PersonalizationPhase: Equatable {
    case skinTypeSelection
    case skinTypeAssessment
    case skinTypeConfirmation
    case skinTypeResult
    case skinSensitivitySelection
    case skinSensitivityAssessment
    case skinSensitivityResult
    case skinConcern
    case summary
}

extension PersonalizationPhase {
    var section: PersonalizationSection {
        switch self {
        case .skinTypeSelection, .skinTypeAssessment, .skinTypeConfirmation, .skinTypeResult:
            .skinType
        case .skinSensitivitySelection, .skinSensitivityAssessment, .skinSensitivityResult:
            .skinSensitivity
        case .skinConcern:
            .skinConcern
        case .summary:
            .summary
        }
    }
}

// MARK: - Question Bank (Rule-Based)

enum PersonalizationContent {

    // ── Skin Type: 7 Questions (Q1–Q5, with Q3 split into 3.1, 3.2, 3.2.1) ──

    static let skinTypeQuestions: [SkinTypeAssessmentQuestion] = [
        // Q1: Washing frequency
        SkinTypeAssessmentQuestion(
            title: "How many times a day do you wash your face?",
            group: .q1,
            options: [
                PersonalizationOption(title: "I don't wash it every day", score: 1),
                PersonalizationOption(title: "Once a day", score: 2),
                PersonalizationOption(title: "Twice a day", score: 3),
                PersonalizationOption(title: "Three times a day", score: 4),
                PersonalizationOption(title: "Four times or more", score: 5)
            ]
        ),
        // Q2: Post-wash condition
        SkinTypeAssessmentQuestion(
            title: "Two to three hours after washing your face without applying any products, how do your forehead and cheeks look and feel in bright light?",
            group: .q2,
            options: [
                PersonalizationOption(title: "Very rough, flaky, or dull", score: 1),
                PersonalizationOption(title: "Tight or stretched", score: 2),
                PersonalizationOption(title: "Well hydrated with no shine", score: 3),
                PersonalizationOption(title: "Shiny in the light", score: 4)
            ]
        ),
        // Q3.1: Cheek oiliness
        SkinTypeAssessmentQuestion(
            title: "How often do your cheeks look or feel oily?",
            group: .q3_1,
            options: [
                PersonalizationOption(title: "Never", score: 1),
                PersonalizationOption(title: "Sometimes", score: 2),
                PersonalizationOption(title: "Often", score: 3),
                PersonalizationOption(title: "Always", score: 4)
            ]
        ),
        // Q3.2: T-zone oiliness
        SkinTypeAssessmentQuestion(
            title: "How often does your T-zone (forehead and nose) look or feel oily?",
            group: .q3_2,
            options: [
                PersonalizationOption(title: "Never", score: 1),
                PersonalizationOption(title: "Sometimes", score: 2),
                PersonalizationOption(title: "Often", score: 3),
                PersonalizationOption(title: "Always", score: 4)
            ]
        ),
        // Q3.2.1: T-zone oiliness speed
        SkinTypeAssessmentQuestion(
            title: "How quickly does your T-zone get oily after washing your face?",
            group: .q3_2_1,
            options: [
                PersonalizationOption(title: "It never gets oily", score: 1),
                PersonalizationOption(title: "After 5 hours or more", score: 2),
                PersonalizationOption(title: "After 2–4 hours", score: 3),
                PersonalizationOption(title: "Within 1 hour", score: 4),
                PersonalizationOption(title: "All day", score: 5)
            ]
        ),
        // Q4: Clogged pores
        SkinTypeAssessmentQuestion(
            title: "How often do you get clogged pores, blackheads, or whiteheads?",
            group: .q4,
            options: [
                PersonalizationOption(title: "Never", score: 1),
                PersonalizationOption(title: "Sometimes", score: 2),
                PersonalizationOption(title: "Often", score: 3),
                PersonalizationOption(title: "Always", score: 4)
            ]
        ),
        // Q5: Self-assessment
        SkinTypeAssessmentQuestion(
            title: "What do you think your skin type is?",
            group: .q5,
            options: [
                PersonalizationOption(title: "Dry", score: 1),
                PersonalizationOption(title: "Normal", score: 2),
                PersonalizationOption(title: "Combination", score: 3),
                PersonalizationOption(title: "Oily", score: 4)
            ]
        )
    ]

    // ── Skin Sensitivity: 10 Questions (scale 0–10) ──

    static let sensitivityQuestions: [SkinSensitivityAssessmentQuestion] = [
        SkinSensitivityAssessmentQuestion(
            title: "How much irritation do you usually feel on your face?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How strong is the tingling or crawling feeling on your face?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How strong is the stinging or burning feeling on your face?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How warm or hot does your face feel?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How tight does your skin feel, especially after washing your face?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How itchy does your face feel?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How much pain or soreness do you feel on your face?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How uncomfortable does your face feel overall?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How strong is the sudden flushing or hot, stinging feeling on your face?",
            lowLabel: "Not at all",
            highLabel: "Very uncomfortable"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "How noticeable are the red patches on your face?",
            lowLabel: "Not noticeable",
            highLabel: "Very noticeable"
        )
    ]

    // ── Skin Concerns ──

    static let concernPages: [SkinConcernTagPage] = [
        SkinConcernTagPage(
            subtitle: "Breakouts and Clogged Pores",
            concerns: [.blackheads, .whiteheads, .acne, .inflamedAcne, .deepAcne]
        ),
        SkinConcernTagPage(
            subtitle: "Dark Spots and Redness",
            concerns: [.darkSpots, .redness, .flecks, .freckles]
        ),
        SkinConcernTagPage(
            subtitle: "Sun Damage and Dullness",
            concerns: [.sunSpots, .unevenTone, .dullSkin]
        )
    ]
}
