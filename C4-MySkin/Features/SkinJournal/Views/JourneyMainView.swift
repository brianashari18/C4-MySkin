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
    let onChooseProduct: () -> Void
    let onViewDetail: () -> Void
    let onViewHistory: () -> Void
    let onViewCalendar: () -> Void

    init(
        journey: SkincareJourney,
        isJourneyActive: Bool = false,
        onAddImage: @escaping () -> Void,
        onChooseProduct: @escaping () -> Void = {},
        onViewDetail: @escaping () -> Void = {},
        onViewHistory: @escaping () -> Void = {},
        onViewCalendar: @escaping () -> Void = {}
    ) {
        self.journey = journey
        self.isJourneyActive = isJourneyActive
        self.onAddImage = onAddImage
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
                        // Photo box: empty state placeholder vs timelapse INLINE
                        // (auto-play 2×, tanggal kanan bawah, produk kiri atas)
                        if journey.progressPhotos.isEmpty {
                            ProgressPhotoCard(imageName: nil)
                                .padding(.horizontal, 28)
                                .padding(.top, 16)
                        } else {
                            PhotoTimelapseCard(
                                photos: journey.progressPhotos,
                                productName: journey.product.name
                            )
                            .padding(.horizontal, 28)
                            .padding(.top, 16)
                        }

                        // Add Photos Pill Button
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            if isJourneyActive {
                                onAddImage()
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    showNoJourneyPrompt = true
                                }
                            }
                        }) {
                            Text("Add Photos")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 200, height: 48)
                                .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                                .clipShape(Capsule())
                                .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add Photos")
                        .padding(.top, 4)

                        // Bottom Card: Add Skincare Journey (Empty) vs Active & Upcoming Milestone Cards
                        if isJourneyActive {
                            Divider()
                                .background(Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.3))
                                .padding(.horizontal, 24)
                                .padding(.top, 8)

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

                            VStack(spacing: 16) {
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    if !journey.journalEntries.isEmpty {
                                        onViewDetail()
                                    } else {
                                        onAddImage()
                                    }
                                }) {
                                    ActiveMilestoneCard(journey: journey)
                                }
                                .buttonStyle(.plain)

                                UpcomingMilestoneCard(milestoneNumber: 2)
                            }
                            .padding(.horizontal, 24)
                        } else {
                            // Empty state: klik container → pilih produk dulu → balik ke halaman ini
                            VStack(spacing: 16) {
                                AddSkincareJourneyCard(onTap: onChooseProduct)

                                if showNoJourneyPrompt {
                                    NoJourneyToastCard()
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
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
            .frame(height: 150)
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

// MARK: - Upcoming / Locked Milestone Card (Milestone #2)
private struct UpcomingMilestoneCard: View {
    let milestoneNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. "Upcoming" Badge Pill
            Text("Upcoming")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.45, green: 0.45, blue: 0.45))
                .clipShape(Capsule())

            // 2. Milestone Title (Muted Dark Gray)
            Text("Milestone #\(milestoneNumber)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(red: 0.40, green: 0.40, blue: 0.40))

            // 3. Timeline Row: Jar Icon --- Dashed Line --- Flags (Locked Gray)
            HStack(spacing: 8) {
                // Jar icon node (gray)
                ZStack {
                    Circle()
                        .fill(Color(white: 0.65))
                        .frame(width: 36, height: 36)

                    Image(systemName: "jar.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white)
                }

                DashedGrayConnector()

                Image(systemName: "flag.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(white: 0.65))

                DashedGrayConnector()

                Image(systemName: "flag.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(white: 0.65))

                DashedGrayConnector()

                Image(systemName: "flag.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(white: 0.65))

                DashedGrayConnector()

                Image(systemName: "flag.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(white: 0.65))
            }
            .frame(height: 36)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.72, green: 0.72, blue: 0.72))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
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
                    .font(.system(size: 15, weight: .bold))
                Text("History")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
            .padding(.horizontal, 14)
            .frame(height: 42)
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

#Preview("Empty State") {
    JourneyMainView(
        journey: SkincareJourney(product: SkincareProduct.samples[0]),
        isJourneyActive: false,
        onAddImage: {}
    )
}

#Preview("Active State") {
    JourneyMainView(
        journey: SkincareJourney(product: SkincareProduct.samples[0]),
        isJourneyActive: true,
        onAddImage: {}
    )
}


