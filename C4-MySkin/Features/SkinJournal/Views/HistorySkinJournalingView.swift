//
//  HistorySkinJournalingView.swift
//  C4-MySkin
//

import SwiftUI

/// Halaman History Skin Journaling — menampilkan daftar produk skincare
/// yang telah/sedang dilacak dalam perjalanan skincare pengguna.
struct HistorySkinJournalingView: View {
    @Environment(\.dismiss) private var dismiss
    let journeys: [SkincareJourney]
    let onSelectJourney: (SkincareJourney) -> Void

    init(
        journeys: [SkincareJourney] = [],
        onSelectJourney: @escaping (SkincareJourney) -> Void = { _ in }
    ) {
        self.journeys = journeys
        self.onSelectJourney = onSelectJourney
    }

    private var displayJourneys: [SkincareProduct] {
        if !journeys.isEmpty {
            return journeys.map { $0.product }
        }
        // Fallback sample items matching reference screenshot
        return [
            SkincareProduct(id: "hist_1", brand: "Kahf", name: "Oil and Acne Care Face Wash", category: "Face Wash", iconName: "jar.fill"),
            SkincareProduct(id: "hist_2", brand: "Kahf", name: "Oil and Acne Care Face Wash", category: "Face Wash", iconName: "jar.fill"),
            SkincareProduct(id: "hist_3", brand: "Kahf", name: "Oil and Acne Care Face Wash", category: "Face Wash", iconName: "jar.fill"),
            SkincareProduct(id: "hist_4", brand: "Kahf", name: "Oil and Acne Care Face Wash", category: "Face Wash", iconName: "jar.fill"),
            SkincareProduct(id: "hist_5", brand: "Kahf", name: "Oil and Acne Care Face Wash", category: "Face Wash", iconName: "jar.fill"),
            SkincareProduct(id: "hist_6", brand: "Kahf", name: "Oil and Acne Care Face Wash", category: "Face Wash", iconName: "jar.fill")
        ]
    }

    var body: some View {
        ZStack {
            // Soft ice blue background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar with Back Button
                HStack {
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title & Subtitle
                        VStack(alignment: .leading, spacing: 6) {
                            Text("History Skin Journaling")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

                            Text("Products you've picked after comparing and analyzing their details.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                .lineSpacing(3)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                        // List of Skincare Products
                        ForEach(Array(displayJourneys.enumerated()), id: \.offset) { index, product in
                            HistoryProductRow(product: product) {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                if index < journeys.count {
                                    onSelectJourney(journeys[index])
                                } else if let firstJourney = journeys.first {
                                    onSelectJourney(firstJourney)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - History Product Card Row Component
private struct HistoryProductRow: View {
    let product: SkincareProduct
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Jar icon box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.92, green: 0.96, blue: 1.0))
                        .frame(width: 44, height: 44)

                    Image(systemName: "jar.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(red: 0.22, green: 0.43, blue: 0.65))
                }

                // Product details
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                        .lineLimit(1)

                    Text(product.brand)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.8), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HistorySkinJournalingView()
}
