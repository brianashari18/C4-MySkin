//
//  JourneyDetailViewModel.swift
//  C4-MySkin
//

import Observation
import Foundation

@MainActor
@Observable
final class JourneyDetailViewModel {
    private let store: SkinJournalStore
    private let product: SkincareProduct

    var isStarting: Bool = false

    init(product: SkincareProduct, store: SkinJournalStore = .shared) {
        self.product = product
        self.store = store
    }

    func startJourney() {
        let journey = SkincareJourney(
            product: product,
            milestones: Milestone.defaultMilestones
        )
        store.addJourney(journey)
        isStarting = true
    }
}
