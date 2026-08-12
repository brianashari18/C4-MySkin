//
//  ComparisonHistoryView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen displaying user's Comparison History list.
struct ComparisonHistoryView: View {

    @StateObject private var viewModel = ProductHistoryViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.App.backgroundGray.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Header & Scrollable List
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        // Header Title & Subtitle
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Comparison History")
                                .font(Font.App.nunitoRounded(size: 24, weight: .bold))
                                .foregroundStyle(Color.App.darkBlue)

                            Text("Access your past comparisons to revisit your product choices.")
                                .font(Font.App.nunitoRounded(size: 13, weight: .medium))
                                .foregroundStyle(Color.App.mediumBlue.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Product Cards List / Empty State
                        if viewModel.comparisonHistory.isEmpty {
                            emptyStateCard
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.comparisonHistory) { item in
                                    ComparisonHistoryCardView(item: item)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Empty State View
    private var emptyStateCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.App.lightBlue.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color.App.mediumBlue)
            }

            VStack(spacing: 6) {
                Text("Belum Ada Riwayat Komparasi")
                    .font(Font.App.nunitoRounded(size: 18, weight: .bold))
                    .foregroundStyle(Color.App.darkBlue)

                Text("Hasil perbandingan 2 produk yang kamu lakukan akan tersimpan di sini untuk dilihat kembali.")
                    .font(Font.App.nunitoRounded(size: 13, weight: .medium))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.App.darkBlue.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .padding(.top, 20)
    }
}

#Preview {
    ComparisonHistoryView()
}
