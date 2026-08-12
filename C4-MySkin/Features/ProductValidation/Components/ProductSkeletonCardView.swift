//
//  ProductSkeletonCardView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 11/08/26.
//

import SwiftUI

/// Skeleton placeholder card with subtle pulse animation used during search & initial browse loading.
struct ProductSkeletonCardView: View {
    @State private var isPulsing: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            // Image area placeholder
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.App.lightBlue.opacity(0.18))
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.App.lightBlue.opacity(0.3), lineWidth: 1)
                )

            // Title text placeholder
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.App.lightBlue.opacity(0.25))
                    .frame(height: 12)
                    .frame(maxWidth: 120)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.App.lightBlue.opacity(0.15))
                    .frame(height: 10)
                    .frame(maxWidth: 80)
            }
        }
        .opacity(isPulsing ? 0.45 : 0.9)
        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
        .onAppear {
            isPulsing = true
        }
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        ForEach(0..<6) { _ in
            ProductSkeletonCardView()
        }
    }
    .padding()
    .background(Color.App.backgroundGray)
}
