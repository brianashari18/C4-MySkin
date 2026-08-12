//
//  SkinJournalRootViewModel.swift
//  C4-MySkin
//

import Observation

@MainActor
@Observable
final class SkinJournalRootViewModel {
    private let store: SkinJournalStore

    init(store: SkinJournalStore) {
        self.store = store
    }

    var hasJourneys: Bool {
        !store.journeys.isEmpty
    }

    var latestJourney: SkincareJourney? {
        store.latestJourney
    }

    var journeys: [SkincareJourney] {
        store.journeys
    }

    func updateLatestJourney(_ transform: @escaping (inout SkincareJourney) -> Void) {
        store.updateLatestJourney(transform)
    }

    func addJourney(_ journey: SkincareJourney) {
        store.addJourney(journey)
    }
}

