//
//  ProductCard.swift
//  C4-MySkin
//

import SwiftUI

struct ProductCard: View {
    let product: SkincareProduct
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                productImage

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                        .lineLimit(2)

                    Text(product.brand)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(red: 0.35, green: 0.58, blue: 0.85))
                        .lineLimit(1)
                }

                Spacer()

                selectionIndicator
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
        .buttonStyle(.plain)
        .accessibilityLabel("\(product.brand) \(product.name)")
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }

    private var productImage: some View {
        Group {
            if let imageURL = product.imageURL, let url = URL(string: imageURL) {
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
    }

    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(
                    isSelected ? Color(red: 0.29, green: 0.56, blue: 0.89) : Color(red: 0.50, green: 0.60, blue: 0.70),
                    lineWidth: 2
                )
                .frame(width: 26, height: 26)

            if isSelected {
                Circle()
                    .fill(Color(red: 0.29, green: 0.56, blue: 0.89))
                    .frame(width: 14, height: 14)
            }
        }
    }
}

/// Placeholder skeleton shown while the product list is loading.
struct ProductCardSkeleton: View {
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.84, green: 0.88, blue: 0.92))
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.84, green: 0.88, blue: 0.92))
                    .frame(width: 160, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.88, green: 0.91, blue: 0.94))
                    .frame(width: 100, height: 11)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89).opacity(0.35), lineWidth: 1.5)
        )
        .redacted(reason: .placeholder)
    }
}

struct JarIconView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.84, green: 0.84, blue: 0.84))
                .frame(width: 52, height: 52)

            VStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.55, green: 0.55, blue: 0.55))
                    .frame(width: 24, height: 8)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.70, green: 0.70, blue: 0.70))
                    .frame(width: 32, height: 24)
            }
        }
    }
}

#Preview {
    VStack {
        ProductCard(product: SkincareProduct.samples[0], isSelected: false) {}
        ProductCard(product: SkincareProduct.samples[1], isSelected: true) {}
        ProductCardSkeleton()
    }
    .padding()
}
