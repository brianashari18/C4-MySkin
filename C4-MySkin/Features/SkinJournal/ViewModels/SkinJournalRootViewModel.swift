//
//  SkinJournalRootViewModel.swift
//  C4-MySkin
//

import Observation

@MainActor
@Observable
final class SkinJournalRootViewModel {
    private let store: SkinJournalStore

    init(store: SkinJournalStore = .shared) {
        self.store = store
    }

    var hasJourneys: Bool {
        !store.journeys.isEmpty
    }

    var latestJourney: SkincareJourney? {
        store.latestJourney
    }

    func updateLatestJourney(_ transform: @escaping (inout SkincareJourney) -> Void) {
        store.updateLatestJourney(transform)
    }
}
