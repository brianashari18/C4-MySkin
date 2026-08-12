//
//  ProductHistoryView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Main screen displaying user's Picked Products and Comparison History.
/// Reusable screen matching the exact mockup design specs.
struct ProductHistoryView: View {

    @StateObject private var viewModel = ProductHistoryViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Light background tint
            Color.App.backgroundGray.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Navigation Top Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(Font.App.nunitoRounded(size: 18, weight: .bold))
                            .foregroundStyle(Color.App.darkBlue)
                            .padding(10)
                            .background(
                                Circle()
                                    .stroke(Color.App.darkBlue, lineWidth: 1.8)
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                // MARK: - Segmented Tab Picker
                segmentedPicker
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: - Dynamic Header & Content ScrollView
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        // Header Title & Subtitle
                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.selectedTab == .picked ? "Picked Product" : "Comparison History")
                                .font(Font.App.nunitoRounded(size: 22, weight: .bold))
                                .foregroundStyle(Color.App.darkBlue)

                            Text(viewModel.selectedTab == .picked
                                 ? "Products you've picked after comparing and analyzing their details."
                                 : "Access your past comparisons to revisit your product choices.")
                                .font(Font.App.nunitoRounded(size: 13, weight: .medium))
                                .foregroundStyle(Color.App.mediumBlue.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Product Cards List
                        if viewModel.selectedTab == .picked {
                            VStack(spacing: 12) {
                                ForEach(viewModel.pickedProducts) { item in
                                    PickedProductCardView(item: item)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.comparisonHistory) { item in
                                    ComparisonHistoryCardView(item: item)
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Custom Segmented Control Pill
    private var segmentedPicker: some View {
        HStack(spacing: 0) {
            ForEach(HistoryTab.allCases) { tab in
                let isSelected = viewModel.selectedTab == tab

                Button {
                    viewModel.selectTab(tab)
                } label: {
                    Text(tab.rawValue)
                        .font(Font.App.nunitoRounded(size: 14, weight: .bold))
                        .foregroundStyle(isSelected ? .white : Color.App.mediumBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.App.mediumBlue : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.App.mediumBlue, lineWidth: 1.5)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    ProductHistoryView()
}
