//
//  ComparisonHistoryCardView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

struct ComparisonHistoryCardView: View {
    let item: ComparisonHistoryItem

    var body: some View {
        VStack(spacing: 0) {
            // Product 1 Row
            productRow(item: item.product1)

            // VS Divider Line with centered pill badge
            ZStack {
                Rectangle()
                    .fill(Color.App.mediumBlue.opacity(0.25))
                    .frame(height: 1)

                Text("vs")
                    .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                    .foregroundStyle(Color.App.darkBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color.white)
            }
            .padding(.vertical, 4)

            // Product 2 Row
            productRow(item: item.product2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.App.mediumBlue.opacity(0.35), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        )
    }

    private func productRow(item: PickedProductItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.App.lightBlue.opacity(0.15))
                    .frame(width: 40, height: 40)

                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                    CachedAsyncImage(url: url) {
                        bottleIcon
                    }
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                } else {
                    bottleIcon
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(Font.App.nunitoRounded(size: 14, weight: .bold))
                    .foregroundStyle(Color.App.darkBlue)
                    .lineLimit(1)

                Text(item.brand)
                    .font(Font.App.nunitoRounded(size: 12, weight: .semibold))
                    .foregroundStyle(Color.App.mediumBlue)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var bottleIcon: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color.App.darkBlue)
    }
}

// MARK: - Preview
#Preview {
    ComparisonHistoryCardView(item: ComparisonHistoryItem.sampleList[0])
        .padding()
        .background(Color.App.backgroundGray)
}
