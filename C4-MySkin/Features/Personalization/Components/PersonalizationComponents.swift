//
//  PersonalizationComponents.swift
//  C4-MySkin
//
//  Created by Codex on 11/08/26.
//

import SwiftUI

struct PersonalizationProgressHeader: View {
    let section: PersonalizationSection
    var fillsCurrentMilestone: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let steps = PersonalizationSection.visibleProgressSections
            let activeIndex = section.progressIndex
            let trackWidth = geometry.size.width
            let milestoneStart = trackWidth * 0.22
            let milestoneEnd = trackWidth * 0.78
            let milestoneSpan = milestoneEnd - milestoneStart
            let lastIndex = max(steps.count - 1, 1)
            let milestoneX = milestoneStart + milestoneSpan * CGFloat(activeIndex) / CGFloat(lastIndex)
            let progressWidth = activeIndex == lastIndex && fillsCurrentMilestone
                ? trackWidth
                : milestoneX - (section == .skinConcern ? 11 : 0)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.82))
                    .frame(height: 8)
                    .overlay {
                        Capsule()
                            .strokeBorder(OnboardingStyle.primaryBlue.opacity(0.08), lineWidth: 1)
                    }
                    .shadow(color: OnboardingStyle.controlShadow.opacity(0.16), radius: 7, y: 3)

                Capsule()
                    .fill(OnboardingStyle.buttonBlue)
                    .frame(width: max(progressWidth, 16), height: 8)

                ForEach(steps.indices, id: \.self) { index in
                    let isCompleted = fillsCurrentMilestone ? index <= activeIndex : index < activeIndex

                    ZStack {
                        Circle()
                            .fill(isCompleted ? OnboardingStyle.primaryBlue : Color.white)
                            .frame(width: 22, height: 22)

                        Circle()
                            .fill(isCompleted ? OnboardingStyle.buttonBlue : OnboardingStyle.backgroundTop)
                            .frame(width: 14, height: 14)
                    }
                        .shadow(color: OnboardingStyle.controlShadow.opacity(isCompleted ? 0.18 : 0.12), radius: 5, y: 2)
                        .position(
                            x: milestoneStart + milestoneSpan * CGFloat(index) / CGFloat(lastIndex),
                            y: 13
                        )
                }
            }
            .frame(height: 26)
            .animation(.snappy(duration: 0.24), value: section)
        }
        .frame(width: 260, height: 30)
        .frame(maxWidth: .infinity)
        .padding(.top, 42)
        .accessibilityLabel("Langkah \(section.progressIndex + 1) dari \(PersonalizationSection.visibleProgressSections.count)")
    }
}

struct PersonalizationSideNavigation: View {
    let canGoBack: Bool
    let canAdvance: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        GeometryReader { geometry in
            PersonalizationSideNavigationButton(
                systemName: "chevron.left",
                isEnabled: canGoBack,
                edge: .left,
                action: onBack
            )
            .position(x: 14, y: geometry.size.height * 0.51)

            PersonalizationSideNavigationButton(
                systemName: "chevron.right",
                isEnabled: canAdvance,
                edge: .right,
                action: onNext
            )
            .position(x: geometry.size.width - 14, y: geometry.size.height * 0.51)
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
    }
}

private struct PersonalizationSideNavigationButton: View {
    let systemName: String
    let isEnabled: Bool
    let edge: SideNavigationEdge
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: edge.alignment) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: 76, height: 44)
                    .background {
                        Capsule()
                            .fill(Color.white.opacity(0.34))
                    }
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.72), lineWidth: 1)
                    }
                    .overlay {
                        Capsule()
                            .stroke(OnboardingStyle.controlShadow.opacity(0.20), lineWidth: 1)
                            .blur(radius: 2)
                            .offset(x: 0, y: 1)
                            .mask {
                                Capsule()
                                    .fill(Color.black)
                            }
                    }
                    .shadow(color: OnboardingStyle.controlShadow.opacity(0.20), radius: 2, x: 0, y: 1)

                Image(systemName: systemName)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(isEnabled ? OnboardingStyle.buttonBlue : Color.white.opacity(0.68))
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.94), lineWidth: 3)
                    }
                    .shadow(color: OnboardingStyle.controlShadow.opacity(0.10), radius: 5, y: 2)
                    .padding(edge.paddingEdge, 10)
                    .foregroundStyle(isEnabled ? .white : OnboardingStyle.buttonBlue.opacity(0.50))
                }
            .frame(width: 76, height: 44)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(systemName == "chevron.left" ? "Kembali" : "Lanjut")
    }
}

private enum SideNavigationEdge {
    case left
    case right

    var alignment: Alignment {
        switch self {
        case .left:
            .trailing
        case .right:
            .leading
        }
    }

    var paddingEdge: Edge.Set {
        switch self {
        case .left:
            .trailing
        case .right:
            .leading
        }
    }
}

struct PersonalizationQuestionLayout<Content: View>: View {
    let title: String
    var subtitle: String?
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 10) {
                OnboardingTitleText(text: title, size: 20, alignment: .center)
                    .frame(maxWidth: .infinity)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(OnboardingStyle.primaryBlue.opacity(0.58))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 8)

            content
        }
    }
}

private extension PersonalizationSection {
    static let visibleProgressSections: [PersonalizationSection] = [
        .skinType,
        .skinSensitivity,
        .skinConcern
    ]

    var progressIndex: Int {
        switch self {
        case .skinType:
            0
        case .skinSensitivity:
            1
        case .skinConcern, .summary:
            2
        }
    }
}

struct PersonalizationOptionList<Option: Identifiable, Content: View>: View where Option.ID: Hashable {
    let options: [Option]
    let content: (Option) -> Content

    var body: some View {
        VStack(spacing: 14) {
            ForEach(options) { option in
                content(option)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PersonalizationMascotFooter: View {
    let noteText: String
    var showsNote: Bool = true
    var mascotAnimation: MascotAnimation = .peekHead

    var body: some View {
        ZStack(alignment: .bottom) {
            OnboardingMascotLottieView(animation: showsNote ? .head : mascotAnimation)
                .frame(width: 420, height: 420)
                .scaleEffect(showsNote ? 1.04 : 2)
                .offset(x: -5, y: showsNote ? 140 : 100)

            if showsNote {
                MascotNoteBubble(text: noteText)
                    .offset(y: -200)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 308)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct MascotNoteBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(OnboardingStyle.primaryBlue)
            .lineLimit(1)
            .minimumScaleFactor(0.86)
            .padding(.horizontal, 22)
            .frame(minWidth: 250, minHeight: 66)
            .offset(y: -10)
            .background {
                Image("bublecloud")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 250, height: 66)
            }
    }
}

struct PersonalizationActionBar: View {
    let primaryTitle: String
    var isPrimaryEnabled: Bool = true
    var secondaryTitle: String?
    let primaryAction: () -> Void
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            OnboardingPrimaryButton(
                title: primaryTitle,
                isEnabled: isPrimaryEnabled,
                fontSize: 18,
                height: 48,
                cornerRadius: 18,
                action: primaryAction
            )

            if let secondaryTitle, let secondaryAction {
                Button(secondaryTitle, action: secondaryAction)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(OnboardingStyle.primaryBlue.opacity(0.72))
                    .frame(height: 44)
                    .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: 280)
        .frame(maxWidth: .infinity)
    }
}

struct PersonalizationSliderQuestion: View {
    @Binding var value: Double
    let lowLabel: String
    let highLabel: String

    var body: some View {
        VStack(spacing: 12) {
            Text(highLabel)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(OnboardingStyle.buttonBlue)
                .multilineTextAlignment(.center)

            GeometryReader { geometry in
                let trackHeight = geometry.size.height - 28
                let knobSize: CGFloat = 54
                let usableHeight = trackHeight - knobSize
                let progress = value / 10
                let knobY = (1 - progress) * usableHeight + knobSize / 2

                ZStack(alignment: .top) {
                    Capsule()
                        .fill(Color.white.opacity(0.72))
                        .frame(width: 20, height: trackHeight)
                        .overlay {
                            Capsule()
                                .stroke(OnboardingStyle.controlShadow.opacity(0.12), lineWidth: 1)
                        }

                    Capsule()
                        .fill(OnboardingStyle.buttonBlue)
                        .frame(width: 20, height: max(0, trackHeight - knobY + knobSize / 2))
                        .frame(height: trackHeight, alignment: .bottom)

                    Text("\(Int(value.rounded()))")
                        .font(OnboardingStyle.roundedFont(size: 28))
                        .foregroundStyle(.white)
                        .frame(width: knobSize, height: knobSize)
                        .background(Circle().fill(OnboardingStyle.buttonBlue))
                        .overlay { Circle().strokeBorder(Color.white, lineWidth: 4) }
                        .shadow(color: OnboardingStyle.controlShadow.opacity(0.16), radius: 8, y: 4)
                        .position(x: geometry.size.width / 2, y: knobY)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let y = min(max(gesture.location.y - knobSize / 2, 0), usableHeight)
                            value = ((1 - y / usableHeight) * 10).rounded()
                        }
                )
                .accessibilityElement()
                .accessibilityLabel("Tingkat sensitivitas")
                .accessibilityValue("\(Int(value.rounded())) dari 10")
            }
            .frame(width: 280, height: 260)

            Text(lowLabel)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(OnboardingStyle.buttonBlue)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 240)
        }
        .padding(.top, 8)
    }
}
