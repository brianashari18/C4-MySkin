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
        ZStack(alignment: .bottom) {
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

            // Mascot fills the bottom — large, partially cropped at bottom
            VStack {
                Spacer()
                MascotLottieView(width: 600)
                    .accessibilityHidden(true)
                    .offset(y: 180) // downward crop for dramatic effect
                    .offset(x: -2) // downward crop for dramatic effect
            }
            .ignoresSafeArea(edges: .bottom)

            // Scrollable content on top
            VStack(spacing: 0) {
                header
                    .padding(.top, 50
                    )

                searchPrompt
                    .padding(.top, 16)

                if let journey = journey {
                    Button(action: {
                        triggerHaptic()
                        onSkinJournaling()
                    }) {
                        ActiveMilestoneCard(journey: journey)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    EmptyStateCard()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }

                actionCircles
                    .padding(.top, 20)

                Spacer(minLength: 0)

                // Speech bubble on the top-right of the mascot
                HStack {
                    Spacer()
                    SpeechBubbleView(text: "Purging berbeda\ndengan breakout\nloh !")
                        .offset(y: 30)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 250)
            }
        }
        .ignoresSafeArea(edges: .bottom)
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
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(Color(red: 0.72, green: 0.76, blue: 0.80))
                        .frame(width: 44, height: 44)
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
        HStack(spacing: 48) {
            ActionBubbleButton(
                title: "Product\nvalidation skin",
                action: onProductValidation,
                amplitude: 0,
                duration: 1
            )

            ActionBubbleButton(
                title: "Skin\njournaling",
                action: onSkinJournaling,
                amplitude: 0,
                duration: 1.2,
                phase: 0.7
            )
        }
        .padding(.horizontal, 20)
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
        .frame(height: 195) // SAKLAK: sama dengan ActiveMilestoneCard (195pt)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.bottom, 16) // samakan total tinggi dengan Active (195 + 16)
    }
}

// MARK: - Active Milestone Card (Tracker Perjalanan)
struct ActiveMilestoneCard: View {
    let journey: SkincareJourney

    private var progress: MilestoneProgress {
        MilestoneProgress(journey: journey)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 1. "Active" Badge Pill
            Text("Active")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(red: 0.38, green: 0.61, blue: 0.93))
                .clipShape(Capsule())

            // 2. Milestone Title
            Text(progress.isComplete ? "Journey Complete" : "Milestone #\(progress.currentFlag)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(red: 0.16, green: 0.35, blue: 0.54))

            // 3. Timeline Row: Jar Icon (Start Date) --- Dashed Line --- Flag Icon (Results in 2 weeks)
            HStack(alignment: .top, spacing: 12) {
                // Left: Circle Jar Icon + Start Date
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.22, green: 0.43, blue: 0.65))
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)

                        Image(systemName: journey.product.iconName ?? "jar.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.white)
                    }

                    VStack(spacing: 1) {
                        Text("Start")
                            .font(.system(size: 12, weight: .bold))
                        Text(formattedDate(journey.startDate))
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Color(red: 0.22, green: 0.43, blue: 0.65))
                }

                // Middle: Custom Dark Blue Filled Progress Bar / Slider with Shortened Length
                GeometryReader { geometry in
                    let trackInset: CGFloat = 16 // Margin on left & right to shorten length
                    let trackWidth = max(20, geometry.size.width - (trackInset * 0.5))
                    let currentProgress = max(0.80, min(1.0, CGFloat(progress.progress)))
                    let fillWidth = trackWidth * currentProgress

                    ZStack(alignment: .leading) {
                        // Background Track (Shortened)
                        Capsule()
                            .fill(Color(red: 0.22, green: 0.43, blue: 0.65).opacity(0.20))
                            .frame(width: trackWidth, height: 8)

                        // Filled Dark Blue Progress Bar
                        Capsule()
                            .fill(Color(red: 0.16, green: 0.35, blue: 0.54))
                            .frame(width: fillWidth, height: 8)

                        // Active Progress Dot
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.16, green: 0.35, blue: 0.54))
                                .frame(width: 16, height: 16)

                            Circle()
                                .stroke(Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.5), lineWidth: 3)
                                .frame(width: 22, height: 22)
                        }
                        .offset(x: fillWidth - 11)
                    }
                    .frame(width: geometry.size.width, height: 44, alignment: .center)
                }

                // Right: Flag Icon + Results in 2 weeks
                VStack(spacing: 4) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color(red: 0.22, green: 0.43, blue: 0.65))
                        .frame(height: 44)

                    VStack(spacing: 1) {
                        if progress.isComplete {
                            Text("Done")
                                .font(.system(size: 11, weight: .bold))
                            Text("All flags")
                                .font(.system(size: 10, weight: .semibold))
                        } else if progress.currentFlag == 1 {
                            Text("Results")
                                .font(.system(size: 12, weight: .bold))
                            Text("in 2 weeks")
                                .font(.system(size: 10, weight: .semibold))
                        } else {
                            Text("Week \(progress.currentWeek)")
                                .font(.system(size: 11, weight: .semibold))
                            Text("of \(progress.totalFlags * 2)")
                                .font(.system(size: 10, weight: .semibold))
                        }
                    }
                    .foregroundStyle(Color(red: 0.22, green: 0.43, blue: 0.65))
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .frame(height: 195) // SAKLAK: sama dengan EmptyStateCard (195pt)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.99, green: 0.90, blue: 0.66))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.init(top: 0, leading: 0, bottom: 16, trailing: 0))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Action Bubble Button
private struct ActionBubbleButton: View {
    let title: String
    let action: () -> Void

    /// Amplitudo ayunan naik-turun (pt).
    var amplitude: CGFloat = 8
    /// Durasi satu siklus mengambang (detik).
    var duration: Double = 2.8
    /// Delay awal (detik) agar dua bubble tidak bergerak sinkron.
    var phase: Double = 0

    @State private var isPressed = false
    @State private var isFloating = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
            .offset(y: isFloating ? -amplitude : 10)
            .animation(
                .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isFloating
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
            .onAppear {
                guard !reduceMotion else { return }
                isFloating = false
                DispatchQueue.main.asyncAfter(deadline: .now() + phase) {
                    isFloating = true
                }
            }
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


