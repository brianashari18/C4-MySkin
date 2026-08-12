//
//  MilestoneTwoCompletionView.swift
//  C4-MySkin
//

import SwiftUI

struct MilestoneTwoCompletionView: View {
    @State private var selectedRating = 0

    let onFinish: (Int) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            OnboardingGradientBackground()

            VStack(spacing: 0) {
                Text("It’s the end of the journey")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(OnboardingStyle.primaryBlue)
                    .padding(.top, 55)

                VStack(spacing: 4) {
                    Text("You passed")
                        .font(.system(size: 20, weight: .medium, design: .rounded))

                    Text("All Milestone!")
                        .font(.system(size: 38, weight: .bold, design: .rounded))

                    Text("Your skin must be so thankful to\nget the best results.")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 330)
                        .padding(.top, 2)
                }
                .foregroundStyle(OnboardingStyle.primaryBlue)
                .padding(.top, 42)

                Text("How’s the skincare journey afterall?")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(OnboardingStyle.primaryBlue)
                    .padding(.top, 36)

                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { rating in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.snappy(duration: 0.18)) {
                                selectedRating = rating
                            }
                        } label: {
                            Image(systemName: rating <= selectedRating ? "star.fill" : "star")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(OnboardingStyle.primaryBlue)
                                .frame(width: 30, height: 42)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(rating) star")
                        .accessibilityAddTraits(rating == selectedRating ? .isSelected : [])
                    }
                }
                .frame(width: 254, height: 66)
                .background(OnboardingStyle.noteYellow)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(OnboardingStyle.primaryBlue, lineWidth: 1.2)
                }
                .padding(.top, 10)

                Text("Rate based on your experience")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(OnboardingStyle.primaryBlue)
                    .padding(.top, 10)

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onFinish(selectedRating)
                } label: {
                    Text("Finish")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 254, height: 42)
                        .background(OnboardingStyle.buttonBlue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 68)

                Spacer(minLength: 270)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            OnboardingMascotLottieView(animation: .peekHead)
                .frame(width: 500, height: 500)
                .scaleEffect(1.5)
                .offset(y: 250)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MilestoneTwoCompletionView(onFinish: { _ in })
}
