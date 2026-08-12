//
//  SelfAssessmentView.swift
//  C4-MySkin
//

import SwiftUI

struct SelfAssessmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: Int = 1
    @State private var selectedCondition: String?
    @State private var selectedFeelings: String?
    @State private var selectedSymptoms: Set<String> = []

    let onSubmit: (_ skinCondition: String, _ howItFeels: String, _ whatYouNoticed: String) -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SelfAssessmentProgressHeader(currentStep: currentStep, totalSteps: 3)

                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 40) {
                            switch currentStep {
                            case 1:
                                stepOneContent
                            case 2:
                                stepTwoContent
                            case 3:
                                stepThreeContent
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, 48)
                        .padding(.top, 50)
                        .padding(.bottom, 300)
                    }

                    PersonalizationMascotFooter(noteText: mascotMessage)
                        .id(currentStep)
                }
            }

            PersonalizationSideNavigation(
                canGoBack: currentStep > 1,
                canAdvance: currentStep == 3 && canProceed,
                onBack: goToPreviousStep,
                onNext: submitAssessment
            )
        }
        .background(OnboardingGradientBackground())
        .navigationBarBackButtonHidden(true)
        .animation(.snappy(duration: 0.24), value: currentStep)
    }

    private var canProceed: Bool {
        switch currentStep {
        case 1: return selectedCondition != nil
        case 2: return selectedFeelings != nil
        case 3: return !selectedSymptoms.isEmpty
        default: return false
        }
    }

    private var mascotMessage: String {
        switch currentStep {
        case 1: return "You are 1 of 3. Let's go!!"
        case 2: return "You are 2 of 3. Let's go!!"
        case 3: return "You can choose more than one"
        default: return ""
        }
    }

    private func goToPreviousStep() {
        guard currentStep > 1 else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep -= 1
        }
    }

    private func selectCondition(_ condition: String) {
        selectedCondition = condition
        moveToStep(2)
    }

    private func selectFeelings(_ feelings: String) {
        selectedFeelings = feelings
        moveToStep(3)
    }

    private func moveToStep(_ step: Int) {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = step
        }
    }

    private func submitAssessment() {
        guard currentStep == 3, canProceed else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            let noticed = selectedSymptoms.isEmpty
                ? "None of the above"
                : selectedSymptoms.joined(separator: ", ")
            onSubmit(
                selectedCondition ?? "Slightly Better",
                selectedFeelings ?? "Feels comfortable",
                noticed
            )
        }
    }

    // MARK: - Step 1: Skin Condition (Gambar 5)
    private var stepOneContent: some View {
        VStack(spacing: 40) {
            Text("Compared to your last\ncheck-in, how does your\nskin look today?")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                QuestionnaireChip(emoji: "😫", title: "Much worse", isSelected: selectedCondition == "Much worse") {
                    selectCondition("Much worse")
                }
                QuestionnaireChip(emoji: "🙁", title: "Slightly worse", isSelected: selectedCondition == "Slightly worse") {
                    selectCondition("Slightly worse")
                }
                QuestionnaireChip(emoji: "😐", title: "No noticeable change", isSelected: selectedCondition == "No noticeable change") {
                    selectCondition("No noticeable change")
                }
                QuestionnaireChip(emoji: "🙂", title: "Slightly better", isSelected: selectedCondition == "Slightly Better") {
                    selectCondition("Slightly Better")
                }
                QuestionnaireChip(emoji: "😄", title: "Much better", isSelected: selectedCondition == "Much better") {
                    selectCondition("Much better")
                }
            }
        }
    }

    // MARK: - Step 2: How It Feels (Gambar 4)
    private var stepTwoContent: some View {
        VStack(spacing: 20) {
            Text("How has your skin reacted\nto this product lately?")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                QuestionnaireChip(emoji: "😫", title: "Irritated", isSelected: selectedFeelings == "Irritated") {
                    selectFeelings("Irritated")
                }
                QuestionnaireChip(emoji: "🙁", title: "Slight Discomfort", isSelected: selectedFeelings == "Slight Discomfort") {
                    selectFeelings("Slight Discomfort")
                }
                QuestionnaireChip(emoji: "😐", title: "No noticeable change", isSelected: selectedFeelings == "No noticeable change") {
                    selectFeelings("No noticeable change")
                }
                QuestionnaireChip(emoji: "🙂", title: "Feels comfortable", isSelected: selectedFeelings == "Feels comfortable") {
                    selectFeelings("Feels comfortable")
                }
                QuestionnaireChip(emoji: "😄", title: "Feels healthier than before", isSelected: selectedFeelings == "Feels healthier than before") {
                    selectFeelings("Feels healthier than before")
                }
            }
        }
    }

    // MARK: - Step 3: What You Noticed (Gambar 3)
    private var stepThreeContent: some View {
        VStack(spacing: 20) {
            Text("Did you notice any of\nthese?")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                QuestionnaireChip(emoji: nil, title: "New breakouts", isSelected: selectedSymptoms.contains("New breakouts")) {
                    toggleSymptom("New breakouts")
                }
                QuestionnaireChip(emoji: nil, title: "Dryness", isSelected: selectedSymptoms.contains("Dryness")) {
                    toggleSymptom("Dryness")
                }
                QuestionnaireChip(emoji: nil, title: "Redness", isSelected: selectedSymptoms.contains("Redness")) {
                    toggleSymptom("Redness")
                }
                QuestionnaireChip(emoji: nil, title: "Itching", isSelected: selectedSymptoms.contains("Itching")) {
                    toggleSymptom("Itching")
                }
                QuestionnaireChip(emoji: nil, title: "New acne", isSelected: selectedSymptoms.contains("New acne")) {
                    toggleSymptom("New acne")
                }
                
                QuestionnaireChip(
                    emoji: nil,
                    title: "None of the above",
                    isSelected: selectedSymptoms.contains("None of the above")
                ) {
                    selectedSymptoms.removeAll()
                    selectedSymptoms.insert("None of the above")
                }
            }
        }
    }

    private func toggleSymptom(_ symptom: String) {
        selectedSymptoms.remove("None of the above")
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
}

// MARK: - Personalization-style progress header
private struct SelfAssessmentProgressHeader: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let milestoneStart = trackWidth * 0.22
            let milestoneEnd = trackWidth * 0.78
            let milestoneSpan = milestoneEnd - milestoneStart
            let lastIndex = max(totalSteps - 1, 1)
            let activeIndex = min(max(currentStep - 1, 0), lastIndex)
            let activeX = milestoneStart + milestoneSpan * CGFloat(activeIndex) / CGFloat(lastIndex)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.82))
                    .frame(height: 10)
                    .overlay {
                        Capsule()
                            .strokeBorder(OnboardingStyle.primaryBlue.opacity(0.08), lineWidth: 1)
                    }
                    .shadow(color: OnboardingStyle.controlShadow.opacity(0.16), radius: 7, y: 3)

                Capsule()
                    .fill(OnboardingStyle.buttonBlue)
                    .frame(width: max(activeX, 16), height: 10)

                ForEach(0..<totalSteps, id: \.self) { index in
                    let isCompleted = index <= activeIndex

                    ZStack {
                        Circle()
                            .fill(isCompleted ? OnboardingStyle.primaryBlue : Color.white)
                            .frame(width: 22, height: 22)

                        Circle()
                            .fill(isCompleted ? OnboardingStyle.buttonBlue : OnboardingStyle.backgroundTop)
                            .frame(width: 14, height: 14)
                    }
                    .shadow(
                        color: OnboardingStyle.controlShadow.opacity(isCompleted ? 0.18 : 0.12),
                        radius: 5,
                        y: 2
                    )
                    .position(
                        x: milestoneStart + milestoneSpan * CGFloat(index) / CGFloat(lastIndex),
                        y: 13
                    )
                }
            }
            .frame(height: 26)
        }
        .frame(width: 240, height: 30)
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
        .accessibilityLabel("Step \(currentStep) of \(totalSteps)")
    }
}

// MARK: - Questionnaire Option Chip
private struct QuestionnaireChip: View {
    let emoji: String?
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let optionShape = RoundedRectangle(cornerRadius: 15, style: .continuous)

        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 18))
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : OnboardingStyle.buttonBlue)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isSelected ? OnboardingStyle.buttonBlue : Color.white.opacity(0.85))
            .overlay {
                optionShape
                    .strokeBorder(OnboardingStyle.buttonBlue, lineWidth: 2)
            }
            .clipShape(optionShape)
            .shadow(color: OnboardingStyle.controlShadow.opacity(0.20), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Speech Bubble View (Attached Mockup Design)
struct SpeechBubbleView: View {
    let text: String
    var maxWidth: CGFloat? = nil

    var body: some View {
        ZStack {
            WhiteSpeechBubbleTailShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.20), radius: 8, x: 0, y: 3)

            bubbleText
        }
        .fixedSize(horizontal: true, vertical: true)
    }

    @ViewBuilder
    private var bubbleText: some View {
        if let maxWidth {
            baseText
                .frame(width: maxWidth, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 22)
        } else {
            baseText
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 22)
        }
    }

    private var baseText: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Color(red: 0.20, green: 0.38, blue: 0.56))
            .multilineTextAlignment(.leading)
    }
}

struct WhiteSpeechBubbleTailShape: Shape {
    let cornerRadius: CGFloat = 22
    let tailWidth: CGFloat = 14
    let tailHeight: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bodyRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - tailHeight)

        path.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

        let tailBaseX = rect.minX + 24
        path.move(to: CGPoint(x: tailBaseX, y: bodyRect.maxY))
        path.addLine(to: CGPoint(x: tailBaseX - 8, y: rect.maxY))
        path.addLine(to: CGPoint(x: tailBaseX + tailWidth, y: bodyRect.maxY))

        path.closeSubpath()
        return path
    }
}

#Preview {
    SelfAssessmentView(onSubmit: { _, _, _ in }, onBack: {})
}
