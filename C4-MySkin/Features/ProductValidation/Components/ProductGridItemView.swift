//
//  ProductGridItemView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Single product card used in the 2-column search grid.
struct ProductGridItemView: View {
    private let imageHeight: CGFloat = 160

    let productName: String
    var image: UIImage? = nil
    var imageURL: String? = nil
    var badgeText: String? = nil

    var isLoading: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // Product image / placeholder
            ZStack(alignment: .topLeading) {
                Group {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                    } else if let imageURL, let url = URL(string: imageURL) {
                        CachedAsyncImage(url: url) {
                            placeholderView
                        }
                        .scaledToFit()
                        .padding(10)
                    } else {
                        placeholderView
                    }
                }

                if let badgeText, !badgeText.isEmpty {
                    Text(badgeText)
                        .font(Font.App.nunitoRounded(size: 10, weight: .bold))
                        .foregroundStyle(Color.App.darkBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.App.sunnyYellow.opacity(0.95))
                        )
                        .padding(8)
                }

                if isLoading {
                    ZStack {
                        Color.white.opacity(0.7)
                        ProgressView()
                            .tint(Color.App.mediumBlue)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isLoading ? Color.App.mediumBlue : Color.App.lightBlue.opacity(0.35), lineWidth: isLoading ? 2 : 1)
            )

            // Product name
            Text(productName)
                .font(Font.App.nunitoRounded(size: 13, weight: .semibold))
                .foregroundStyle(Color.App.darkBlue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }

    private var placeholderView: some View {
        ZStack {
            Color.App.lightBlue.opacity(0.2)
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Color.App.mediumBlue.opacity(0.5))
        }
    }
}

// MARK: - Preview
#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        ForEach(0..<6) { _ in
            ProductGridItemView(productName: "Product name")
        }
    }
    .padding()
    .background(Color.App.backgroundGray)
}
