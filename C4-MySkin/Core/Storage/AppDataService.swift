//
//  AppDataService.swift
//  C4-MySkin
//
//  Central SwiftData service for all persistence operations.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class AppDataService {
    static let shared = AppDataService()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    private init() {
        do {
            let schema = Schema([
                UserProfile.self,
                PickedProduct.self,
                ProductComparison.self,
                TrackedProduct.self,
                Journey.self,
                JourneyMilestone.self,
                JourneyEntry.self,
                JourneyPhoto.self,
                CompletedJourney.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - User Profile

    func fetchOrCreateProfile() -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let profile = UserProfile()
        modelContext.insert(profile)
        try? modelContext.save()
        return profile
    }

    func saveProfile(_ profile: UserProfile) {
        try? modelContext.save()
    }

    func markPersonalizationCompleted() {
        let profile = fetchOrCreateProfile()
        profile.hasCompletedPersonalization = true
        try? modelContext.save()
    }

    var hasCompletedPersonalization: Bool {
        let profile = fetchOrCreateProfile()
        return profile.hasCompletedPersonalization
    }

    func updateOnboarding(name: String, skinType: SkinType?, skinSensitivity: SkinSensitivity?) {
        let profile = fetchOrCreateProfile()
        profile.name = name
        profile.skinTypeRaw = skinType?.rawValue
        profile.skinSensitivityRaw = skinSensitivity?.rawValue
        try? modelContext.save()
    }

    // MARK: - Tracked Product (Skin Journal)

    func saveTrackedProduct(
        name: String,
        brand: String,
        category: String = "",
        imageURL: String? = nil,
        slug: String? = nil,
        highlights: [String] = []
    ) {
        let profile = fetchOrCreateProfile()
        let tracked = TrackedProduct(
            name: name,
            brand: brand,
            category: category,
            imageURL: imageURL,
            slug: slug,
            highlights: highlights
        )
        tracked.profile = profile
        modelContext.insert(tracked)
        profile.trackedProducts = (profile.trackedProducts ?? []) + [tracked]
        try? modelContext.save()
    }
}
