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
    static let bottomOffsetY: CGFloat = 34
    static let bottomButtonWidth: CGFloat = 275
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
                case .welcome:
                    WelcomeScreen(action: viewModel.advance)
                case .introduction:
                    IntroductionScreen(action: viewModel.advance)
                case .skincareHelp:
                    SkincareHelpScreen(action: viewModel.advance)
                case .getNamePrompt:
                    NamePromptScreen(action: viewModel.advance)
                case .inputName:
                    NameInputScreen(
                        name: $viewModel.personalization.name,
                        canSubmit: viewModel.canSubmitName,
                        action: viewModel.submitName
                    )
                case .personalizationIntro:
                    PersonalizationIntroScreen(
                        name: viewModel.trimmedName,
                        action: viewModel.advance
                    )
                case .personalization:
                    PersonalizationView(
                        initialPersonalization: viewModel.personalization,
                        allowsAssessment: false,
                        allowsSkinTypeAssessment: true,
                        onComplete: viewModel.completePersonalization
                    )
                case .mainPage:
                    MainPlaceholderView(personalization: viewModel.personalization)
                }
            }
        }
        .onAppear {
            MascotLottieCache.preloadAllOnce()
        }
    }
}

private struct WelcomeScreen: View {
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Halo!")
                    .font(OnboardingStyle.roundedFont(size: 20))

                Text("Selamat datang di")
                    .font(OnboardingStyle.roundedFont(size: 20))
                
                Text("Foamy")
                    .font(OnboardingStyle.roundedFont(size: 36))
                    .underline(true, color: OnboardingStyle.primaryBlue)
            }
            .foregroundStyle(OnboardingStyle.primaryBlue)
            .padding(.top, 50)
            .padding(.leading, 75)

            Spacer()

            MascotLottieView(animation: .wave)
                .frame(width: 450, height: 450)
                .frame(maxWidth: .infinity)
                .offset(y: -10)

            Spacer()

            OnboardingBottomTapText()
                .offset(y: OnboardingLayout.bottomOffsetY)
                .padding(.bottom, OnboardingLayout.bottomPadding)
        }
        .padding(.horizontal, OnboardingLayout.screenHorizontalPadding)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

private struct IntroductionScreen: View {
    let action: () -> Void

    var body: some View {
        OnboardingSectionLayout(
            top: {
                IntroTextBlock()
            },
            middle: {
                MascotLottieView(animation: .idle)
                    .frame(width: 450, height: 450)
            },
            bottom: {
                OnboardingBottomTapText()
            }
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

private struct SkincareHelpScreen: View {
    let action: () -> Void

    var body: some View {
        OnboardingSectionLayout(
            top: {
                SkincareHelpTextBlock()
            },
            middle: {
                MascotLottieView(animation: .idle)
                    .frame(width: 450, height: 450)
            },
            bottom: {
                OnboardingBottomTapText()
            }
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

private struct OnboardingSectionLayout<Top: View, Middle: View, Bottom: View>: View {
    let top: Top
    let middle: Middle
    let bottom: Bottom

    init(
        @ViewBuilder top: () -> Top,
        @ViewBuilder middle: () -> Middle,
        @ViewBuilder bottom: () -> Bottom
    ) {
        self.top = top()
        self.middle = middle()
        self.bottom = bottom()
    }

    var body: some View {
        VStack(spacing: 0) {
            top
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 130, alignment: .topLeading)
                .padding(.top, 50)

            Spacer()

            middle
                .frame(maxWidth: .infinity)
                .offset(y: -10)

            Spacer()

            bottom
                .frame(maxWidth: .infinity)
                .offset(y: OnboardingLayout.bottomOffsetY)
        }
        .padding(.horizontal, OnboardingLayout.screenHorizontalPadding)
        .padding(.bottom, OnboardingLayout.bottomPadding)
    }
}

private struct OnboardingBottomTapText: View {
    var body: some View {
        Text("Tekan di mana saja untuk lanjut")
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(OnboardingStyle.strongShadow.opacity(0.35))
            .frame(maxWidth: .infinity)
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

private struct IntroTextBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kenalin aku FUUMII!")

            Text("Aku akan bantu memudahkan\nperjalanan skincare-mu.")
        }
        .font(OnboardingStyle.roundedFont(size: 20))
        .foregroundStyle(OnboardingStyle.primaryBlue)
        .padding(.leading, 50)
    }
}

private struct SkincareHelpTextBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Aku bisa membantu kamu...")

            Text("Menganalisis skincare terbaik\nberdasarkan kulitmu sampai\nmenemani perjalananmu\nmenggunakannya.")
        }
        .font(OnboardingStyle.roundedFont(size: 20))
        .foregroundStyle(OnboardingStyle.primaryBlue)
        .padding(.leading, 50)
    }
}

private struct NamePromptTextBlock: View {
    var body: some View {
        Text("Cukup tentang aku.\n\nSekarang giliran aku\nmengenalmu.")
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
            Text("Oke \(name), sekarang")
            Text("bantu aku mengisi kuis")
            Text("tentang kulitmu untuk")
            Text("menemukan skincare terbaik!")
        }
        .font(OnboardingStyle.roundedFont(size: 20))
        .foregroundStyle(OnboardingStyle.primaryBlue)
        .multilineTextAlignment(.leading)
        .padding(.leading, 50)
    }
}

private struct MascotStoryScreen: View {
    let title: String
    let mascot: MascotAnimation
    let mascotSize: CGSize
    var bottomText: String?
    var topPadding: CGFloat = 50
    var mascotOffsetY: CGFloat = 0
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 42) {
            OnboardingTitleText(text: title)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            MascotLottieView(animation: mascot)
                .frame(width: mascotSize.width, height: mascotSize.height)
                .frame(maxWidth: .infinity)
                .offset(y: mascotOffsetY)

            Spacer(minLength: 0)

            if let bottomText {
                Text(bottomText)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(OnboardingStyle.primaryBlue)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, topPadding)
        .padding(.bottom, 66)
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

private struct NamePromptScreen: View {
    let action: () -> Void

    var body: some View {
        OnboardingSectionLayout(
            top: {
                NamePromptTextBlock()
            },
            middle: {
                MascotLottieView(animation: .pointing)
                    .frame(width: 450, height: 450)
            },
            bottom: {
                OnboardingBottomTapText()
            }
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

private struct NameInputScreen: View {
    @Binding var name: String
    let canSubmit: Bool
    let action: () -> Void
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(spacing: 42) {
            OnboardingTitleText(text: "Siapa nama kamu?", size: 20, alignment: .center)

            Spacer()

            ZStack(alignment: .top) {
                MascotLottieView(animation: .peekHead)
                    .frame(width: 300, height: 300)
                    .offset(y: -2)
                    .offset(x: -7)
                    .allowsHitTesting(false)
                    .padding(.top, -30)

                NameCardTextField(name: $name, isFocused: $isNameFocused)
                    .padding(.top, 118)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isNameFocused = true
            }
            .offset(y: -24)

            OnboardingPrimaryButton(title: "Selesai", isEnabled: canSubmit, cornerRadius: 27, action: action)
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

private struct PersonalizationIntroScreen: View {
    let name: String
    let action: () -> Void

    var body: some View {
        OnboardingSectionLayout(
            top: {
                PersonalizationIntroTextBlock(name: name)
            },
            middle: {
                MascotLottieView(animation: .idle)
                    .frame(width: 450, height: 450)
            },
            bottom: {
                OnboardingBottomCTA(title: "Mulai Kuis", action: action)
            }
        )
    }
}

private struct MainPlaceholderView: View {
    let personalization: OnboardingPersonalization

    var body: some View {
        VStack(spacing: 16) {
            Text(personalization.name.isEmpty ? "Welcome" : "Welcome, \(personalization.name)")
                .font(OnboardingStyle.roundedFont(size: 24))
                .foregroundStyle(OnboardingStyle.primaryBlue)

            Text(summaryText)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(OnboardingStyle.primaryBlue.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var summaryText: String {
        let skinType = personalization.skinType?.rawValue ?? "-"
        let sensitivity = personalization.skinSensitivity?.rawValue ?? "-"
        let concerns = personalization.skinConcerns.isEmpty
            ? "Tidak ada"
            : personalization.skinConcerns.map(\.rawValue).joined(separator: ", ")

        return "Tipe: \(skinType)\nSensitivitas: \(sensitivity)\nConcern: \(concerns)"
    }
}

#Preview("Full Onboarding Flow") {
    OnboardingView()
}
