//
//
//  PersonalizationView.swift
//  C4-MySkin
//
//  Created by Codex on 11/08/26.
//

import SwiftUI

struct PersonalizationView: View {
    @State private var viewModel: PersonalizationViewModel
    let onComplete: (OnboardingPersonalization) -> Void
    let finishesAfterSensitivity: Bool
    let stopsAtSensitivitySelection: Bool

    init(
        initialPersonalization: OnboardingPersonalization = OnboardingPersonalization(),
        allowsAssessment: Bool = true,
        allowsSkinTypeAssessment: Bool? = nil,
        allowsSensitivityAssessment: Bool? = nil,
        finishesAfterSensitivity: Bool = false,
        stopsAtSensitivitySelection: Bool = false,
        onComplete: @escaping (OnboardingPersonalization) -> Void
    ) {
        _viewModel = State(
            initialValue: PersonalizationViewModel(
                initialPersonalization: initialPersonalization,
                allowsAssessment: allowsAssessment,
                allowsSkinTypeAssessment: allowsSkinTypeAssessment,
                allowsSensitivityAssessment: allowsSensitivityAssessment
                , stopsAtSensitivitySelection: stopsAtSensitivitySelection
            )
        )
        self.onComplete = onComplete
        self.finishesAfterSensitivity = finishesAfterSensitivity
        self.stopsAtSensitivitySelection = stopsAtSensitivitySelection
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if !finishesAfterSensitivity {
                    PersonalizationProgressHeader(
                        section: viewModel.phase.section,
                        fillsCurrentMilestone: viewModel.phase.fillsCurrentMilestone
                    )
                }

                ZStack(alignment: .bottom) {
                    VStack(spacing: 32) {
                        content
                            .padding(.top, viewModel.phase == .skinSensitivityAssessment ? 20 : 34)

                        Spacer(minLength: 148)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)

                    if !finishesAfterSensitivity || viewModel.phase == .skinTypeSelection {
                        PersonalizationMascotFooter(
                            noteText: viewModel.mascotNoteText,
                            showsNote: !finishesAfterSensitivity && !viewModel.phase.isResult,
                            mascotAnimation: finishesAfterSensitivity ? .idle : .peekHead
                        )
                        .id(viewModel.phase)
                    }
                }
            }

            PersonalizationSideNavigation(
                canGoBack: viewModel.phase != .skinTypeSelection &&
                    viewModel.phase != .skinSensitivitySelection &&
                    !(viewModel.phase == .skinConcern &&
                        viewModel.concernPageIndex == 0 &&
                        viewModel.selectedSkinSensitivity != .notSureYet),
                canAdvance: viewModel.canAdvance,
                onBack: viewModel.goBack,
                onNext: advanceFromSideNavigation
            )
            .opacity(viewModel.phase.showsSideNavigation && !finishesAfterSensitivity ? 1 : 0)
            .allowsHitTesting(viewModel.phase.showsSideNavigation && !finishesAfterSensitivity)
        }
        .navigationBarBackButtonHidden(true)
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.phase == .summary {
                onComplete(viewModel.result)
            }
        }
        .onChange(of: viewModel.phase) { _, phase in
            if finishesAfterSensitivity && phase == .skinConcern {
                onComplete(viewModel.result)
            }
        }
        .background(OnboardingGradientBackground())
        .animation(.snappy(duration: 0.24), value: viewModel.phase)
        .task(id: viewModel.phase) {
            guard viewModel.phase == .skinTypeResult || viewModel.phase == .skinSensitivityResult || viewModel.phase == .summary else { return }

            try? await Task.sleep(for: .seconds(3))

            guard !Task.isCancelled else { return }

            if viewModel.phase == .summary {
                onComplete(viewModel.result)
            } else if viewModel.phase == .skinTypeResult {
                viewModel.acceptSkinTypeResult()
            } else if viewModel.phase == .skinSensitivityResult {
                viewModel.acceptSensitivityResult()
            }
        }
    }

    private func advanceFromSideNavigation() {
        if viewModel.phase == .summary {
            onComplete(viewModel.result)
        } else {
            viewModel.advanceFromCurrentPhase()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .skinTypeSelection:
            SkinTypeSelectionContent(
                selectedSkinType: viewModel.selectedSkinType,
                onSelect: viewModel.selectSkinType
            )
        case .skinTypeAssessment:
            SkinTypeAssessmentContent(viewModel: viewModel)
        case .skinTypeConfirmation:
            SkinTypeConfirmationContent(
                selectedSkinType: viewModel.selectedSkinType,
                onSelect: viewModel.selectConfirmedSkinType
            )
        case .skinTypeResult:
            ResultContent(
                eyebrow: "Your skin type is...",
                title: viewModel.selectedSkinType?.personalizationDisplayName ?? "Normal",
                actionTitle: nil,
                action: nil
            )
        case .skinSensitivitySelection:
            SkinSensitivitySelectionContent(
                selectedSensitivity: viewModel.selectedSkinSensitivity,
                onSelect: viewModel.selectSkinSensitivity,
                showsCompletionButton: stopsAtSensitivitySelection,
                onComplete: { onComplete(viewModel.result) }
            )
        case .skinSensitivityAssessment:
            SkinSensitivityAssessmentContent(viewModel: viewModel)
        case .skinSensitivityResult:
            ResultContent(
                eyebrow: "Your skin sensitivity is...",
                title: viewModel.selectedSkinSensitivity?.personalizationDisplayName ?? "Normal",
                actionTitle: nil,
                action: nil
            )
        case .skinConcern:
            SkinConcernContent(viewModel: viewModel)
        case .summary:
            SummaryContent(viewModel: viewModel) {
                onComplete(viewModel.result)
            }
        }
    }
}

private extension PersonalizationPhase {
    var isResult: Bool {
        self == .skinTypeResult || self == .skinSensitivityResult || self == .summary
    }
}

private struct SkinTypeSelectionContent: View {
    let selectedSkinType: SkinType?
    let onSelect: (SkinType) -> Void

    var body: some View {
        PersonalizationQuestionLayout(title: "What is your skin type?") {
            PersonalizationOptionList(options: SkinType.allCases) { skinType in
                OnboardingOptionButton(
                    title: skinType.personalizationDisplayName,
                    isSelected: selectedSkinType == skinType,
                    fontSize: 16,
                    height: 44
                ) {
                    onSelect(skinType)
                }
                .frame(maxWidth: 280)
            }
        }
    }
}

private struct SkinTypeAssessmentContent: View {
    @Bindable var viewModel: PersonalizationViewModel

    var body: some View {
        PersonalizationQuestionLayout(
            title: viewModel.skinTypeQuestion.title
        ) {
            PersonalizationOptionList(options: viewModel.skinTypeQuestion.options) { option in
                OnboardingOptionButton(
                    title: option.title,
                    isSelected: viewModel.selectedSkinTypeOption?.title == option.title,
                    fontSize: 14,
                    height: 46
                ) {
                    viewModel.selectSkinTypeOption(option)
                }
                .frame(maxWidth: 300)
            }
        }
    }
}

private struct SkinTypeConfirmationContent: View {
    let selectedSkinType: SkinType?
    let onSelect: (SkinType) -> Void

    var body: some View {
        PersonalizationQuestionLayout(title: "What do you think\nyour skin type is?") {
            PersonalizationOptionList(options: SkinType.assessmentConfirmationCases) { skinType in
                OnboardingOptionButton(
                    title: skinType.personalizationDisplayName,
                    isSelected: selectedSkinType == skinType,
                    fontSize: 16,
                    height: 44
                ) {
                    onSelect(skinType)
                }
                .frame(maxWidth: 300)
            }
        }
    }
}

private struct SkinSensitivitySelectionContent: View {
    let selectedSensitivity: SkinSensitivity?
    let onSelect: (SkinSensitivity) -> Void
    var showsCompletionButton = false
    var onComplete: (() -> Void)?

    var body: some View {
        PersonalizationQuestionLayout(title: "How sensitive is\nyour skin?") {
            PersonalizationOptionList(options: SkinSensitivity.allCases) { sensitivity in
                OnboardingOptionButton(
                    title: sensitivity.personalizationDisplayName,
                    isSelected: selectedSensitivity == sensitivity,
                    fontSize: 16,
                    height: 44
                ) {
                    onSelect(sensitivity)
                }
                .frame(maxWidth: 280)
            }

            if showsCompletionButton, let onComplete {
                PersonalizationActionBar(
                    primaryTitle: "Done",
                    primaryAction: onComplete
                )
                .padding(.top, 20)
            }
        }
    }
}

private struct SkinSensitivityAssessmentContent: View {
    @Bindable var viewModel: PersonalizationViewModel

    var body: some View {
        PersonalizationQuestionLayout(
            title: viewModel.sensitivityQuestion.title,
            subtitle: viewModel.assessmentProgressText
        ) {
            PersonalizationSliderQuestion(
                value: $viewModel.sensitivityValue,
                lowLabel: viewModel.sensitivityQuestion.lowLabel,
                highLabel: viewModel.sensitivityQuestion.highLabel
            )
            .offset(y: -45)
        }
    }
}

private struct SkinConcernContent: View {
    @Bindable var viewModel: PersonalizationViewModel

    var body: some View {
        PersonalizationQuestionLayout(
            title: "What is your skin like\nright now?",
            subtitle: viewModel.concernPage.subtitle
        ) {
            VStack(spacing: 12) {
                ForEach(viewModel.concernPage.concerns) { concern in
                    OnboardingOptionButton(
                        title: concern.personalizationDisplayName,
                        isSelected: viewModel.selectedConcerns.contains(concern),
                        fontSize: concern.personalizationDisplayName.count > 24 ? 12 : 16,
                        height: 44
                    ) {
                        viewModel.toggleConcern(concern)
                    }
                    .frame(maxWidth: 300)
                }

                OnboardingOptionButton(
                    title: "None",
                    isSelected: viewModel.isNoConcernSelectedForCurrentPage,
                    fontSize: 16,
                    height: 44
                ) {
                    viewModel.selectNoConcernForCurrentPage()
                }
                .frame(maxWidth: 300)
                .padding(.top, 4)
            }
        }
    }
}

private struct ResultContent: View {
    let eyebrow: String
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 18) {
            Text(eyebrow)
                .font(.system(size: actionTitle == nil ? 21 : 15, weight: .bold, design: .rounded))
                .foregroundStyle(OnboardingStyle.primaryBlue.opacity(0.66))

            Text(title)
                .font(OnboardingStyle.roundedFont(size: actionTitle == nil ? 56 : 34))
                .foregroundStyle(OnboardingStyle.primaryBlue)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                PersonalizationActionBar(primaryTitle: actionTitle, primaryAction: action)
                    .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 120)
    }
}

#Preview("Skin Type Result") {
    PersonalizationResultPreview()
}

#Preview("Skin Sensitivity Result") {
    PersonalizationSensitivityResultPreview()
}

#Preview("Skin All Result") {
    PersonalizationAllResultPreview()
}

private struct PersonalizationResultPreview: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                PersonalizationProgressHeader(
                    section: .skinType,
                    fillsCurrentMilestone: false
                )

                ResultContent(
                    eyebrow: "Your skin type is...",
                    title: "Combination",
                    actionTitle: nil,
                    action: nil
                )

                Spacer()
            }

            PersonalizationMascotFooter(
                noteText: "",
                showsNote: false
            )
        }
        .background(OnboardingGradientBackground())
    }
}

private struct PersonalizationSensitivityResultPreview: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                PersonalizationProgressHeader(
                    section: .skinSensitivity,
                    fillsCurrentMilestone: true
                )

                ResultContent(
                    eyebrow: "Your skin sensitivity is...",
                    title: "Sensitive",
                    actionTitle: nil,
                    action: nil
                )

                Spacer()
            }

            PersonalizationMascotFooter(
                noteText: "",
                showsNote: false
            )
        }
        .background(OnboardingGradientBackground())
    }
}

private struct PersonalizationAllResultPreview: View {
    private let viewModel: PersonalizationViewModel

    init() {
        let model = PersonalizationViewModel()
        model.selectedSkinType = .dry
        model.selectedSkinSensitivity = .normalResistant
        model.selectedConcerns = [.acne, .blackheads, .whiteheads]
        self.viewModel = model
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                PersonalizationProgressHeader(
                    section: .summary,
                    fillsCurrentMilestone: true
                )

                SummaryContent(viewModel: viewModel) { }

                Spacer()
            }

            PersonalizationMascotFooter(
                noteText: "",
                showsNote: false
            )
        }
        .background(OnboardingGradientBackground())
    }
}

private struct SummaryContent: View {
    let viewModel: PersonalizationViewModel
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 2) {
            Text("All done!")
            Text("Thank you!")
        }
        .font(OnboardingStyle.roundedFont(size: 52))
            .foregroundStyle(OnboardingStyle.primaryBlue)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 130)
        .contentShape(Rectangle())
        .onTapGesture(perform: onComplete)
    }
}

private extension SkinType {
    var personalizationDisplayName: String {
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
    var personalizationDisplayName: String {
        switch self {
        case .normalResistant: "Normal / Resistant"
        case .slightlySensitive: "Slightly Sensitive"
        case .sensitive: "Sensitive"
        case .verySensitive: "Very Sensitive"
        case .notSureYet: "Not Sure Yet"
        }
    }
}

private extension SkinConcernTag {
    var personalizationDisplayName: String {
        switch self {
        case .blackheads: "Blackheads"
        case .whiteheads: "Whiteheads"
        case .acne: "Red Pimples"
        case .inflamedAcne: "Inflamed Pimples"
        case .deepAcne: "Deep Pimples"
        case .darkSpots: "Dark Acne Marks"
        case .redness: "Redness"
        case .flecks: "Dark Spots"
        case .freckles: "Brown or Gray Spots"
        case .sunSpots: "Sun Spots"
        case .unevenTone: "Uneven Skin Tone"
        case .dullSkin: "Dull Skin"
        }
    }
}

#Preview {
    PersonalizationView { _ in }
}

private extension PersonalizationPhase {
    var showsSideNavigation: Bool {
        switch self {
        case .skinTypeResult, .skinSensitivityResult, .summary:
            false
        default:
            true
        }
    }

    var fillsCurrentMilestone: Bool {
        switch self {
        case .skinTypeResult, .skinSensitivityResult, .summary:
            true
        default:
            false
        }
    }
}
