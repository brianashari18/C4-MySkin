//
//  OnboardingControls.swift
//  C4-MySkin
//
//  Created by Codex on 10/08/26.
//

import SwiftUI

struct OnboardingPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var fontSize: CGFloat = 24
    var height: CGFloat = 54
    var cornerRadius: CGFloat = 15
    let action: () -> Void

    var body: some View {
        let buttonShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(isEnabled ? OnboardingStyle.buttonBlue : OnboardingStyle.buttonBlue.opacity(0.45))
                .clipShape(buttonShape)
                .shadow(color: OnboardingStyle.primaryBlue.opacity(0.18), radius: 8, y: 5)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

struct OnboardingOptionButton: View {
    let title: String
    let isSelected: Bool
    var fontSize: CGFloat = 24
    var height: CGFloat = 55
    let action: () -> Void

    var body: some View {
        let optionShape = RoundedRectangle(cornerRadius: 15, style: .continuous)

        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .white : OnboardingStyle.buttonBlue)
                .frame(maxWidth: .infinity)
                .frame(height: height)
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

struct OnboardingTitleText: View {
    let text: String
    var size: CGFloat = 24
    var alignment: TextAlignment = .leading

    var body: some View {
        Text(text)
            .font(OnboardingStyle.roundedFont(size: size))
            .foregroundStyle(OnboardingStyle.primaryBlue)
            .multilineTextAlignment(alignment)
            .lineSpacing(1)
    }
}
