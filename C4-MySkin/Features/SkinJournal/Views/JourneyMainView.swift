//
//  JourneyMainView.swift
//  C4-MySkin
//

import SwiftUI

struct JourneyMainView: View {
    @State private var viewModel: JourneyMainViewModel?
    let journey: SkincareJourney
    let onAddImage: () -> Void
    let onJournalEntry: () -> Void
    let onSelfAssessment: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Your skin from time to time")
                    .font(.title2.weight(.bold))
                    .padding(.top, 16)

                ProgressPhotoCard()
                    .padding(.horizontal, 20)

                Button(action: onAddImage) {
                    Text("Add Image")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(.label))
                        .frame(minWidth: 160, minHeight: 48)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Image")

                MilestoneCard(
                    milestones: viewModel?.journey.milestones ?? journey.milestones,
                    onJournalEntry: onJournalEntry,
                    onSelfAssessment: onSelfAssessment
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 32)
            }
        }
        .onAppear {
            viewModel = JourneyMainViewModel(journey: journey)
        }
    }
}

private struct MilestoneCard: View {
    let milestones: [Milestone]
    let onJournalEntry: () -> Void
    let onSelfAssessment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestone #\(currentMilestoneOrder)")
                .font(.title3.weight(.bold))

            MilestoneTimeline(milestones: milestones)

            Divider()

            VStack(spacing: 12) {
                Button(action: onJournalEntry) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("add your skincare journey")
                            .font(.body.weight(.medium))
                        Spacer()
                    }
                    .foregroundStyle(Color(.label))
                    .padding(16)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onSelfAssessment) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete milestone check")
                            .font(.body.weight(.medium))
                        Spacer()
                    }
                    .foregroundStyle(Color(.label))
                    .padding(16)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var currentMilestoneOrder: Int {
        milestones.first { !$0.isCompleted }?.order ?? milestones.count
    }
}

#Preview {
    JourneyMainView(
        journey: SkincareJourney(product: SkincareProduct.samples[0]),
        onAddImage: {},
        onJournalEntry: {},
        onSelfAssessment: {}
    )
}
