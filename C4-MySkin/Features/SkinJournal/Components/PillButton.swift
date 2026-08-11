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
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(isEnabled ? Color(.label) : Color(.secondaryLabel))
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(isEnabled ? Color(.secondarySystemBackground) : Color(.tertiarySystemBackground))
                .clipShape(Capsule())
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
