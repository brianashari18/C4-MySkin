//
//  PillButton.swift
//  C4-MySkin
//

import SwiftUI

struct PillButton: View {
    let title: String
    let action: () -> Void
    let isEnabled: Bool

    init(title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(
                    isEnabled
                    ? Color(red: 0.38, green: 0.61, blue: 0.93)
                    : Color(red: 0.70, green: 0.80, blue: 0.92)
                )
                .clipShape(Capsule())
                .shadow(
                    color: isEnabled ? Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3) : .clear,
                    radius: 8, x: 0, y: 4
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 12) {
        PillButton(title: "Continue", isEnabled: true) {}
        PillButton(title: "Continue", isEnabled: false) {}
    }
    .padding()
}

