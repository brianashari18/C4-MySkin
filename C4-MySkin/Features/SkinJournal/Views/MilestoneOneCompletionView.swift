//
//  MilestoneOneCompletionView.swift
//  C4-MySkin
//

import SwiftUI

struct MilestoneOneCompletionView: View {
    let onStopJourney: () -> Void
    let onContinueJourney: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            OnboardingGradientBackground()

            VStack(spacing: 0) {
                Text("You’re in the end of Milestone 1")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(OnboardingStyle.primaryBlue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 74)

                VStack(spacing: 12) {
                    Text("Do you want to\ncontinue your journey to")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingStyle.primaryBlue)
                        .multilineTextAlignment(.center)

                    Text("Milestone 2?")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(OnboardingStyle.primaryBlue)

                    Text("it’s help you see the best results.")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundStyle(OnboardingStyle.primaryBlue)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 72)

                HStack(spacing: 24) {
                    decisionButton(
                        title: "No, I am not",
                        foregroundColor: OnboardingStyle.noteYellow,
                        backgroundColor: OnboardingStyle.buttonBlue,
                        borderColor: OnboardingStyle.noteYellow,
                        action: onStopJourney
                    )

                    decisionButton(
                        title: "Yes, I’m in!",
                        foregroundColor: OnboardingStyle.primaryBlue,
                        backgroundColor: OnboardingStyle.noteYellow,
                        borderColor: OnboardingStyle.primaryBlue,
                        action: onContinueJourney
                    )
                }
                .padding(.top, 34)
                .padding(.horizontal, 32)

                Spacer(minLength: 310)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            OnboardingMascotLottieView(animation: .peekHead)
                .frame(width: 500, height: 500)
                .scaleEffect(1.8)
                .offset(y:190)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func decisionButton(
        title: String,
        foregroundColor: Color,
        backgroundColor: Color,
        borderColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(foregroundColor)
                .frame(width: 142, height: 62)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                }
                .shadow(color: OnboardingStyle.controlShadow.opacity(0.10), radius: 5, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MilestoneOneCompletionView(
        onStopJourney: {},
        onContinueJourney: {}
    )
}
