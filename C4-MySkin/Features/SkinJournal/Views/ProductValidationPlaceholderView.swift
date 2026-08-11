//
//  ProductValidationPlaceholderView.swift
//  C4-MySkin
//

import SwiftUI

struct ProductValidationPlaceholderView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            BackButton(action: onBack)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Spacer()

            Image(systemName: "checkmark.shield")
                .font(.system(size: 80))
                .foregroundStyle(Color(.secondaryLabel))

            Text("Product Validation")
                .font(.title2.weight(.bold))

            Text("This feature is coming soon.")
                .font(.body)
                .foregroundStyle(Color(.secondaryLabel))

            Spacer()
        }
    }
}

#Preview {
    ProductValidationPlaceholderView(onBack: {})
}
