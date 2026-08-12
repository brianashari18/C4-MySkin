//
//  AppDataSchema.swift
//  C4-MySkin
//
//  SwiftData schema for all persistent data.
//

import Foundation
import SwiftData

// MARK: - User Profile (Onboarding + Skin Profile)

@Model
final class UserProfile {
    var name: String = ""
    var skinTypeRaw: String?
    var skinSensitivityRaw: String?
    var profilePhotoName: String?
    var selectedConcernIDs: [String] = []

    @Relationship(deleteRule: .cascade) var pickedProducts: [PickedProduct]? = []
    @Relationship(deleteRule: .cascade) var productComparisons: [ProductComparison]? = []
    @Relationship(deleteRule: .cascade) var activeJourneys: [Journey]? = []
    @Relationship(deleteRule: .cascade) var completedJourneys: [CompletedJourney]? = []
    @Relationship(deleteRule: .cascade) var trackedProducts: [TrackedProduct]? = []

    init(name: String = "", skinTypeRaw: String? = nil, skinSensitivityRaw: String? = nil) {
        self.name = name
        self.skinTypeRaw = skinTypeRaw
        self.skinSensitivityRaw = skinSensitivityRaw
    }
}

// MARK: - Product History

@Model
final class PickedProduct {
    var name: String
    var brand: String
    var imageURL: String?
    var pickedAt: Date

    init(name: String, brand: String, imageURL: String? = nil, pickedAt: Date = Date()) {
        self.name = name
        self.brand = brand
        self.imageURL = imageURL
        self.pickedAt = pickedAt
    }
}

@Model
final class ProductComparison {
    var product1Name: String
    var product1Brand: String
    var product2Name: String
    var product2Brand: String
    var comparedAt: Date

    init(product1Name: String, product1Brand: String, product2Name: String, product2Brand: String, comparedAt: Date = Date()) {
        self.product1Name = product1Name
        self.product1Brand = product1Brand
        self.product2Name = product2Name
        self.product2Brand = product2Brand
        self.comparedAt = comparedAt
    }
}

// MARK: - Tracked Product (Skin Journal)
// A product the user chose to track in the skincare journal flow.
// Distinct from `PickedProduct` (Product History) — that is a different use case.

@Model
final class TrackedProduct {
    @Attribute(.unique) var id: UUID
    var name: String
    var brand: String
    var category: String
    var imageURL: String?
    var slug: String?
    var highlights: [String]
    var chosenAt: Date

    var profile: UserProfile?

    init(
        name: String,
        brand: String,
        category: String = "",
        imageURL: String? = nil,
        slug: String? = nil,
        highlights: [String] = [],
        chosenAt: Date = Date()
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.category = category
        self.imageURL = imageURL
        self.slug = slug
        self.highlights = highlights
        self.chosenAt = chosenAt
    }
}

// MARK: - Journey

@Model
final class Journey {
    @Attribute(.unique) var id: UUID
    var productID: String
    var productBrand: String
    var productName: String
    var productCategory: String
    var productIconName: String?
    var startDate: Date
    var isCompleted: Bool
    var completedDate: Date?

    @Relationship(deleteRule: .cascade) var milestones: [JourneyMilestone]? = []
    @Relationship(deleteRule: .cascade) var journalEntries: [JourneyEntry]? = []
    @Relationship(deleteRule: .cascade) var progressPhotos: [JourneyPhoto]? = []

    init(
        id: UUID = UUID(),
        productID: String,
        productBrand: String,
        productName: String,
        productCategory: String,
        productIconName: String? = nil,
        startDate: Date = Date(),
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        milestones: [JourneyMilestone] = JourneyMilestone.defaultMilestones
    ) {
        self.id = id
        self.productID = productID
        self.productBrand = productBrand
        self.productName = productName
        self.productCategory = productCategory
        self.productIconName = productIconName
        self.startDate = startDate
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.milestones = milestones
    }
}

// MARK: - Milestone

@Model
final class JourneyMilestone {
    var title: String
    var subtitle: String
    var order: Int
    var isCompleted: Bool
    var completedDate: Date?
    var intervalDays: Int

    var targetDate: Date? {
        guard let journey = journey else { return nil }
        let previousDays = journey.milestones?
            .filter { $0.order < self.order }
            .reduce(0) { $0 + $1.intervalDays } ?? 0
        return Calendar.current.date(byAdding: .day, value: previousDays + intervalDays, to: journey.startDate)
    }

    var journey: Journey?

    init(title: String, subtitle: String, order: Int, intervalDays: Int, isCompleted: Bool = false, completedDate: Date? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.order = order
        self.intervalDays = intervalDays
        self.isCompleted = isCompleted
        self.completedDate = completedDate
    }

    static let defaultMilestones: [JourneyMilestone] = [
        JourneyMilestone(title: "Compatibility Check", subtitle: "to see the product works well with your skin", order: 1, intervalDays: 14),
        JourneyMilestone(title: "Results Check", subtitle: "to see the visible improvements on your skin", order: 2, intervalDays: 56)
    ]
}

// MARK: - Journal Entry

@Model
final class JourneyEntry {
    var date: Date
    var note: String
    var moodRaw: String?
    var reactionRaw: String?
    var symptomRaws: [String] = []
    var skinCondition: String?
    var imageName: String?

    var journey: Journey?

    init(date: Date, note: String, moodRaw: String? = nil, reactionRaw: String? = nil, symptomRaws: [String] = [], skinCondition: String? = nil, imageName: String? = nil) {
        self.date = date
        self.note = note
        self.moodRaw = moodRaw
        self.reactionRaw = reactionRaw
        self.symptomRaws = symptomRaws
        self.skinCondition = skinCondition
        self.imageName = imageName
    }
}

// MARK: - Progress Photo

@Model
final class JourneyPhoto {
    var date: Date
    var imageName: String
    var milestoneOrder: Int?

    var journey: Journey?

    init(date: Date, imageName: String, milestoneOrder: Int? = nil) {
        self.date = date
        self.imageName = imageName
        self.milestoneOrder = milestoneOrder
    }
}

// MARK: - Completed Journey (History)

@Model
final class CompletedJourney {
    var originalJourneyID: UUID
    var productName: String
    var productBrand: String
    var productCategory: String
    var startDate: Date
    var completedDate: Date
    var totalDays: Int
    var totalEntries: Int
    var totalPhotos: Int
    var milestone1Completed: Bool
    var milestone2Completed: Bool

    init(from journey: Journey) {
        let endDate = journey.completedDate ?? Date()
        self.originalJourneyID = journey.id
        self.productName = journey.productName
        self.productBrand = journey.productBrand
        self.productCategory = journey.productCategory
        self.startDate = journey.startDate
        self.completedDate = endDate
        self.totalDays = Calendar.current.dateComponents([.day], from: journey.startDate, to: endDate).day ?? 0
        self.totalEntries = journey.journalEntries?.count ?? 0
        self.totalPhotos = journey.progressPhotos?.count ?? 0
        let ms = journey.milestones ?? []
        self.milestone1Completed = ms.first { $0.order == 1 }?.isCompleted ?? false
        self.milestone2Completed = ms.first { $0.order == 2 }?.isCompleted ?? false
    }
}
