//
//  OnboardingView.swift
//  C4-MySkin
//
//  Created by Codex on 10/08/26.
//

import SwiftUI
import UIKit

private enum OnboardingLayout {
    static let screenHorizontalPadding: CGFloat = 54
    static let bottomPadding: CGFloat = 72
    static let bottomOffsetY: CGFloat = 50
    static let bottomButtonWidth: CGFloat = 350
    static let bottomButtonFontSize: CGFloat = 22
    static let bottomButtonHeight: CGFloat = 52
}

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            OnboardingGradientBackground()

            Group {
                switch viewModel.currentStep {
                case .welcome, .introduction, .skincareHelp, .getNamePrompt:
                    OnboardingConversationScreen(
                        step: viewModel.currentStep,
                        name: viewModel.trimmedName,
                        isContentVisible: viewModel.isConversationContentVisible,
                        isMascotDroppingToQuiz: viewModel.isMascotDroppingToQuiz,
                        action: viewModel.advanceConversation
                    )
                case .inputName:
                    NameInputScreen(
                        name: $viewModel.personalization.name,
                        canSubmit: viewModel.canSubmitName,
                        action: viewModel.submitNameWithConversationTransition
                    )
                case .personalizationIntro:
                    OnboardingConversationScreen(
                        step: viewModel.currentStep,
                        name: viewModel.trimmedName,
                        isContentVisible: viewModel.isConversationContentVisible,
                        isMascotDroppingToQuiz: viewModel.isMascotDroppingToQuiz,
                        action: viewModel.advanceConversation
                    )
                case .skinType:
                    SkinTypeScreen(
                        selectedSkinType: viewModel.personalization.skinType,
                        onSelect: selectSkinTypeWithAnimation
                    )
                case .skinSensitivity:
                    SkinSensitivityScreen(
                        selectedSensitivity: viewModel.personalization.skinSensitivity,
                        onSelect: viewModel.selectSkinSensitivity,
                        onStart: viewModel.finishOnboarding
                    )
                case .mainPage:
                    SkinJournalRootView()
                }
            }
        }
        .onAppear {
            OnboardingMascotLottieCache.preloadAllOnce()
        }
    }

    private func selectSkinTypeWithAnimation(_ skinType: SkinType) {
        withAnimation(.easeInOut(duration: 0.24)) {
            viewModel.selectSkinType(skinType)
        }
    }
}

private struct OnboardingConversationScreen: View {
    let step: OnboardingStep
    let name: String
    let isContentVisible: Bool
    let isMascotDroppingToQuiz: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topContent
                .id("top-\(step.rawValue)")
                .frame(maxWidth: .infinity, alignment: topAlignment)
                .frame(height: 130, alignment: topFrameAlignment)
                .padding(.top, 50)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .opacity(isContentVisible ? 1 : 0)
                .offset(y: isContentVisible ? 0 : -14)

            Spacer()

            ZStack(alignment: .bottom) {
                OnboardingMascotShadow()
                    .offset(y: 15)
                    .offset(x: -5)

                OnboardingMascotLottieView(animation: step.mascotAnimation ?? .idle)
                    .frame(width: 450, height: 450)
                    .scaleEffect(isMascotDroppingToQuiz ? 1.10 : 1)
            }
                .frame(maxWidth: .infinity)
                .offset(y: isMascotDroppingToQuiz ? 300 : mascotOffsetY)
                .animation(.easeInOut(duration: 0.22), value: step.rawValue)
                .animation(.easeOut(duration: 0.20), value: isMascotDroppingToQuiz)

            Spacer()

            bottomContent
                .id("bottom-\(step.rawValue)")
                .frame(maxWidth: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .opacity(isContentVisible ? 1 : 0)
                .offset(y: isContentVisible ? OnboardingLayout.bottomOffsetY : OnboardingLayout.bottomOffsetY + 14)
        }
        .padding(.horizontal, OnboardingLayout.screenHorizontalPadding)
        .padding(.bottom, OnboardingLayout.bottomPadding)
        .contentShape(Rectangle())
        .onTapGesture {
            guard step.advancesOnTap else { return }
            OnboardingHaptics.tap()
            action()
        }
    }

    @ViewBuilder
    private var topContent: some View {
        switch step {
        case .welcome:
            WelcomeTextBlock()
        case .introduction:
            IntroTextBlock()
        case .skincareHelp:
            SkincareHelpTextBlock()
        case .getNamePrompt:
            NamePromptTextBlock()
        case .personalizationIntro:
            PersonalizationIntroTextBlock(name: name)
        case .inputName, .skinType, .skinSensitivity, .mainPage:
            EmptyView()
        }
    }

    @ViewBuilder
    private var bottomContent: some View {
        switch step {
        case .personalizationIntro:
            OnboardingBottomCTA(title: "Start Quiz", action: action)
        case .welcome, .introduction, .skincareHelp, .getNamePrompt:
            OnboardingBottomTapText()
        case .inputName, .skinType, .skinSensitivity, .mainPage:
            EmptyView()
        }
    }

    private var topAlignment: Alignment {
        step == .welcome ? .leading : .leading
    }

    private var topFrameAlignment: Alignment {
        step == .welcome ? .topLeading : .topLeading
    }

    private var mascotOffsetY: CGFloat {
        step == .welcome ? -10 : -10
    }

}

private struct OnboardingBottomTapText: View {
    var body: some View {
        Text("Tap anywhere to continue")
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(OnboardingStyle.strongShadow.opacity(0.35))
            .frame(maxWidth: .infinity)
    }
}

private struct OnboardingMascotShadow: View {
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.22),
                        Color.black.opacity(0.12),
                        Color.black.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 90
                )
            )
            .frame(width: 250, height: 40)
            .blur(radius: 2)
            .allowsHitTesting(false)
    }
}

private struct OnboardingBottomCTA: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        OnboardingPrimaryButton(
            title: title,
            isEnabled: isEnabled,
            fontSize: OnboardingLayout.bottomButtonFontSize,
            height: OnboardingLayout.bottomButtonHeight,
            action: action
        )
        .frame(maxWidth: OnboardingLayout.bottomButtonWidth)
        .frame(maxWidth: .infinity)
    }
}

private struct WelcomeTextBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Hi!")
                .font(OnboardingStyle.roundedFont(size: 20))

            Text("Welcome to")
                .font(OnboardingStyle.roundedFont(size: 20))

            Text("Foamy")
                .font(OnboardingStyle.roundedFont(size: 36))
                .underline(true, color: OnboardingStyle.primaryBlue)
        }
        .foregroundStyle(OnboardingStyle.primaryBlue)
        .padding(.leading, 75)
    }
}

private struct IntroTextBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hi, I'm FUUMII!")

            Text("I'll make your skincare\njourney easier.")
        }
        .font(OnboardingStyle.roundedFont(size: 20))
        .foregroundStyle(OnboardingStyle.primaryBlue)
        .padding(.leading, 50)
    }
}

private struct SkincareHelpTextBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Here's how I can help...")

            Text("I'll find the best skincare for your skin \nand support you throughout your \njourney.")
        }
        .font(OnboardingStyle.roundedFont(size: 20))
        .foregroundStyle(OnboardingStyle.primaryBlue)
        .padding(.leading, 50)
    }
}

private struct NamePromptTextBlock: View {
    var body: some View {
        Text("Enough about me.\n\nNow it's my turn\nto get to know you.")
            .font(OnboardingStyle.roundedFont(size: 20))
            .foregroundStyle(OnboardingStyle.primaryBlue)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 50)
    }
}

private struct PersonalizationIntroTextBlock: View {
    let name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Okay \(name), ")
            Text("now take a quick quiz about your skin \nso we can find your best skincare!")
        }
        .font(OnboardingStyle.roundedFont(size: 20))
        .foregroundStyle(OnboardingStyle.primaryBlue)
        .multilineTextAlignment(.leading)
        .padding(.leading, 50)
    }
}

private struct NameInputScreen: View {
    @Binding var name: String
    let canSubmit: Bool
    let action: () -> Void
    @FocusState private var isNameFocused: Bool
    private let mascotCanvasSize: CGFloat = 300
    private let mascotScale: CGFloat = 0.55

    var body: some View {
        VStack(spacing: 42) {
            OnboardingTitleText(text: "What should I call you?", size: 20, alignment: .center)

            Spacer()

            ZStack(alignment: .top) {
                OnboardingMascotLottieView(animation: .head)
                    .frame(width: mascotCanvasSize, height: mascotCanvasSize)
                    .scaleEffect(mascotScale)
                    .offset(y: -2)
                    .offset(x: -7)
                    .allowsHitTesting(false)
                    .padding(.top, -35)

                NameCardTextField(name: $name, isFocused: $isNameFocused)
                    .padding(.top, 118)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                OnboardingHaptics.tap()
                isNameFocused = true
            }
            .offset(y: -24)

            OnboardingPrimaryButton(title: "Done", isEnabled: canSubmit, cornerRadius: 27, action: action)
                .frame(maxWidth: 200)
                .padding(.top, -70)
                .offset(y: -24)

            Spacer()
        }
        .padding(.horizontal, 48)
        .padding(.top, 144)
        .padding(.bottom, 136)
    }
}

private struct NameCardTextField: View {
    @Binding var name: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        ZStack {
            if let noteCardImage = UIImage.bundleImage(named: "NameNoteCard", extension: "png") {
                Image(uiImage: noteCardImage)
                    .resizable()
                    .scaledToFit()
            }

            TextField("", text: $name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(OnboardingStyle.primaryBlue)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .padding(.horizontal, 120)
                .offset(y: 0)
                .focused(isFocused)
                .onChange(of: name) { _, newValue in
                    if newValue.count > 10 {
                        name = String(newValue.prefix(10))
                    }
                }
        }
        .frame(width: 500, height: 300)
    }
}

private extension UIImage {
    static func bundleImage(named name: String, extension fileExtension: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: fileExtension) else {
            return nil
        }

        return UIImage(contentsOfFile: path)
    }
}

private struct SkinTypeScreen: View {
    let selectedSkinType: SkinType?
    let onSelect: (SkinType) -> Void

    var body: some View {
        VStack(spacing: 32) {
            OnboardingTitleText(text: "What is your skin type?", size: 20, alignment: .center)
                .frame(maxWidth: .infinity)

            VStack(spacing: 28) {
                ForEach(SkinType.allCases) { skinType in
                    OnboardingOptionButton(
                        title: skinType.onboardingDisplayName,
                        isSelected: selectedSkinType == skinType,
                        fontSize: 18,
                        height: 44
                    ) {
                        onSelect(skinType)
                    }
                    .frame(maxWidth: 275)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            OnboardingMascotLottieView(animation: .idle)
                .frame(width: 450, height: 450)
                .scaleEffect(1.10)
                .offset(y: 10)
                .frame(height: 300)
                .clipped()
                .allowsHitTesting(false)
        }
        .padding(.horizontal, 56)
        .padding(.top, 176)
        .padding(.bottom, 0)
    }
}

private struct SkinSensitivityScreen: View {
    let selectedSensitivity: SkinSensitivity?
    let onSelect: (SkinSensitivity) -> Void
    let onStart: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 32) {
                OnboardingTitleText(text: "How sensitive is\nyour skin?", size: 20, alignment: .center)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 28) {
                    ForEach(SkinSensitivity.allCases) { sensitivity in
                        OnboardingOptionButton(
                            title: sensitivity.onboardingDisplayName,
                            isSelected: selectedSensitivity == sensitivity,
                            fontSize: 18,
                            height: 44
                        ) {
                            onSelect(sensitivity)
                        }
                        .frame(maxWidth: 275)
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(.horizontal, OnboardingLayout.screenHorizontalPadding)
            .padding(.top, 100)

            OnboardingBottomCTA(title: "Done", isEnabled: selectedSensitivity != nil, action: onStart)
                .offset(y: OnboardingLayout.bottomOffsetY)
        }
        .padding(.bottom, OnboardingLayout.bottomPadding)
    }
}

private extension SkinType {
    var onboardingDisplayName: String {
        switch self {
        case .dry: "Dry"
        case .normal: "Normal"
        case .oily: "Oily"
        case .combination: "Combination"
        case .notSureYet: "Not Sure Yet"
        }
    }
}

private extension SkinSensitivity {
    var onboardingDisplayName: String {
        switch self {
        case .normalResistant: "Normal / Resistant"
        case .slightlySensitive: "Slightly Sensitive"
        case .sensitive: "Sensitive"
        case .verySensitive: "Very Sensitive"
        case .notSureYet: "Not Sure Yet"
        }
    }
}

private struct MainPlaceholderView: View {
    let name: String

    var body: some View {
        VStack(spacing: 16) {
            Text(name.isEmpty ? "Welcome" : "Welcome, \(name)")
                .font(OnboardingStyle.roundedFont(size: 24))
                .foregroundStyle(OnboardingStyle.primaryBlue)

            Text("Main Page")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(OnboardingStyle.primaryBlue.opacity(0.75))
        }
        .padding()
    }
}

#Preview("Full Onboarding Flow") {
    OnboardingView()
}
