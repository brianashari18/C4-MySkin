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

            // VS Divider Line with centered vs label
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.29, green: 0.56, blue: 0.89).opacity(0.35))
                    .frame(height: 1)

                Text("vs")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(red: 0.29, green: 0.56, blue: 0.89))
                    .padding(.horizontal, 10)
                    .background(Color.white)
            }
            .padding(.vertical, 8)

            // Product 2 Row
            productRow(item: item.product2)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    private func productRow(item: PickedProductItem) -> some View {
        HStack(spacing: 14) {
            Group {
                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)

                        CachedAsyncImage(url: url) {
                            JarIconView()
                        }
                        .scaledToFit()
                        .padding(4)
                    }
                    .frame(width: 48, height: 48)
                } else {
                    JarIconView()
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                    .lineLimit(2)

                Text(item.brand)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(red: 0.35, green: 0.58, blue: 0.85))
                    .lineLimit(1)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    ComparisonHistoryCardView(item: ComparisonHistoryItem.sampleList[0])
        .padding()
        .background(Color.App.backgroundGray)
}
