//
//  JourneyDetailView.swift
//  C4-MySkin
//

import SwiftUI

/// Halaman Detail History Journal & Milestone yang telah dijurnalkan.
/// Menampilkan foto progress dengan tombol navigasi panah kiri/kanan,
/// ringkasan kuesioner 2 kolom, dan kartu catatan bergaris dengan mascot di kanan bawah.
struct JourneyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let journey: SkincareJourney
    let hideProgressBar: Bool
    let onSkipToMilestoneOne: () -> Void
    let onSkipToMilestoneTwo: () -> Void
    @State private var selectedIndex: Int

    init(
            journey: SkincareJourney,
            initialIndex: Int? = nil,
            hideProgressBar: Bool = false,
            onSkipToMilestoneOne: @escaping () -> Void = {},
            onSkipToMilestoneTwo: @escaping () -> Void = {}
        ) {
            self.journey = journey
            self.hideProgressBar = hideProgressBar
            self.onSkipToMilestoneOne = onSkipToMilestoneOne
            self.onSkipToMilestoneTwo = onSkipToMilestoneTwo
        let defaultIndex = max(0, journey.journalEntries.count - 1)
        _selectedIndex = State(initialValue: initialIndex ?? defaultIndex)
    }

    private var entries: [JournalEntry] {
        journey.journalEntries.isEmpty
            ? [JournalEntry(date: Date(), note: "hari ini kulitku kayak gemoy gitu, suka!!\n\nmungkin karena aku rajin pake night cream.", skinCondition: "Slightly Better", howItFeels: "Feels comfortable", whatYouNoticed: "Dryness")]
            : journey.journalEntries
    }

    private var currentEntry: JournalEntry {
        let validIndex = max(0, min(entries.count - 1, selectedIndex))
        return entries[validIndex]
    }

    private var currentPhotoName: String? {
        if let imageName = currentEntry.imageName, !imageName.isEmpty {
            return imageName
        }
        if !journey.progressPhotos.isEmpty {
            let validIndex = max(0, min(journey.progressPhotos.count - 1, selectedIndex))
            return journey.progressPhotos[validIndex].imageName
        }
        return nil
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
                // Top Bar with Back Button & Milestone Title
                VStack(spacing: 12) {
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        Spacer()
                        if DemoConfiguration.isEnabled {
                            demoSkipButtons
                        }
                    }
                    

                    Text("Milestone #\(currentMilestoneOrder)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                }
                .padding(.horizontal, 24)

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
                            .disabled(selectedIndex <= 0)

                            // Center Captured Photo Frame with Date Pill Overlay & Product Name
                            ZStack(alignment: .bottomTrailing) {
                                if let photoName = currentPhotoName,
                                   let uiImage = CameraViewModel.loadImage(named: photoName) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 250, height: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                } else {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
                                        .overlay(
                                            FaceOutline()
                                                .padding(24)
                                        )
                                        .frame(width: 250, height: 250)
                                }

                                // Product Name Overlay at Top Left
                                Text(journey.product.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .shadow(color: Color.black.opacity(0.6), radius: 3, x: 0, y: 1)
                                    .padding(14)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                                // Date Pill Overlay at Bottom Right
                                Text(formattedDate(currentEntry.date))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.85))
                                    .clipShape(Capsule())
                                    .padding(14)
                            }
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color(red: 0.22, green: 0.43, blue: 0.65), lineWidth: 3.5)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                            // Right Arrow Button
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                withAnimation {
                                    selectedIndex = min(entries.count - 1, selectedIndex + 1)
                                }
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .opacity(selectedIndex < entries.count - 1 ? 1.0 : 0.35)
                            }
                            .disabled(selectedIndex >= entries.count - 1)
                        }
                        .padding(.horizontal, 16)

                        // Questionnaire Results Summary (2 Columns)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 24) {
                                Text("Skin Condition")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .frame(width: 140, alignment: .leading)

                                Text(currentEntry.skinCondition ?? "Slightly Better")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack(alignment: .top, spacing: 24) {
                                Text("How It Feels")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .frame(width: 140, alignment: .leading)

                                Text(currentEntry.howItFeels ?? "Feels comfortable")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack(alignment: .top, spacing: 24) {
                                Text("What You Noticed")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .frame(width: 140, alignment: .leading)

                                Text(currentEntry.whatYouNoticed ?? "Dryness")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 4)

                        // Prompt Question Header
                        Text("How's your skin condition?")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .padding(.top, 4)

                        // Yellow Ruled Paper Note Box with Mascot Overlaid at Bottom Right
                        ZStack(alignment: .bottomTrailing) {
                            YellowRuledPaperReadOnlyBox(
                                text: currentEntry.note.isEmpty
                                    ? "hari ini kulitku kayak gemoy gitu, suka!!\n\nmungkin karena aku rajin pake night cream."
                                    : currentEntry.note
                            )

                            // Mascot Character Graphic Overlaid at Bottom Right
                            MascotLottieView(width: 150)
                                .accessibilityHidden(true)
                                .offset(x: 130, y: 50)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 36)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var demoSkipButtons: some View {
            HStack(spacing: 8) {
                demoSkipButton(
                    title: "To M1",
                    foregroundColor: .white,
                    backgroundColor: OnboardingStyle.buttonBlue,
                    action: onSkipToMilestoneOne
                )

                demoSkipButton(
                    title: "To M2",
                    foregroundColor: OnboardingStyle.primaryBlue,
                    backgroundColor: OnboardingStyle.noteYellow,
                    action: onSkipToMilestoneTwo
                )
            }
        }

        private func demoSkipButton(
            title: String,
            foregroundColor: Color,
            backgroundColor: Color,
            action: @escaping () -> Void
        ) -> some View {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            } label: {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(foregroundColor)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(backgroundColor)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(OnboardingStyle.primaryBlue, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip to \(title == "To M1" ? "Milestone 1" : "Milestone 2") completion")
        }
    
    private var currentMilestoneOrder: Int {
        journey.milestones.first { !$0.isCompleted }?.order ?? 1
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Read-Only Yellow Ruled Paper Box Component
private struct YellowRuledPaperReadOnlyBox: View {
    let text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Warm yellow pastel background
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))

            // Lined paper rules
            VStack(spacing: 0) {
                Spacer().frame(height: 38)
                ForEach(0..<4, id: \.self) { _ in
                    Divider()
                        .background(Color(red: 0.82, green: 0.72, blue: 0.52).opacity(0.6))
                    Spacer().frame(height: 35)
                }
            }
            .padding(.horizontal, 20)

            // Text content
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .lineSpacing(14)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.trailing, 80) // Leave space so text doesn't hide behind mascot
        }
        .frame(minHeight: 150)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Journal Timeline Header Component (Carousel Indicator Index-Mapped Dashed Line)
private struct JournalTimelineHeader: View {
    let milestoneNumber: Int
    let totalEntries: Int
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if milestoneNumber == 1 {
                // Milestone #1: 14 Total Carousel Items (Index 0 = Bottle, Indices 1..12 = 12 Dashes, Index 13 = Flag)
                let dashCount = 12

                // 1. Bottle Node (Carousel Index 0)
                Button {
                    selectNode(0)
                } label: {
                    CircleNodeIconView(
                        iconName: "jar.fill",
                        isBottle: true,
                        isSelected: selectedIndex == 0,
                        isReached: totalEntries > 0
                    )
                }
                .buttonStyle(.plain)

                // 2. Middle 12 Dashes (Carousel Indices 1 to 12)
                HStack(spacing: 3) {
                    ForEach(0..<dashCount, id: \.self) { dashIdx in
                        let itemIndex = dashIdx + 1
                        let isSelected = selectedIndex == itemIndex
                        let isReached = itemIndex < totalEntries
                        let isAvailable = itemIndex < totalEntries

                        Button {
                            selectNode(itemIndex)
                        } label: {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(
                                    isSelected
                                        ? Color(red: 0.16, green: 0.35, blue: 0.54) // Darkest Blue Highlighted
                                        : (isReached
                                            ? Color(red: 0.22, green: 0.43, blue: 0.65) // Dark Blue Active Reached
                                            : Color(red: 0.74, green: 0.88, blue: 0.98)) // Light Ice Blue Inactive
                                )
                                .frame(height: isSelected ? 7 : 5)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isAvailable && !isSelected)
                    }
                }
                .frame(maxWidth: .infinity)

                // 3. Flag Node (Carousel Index 13)
                Button {
                    selectNode(13)
                } label: {
                    FlagNodeIconView(
                        isSelected: selectedIndex == 13,
                        isReached: totalEntries >= 14
                    )
                }
                .buttonStyle(.plain)

            } else {
                // Milestone #2: 5 Checkpoint Nodes (Indices 0, 3, 6, 9, 12) with 2 Dashes between each
                ForEach(0..<5, id: \.self) { nodeIdx in
                    let checkpointItemIndex = nodeIdx * 3
                    let isSelected = selectedIndex == checkpointItemIndex
                    let isReached = totalEntries > checkpointItemIndex

                    Button {
                        selectNode(checkpointItemIndex)
                    } label: {
                        if nodeIdx == 0 {
                            CircleNodeIconView(
                                iconName: "jar.fill",
                                isBottle: true,
                                isSelected: isSelected,
                                isReached: isReached
                            )
                        } else {
                            FlagNodeIconView(
                                isSelected: isSelected,
                                isReached: isReached
                            )
                        }
                    }
                    .buttonStyle(.plain)

                    if nodeIdx < 4 {
                        // 2 connector dashes between checkpoint nodes
                        HStack(spacing: 2) {
                            ForEach(1...2, id: \.self) { dashOffset in
                                let dashItemIndex = checkpointItemIndex + dashOffset
                                let isDashSelected = selectedIndex == dashItemIndex
                                let isDashReached = dashItemIndex < totalEntries
                                let isDashAvailable = dashItemIndex < totalEntries

                                Button {
                                    selectNode(dashItemIndex)
                                } label: {
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(
                                            isDashSelected
                                                ? Color(red: 0.16, green: 0.35, blue: 0.54)
                                                : (isDashReached
                                                    ? Color(red: 0.22, green: 0.43, blue: 0.65)
                                                    : Color(red: 0.74, green: 0.88, blue: 0.98))
                                        )
                                        .frame(height: isDashSelected ? 7 : 5)
                                }
                                .buttonStyle(.plain)
                                .disabled(!isDashAvailable && !isDashSelected)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(height: 38)
        .padding(.horizontal, 24)
    }

    private func selectNode(_ index: Int) {
        guard index < totalEntries else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedIndex = index
        }
    }
}

private struct CircleNodeIconView: View {
    let iconName: String
    let isBottle: Bool
    let isSelected: Bool
    let isReached: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    isReached || isSelected
                        ? Color(red: 0.22, green: 0.43, blue: 0.65)
                        : Color(red: 0.74, green: 0.88, blue: 0.98)
                )
                .frame(width: isSelected ? 36 : 32, height: isSelected ? 36 : 32)
                .shadow(
                    color: isSelected ? Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.35) : Color.clear,
                    radius: 5, x: 0, y: 2
                )

            Image(systemName: iconName)
                .font(.system(size: isSelected ? 15 : 13, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(width: 36, height: 36)
        .contentShape(Rectangle())
    }
}

private struct FlagNodeIconView: View {
    let isSelected: Bool
    let isReached: Bool

    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color(red: 0.22, green: 0.43, blue: 0.65))
                    .frame(width: 36, height: 36)
                    .shadow(color: Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.35), radius: 5, x: 0, y: 2)

                Image(systemName: "flag.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(red: 0.82, green: 0.91, blue: 0.99))
            } else {
                Image(systemName: "flag.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        isReached
                            ? Color(red: 0.22, green: 0.43, blue: 0.65)
                            : Color(red: 0.74, green: 0.88, blue: 0.98)
                    )
            }
        }
        .frame(width: 36, height: 36)
        .contentShape(Rectangle())
    }
}

#Preview {
    JourneyDetailView(journey: SkincareJourney(product: SkincareProduct.samples[0]))
}
