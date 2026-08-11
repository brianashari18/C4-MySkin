//
//  SkinJournalRootView.swift
//  C4-MySkin
//

import SwiftUI

struct SkinJournalRootView: View {
    @State private var viewModel = SkinJournalRootViewModel()
    @State private var path = NavigationPath()
    @State private var selectedProduct: SkincareProduct?

    var body: some View {
        NavigationStack(path: $path) {
            SkinJournalMainView(
                journey: viewModel.latestJourney,
                onSkinJournaling: { path.append(SkinJournalRoute.chooseProduct) },
                onProductValidation: { path.append(SkinJournalRoute.productValidation) }
            )
            .navigationDestination(for: SkinJournalRoute.self) { route in
                switch route {
                case .chooseProduct:
                    ChooseProductView(
                        selectedProduct: $selectedProduct,
                        onContinue: { path.append(SkinJournalRoute.journeyDetail) }
                    )

                case .journeyDetail:
                    if let product = selectedProduct {
                        JourneyDetailView(product: product) {
                            path.append(SkinJournalRoute.mainJourney)
                        }
                    }

                case .mainJourney:
                    if let journey = viewModel.latestJourney {
                        JourneyMainView(
                            journey: journey,
                            onAddImage: { path.append(SkinJournalRoute.camera) },
                            onJournalEntry: { path.append(SkinJournalRoute.journalEntry) },
                            onSelfAssessment: { path.append(SkinJournalRoute.selfAssessment) }
                        )
                    }

                case .camera:
                    CameraFlowView { _ in
                        path.removeLast()
                    }

                case .journalEntry:
                    if viewModel.latestJourney != nil {
                        JournalEntryView(
                            milestoneTitle: "Milestone \(viewModel.latestJourney?.milestones.first { !$0.isCompleted }?.order ?? 1)"
                        ) { entry in
                            viewModel.updateLatestJourney { journey in
                                journey.journalEntries.append(entry)
                            }
                            path.removeLast()
                        } onBack: {
                            path.removeLast()
                        }
                    }

                case .selfAssessment:
                    SelfAssessmentView { mood, symptoms, note in
                        viewModel.updateLatestJourney { journey in
                            if let index = journey.journalEntries.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
                                journey.journalEntries[index].mood = mood
                                journey.journalEntries[index].symptoms = symptoms
                                journey.journalEntries[index].note += "\n\(note)"
                            }
                            if let milestoneIndex = journey.milestones.firstIndex(where: { !$0.isCompleted }) {
                                journey.milestones[milestoneIndex].isCompleted = true
                                journey.milestones[milestoneIndex].completedDate = Date()
                            }
                        }
                        path.removeLast()
                    } onBack: {
                        path.removeLast()
                    }

                case .productValidation:
                    ProductValidationPlaceholderView {
                        path.removeLast()
                    }
                }
            }
        }
    }
}

enum SkinJournalRoute: Hashable {
    case chooseProduct
    case journeyDetail
    case mainJourney
    case camera
    case journalEntry
    case selfAssessment
    case productValidation
}

#Preview {
    SkinJournalRootView()
}
