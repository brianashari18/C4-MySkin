//
//  ProgressPhotoCard.swift
//  C4-MySkin
//

import SwiftUI

struct ProgressPhotoCard: View {
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    VStack(spacing: 4) {
                        Text("photo")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Color(.secondaryLabel))
                        Text("progress")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                )
        }
    }
}

#Preview {
    ProgressPhotoCard()
        .padding()
}
