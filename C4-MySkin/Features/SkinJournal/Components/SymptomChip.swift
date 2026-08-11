//
//  SymptomChip.swift
//  C4-MySkin
//

import SwiftUI

struct SymptomChip: View {
    let symptom: Symptom
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(symptom.rawValue)
                .font(.body.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, minHeight: 56)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symptom.rawValue)
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }

    private var foregroundColor: Color {
        isSelected && symptom == .none ? Color(.systemBackground) : Color(.label)
    }

    private var backgroundColor: Color {
        if isSelected && symptom == .none {
            return Color(.darkGray)
        }
        return isSelected ? Color(.label) : Color(.secondarySystemBackground)
    }
}

#Preview {
    VStack(spacing: 12) {
        SymptomChip(symptom: .dryness, isSelected: false) {}
        SymptomChip(symptom: .none, isSelected: true) {}
    }
    .padding()
}
