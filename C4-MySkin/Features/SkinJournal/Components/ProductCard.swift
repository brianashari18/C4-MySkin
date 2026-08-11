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
        Button(action: action) {
            HStack(spacing: 16) {
                productIcon

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.brand)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(.label))

                    Text(product.name)
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Spacer()

                selectionIndicator
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(.label) : Color(.separator), lineWidth: isSelected ? 2 : 0.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(product.brand) \(product.name)")
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }

    private var productIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
                .frame(width: 48, height: 48)

            Image(systemName: "drop.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color(.secondaryLabel))
        }
    }

    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(Color(isSelected ? .label : .separator), lineWidth: 2)
                .frame(width: 24, height: 24)

            if isSelected {
                Circle()
                    .fill(Color(.label))
                    .frame(width: 14, height: 14)
            }
        }
    }
}

#Preview {
    VStack {
        ProductCard(product: SkincareProduct.samples[0], isSelected: false) {}
        ProductCard(product: SkincareProduct.samples[1], isSelected: true) {}
    }
    .padding()
}
