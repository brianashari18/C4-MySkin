//
//  ProductNotFoundModalView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Popup modal displayed over camera or photo review when a scanned product is not found in the database.
/// Matches the exact design specifications from the mockup.
struct ProductNotFoundModalView: View {

    let onScanAnother: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent dim background
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            // White rounded popup card
            VStack(spacing: 22) {
                Text("Produk Tidak\nDitemukan")
                    .font(Font.App.nunitoRounded(size: 20, weight: .bold))
                    .foregroundStyle(Color.App.textDark)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)

                Button {
                    onScanAnother()
                } label: {
                    Text("Pindai Produk Lain")
                        .font(Font.App.nunitoRounded(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 13)
                        .background(
                            Capsule()
                                .fill(Color.App.mediumBlue)
                                .shadow(color: Color.App.mediumBlue.opacity(0.35), radius: 8, x: 0, y: 4)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 26)
            .frame(width: 290)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 6)
            )
            .transition(.scale(scale: 0.88).combined(with: .opacity))
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: true)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        ProductNotFoundModalView(onScanAnother: {})
    }
}
