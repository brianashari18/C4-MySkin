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

                            // Center Captured Photo Frame with Date Pill Overlay
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
    JourneyDetailView(journey: SkincareJourney(product: SkincareProduct.samples[0]))
}
