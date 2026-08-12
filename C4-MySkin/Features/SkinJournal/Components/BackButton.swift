//
//  BackButton.swift
//  C4-MySkin
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .stroke(Color(red: 0.11, green: 0.27, blue: 0.42), lineWidth: 2)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
}

#Preview {
    BackButton(action: {})
        .padding()
}

