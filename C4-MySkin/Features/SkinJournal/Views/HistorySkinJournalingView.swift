//
//  HistorySkinJournalingView.swift
//  C4-MySkin
//

import SwiftUI

/// Halaman History Skin Journaling ("Journey History") — menampilkan daftar produk skincare
/// yang telah/sedang dilacak dalam perjalanan skincare pengguna sesuai referensi desain.
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

    private var itemsData: [HistoryItemData] {
        if !journeys.isEmpty {
            return journeys.enumerated().map { index, j in
                itemData(for: j, index: index)
            }
        }
        return sampleHistoryItems
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
                // Top Bar Header with Back Button
                HStack {
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title Header
                        Text("Journey History")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .padding(.top, 16)
                            .padding(.bottom, 4)

                        // List of History Skincare Cards
                        ForEach(Array(itemsData.enumerated()), id: \.offset) { index, item in
                            HistoryProductRow(item: item) {
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

    private func itemData(for journey: SkincareJourney, index: Int) -> HistoryItemData {
        let m1 = journey.milestones.first?.isCompleted ?? false
        let m2 = journey.milestones.count > 1 ? journey.milestones[1].isCompleted : false

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"

        let startStr = formatter.string(from: journey.startDate)
        let endDate = journey.milestones.compactMap(\.completedDate).max() ?? journey.startDate
        let endStr = formatter.string(from: endDate)

        let ratingVal = journey.rating ?? ((m1 && m2) ? 5 : (m1 ? 3 : 1))

        return HistoryItemData(
            dateRange: "\(startStr) - \(endStr)",
            productName: journey.product.name,
            brandName: journey.product.brand,
            rating: journey.experienceRating ?? ((m1 && m2) ? 5 : (m1 ? 3 : 1)),
            milestone1Completed: m1,
            milestone2Completed: m2,
            iconName: journey.product.iconName ?? "jar.fill",
            imageURL: journey.product.imageURL
        )
    }

    private var sampleHistoryItems: [HistoryItemData] {
        [
            HistoryItemData(
                dateRange: "12 Juli - 12 Agustus 2026",
                productName: "PH Balancing Toner",
                brandName: "Skin 1004",
                rating: 5,
                milestone1Completed: true,
                milestone2Completed: true,
                iconName: "jar.fill",
                imageURL: nil
            ),
            HistoryItemData(
                dateRange: "12 Mei - 12 Juli 2026",
                productName: "Creamy Cleaning Gel",
                brandName: "ANUA",
                rating: 3,
                milestone1Completed: true,
                milestone2Completed: false,
                iconName: "jar.fill",
                imageURL: nil
            ),
            HistoryItemData(
                dateRange: "12 Maret - 12 April 2026",
                productName: "Night Moisturizer",
                brandName: "Oriflame",
                rating: 4,
                milestone1Completed: true,
                milestone2Completed: true,
                iconName: "jar.fill",
                imageURL: nil
            ),
            HistoryItemData(
                dateRange: "12 Januari - 15 Januari 2026",
                productName: "PH Balancing Toner",
                brandName: "Skintific",
                rating: 1,
                milestone1Completed: false,
                milestone2Completed: false,
                iconName: "jar.fill",
                imageURL: nil
            )
        ]
    }
}

// MARK: - History Item Model
private struct HistoryItemData {
    let dateRange: String
    let productName: String
    let brandName: String
    let rating: Int
    let milestone1Completed: Bool
    let milestone2Completed: Bool
    let iconName: String
    let imageURL: String?
}

// MARK: - History Product Card Row Component
private struct HistoryProductRow: View {
    let item: HistoryItemData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Top Row: Date range badge pill on left, chevron on right
                HStack {
                    Text(item.dateRange)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.99, green: 0.92, blue: 0.76))
                        )

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))
                }

                // Content Row: Product Image Box on left, Details on right
                HStack(spacing: 14) {
                    // Soft Sky Blue Product Image Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.74, green: 0.88, blue: 0.98))
                            .frame(width: 95, height: 95)

                        if let imageURLStr = item.imageURL, let url = URL(string: imageURLStr) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 75, height: 75)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                default:
                                    Image(systemName: item.iconName)
                                        .font(.system(size: 42))
                                        .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                }
                            }
                        } else {
                            Image(systemName: item.iconName)
                                .font(.system(size: 42))
                                .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                        }
                    }

                    // Product Details Column
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.productName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .lineLimit(1)

                        Text(item.brandName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))

                        // Star Rating Row
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= item.rating ? "star.fill" : "star")
                                    .font(.system(size: 15))
                                    .foregroundStyle(
                                        star <= item.rating
                                            ? Color(red: 0.98, green: 0.78, blue: 0.25)
                                            : Color(red: 0.82, green: 0.86, blue: 0.92)
                                    )
                            }
                        }
                        .padding(.vertical, 1)

                        // Milestone 1 Status
                        HStack(spacing: 6) {
                            Image(systemName: item.milestone1Completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))

                            Text("Milestone #1 Completed")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))
                        }

                        // Milestone 2 Status
                        HStack(spacing: 6) {
                            Image(systemName: item.milestone2Completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))

                            Text("Milestone #2 Completed")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color(red: 0.20, green: 0.40, blue: 0.60).opacity(0.8), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HistorySkinJournalingView()
}
