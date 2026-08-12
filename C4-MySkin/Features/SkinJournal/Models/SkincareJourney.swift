//
//  SkincareJourney.swift
//  C4-MySkin
//

import Foundation

/// Represents a user's skincare journey for a specific product.
/// A journey consists of two milestones: Compatibility Check and Results Check.
struct SkincareJourney: Identifiable, Codable {
    let id: UUID
    var product: SkincareProduct
    var startDate: Date
    var endDate: Date?
    var rating: Int?
    var milestones: [Milestone]
    var journalEntries: [JournalEntry]
    var progressPhotos: [ProgressPhoto]

    init(
        id: UUID = UUID(),
        product: SkincareProduct,
        startDate: Date = Date(),
        endDate: Date? = nil,
        rating: Int? = nil,
        milestones: [Milestone] = Milestone.defaultMilestones,
        journalEntries: [JournalEntry] = [],
        progressPhotos: [ProgressPhoto] = []
    ) {
        self.id = id
        self.product = product
        self.startDate = startDate
        self.endDate = endDate
        self.rating = rating
        self.milestones = milestones
        self.journalEntries = journalEntries
        self.progressPhotos = progressPhotos
    }
}

/// A milestone inside a skincare journey.
struct Milestone: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var order: Int
    var isCompleted: Bool
    var completedDate: Date?
    var reminderIntervalDays: Int?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        order: Int,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        reminderIntervalDays: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.order = order
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.reminderIntervalDays = reminderIntervalDays
    }

    static let defaultMilestones: [Milestone] = [
        Milestone(
            title: "Compatibility Check",
            subtitle: "to see the product works well with your skin",
            order: 1,
            reminderIntervalDays: 14
        ),
        Milestone(
            title: "Results Check",
            subtitle: "to see the visible improvements on your skin",
            order: 2,
            reminderIntervalDays: 28
        )
    ]
}

/// A daily/periodic journal entry for a journey.
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var note: String
    var mood: SkinMood?
    var symptoms: [Symptom]
    var quickTags: [QuickTag]
    var skinCondition: String?
    var howItFeels: String?
    var whatYouNoticed: String?
    var imageName: String?

    init(
        id: UUID = UUID(),
        date: Date,
        note: String,
        mood: SkinMood? = nil,
        symptoms: [Symptom] = [],
        quickTags: [QuickTag] = [],
        skinCondition: String? = nil,
        howItFeels: String? = nil,
        whatYouNoticed: String? = nil,
        imageName: String? = nil
    ) {
        self.id = id
        self.date = date
        self.note = note
        self.mood = mood
        self.symptoms = symptoms
        self.quickTags = quickTags
        self.skinCondition = skinCondition
        self.howItFeels = howItFeels
        self.whatYouNoticed = whatYouNoticed
        self.imageName = imageName
    }
}

enum SkinMood: String, CaseIterable, Codable, Identifiable {
    case irritated = "Irritated"
    case slightDiscomfort = "Slight Discomfort"
    case noReaction = "No noticeable reaction"
    case comfortable = "Feels comfortable"
    case healthier = "Feels healthier than before"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .irritated: return "😣"
        case .slightDiscomfort: return "🙁"
        case .noReaction: return "😐"
        case .comfortable: return "🙂"
        case .healthier: return "😄"
        }
    }
}

enum Symptom: String, CaseIterable, Codable, Identifiable {
    case newBreakouts = "New breakouts"
    case dryness = "Dryness"
    case redness = "Redness"
    case itching = "Itching"
    case newAcne = "New acne"
    case none = "None of the above"

    var id: String { rawValue }
}

enum QuickTag: String, CaseIterable, Codable, Identifiable {
    case dry = "Dry"
    case oily = "Oily"
    case breakout = "Breakout"
    case sensitive = "Sensitive"
    case glowing = "Glowing"

    var id: String { rawValue }
}

/// A progress photo taken during a journey.
struct ProgressPhoto: Identifiable, Codable {
    let id: UUID
    var date: Date
    var imageName: String
    var milestoneOrder: Int?

    init(
        id: UUID = UUID(),
        date: Date,
        imageName: String,
        milestoneOrder: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.imageName = imageName
        self.milestoneOrder = milestoneOrder
    }
}

/// Algoritma progress milestone/flag perjalanan skincare.
///
/// Aturan: tiap FLAG = periode 2 minggu (14 hari). Upload foto/jurnal yang
/// menyelesaikan milestone = flag selesai → lanjut ke flag berikutnya.
/// Nomor flag diambil dari milestone pertama yang BELUM selesai (upload-driven);
/// minggu berjalan DI DALAM flag dihitung dari waktu (pengingat "skrg minggu
/// ke berapa").
struct MilestoneProgress {
    /// Durasi satu flag (hari) = 2 minggu.
    static let flagDurationDays = 14

    /// Nomor flag saat ini (1-based). > totalFlags berarti semua selesai.
    let currentFlag: Int
    /// Total flag pada journey ini.
    let totalFlags: Int
    /// Hari sudah berjalan di flag saat ini (tidak dibatasi — bisa overdue).
    let daysIntoFlag: Int
    /// Minggu berjalan (1-based) — reminder "skrg di minggu ke berapa".
    let currentWeek: Int
    /// Progress 0...1 menuju target upload berikutnya (capped di 1).
    let progress: Double
    /// Tanggal flag saat ini dimulai (flag 1 = startDate journey, selanjutnya =
    /// tanggal selesai flag sebelumnya).
    let flagStartDate: Date
    /// Tanggal target upload foto berikutnya (akhir flag).
    let nextUploadDate: Date
    /// Sudah lewat target upload (belum upload).
    let isOverdue: Bool
    /// Semua flag sudah selesai.
    let isComplete: Bool

    init(journey: SkincareJourney, now: Date = Date()) {
        let sorted = journey.milestones.sorted { $0.order < $1.order }
        totalFlags = max(sorted.count, 1)
        let completed = sorted.filter(\.isCompleted)
        isComplete = completed.count >= totalFlags
        currentFlag = isComplete
            ? totalFlags + 1
            : (sorted.first { !$0.isCompleted }?.order ?? totalFlags)

        let flagStart: Date
        if isComplete {
            // Semua selesai — anchor di flag terakhir yang selesai
            flagStart = completed.last?.completedDate ?? journey.startDate
        } else if currentFlag <= 1 {
            flagStart = journey.startDate
        } else if let prev = completed.last, let completedDate = prev.completedDate {
            // Flag baru dimulai saat flag sebelumnya diselesaikan (upload)
            flagStart = completedDate
        } else {
            flagStart = journey.startDate
                .addingTimeInterval(TimeInterval(currentFlag - 1) * Double(Self.flagDurationDays) * 86400)
        }
        flagStartDate = flagStart

        let seconds = now.timeIntervalSince(flagStart)
        daysIntoFlag = max(0, Int(seconds / 86400))
        currentWeek = daysIntoFlag / 7 + 1
        progress = min(1, Double(daysIntoFlag) / Double(Self.flagDurationDays))
        nextUploadDate = flagStart.addingTimeInterval(TimeInterval(Self.flagDurationDays) * 86400)
        isOverdue = now > nextUploadDate
    }
}
