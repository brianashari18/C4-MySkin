//
//  JournalEntryView.swift
//  C4-MySkin
//

import SwiftUI

struct JournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var note: String = ""
    let milestoneTitle: String?
    let imageName: String?
    let skinCondition: String
    let howItFeels: String
    let whatYouNoticed: String

    let onSave: (JournalEntry) -> Void
    let onBack: () -> Void

    init(
        milestoneTitle: String?,
        imageName: String? = nil,
        skinCondition: String = "Slightly Better",
        howItFeels: String = "Feels comfortable",
        whatYouNoticed: String = "Dryness",
        initialNote: String = "",
        onSave: @escaping (JournalEntry) -> Void,
        onBack: @escaping () -> Void
    ) {
        self.milestoneTitle = milestoneTitle
        self.imageName = imageName
        self.skinCondition = skinCondition
        self.howItFeels = howItFeels
        self.whatYouNoticed = whatYouNoticed
        self.onSave = onSave
        self.onBack = onBack
        _note = State(initialValue: initialNote)
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
                // Top Bar with Back Button & Milestone Title (matching Main Page header top padding)
                VStack(spacing: 12) {
                    HStack {
                        BackButton(action: onBack)
                        Spacer()
                    }

                    Text(milestoneTitle ?? "Milestone #1")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                }
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Timeline Progress Indicator Bar
                        JournalTimelineHeader()
                            .padding(.top, 12)

                        // Center Captured Photo Frame with Date Pill Overlay
                        ZStack(alignment: .bottomTrailing) {
                            if let imageName, !imageName.isEmpty, let uiImage = CameraViewModel.loadImage(named: imageName) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 280, height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            } else {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white)
                                    .overlay(
                                        FaceOutline()
                                            .padding(24)
                                    )
                                    .frame(width: 280, height: 280)
                            }

                            // Date Pill Overlay at Bottom Right
                            Text(formattedCurrentDate)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.85))
                                .clipShape(Capsule())
                                .padding(14)
                        }
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color(red: 0.22, green: 0.43, blue: 0.65), lineWidth: 3.5)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                        // Questionnaire Results Summary (Aligned matching reference image)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 24) {
                                Text("Skin Condition")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .frame(width: 140, alignment: .leading)

                                Text(skinCondition)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack(alignment: .top, spacing: 24) {
                                Text("How It Feels")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .frame(width: 140, alignment: .leading)

                                Text(howItFeels)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack(alignment: .top, spacing: 24) {
                                Text("What You Noticed")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                                    .frame(width: 140, alignment: .leading)

                                Text(whatYouNoticed)
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

                        // Responsive Yellow Ruled Paper Editor
                        YellowRuledPaperEditor(text: $note)
                            .padding(.horizontal, 24)

                        // Save Bottom CTA Button
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            let entry = JournalEntry(
                                date: Date(),
                                note: note,
                                mood: .comfortable,
                                quickTags: []
                            )
                            onSave(entry)
                        }) {
                            Text("Save")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                                .clipShape(Capsule())
                                .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Journal Timeline Header Component
private struct JournalTimelineHeader: View {
    var body: some View {
        ZStack {
            // Background Progress Bar Slider Track (matching Main Page style)
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let fillWidth = totalWidth * 0.50 // Filled up to current active step (smile face)

                ZStack(alignment: .leading) {
                    // Background Track
                    Capsule()
                        .fill(Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.20))
                        .frame(height: 7)

                    // Filled Dark Blue Progress Bar
                    Capsule()
                        .fill(Color(red: 0.16, green: 0.35, blue: 0.54))
                        .frame(width: fillWidth, height: 7)

                    // Active Progress Dot (matching QuestionnaireStepSlider & Main Page)
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .frame(width: 14, height: 14)

                        Circle()
                            .stroke(Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.5), lineWidth: 3)
                            .frame(width: 20, height: 20)
                    }
                    .offset(x: max(0, fillWidth - 10))
                }
                .frame(width: totalWidth, height: 36, alignment: .center)
            }
            .padding(.horizontal, 16)

            // Timeline Icon Nodes (Jar, Flags, Smile Face overlayed on top)
            HStack {
                CircleIconNode(iconName: "jar.fill", isActive: false)
                Spacer()
                CircleIconNode(iconName: "flag.fill", isActive: false)
                Spacer()
                CircleIconNode(iconName: "face.smiling.fill", isActive: true)
                Spacer()
                CircleIconNode(iconName: "flag.fill", isActive: false)
                Spacer()
                CircleIconNode(iconName: "flag.fill", isActive: false)
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 36)
        .padding(.horizontal, 28)
    }
}

private struct CircleIconNode: View {
    let iconName: String
    var isActive: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(isActive ? Color(red: 0.16, green: 0.35, blue: 0.54) : Color(red: 0.82, green: 0.90, blue: 0.98))
                .frame(width: 34, height: 34)

            Image(systemName: iconName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(isActive ? Color.white : Color(red: 0.38, green: 0.61, blue: 0.93))
        }
    }
}

private struct DashedConnector: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 1.5))
            path.addLine(to: CGPoint(x: 18, y: 1.5))
        }
        .stroke(
            Color(red: 0.70, green: 0.82, blue: 0.94),
            style: StrokeStyle(lineWidth: 2, dash: [3, 2])
        )
        .frame(width: 18, height: 3)
    }
}

#Preview {
    JournalEntryView(
        milestoneTitle: "Milestone 1",
        onSave: { _ in },
        onBack: {}
    )
}

