//
//  SkinJournalMainView.swift
//  C4-MySkin
//

import SwiftUI

struct SkinJournalMainView: View {
    let journey: SkincareJourney?
    let onSkinJournaling: () -> Void
    let onProductValidation: () -> Void

    var body: some View {
        ZStack {
            // Soft ice blue background gradient matching colored mockup
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 8)

                    searchPrompt
                        .padding(.top, 16)

                    if let journey = journey {
                        ActiveMilestoneCard(journey: journey)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    } else {
                        EmptyStateCard()
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }

                    actionCircles
                        .padding(.top, 24)

                    Spacer(minLength: 16)

                    mascotSection
                        .padding(.top, 8)
                }
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            HStack(spacing: 0) {
                Text("Hi, ")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                Text("POLO")
                    .font(.system(size: 26, weight: .bold))
                    .underline()
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                Text("!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    triggerHaptic()
                }) {
                    Image(systemName: "heart")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Saved items")

                Button(action: {
                    triggerHaptic()
                }) {
                    Circle()
                        .fill(Color(red: 0.82, green: 0.83, blue: 0.85))
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Profile")
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Search Prompt
    private var searchPrompt: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))

            Text("Check active products on you!")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.60))

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - Action Circles
    private var actionCircles: some View {
        HStack(spacing: 24) {
            ActionBubbleButton(
                title: "Product\nvalidation\nskin",
                action: onProductValidation
            )

            ActionBubbleButton(
                title: "Skin\njournaling",
                action: onSkinJournaling
            )
        }
    }

    // MARK: - Mascot & Speech Bubble Section
    private var mascotSection: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: -10) {
                HStack {
                    Spacer()
                    MascotBubble(message: "Purging berbeda\ndengan breakout\nloh !")
                        .frame(maxWidth: 220)
                        .padding(.trailing, 20)
                }

                Image("MascotBlue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320)
            }
        }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Empty State Card
private struct EmptyStateCard: View {
    var body: some View {
        VStack {
            Text("No active product yet")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Color(red: 0.15, green: 0.33, blue: 0.50))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Active Milestone Card
private struct ActiveMilestoneCard: View {
    let journey: SkincareJourney

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 52, height: 52)

                    Image(systemName: "jar.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(red: 0.15, green: 0.33, blue: 0.50))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Monitoring Period")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(red: 0.15, green: 0.33, blue: 0.50))

                        Spacer()

                        HStack(spacing: 4) {
                            Text("Result in 2 weeks")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color(red: 0.15, green: 0.33, blue: 0.50))

                            Image(systemName: "flag.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color(red: 0.15, green: 0.33, blue: 0.50))
                        }
                    }

                    DashedProgressLine()
                        .frame(height: 4)
                        .padding(.top, 4)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Action Bubble Button
private struct ActionBubbleButton: View {
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Image("BubbleButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 135, height: 135)
                    .shadow(color: Color.blue.opacity(0.12), radius: 6, x: 0, y: 3)

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .foregroundStyle(Color(red: 0.15, green: 0.33, blue: 0.50))
            }
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressedButtonStyle(isPressed: $isPressed))
        .accessibilityLabel(title.replacingOccurrences(of: "\n", with: " "))
    }
}

private struct PressedButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Dashed Progress Line
private struct DashedProgressLine: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
            }
            .stroke(
                Color(red: 0.15, green: 0.33, blue: 0.50),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [5, 4])
            )
        }
    }
}

#Preview("Empty State") {
    SkinJournalMainView(
        journey: nil,
        onSkinJournaling: {},
        onProductValidation: {}
    )
}

#Preview("Active State") {
    SkinJournalMainView(
        journey: SkincareJourney(
            product: SkincareProduct(
                id: "sk-1",
                brand: "SKIN1004",
                name: "Centella Ampoule",
                category: "Serum",
                iconName: "drop.fill"
            )
        ),
        onSkinJournaling: {},
        onProductValidation: {}
    )
}


