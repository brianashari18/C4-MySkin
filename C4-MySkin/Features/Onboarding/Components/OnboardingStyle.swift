//
//  OnboardingStyle.swift
//  C4-MySkin
//
//  Created by Codex on 10/08/26.
//

import SwiftUI

enum OnboardingStyle {
    static let primaryBlue = Color(red: 69 / 255, green: 111 / 255, blue: 154 / 255)
    static let buttonBlue = Color(red: 104 / 255, green: 166 / 255, blue: 232 / 255)
    static let backgroundTop = Color(red: 240 / 255, green: 247 / 255, blue: 253 / 255)
    static let backgroundBottom = Color.white
    static let controlShadow = Color(red: 93 / 255, green: 93 / 255, blue: 93 / 255)
    static let strongShadow = Color(red: 49 / 255, green: 49 / 255, blue: 49 / 255)
    static let noteYellow = Color(red: 255 / 255, green: 227 / 255, blue: 158 / 255)

    static func roundedFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

struct OnboardingGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                OnboardingStyle.backgroundTop,
                OnboardingStyle.backgroundBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
