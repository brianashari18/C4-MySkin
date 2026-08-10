//
//  ProductGridItemView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Single product card used in the 2-column search grid.
struct ProductGridItemView: View {

    let productName: String
    var image: UIImage? = nil

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // Product image / placeholder
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color.App.lightBlue.opacity(0.2)
                        Image(systemName: "photo")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(Color.App.mediumBlue.opacity(0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.App.lightBlue.opacity(0.35), lineWidth: 1)
            )

            // Product name
            Text(productName)
                .font(Font.App.nunitoRounded(size: 13, weight: .semibold))
                .foregroundStyle(Color.App.darkBlue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
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
