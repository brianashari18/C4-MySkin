//
//  JourneyDetailView.swift
//  C4-MySkin
//

import SwiftUI

struct JourneyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let product: SkincareProduct
    let onStart: () -> Void

    @State private var viewModel: JourneyDetailViewModel?

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
                // Top bar with Back button
                HStack {
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Timeline Progress Indicator Bar (hidden when opened from calendar view)
                        if !hideProgressBar {
                            JournalTimelineHeader(
                                milestoneNumber: currentMilestoneOrder,
                                totalEntries: entries.count,
                                selectedIndex: $selectedIndex
                            )
                            .padding(.top, 12)
                        }

                        // Photo Frame Row with Left & Right Paging Arrow Buttons
                        HStack(spacing: 12) {
                            // Left Arrow Button
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation {
                                    selectedIndex = max(0, selectedIndex - 1)
                                }
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .opacity(selectedIndex > 0 ? 1.0 : 0.35)
                            }
                        }

                        Spacer(minLength: 24)

                        TipCard()
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                PillButton(title: "Start Journey") {
                    viewModel?.startJourney()
                    onStart()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel = JourneyDetailViewModel(product: product, store: .shared)
        }
    }
}

private struct SelectedProductCard: View {
    let product: SkincareProduct

    var body: some View {
        HStack(spacing: 16) {
            JarIconView()

            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand == "detail" || product.brand.lowercased().starts(with: "brand") ? "Oil Face Wash" : product.brand)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                Text("Niacinamide, AHA, Panthenol")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(red: 0.35, green: 0.58, blue: 0.85))
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Journal Timeline Header Component (Interaktif per Flag)
private struct JournalTimelineHeader: View {
    let milestoneNumber: Int
    let totalEntries: Int
    @Binding var selectedIndex: Int

    private var nodeCount: Int {
        milestoneNumber == 2 ? 5 : max(2, min(5, totalEntries))
    }

    private var progressRatio: Double {
        guard nodeCount > 1 else { return 0 }
        let current = min(selectedIndex, nodeCount - 1)
        return Double(current) / Double(nodeCount - 1)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background Progress Bar Slider Track
                GeometryReader { geometry in
                    let totalWidth = geometry.size.width
                    let fillWidth = totalWidth * progressRatio

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.20))
                            .frame(height: 6)

                        Capsule()
                            .fill(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .frame(width: max(0, fillWidth), height: 6)

                        ZStack {
                            Circle()
                                .fill(Color(red: 0.16, green: 0.35, blue: 0.54))
                                .frame(width: 14, height: 14)

                            Circle()
                                .stroke(Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.6), lineWidth: 3)
                                .frame(width: 20, height: 20)
                        }
                        .offset(x: max(0, min(totalWidth - 10, fillWidth - 10)))
                    }
                    .frame(width: totalWidth, height: 40, alignment: .center)
                }
                .padding(.horizontal, 16)

                // Timeline Icon Nodes (Clickable Flag Buttons)
                HStack {
                    ForEach(0..<nodeCount, id: \.self) { nodeIndex in
                        let iconName = nodeIndex == 0 ? "jar.fill" : "flag.fill"
                        let isSelected = nodeIndex == selectedIndex
                        let isAvailable = nodeIndex < totalEntries

                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            let targetIndex = min(nodeIndex, max(0, totalEntries - 1))
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedIndex = targetIndex
                            }
                        }) {
                            CircleIconNode(
                                iconName: iconName,
                                isSelected: isSelected,
                                isAvailable: isAvailable
                            )
                        }
                        .buttonStyle(.plain)

                        if nodeIndex < nodeCount - 1 {
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 40)
        }
        .padding(.horizontal, 24)
    }
}

private struct CircleIconNode: View {
    let iconName: String
    let isSelected: Bool
    let isAvailable: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    isSelected
                        ? Color(red: 0.16, green: 0.35, blue: 0.54)
                        : (isAvailable ? Color(red: 0.74, green: 0.83, blue: 0.93) : Color(red: 0.88, green: 0.90, blue: 0.93))
                )
                .frame(width: isSelected ? 36 : 30, height: isSelected ? 36 : 30)

            if isSelected {
                Circle()
                    .stroke(Color(red: 0.38, green: 0.61, blue: 0.93), lineWidth: 2.5)
                    .frame(width: 42, height: 42)
            }

            Image(systemName: iconName)
                .font(.system(size: isSelected ? 15 : 13, weight: .bold))
                .foregroundStyle(
                    isSelected
                        ? Color.white
                        : (isAvailable ? Color(red: 0.16, green: 0.35, blue: 0.54) : Color(red: 0.60, green: 0.68, blue: 0.76))
                )
        }
        .frame(width: 42, height: 42)
        .contentShape(Rectangle())
    }
}

#Preview {
    JourneyDetailView(product: SkincareProduct.samples[0], onStart: {})
}

