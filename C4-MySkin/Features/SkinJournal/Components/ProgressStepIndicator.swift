//
//  ProgressStepIndicator.swift
//  C4-MySkin
//

import SwiftUI

struct ProgressStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= currentStep ? Color(.label) : Color(.secondarySystemBackground))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color(.separator), lineWidth: index <= currentStep ? 0 : 1)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview {
    ProgressStepIndicator(currentStep: 1, totalSteps: 3)
        .padding()
}
