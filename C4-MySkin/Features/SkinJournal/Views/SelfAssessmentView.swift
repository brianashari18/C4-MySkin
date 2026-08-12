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
            // Soft ice blue background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Step Slider Header Indicator
                QuestionnaireStepSlider(currentStep: currentStep, totalSteps: 3)
                    .padding(.top, 24)

                Spacer(minLength: 16)

                // Question Title & Options Frame with Side Navigation Arrows
                ZStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
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
                    }

                    // Floating Side Navigation Arrows (< and >)
                    HStack {
                        if currentStep > 1 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    currentStep -= 1
                                }
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()

                        Button(action: {
                            if canProceed {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    if currentStep < 3 {
                                        currentStep += 1
                                    } else {
                                        let noticed = selectedSymptoms.isEmpty ? "None of the above" : selectedSymptoms.joined(separator: ", ")
                                        onSubmit(
                                            selectedCondition ?? "Slightly Better",
                                            selectedFeelings ?? "Feels comfortable",
                                            noticed
                                        )
                                    }
                                }
                            }
                        }) {
                            Circle()
                                .fill(canProceed ? Color(red: 0.38, green: 0.61, blue: 0.93) : Color.white)
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                .overlay(
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(canProceed ? Color.white : Color(red: 0.80, green: 0.85, blue: 0.90))
                                )
                        }
                        .disabled(!canProceed)
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                }

                Spacer(minLength: 8)

                // Mascot Animation & Speech Bubble at Bottom
                QuestionnaireMascotBottomView(message: mascotMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
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

    // MARK: - Step 1: Skin Condition (Gambar 5)
    private var stepOneContent: some View {
        VStack(spacing: 20) {
            Text("Compared to your last\ncheck-in, how does your\nskin look today?")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                QuestionnaireChip(emoji: "😫", title: "Much worse", isSelected: selectedCondition == "Much worse") {
                    selectedCondition = "Much worse"
                }
                QuestionnaireChip(emoji: "🙁", title: "Slightly worse", isSelected: selectedCondition == "Slightly worse") {
                    selectedCondition = "Slightly worse"
                }
                QuestionnaireChip(emoji: "😐", title: "No noticeable change", isSelected: selectedCondition == "No noticeable change") {
                    selectedCondition = "No noticeable change"
                }
                QuestionnaireChip(emoji: "🙂", title: "Slightly better", isSelected: selectedCondition == "Slightly Better") {
                    selectedCondition = "Slightly Better"
                }
                QuestionnaireChip(emoji: "😄", title: "Much better", isSelected: selectedCondition == "Much better") {
                    selectedCondition = "Much better"
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
                    selectedFeelings = "Irritated"
                }
                QuestionnaireChip(emoji: "🙁", title: "Slight Discomfort", isSelected: selectedFeelings == "Slight Discomfort") {
                    selectedFeelings = "Slight Discomfort"
                }
                QuestionnaireChip(emoji: "😐", title: "No noticeable change", isSelected: selectedFeelings == "No noticeable change") {
                    selectedFeelings = "No noticeable change"
                }
                QuestionnaireChip(emoji: "🙂", title: "Feels comfortable", isSelected: selectedFeelings == "Feels comfortable") {
                    selectedFeelings = "Feels comfortable"
                }
                QuestionnaireChip(emoji: "😄", title: "Feels healthier than before", isSelected: selectedFeelings == "Feels healthier than before") {
                    selectedFeelings = "Feels healthier than before"
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
                
                // "None of the above" filled button (Gambar 3)
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    selectedSymptoms.removeAll()
                    selectedSymptoms.insert("None of the above")
                }) {
                    Text("None of the above")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .buttonStyle(.plain)
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

// MARK: - Questionnaire Step Slider Header
private struct QuestionnaireStepSlider: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? Color(red: 0.38, green: 0.61, blue: 0.93) : Color(red: 0.90, green: 0.93, blue: 0.96))
                            .frame(width: 20, height: 20)

                        if step == currentStep {
                            Circle()
                                .stroke(Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.4), lineWidth: 4)
                                .frame(width: 26, height: 26)
                        }
                    }

                    if step < totalSteps {
                        Rectangle()
                            .fill(step < currentStep ? Color(red: 0.38, green: 0.61, blue: 0.93) : Color(red: 0.90, green: 0.93, blue: 0.96))
                            .frame(height: 4)
                    }
                }
            }
        }
        .frame(width: 180)
    }
}

// MARK: - Questionnaire Option Chip
private struct QuestionnaireChip: View {
    let emoji: String?
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        isSelected
                        ? Color(red: 0.23, green: 0.46, blue: 0.69)
                        : Color(red: 0.38, green: 0.61, blue: 0.93),
                        lineWidth: isSelected ? 2.5 : 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Speech Bubble View (Attached Mockup Design)
struct SpeechBubbleView: View {
    let text: String

    var body: some View {
        ZStack {
            WhiteSpeechBubbleTailShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.20), radius: 8, x: 0, y: 3)

            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 0.20, green: 0.38, blue: 0.56))
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 22)
        }
        .fixedSize(horizontal: true, vertical: true)
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

// MARK: - Questionnaire Mascot Bottom View (Lottie Mascot + Speech Bubble)
private struct QuestionnaireMascotBottomView: View {
    let message: String

    var body: some View {
        VStack(spacing: -450) {
            SpeechBubbleView(text: message)
                .zIndex(10)

            MascotLottieView(width: 655)
                .accessibilityHidden(true)
                .offset(x: -2, y: 250)
            
        }
        .padding(.bottom, 8)
    }
}






#Preview {
    SelfAssessmentView(onSubmit: { _, _, _ in }, onBack: {})
}
