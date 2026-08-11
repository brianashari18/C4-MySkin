//
//  SelfAssessmentViewModel.swift
//  C4-MySkin
//

import Observation

@MainActor
@Observable
final class SelfAssessmentViewModel {
    var selectedMood: SkinMood?
    var selectedSymptoms: Set<Symptom> = []
    var note: String = ""

    var canSubmit: Bool {
        selectedMood != nil
    }

    func toggleSymptom(_ symptom: Symptom) {
        if symptom == .none {
            selectedSymptoms = [.none]
            return
        }

        selectedSymptoms.remove(.none)
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }

    func isSymptomSelected(_ symptom: Symptom) -> Bool {
        selectedSymptoms.contains(symptom)
    }
}
