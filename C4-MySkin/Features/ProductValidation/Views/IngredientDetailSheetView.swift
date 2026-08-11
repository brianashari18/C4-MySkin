//
//  IngredientDetailSheetView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Bottom sheet view presenting detailed ingredient information from cosmetic.science API.
struct IngredientDetailSheetView: View {

    let ingredientName: String
    let detail: IngredientDetailResponse?
    let isLoading: Bool
    let errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.App.backgroundGray.ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color.App.mediumBlue)
                        Text("Memuat informasi bahan...")
                            .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                            .foregroundStyle(Color.App.darkBlue.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let detail {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header Banner
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Kosmetik & Dermatologi")
                                    .font(Font.App.nunitoRounded(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.App.mediumBlue)

                                Text(detail.name)
                                    .font(Font.App.nunitoRounded(size: 24, weight: .bold))
                                    .foregroundStyle(Color.App.darkBlue)

                                if let overview = detail.overview, !overview.isEmpty {
                                    Text(overview)
                                        .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                                        .foregroundStyle(Color.App.textDark.opacity(0.85))
                                        .padding(.top, 4)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.App.sunnyYellow.opacity(0.25))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.App.sunnyYellow, lineWidth: 1.5)
                                    )
                            )

                            // Quick Stats (Expected Time & Tolerability)
                            HStack(spacing: 12) {
                                if let expectedTime = detail.expectedTime, !expectedTime.isEmpty {
                                    statBox(title: "Waktu Hasil", value: expectedTime, icon: "clock")
                                }
                                if let tolerability = detail.tolerability, !tolerability.isEmpty {
                                    statBox(title: "Tolerabilitas", value: tolerability, icon: "shield.checkerboard")
                                }
                            }

                            // Benefits (Manfaat Utama)
                            if !detail.benefits.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Manfaat Utama")
                                        .font(Font.App.nunitoRounded(size: 16, weight: .bold))
                                        .foregroundStyle(Color.App.darkBlue)

                                    FlowLayout(spacing: 8) {
                                        ForEach(detail.benefits, id: \.name) { benefit in
                                            HStack(spacing: 6) {
                                                Text(benefit.name)
                                                    .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                                    .foregroundStyle(Color.App.darkBlue)
                                                Text("★ \(benefit.score)")
                                                    .font(Font.App.nunitoRounded(size: 11, weight: .bold))
                                                    .foregroundStyle(Color.App.mediumBlue)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Capsule().fill(Color.white))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(Color.App.lightBlue.opacity(0.3))
                                                    .overlay(Capsule().stroke(Color.App.mediumBlue.opacity(0.4), lineWidth: 1))
                                            )
                                        }
                                    }
                                }
                            }

                            // Side Effects / Concerns
                            if !detail.sideEffects.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Perhatian & Efek Samping")
                                        .font(Font.App.nunitoRounded(size: 16, weight: .bold))
                                        .foregroundStyle(Color.App.darkBlue)

                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(detail.sideEffects, id: \.self) { effect in
                                            HStack(alignment: .top, spacing: 8) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(Color.orange)
                                                    .padding(.top, 2)

                                                Text(effect)
                                                    .font(Font.App.nunitoRounded(size: 13, weight: .medium))
                                                    .foregroundStyle(Color.App.textDark)
                                            }
                                        }
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.orange.opacity(0.08))
                                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.3), lineWidth: 1))
                                    )
                                }
                            }

                            // Summary / Research Overview
                            if let summary = detail.summary ?? detail.whatTheResearchSays, !summary.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ringkasan Penelitian")
                                        .font(Font.App.nunitoRounded(size: 16, weight: .bold))
                                        .foregroundStyle(Color.App.darkBlue)

                                    Text(summary)
                                        .font(Font.App.nunitoRounded(size: 13, weight: .regular))
                                        .foregroundStyle(Color.App.textDark.opacity(0.85))
                                        .lineSpacing(4)
                                }
                            }
                        }
                        .padding(20)
                    }
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(Color.gray)
                        Text(errorMessage)
                            .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                            .foregroundStyle(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 12) {
                        Text(ingredientName)
                            .font(Font.App.nunitoRounded(size: 20, weight: .bold))
                            .foregroundStyle(Color.App.darkBlue)
                        Text("Informasi mendalam tidak tersedia untuk bahan ini.")
                            .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                            .foregroundStyle(Color.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(ingredientName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.gray.opacity(0.6))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func statBox(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.App.mediumBlue)
                Text(title)
                    .font(Font.App.nunitoRounded(size: 11, weight: .semibold))
                    .foregroundStyle(Color.gray)
            }
            Text(value)
                .font(Font.App.nunitoRounded(size: 14, weight: .bold))
                .foregroundStyle(Color.App.darkBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.App.mediumBlue.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Simple FlowLayout for Benefit Badges
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.offsets[index].x, y: bounds.minY + result.offsets[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var offsets: [CGPoint] = []

        init(in maxLineWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxLineWidth, currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                offsets.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            size = CGSize(width: maxLineWidth, height: currentY + lineHeight)
        }
    }
}
