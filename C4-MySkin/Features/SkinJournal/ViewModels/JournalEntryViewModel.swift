//
//  JournalEntryViewModel.swift
//  C4-MySkin
//

import Observation
import Foundation

@MainActor
@Observable
final class JournalEntryViewModel {
    var date: Date = Date()
    var note: String = ""
    var selectedTags: Set<QuickTag> = []
    var selectedMood: SkinMood?

    var canSave: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func toggleTag(_ tag: QuickTag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func createEntry() -> JournalEntry {
        JournalEntry(
            date: date,
            note: note,
            mood: selectedMood,
            quickTags: Array(selectedTags)
        )
    }
}
