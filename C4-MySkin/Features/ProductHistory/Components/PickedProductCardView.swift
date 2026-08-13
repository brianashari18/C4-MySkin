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
                    .frame(width: 52, height: 52)
                } else {
                    JarIconView()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                    .lineLimit(2)

                Text(item.brand)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(red: 0.35, green: 0.58, blue: 0.85))
                    .lineLimit(1)
            }

            Spacer()
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
}

// MARK: - Preview
#Preview {
    PickedProductCardView(item: PickedProductItem.sampleList[0])
        .padding()
        .background(Color.App.backgroundGray)
}
