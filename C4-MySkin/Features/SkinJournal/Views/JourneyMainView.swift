//
//  JourneyMainView.swift
//  C4-MySkin
//

import SwiftUI

struct JourneyMainView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showNoJourneyPrompt = false

    let journey: SkincareJourney
    let isJourneyActive: Bool
    let onAddImage: () -> Void
    let onStartAssessment: () -> Void
    let onChooseProduct: () -> Void
    let onViewDetail: () -> Void
    let onViewHistory: () -> Void
    let onViewCalendar: () -> Void

    init(
        journey: SkincareJourney,
        isJourneyActive: Bool = false,
        onAddImage: @escaping () -> Void = {},
        onStartAssessment: @escaping () -> Void = {},
        onChooseProduct: @escaping () -> Void = {},
        onViewDetail: @escaping () -> Void = {},
        onViewHistory: @escaping () -> Void = {},
        onViewCalendar: @escaping () -> Void = {}
    ) {
        self.journey = journey
        self.isJourneyActive = isJourneyActive
        self.onAddImage = onAddImage
        self.onStartAssessment = onStartAssessment
        self.onChooseProduct = onChooseProduct
        self.onViewDetail = onViewDetail
        self.onViewHistory = onViewHistory
        self.onViewCalendar = onViewCalendar
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
                // Top Bar with Back Button, Calendar Button, History Button & Title
                VStack(spacing: 12) {
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            CalendarButton {
                                onViewCalendar()
                            }
                            HistoryButton {
                                onViewHistory()
                            }
                        }
                    }

                    Text("Your skin from time to time")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                }
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Photo box: empty state placeholder ("no photos yet") vs captured photo / timelapse
                        if journey.progressPhotos.isEmpty {
                            ProgressPhotoCard(imageName: nil)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                        } else {
                            PhotoTimelapseCard(
                                photos: journey.progressPhotos,
                                productName: journey.product.name
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }

                        // Middle Container: Milestone Card (bila foto sudah di-capture atau journey aktif) vs AddSkincareJourneyCard (bila awal)
                        let isMilestoneActive = isJourneyActive || !journey.progressPhotos.isEmpty
                        if isMilestoneActive {
                            Divider()
                                .background(Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.3))
                                .padding(.horizontal, 24)
                                .padding(.top, 8)

                            if !journey.journalEntries.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Skincare Journey")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

                                    Text(journey.product.name)
                                        .font(.system(size: 19, weight: .bold))
                                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                            }

                            VStack(spacing: 16) {
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    if !journey.journalEntries.isEmpty {
                                        onViewDetail()
                                    } else {
                                        onStartAssessment()
                                    }
                                }) {
                                    ActiveMilestoneCard(journey: journey)
                                }
                                .buttonStyle(.plain)

                            if !journey.journalEntries.isEmpty {
                                UpcomingMilestoneCard(milestoneNumber: 2, startDate: journey.startDate)
                            }
                            }
                            .padding(.horizontal, 24)
                        } else {
                            // Empty / Initial state: container kuning "add your skincare journey"
                            VStack(spacing: 16) {
                                AddSkincareJourneyCard(onTap: onChooseProduct)

                                if showNoJourneyPrompt {
                                    NoJourneyToastCard()
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }

                        // Start Journey CTA Button: Hanya tampil SEBELUM config awal jurnal diselesaikan & di-save!
                        if journey.journalEntries.isEmpty {
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                if isMilestoneActive {
                                    onStartAssessment()
                                }
                            }) {
                                Text("Start Journey")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        isMilestoneActive
                                            ? Color(red: 0.38, green: 0.61, blue: 0.93)
                                            : Color(red: 0.72, green: 0.76, blue: 0.82)
                                    )
                                    .clipShape(Capsule())
                                    .shadow(
                                        color: isMilestoneActive
                                            ? Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3)
                                            : Color.clear,
                                        radius: 6, x: 0, y: 3
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(!isMilestoneActive)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }

                        Spacer(minLength: 24)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var currentMilestoneOrder: Int {
        journey.milestones.first { !$0.isCompleted }?.order ?? 1
    }
}


// MARK: - Add Skincare Journey Card (Empty State)
private struct AddSkincareJourneyCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onTap()
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.23, green: 0.46, blue: 0.69))
                        .frame(width: 44, height: 44)

                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                }

                Text("add your skincare journey")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.15, green: 0.33, blue: 0.50))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 195)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.99, green: 0.90, blue: 0.66))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - No Journey Toast Card
private struct NoJourneyToastCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("You should add your journey first!")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.white)

            Text("tap button “add your skincare journey” to begin")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.95))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.48, green: 0.48, blue: 0.48))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Upcoming / Locked Milestone Card (Milestone #2 - 4 Flags)
private struct UpcomingMilestoneCard: View {
    let milestoneNumber: Int
    var startDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. "Upcoming" Badge Pill
            Text("Upcoming")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.55, green: 0.62, blue: 0.70))
                .clipShape(Capsule())

            // 2. Milestone Title (Muted Dark Gray)
            Text("Milestone #\(milestoneNumber)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(red: 0.35, green: 0.42, blue: 0.50))

            // 3. Timeline Layout: 4 Flags (Start: +2 minggu dari M1 start, Finish: in 8 weeks)
            HStack(alignment: .top, spacing: 4) {
                // Jar icon node (gray)
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.65, green: 0.72, blue: 0.80))
                            .frame(width: 44, height: 44)

                        Image(systemName: "jar.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.white)
                    }

                    VStack(spacing: 1) {
                        Text("Start")
                            .font(.system(size: 12, weight: .bold))
                        Text(formattedDate(startDate.addingTimeInterval(14 * 86400)))
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Color(red: 0.55, green: 0.62, blue: 0.70))
                }

                Spacer(minLength: 0)

                ForEach(1...4, id: \.self) { flagIndex in
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color(red: 0.78, green: 0.83, blue: 0.90))
                                .frame(width: 8, height: 4)
                        }
                    }
                    .frame(height: 44)

                    Spacer(minLength: 0)

                    VStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(Color(red: 0.65, green: 0.72, blue: 0.80))
                            .frame(height: 44)

                        if flagIndex == 4 {
                            VStack(spacing: 1) {
                                Text("Results")
                                    .font(.system(size: 12, weight: .bold))
                                Text("in 8 weeks")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(Color(red: 0.55, green: 0.62, blue: 0.70))
                        }
                    }

                    if flagIndex < 4 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .frame(height: 195) // SAKLAK: 195pt identik dengan Milestone 1
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.88, green: 0.90, blue: 0.93))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

private struct DashedGrayConnector: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 1.5))
            path.addLine(to: CGPoint(x: 18, y: 1.5))
        }
        .stroke(
            Color(white: 0.85),
            style: StrokeStyle(lineWidth: 2, dash: [4, 3])
        )
        .frame(width: 18, height: 3)
    }
}


private struct DashedLineView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
            }
            .stroke(
                Color(red: 0.15, green: 0.33, blue: 0.50),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 3])
            )
        }
    }
}

// MARK: - Calendar Top Bar Icon Button Component
private struct CalendarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: "calendar")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .stroke(Color(red: 0.11, green: 0.27, blue: 0.42), lineWidth: 2)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Calendar")
    }
}

// MARK: - History Top Bar Button Component
private struct HistoryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
            .padding(.horizontal, 14)
            .frame(width: 42, height: 42)
            .background(
                Capsule()
                    .stroke(Color(red: 0.11, green: 0.27, blue: 0.42), lineWidth: 2)
                    .background(Capsule().fill(Color.white.opacity(0.9)))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("History")
    }
}

private extension SkincareJourney {
    static var sampleMilestone1: SkincareJourney {
        var j = SkincareJourney(product: SkincareProduct.samples[0])
        j.journalEntries = [
            JournalEntry(date: Date(), note: "Awal pemakaian produk baru.")
        ]
        j.progressPhotos = [
            ProgressPhoto(date: Date(), imageName: "sample_1", milestoneOrder: 1)
        ]
        return j
    }

    static var sampleMilestone2: SkincareJourney {
        var j = SkincareJourney(product: SkincareProduct.samples[0])
        if !j.milestones.isEmpty {
            j.milestones[0].isCompleted = true
        }
        j.journalEntries = [
            JournalEntry(date: Date(), note: "Progress hari ini bagus banget! Kulit terasa lembab."),
            JournalEntry(date: Date().addingTimeInterval(86400 * 3), note: "Sore ini habis panas-panasan tapi tidak iritasi.")
        ]
        j.progressPhotos = [
            ProgressPhoto(date: Date(), imageName: "sample_1", milestoneOrder: 1),
            ProgressPhoto(date: Date().addingTimeInterval(86400 * 3), imageName: "sample_2", milestoneOrder: 2)
        ]
        return j
    }
}

#Preview("Empty State") {
    JourneyMainView(
        journey: SkincareJourney(product: SkincareProduct.samples[0]),
        isJourneyActive: false
    )
}

#Preview("Active State (Milestone 1)") {
    JourneyMainView(
        journey: .sampleMilestone1,
        isJourneyActive: true
    )
}

#Preview("Milestone 2 State") {
    JourneyMainView(
        journey: .sampleMilestone2,
        isJourneyActive: true
    )
}


