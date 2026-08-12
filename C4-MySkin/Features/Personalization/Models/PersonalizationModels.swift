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
            title: "Berapa kali dalam sehari kamu mencuci muka?",
            group: .q1,
            options: [
                PersonalizationOption(title: "Saya tidak mencuci muka setiap hari", score: 1),
                PersonalizationOption(title: "1 kali sehari", score: 2),
                PersonalizationOption(title: "2 kali sehari", score: 3),
                PersonalizationOption(title: "3 kali sehari", score: 4),
                PersonalizationOption(title: "4 kali atau lebih", score: 5)
            ]
        ),
        // Q2: Post-wash condition
        SkinTypeAssessmentQuestion(
            title: "2-3 jam setelah mencuci wajah dan tidak mengoleskan pelembap, sunscreen, toner, bedak, atau produk lainnya... Bagaimana rasa/tampilan dahi dan pipimu di bawah cahaya terang?",
            group: .q2,
            options: [
                PersonalizationOption(title: "Sangat kasar, mengelupas, atau pucat keabu-abuan", score: 1),
                PersonalizationOption(title: "Kencang (tertarik)", score: 2),
                PersonalizationOption(title: "Terhidrasi dengan baik tanpa pantulan cahaya", score: 3),
                PersonalizationOption(title: "Mengkilap dengan pantulan cahaya terang", score: 4)
            ]
        ),
        // Q3.1: Cheek oiliness
        SkinTypeAssessmentQuestion(
            title: "Seberapa sering pipi kamu terasa/tampak berminyak?",
            group: .q3_1,
            options: [
                PersonalizationOption(title: "Tidak pernah", score: 1),
                PersonalizationOption(title: "Kadang-kadang", score: 2),
                PersonalizationOption(title: "Sering", score: 3),
                PersonalizationOption(title: "Selalu", score: 4)
            ]
        ),
        // Q3.2: T-zone oiliness
        SkinTypeAssessmentQuestion(
            title: "Seberapa sering T-zone (dahi & hidung) kamu terasa/tampak berminyak?",
            group: .q3_2,
            options: [
                PersonalizationOption(title: "Tidak pernah", score: 1),
                PersonalizationOption(title: "Kadang-kadang", score: 2),
                PersonalizationOption(title: "Sering", score: 3),
                PersonalizationOption(title: "Selalu", score: 4)
            ]
        ),
        // Q3.2.1: T-zone oiliness speed
        SkinTypeAssessmentQuestion(
            title: "Seberapa cepat T-zone (dahi & hidung) jadi berminyak setelah mencuci muka?",
            group: .q3_2_1,
            options: [
                PersonalizationOption(title: "Tidak pernah berminyak", score: 1),
                PersonalizationOption(title: "5 jam atau lebih setelah cuci muka", score: 2),
                PersonalizationOption(title: "2 - 4 jam setelah cuci muka", score: 3),
                PersonalizationOption(title: "1 jam setelah cuci muka", score: 4),
                PersonalizationOption(title: "Sepanjang hari", score: 5)
            ]
        ),
        // Q4: Clogged pores
        SkinTypeAssessmentQuestion(
            title: "Kamu memiliki pori-pori yang tersumbat (komedo hitam atau komedo putih)?",
            group: .q4,
            options: [
                PersonalizationOption(title: "Tidak pernah", score: 1),
                PersonalizationOption(title: "Kadang-kadang", score: 2),
                PersonalizationOption(title: "Sering", score: 3),
                PersonalizationOption(title: "Selalu", score: 4)
            ]
        ),
        // Q5: Self-assessment
        SkinTypeAssessmentQuestion(
            title: "Menurutmu, kulitmu termasuk tipe apa?",
            group: .q5,
            options: [
                PersonalizationOption(title: "Kering", score: 1),
                PersonalizationOption(title: "Normal", score: 2),
                PersonalizationOption(title: "Kombinasi", score: 3),
                PersonalizationOption(title: "Berminyak", score: 4)
            ]
        )
    ]

    // ── Skin Sensitivity: 10 Questions (scale 0–10) ──

    static let sensitivityQuestions: [SkinSensitivityAssessmentQuestion] = [
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa parah iritasi yang kamu rasakan pada kulit wajah secara umum?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa sering/parah rasa geli, merinding, atau seperti ada yang merayap di wajah?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa parah rasa panas menyengat seperti terbakar di kulit wajah?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa parah sensasi hangat/panas pada kulit wajah kamu?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa parah rasa kaku atau kulit wajah terasa \"ketarik\" (misalnya setelah cuci muka)?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa parah rasa gatal pada kulit wajah kamu?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa parah rasa sakit atau perih fisik pada kulit wajah?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa parah rasa tidak nyaman secara keseluruhan pada kulit wajah kamu?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa sering/parah wajah terasa tiba-tiba memerah dan menyengat panas?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        ),
        SkinSensitivityAssessmentQuestion(
            title: "Seberapa jelas/parah bercak kemerahan yang terlihat pada kulit wajah kamu?",
            lowLabel: "Tidak dirasakan sama sekali",
            highLabel: "Sangat mengganggu"
        )
    ]

    // ── Skin Concerns ──

    static let concernPages: [SkinConcernTagPage] = [
        SkinConcernTagPage(
            subtitle: "Jerawat dan Penyumbatan Pori",
            concerns: [.blackheads, .whiteheads, .acne, .inflamedAcne, .deepAcne]
        ),
        SkinConcernTagPage(
            subtitle: "Warna Kulit Tidak Merata",
            concerns: [.darkSpots, .redness, .flecks, .freckles]
        ),
        SkinConcernTagPage(
            subtitle: "Akibat Paparan Sinar Matahari",
            concerns: [.sunSpots, .unevenTone, .dullSkin]
        )
    ]
}
