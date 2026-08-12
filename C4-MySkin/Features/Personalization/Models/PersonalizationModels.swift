//
//  PersonalizationModels.swift
//  C4-MySkin
//
//  Created by Codex on 11/08/26.
//

import Foundation

struct PersonalizationOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let skinTypeScore: SkinType?
}

struct SkinTypeAssessmentQuestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let options: [PersonalizationOption]
}

struct SkinSensitivityAssessmentQuestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let lowLabel: String
    let highLabel: String
}

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

enum PersonalizationContent {
    static let skinTypeQuestions: [SkinTypeAssessmentQuestion] = [
        SkinTypeAssessmentQuestion(
            title: "Berapa kali dalam sehari kamu mencuci muka?",
            options: [
                PersonalizationOption(title: "Saya tidak mencuci muka setiap hari", skinTypeScore: .dry),
                PersonalizationOption(title: "1 kali sehari", skinTypeScore: .dry),
                PersonalizationOption(title: "2 kali sehari", skinTypeScore: .normal),
                PersonalizationOption(title: "3 kali sehari", skinTypeScore: .oily),
                PersonalizationOption(title: "1 kali sehari atau lebih", skinTypeScore: .combination)
            ]
        ),
        SkinTypeAssessmentQuestion(
            title: "2-3 jam setelah mencuci muka dan tidak menggunakan produk skincare, bagaimana rasa/tampilan kulit dan minyaknya di bawah cahaya terang?",
            options: [
                PersonalizationOption(title: "Sangat kering, mengelupas, dan terasa tertarik", skinTypeScore: .dry),
                PersonalizationOption(title: "Kencang atau tertarik", skinTypeScore: .dry),
                PersonalizationOption(title: "Terlihat dengan baik tanpa pantulan cahaya", skinTypeScore: .normal),
                PersonalizationOption(title: "Mengkilap dengan pantulan cahaya terang", skinTypeScore: .oily)
            ]
        ),
        SkinTypeAssessmentQuestion(
            title: "Seberapa sering pipi kamu terasa/tampak berminyak?",
            options: [
                PersonalizationOption(title: "Tidak pernah", skinTypeScore: .dry),
                PersonalizationOption(title: "Kadang-kadang", skinTypeScore: .normal),
                PersonalizationOption(title: "Sering", skinTypeScore: .combination),
                PersonalizationOption(title: "Selalu", skinTypeScore: .oily)
            ]
        ),
        SkinTypeAssessmentQuestion(
            title: "Seberapa sering T-zone (dahi & hidung) kamu terasa/tampak berminyak?",
            options: [
                PersonalizationOption(title: "Tidak pernah", skinTypeScore: .dry),
                PersonalizationOption(title: "Kadang-kadang", skinTypeScore: .normal),
                PersonalizationOption(title: "Sering", skinTypeScore: .combination),
                PersonalizationOption(title: "Selalu", skinTypeScore: .oily)
            ]
        ),
        SkinTypeAssessmentQuestion(
            title: "Seberapa cepat T-zone (dahi & hidung) kamu berminyak setelah mencuci muka?",
            options: [
                PersonalizationOption(title: "Tidak pernah berminyak", skinTypeScore: .dry),
                PersonalizationOption(title: "5 jam atau lebih setelah cuci muka", skinTypeScore: .normal),
                PersonalizationOption(title: "2-4 jam setelah cuci muka", skinTypeScore: .combination),
                PersonalizationOption(title: "1 jam setelah cuci muka", skinTypeScore: .oily),
                PersonalizationOption(title: "Sepanjang hari", skinTypeScore: .oily)
            ]
        ),
        SkinTypeAssessmentQuestion(
            title: "Kamu memiliki pori-pori yang tersumbat (komedo hitam atau komedo putih)?",
            options: [
                PersonalizationOption(title: "Tidak pernah", skinTypeScore: .dry),
                PersonalizationOption(title: "Kadang-kadang", skinTypeScore: .normal),
                PersonalizationOption(title: "Sering", skinTypeScore: .combination),
                PersonalizationOption(title: "Selalu", skinTypeScore: .oily)
            ]
        )
    ]

    static let sensitivityQuestions: [SkinSensitivityAssessmentQuestion] = [
        SkinSensitivityAssessmentQuestion(title: "Seberapa parah iritasi yang kamu rasakan pada kulit wajah secara umum?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa sering/parah rasa gatal, merinding, atau seperti ada yang merayap di wajah?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa parah rasa panas menyengat seperti terbakar di kulit wajah?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa parah sensasi hangat/panas pada kulit wajah kamu?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa parah rasa kaku atau kulit wajah terasa tertarik?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa parah rasa gatal pada kulit wajah kamu?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa parah rasa sakit atau perih fisik pada kulit wajah?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa parah rasa tidak nyaman pada kulit wajah kamu?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa sering/parah wajah terasa tiba-tiba memerah dan terasa panas?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu"),
        SkinSensitivityAssessmentQuestion(title: "Seberapa jelas/parah bercak kemerahan yang terlihat pada kulit wajah kamu?", lowLabel: "Tidak dirasakan sama sekali", highLabel: "Sangat mengganggu")
    ]

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
