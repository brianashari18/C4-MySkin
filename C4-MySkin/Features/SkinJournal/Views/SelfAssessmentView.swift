//
//  SelfAssessmentView.swift
//  C4-MySkin
//

import SwiftUI

struct SelfAssessmentView: View {
    @State private var viewModel = SelfAssessmentViewModel()
    let onSubmit: (SkinMood, [Symptom], String) -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressStepIndicator(currentStep: 2, totalSteps: 3)

                Text("How has your skin reacted\nto this product over the past\n2 weeks?")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    ForEach(SkinMood.allCases) { mood in
                        MoodChip(
                            mood: mood,
                            isSelected: viewModel.selectedMood == mood
                        ) {
                            viewModel.selectedMood = mood
                        }
                    }
                }
                .padding(.horizontal, 20)

                Text("Did you notice any of these?")
                    .font(.title3.weight(.bold))
                    .padding(.top, 16)

                VStack(spacing: 12) {
                    ForEach(Symptom.allCases) { symptom in
                        SymptomChip(
                            symptom: symptom,
                            isSelected: viewModel.isSymptomSelected(symptom)
                        ) {
                            viewModel.toggleSymptom(symptom)
                        }
                    }
                }
                .padding(.horizontal, 20)

                MascotBubble(message: "You can choose more than one")
                    .padding(.horizontal, 40)

                TextEditor(text: $viewModel.note)
                    .font(.body)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)

                PillButton(
                    title: "Submit",
                    isEnabled: viewModel.canSubmit
                ) {
                    if let mood = viewModel.selectedMood {
                        onSubmit(mood, Array(viewModel.selectedSymptoms), viewModel.note)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    SelfAssessmentView(onSubmit: { _, _, _ in }, onBack: {})
}
