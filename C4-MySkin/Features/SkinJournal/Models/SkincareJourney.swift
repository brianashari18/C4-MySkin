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
    var milestones: [Milestone]
    var journalEntries: [JournalEntry]
    var progressPhotos: [ProgressPhoto]

    init(
        id: UUID = UUID(),
        product: SkincareProduct,
        startDate: Date = Date(),
        milestones: [Milestone] = Milestone.defaultMilestones,
        journalEntries: [JournalEntry] = [],
        progressPhotos: [ProgressPhoto] = []
    ) {
        self.id = id
        self.product = product
        self.startDate = startDate
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

    init(
        id: UUID = UUID(),
        date: Date,
        note: String,
        mood: SkinMood? = nil,
        symptoms: [Symptom] = [],
        quickTags: [QuickTag] = []
    ) {
        self.id = id
        self.date = date
        self.note = note
        self.mood = mood
        self.symptoms = symptoms
        self.quickTags = quickTags
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
