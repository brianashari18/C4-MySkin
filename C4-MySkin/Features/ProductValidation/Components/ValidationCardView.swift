//
//  ValidationCardView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Reusable yellow-header card used in the Validation Result screen.
/// Matches the "Insight" and "Ingredient" cards in the mockup.
struct ValidationCardView: View {

    let title: String
    let items: [String]

    var body: some View {
        ZStack(alignment: .top) {
            // White card body
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.App.sunnyYellow.opacity(0.55), lineWidth: 1.5)
                )
                .shadow(color: Color.App.mediumBlue.opacity(0.07), radius: 8, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 10) {
                // Spacer for the pill header
                Spacer().frame(height: 18)

                // Items list
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 8) {
                        Text("–")
                            .foregroundStyle(Color.App.darkBlue)
                        Text(item)
                            .foregroundStyle(Color.App.darkBlue)
                    }
                    .font(Font.App.nunitoRounded(size: 15, weight: .regular))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)

            // Yellow pill header — sits on top, centered
            Text(title)
                .font(Font.App.nunitoRounded(size: 15, weight: .bold))
                .foregroundStyle(Color.App.darkBlue)
                .padding(.horizontal, 20)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.App.sunnyYellow)
                )
                .offset(y: -18)
        }
        .padding(.top, 18) // compensate for the overhanging pill
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 32) {
        ValidationCardView(
            title: "Insight",
            items: ["Price: Rp 120.000", "Brand: SomeName", "Review: 4.5/5"]
        )
        ValidationCardView(
            title: "Ingredient",
            items: ["Niacinamide", "Hyaluronic Acid", "Glycerin"]
        )
    }
    .padding()
    .background(Color.App.backgroundGray)
}
