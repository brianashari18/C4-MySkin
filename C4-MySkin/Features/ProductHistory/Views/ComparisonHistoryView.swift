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
    var onBack: (() -> Void)? = nil

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

            VStack(alignment: .leading, spacing: 0) {
                // Top Navigation Bar with Back button
                HStack {
                    BackButton {
                        if let onBack {
                            onBack()
                        } else {
                            dismiss()
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Header Title & Subtitle
                VStack(alignment: .leading, spacing: 6) {
                    Text("Comparison History")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                    Text("Access your past comparisons to revisit your product choices.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 0.35, green: 0.58, blue: 0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Product Cards List / Empty State
                if viewModel.comparisonHistory.isEmpty {
                    VStack {
                        Spacer()
                        Text("No comparison history yet")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(red: 0.60, green: 0.68, blue: 0.78))
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(viewModel.comparisonHistory) { item in
                                ComparisonHistoryCardView(item: item)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    ComparisonHistoryView()
}
