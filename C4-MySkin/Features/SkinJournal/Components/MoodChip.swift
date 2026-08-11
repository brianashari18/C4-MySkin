//
//  MoodChip.swift
//  C4-MySkin
//

import SwiftUI

struct MoodChip: View {
    let mood: SkinMood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(mood.emoji)
                    .font(.title3)

                Text(mood.rawValue)
                    .font(.body)
                    .foregroundStyle(isSelected ? Color(.systemBackground) : Color(.label))

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 56)
            .background(isSelected ? Color(.label) : Color(.secondarySystemBackground))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mood.rawValue)
    }
}

#Preview {
    VStack(spacing: 12) {
        MoodChip(mood: .noReaction, isSelected: false) {}
        MoodChip(mood: .healthier, isSelected: true) {}
    }
    .padding()
}
