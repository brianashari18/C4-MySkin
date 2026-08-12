//
//  JourneyDetailView.swift
//  C4-MySkin
//

import SwiftUI

/// Detail riwayat jurnal untuk sebuah skincare journey.
struct JourneyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let journey: SkincareJourney
    let hideProgressBar: Bool
    @State private var selectedIndex: Int

    init(journey: SkincareJourney, initialIndex: Int? = nil, hideProgressBar: Bool = false) {
        self.journey = journey
        self.hideProgressBar = hideProgressBar
        let defaultIndex = max(0, journey.journalEntries.count - 1)
        _selectedIndex = State(initialValue: initialIndex ?? defaultIndex)
    }

    private var entries: [JournalEntry] {
        journey.journalEntries.isEmpty
            ? [JournalEntry(
                date: Date(),
                note: "Belum ada catatan untuk perjalanan ini.",
                skinCondition: "-",
                howItFeels: "-",
                whatYouNoticed: "-"
            )]
            : journey.journalEntries
    }

    private var currentEntry: JournalEntry {
        entries[max(0, min(entries.count - 1, selectedIndex))]
    }

    private var currentPhotoName: String? {
        if let imageName = currentEntry.imageName, !imageName.isEmpty {
            return imageName
        }

        guard !journey.progressPhotos.isEmpty else { return nil }
        let validIndex = max(0, min(journey.progressPhotos.count - 1, selectedIndex))
        return journey.progressPhotos[validIndex].imageName
    }

    private var currentMilestoneOrder: Int {
        journey.milestones.first { !$0.isCompleted }?.order
            ?? journey.milestones.last?.order
            ?? 1
    }

    var body: some View {
        ZStack {
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
                VStack(spacing: 12) {
                    HStack {
                        BackButton { dismiss() }
                        Spacer()
                    }

                    Text("Milestone #\(currentMilestoneOrder)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                }
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if !hideProgressBar {
                            JournalTimelineHeader(
                                milestoneNumber: currentMilestoneOrder,
                                totalEntries: entries.count,
                                selectedIndex: $selectedIndex
                            )
                            .padding(.top, 12)
                        }

                        photoPager
                            .padding(.horizontal, 16)

                        questionnaireSummary
                            .padding(.horizontal, 32)
                            .padding(.top, 4)

                        Text("How's your skin condition?")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .padding(.top, 4)

                        ZStack(alignment: .bottomTrailing) {
                            YellowRuledPaperReadOnlyBox(text: currentEntry.note)

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
        .onChange(of: entries.count) { _, count in
            selectedIndex = max(0, min(selectedIndex, count - 1))
        }
    }

    private var photoPager: some View {
        HStack(spacing: 12) {
            pagingButton(
                systemName: "chevron.left.circle.fill",
                isEnabled: selectedIndex > 0
            ) {
                selectedIndex = max(0, selectedIndex - 1)
            }

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
                        .overlay(FaceOutline().padding(24))
                        .frame(width: 250, height: 250)
                }

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

            pagingButton(
                systemName: "chevron.right.circle.fill",
                isEnabled: selectedIndex < entries.count - 1
            ) {
                selectedIndex = min(entries.count - 1, selectedIndex + 1)
            }
        }
    }

    private func pagingButton(
        systemName: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation { action() }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                .opacity(isEnabled ? 1 : 0.35)
        }
        .disabled(!isEnabled)
    }

    private var questionnaireSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            summaryRow(label: "Skin Condition", value: currentEntry.skinCondition ?? "-")
            summaryRow(label: "How It Feels", value: currentEntry.howItFeels ?? "-")
            summaryRow(label: "What You Noticed", value: currentEntry.whatYouNoticed ?? "-")
        }
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 24) {
            Text(label)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                .frame(width: 140, alignment: .leading)

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

private struct YellowRuledPaperReadOnlyBox: View {
    let text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))

            VStack(spacing: 0) {
                Spacer().frame(height: 38)
                ForEach(0..<4, id: \.self) { _ in
                    Divider()
                        .background(Color(red: 0.82, green: 0.72, blue: 0.52).opacity(0.6))
                    Spacer().frame(height: 35)
                }
            }
            .padding(.horizontal, 20)

            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .lineSpacing(14)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.trailing, 80)
        }
        .frame(minHeight: 150)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

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

                HStack {
                    ForEach(0..<nodeCount, id: \.self) { nodeIndex in
                        let iconName = nodeIndex == 0 ? "jar.fill" : "flag.fill"
                        let isSelected = nodeIndex == selectedIndex
                        let isAvailable = nodeIndex < totalEntries

                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            let targetIndex = min(nodeIndex, max(0, totalEntries - 1))
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedIndex = targetIndex
                            }
                        } label: {
                            CircleIconNode(
                                iconName: iconName,
                                isSelected: isSelected,
                                isAvailable: isAvailable
                            )
                        }
                        .buttonStyle(.plain)

                        if nodeIndex < nodeCount - 1 { Spacer() }
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
                        : (isAvailable
                            ? Color(red: 0.74, green: 0.83, blue: 0.93)
                            : Color(red: 0.88, green: 0.90, blue: 0.93))
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
                        : (isAvailable
                            ? Color(red: 0.16, green: 0.35, blue: 0.54)
                            : Color(red: 0.60, green: 0.68, blue: 0.76))
                )
        }
        .frame(width: 42, height: 42)
        .contentShape(Rectangle())
    }
}

#Preview {
    JourneyDetailView(journey: SkincareJourney(product: SkincareProduct.samples[0]))
}
