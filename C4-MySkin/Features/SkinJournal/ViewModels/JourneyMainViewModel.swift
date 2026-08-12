//
//  JourneyMainViewModel.swift
//  C4-MySkin
//

import Observation
import SwiftUI

@MainActor
@Observable
final class JourneyMainViewModel {
    private let store: SkinJournalStore
    private(set) var journey: SkincareJourney

    var showCameraGuide: Bool = false
    var showJournalEntry: Bool = false
    var showSelfAssessment: Bool = false

    init(journey: SkincareJourney, store: SkinJournalStore) {
        self.journey = journey
        self.store = store
    }

    var currentMilestone: Milestone? {
        journey.milestones.first { !$0.isCompleted }
    }

    var completedMilestoneCount: Int {
        journey.milestones.filter(\.isCompleted).count
    }

    var latestPhoto: ProgressPhoto? {
        journey.progressPhotos.sorted(by: { $0.date > $1.date }).first
    }

    var latestEntry: JournalEntry? {
        journey.journalEntries.sorted(by: { $0.date > $1.date }).first
    }

    func addPhoto(_ imageName: String) {
        let photo = ProgressPhoto(
            date: Date(),
            imageName: imageName,
            milestoneOrder: currentMilestone?.order
        )
        journey.progressPhotos.append(photo)
        store.updateJourney(journey)
    }

    func addJournalEntry(_ entry: JournalEntry) {
        journey.journalEntries.append(entry)
        store.updateJourney(journey)
    }

    func submitSelfAssessment(mood: SkinMood, symptoms: [Symptom], note: String) {
        let entry = JournalEntry(
            date: Date(),
            note: note,
            mood: mood,
            symptoms: symptoms
        )
        addJournalEntry(entry)

        if let index = journey.milestones.firstIndex(where: { !$0.isCompleted }) {
            journey.milestones[index].isCompleted = true
            journey.milestones[index].completedDate = Date()
            store.updateJourney(journey)
        }
    }
}
