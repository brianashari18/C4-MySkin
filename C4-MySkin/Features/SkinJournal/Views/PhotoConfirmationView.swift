//
//  PhotoConfirmationView.swift
//  C4-MySkin
//

import SwiftUI

struct PhotoConfirmationView: View {
    let onRetake: () -> Void
    let onUsePhoto: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Nicely captured!")
                .font(.title2.weight(.bold))
                .padding(.top, 24)

            Spacer()

            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
                .aspectRatio(3/4, contentMode: .fit)
                .overlay(
                    FaceOutline()
                        .frame(width: 200, height: 260)
                )
                .padding(.horizontal, 40)

            Spacer()

            HStack(spacing: 16) {
                Button(action: onRetake) {
                    HStack(spacing: 6) {
                        Text("Retake")
                            .font(.body.weight(.semibold))
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .foregroundStyle(Color(.label))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onUsePhoto) {
                    Text("Use This Photo")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(.systemBackground))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color(.label))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    PhotoConfirmationView(onRetake: {}, onUsePhoto: {})
}
