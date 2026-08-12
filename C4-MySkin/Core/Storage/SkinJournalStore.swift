//
//  SkinJournalStore.swift
//  C4-MySkin
//

import Foundation

/// Local persistence store for skin journal data.
/// Uses UserDefaults-backed JSON storage for simplicity.
@MainActor
@Observable
final class SkinJournalStore {
    static let shared = SkinJournalStore()

    private let journeysKey = "skinJournal.journeys"

    private(set) var journeys: [SkincareJourney] = []

    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    var latestJourney: SkincareJourney? {
        journeys.sorted(by: { $0.startDate > $1.startDate }).first
    }

    // MARK: - Journeys

    func addJourney(_ journey: SkincareJourney) {
        journeys.append(journey)
        saveJourneys()
    }

    func updateJourney(_ journey: SkincareJourney) {
        guard let index = journeys.firstIndex(where: { $0.id == journey.id }) else { return }
        journeys[index] = journey
        saveJourneys()
    }

    func updateLatestJourney(_ transform: (inout SkincareJourney) -> Void) {
        guard let index = journeys.firstIndex(where: { $0.id == latestJourney?.id }) else { return }
        transform(&journeys[index])
        saveJourneys()
    }

    func deleteJourney(id: UUID) {
        journeys.removeAll { $0.id == id }
        saveJourneys()
    }

    // MARK: - Persistence

    private func load() {
        if let data = defaults.data(forKey: journeysKey),
           let decoded = try? JSONDecoder().decode([SkincareJourney].self, from: data) {
            journeys = decoded
        }
    }

    private func saveJourneys() {
        if let data = try? JSONEncoder().encode(journeys) {
            defaults.set(data, forKey: journeysKey)
        }
    }
}
