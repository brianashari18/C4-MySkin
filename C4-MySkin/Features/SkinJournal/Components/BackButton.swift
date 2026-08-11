//
//  BackButton.swift
//  C4-MySkin
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(.label))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .stroke(Color(.separator), lineWidth: 1)
                        .background(Circle().fill(Color(.systemBackground)))
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
