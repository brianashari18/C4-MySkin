//
//  PickedProductCardView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

struct PickedProductCardView: View {
    let item: PickedProductItem

    var body: some View {
        HStack(spacing: 16) {
            // Skincare Bottle Icon (or thumbnail)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.App.lightBlue.opacity(0.15))
                    .frame(width: 48, height: 48)

                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                    CachedAsyncImage(url: url) {
                        bottleIcon
                    }
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                } else {
                    bottleIcon
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(Font.App.nunitoRounded(size: 15, weight: .bold))
                    .foregroundStyle(Color.App.darkBlue)
                    .lineLimit(1)

                Text(item.brand)
                    .font(Font.App.nunitoRounded(size: 13, weight: .semibold))
                    .foregroundStyle(Color.App.mediumBlue)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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

    private var bottleIcon: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Color.App.darkBlue)
    }
}

// MARK: - Preview
#Preview {
    PickedProductCardView(item: PickedProductItem.sampleList[0])
        .padding()
        .background(Color.App.backgroundGray)
}
