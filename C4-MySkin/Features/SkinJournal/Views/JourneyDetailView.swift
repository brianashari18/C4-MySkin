//
//  JourneyDetailView.swift
//  C4-MySkin
//

import SwiftUI

struct JourneyDetailView: View {
    let product: SkincareProduct
    let onStart: () -> Void

    @State private var viewModel: JourneyDetailViewModel?

    var body: some View {
        VStack(spacing: 0) {
            BackButton { }
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Text("Selected product")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ProductRow(product: product)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            Text("You'll go through 2 milestones")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 24) {
                ForEach(Milestone.defaultMilestones) { milestone in
                    MilestoneRow(milestone: milestone)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)

            TipCard()
                .padding(.horizontal, 20)
                .padding(.top, 24)

            Spacer()

            PillButton(title: "Start journey") {
                viewModel?.startJourney()
                onStart()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .onAppear {
            viewModel = JourneyDetailViewModel(product: product)
        }
    }
}

private struct ProductRow: View {
    let product: SkincareProduct

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "drop.fill")
                        .foregroundStyle(Color(.secondaryLabel))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .font(.body.weight(.semibold))
                Text(product.name)
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

private struct MilestoneRow: View {
    let milestone: Milestone

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Milestone \(milestone.order)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(.secondaryLabel))

            Text(milestone.title)
                .font(.title3.weight(.bold))

            Text(milestone.subtitle)
                .font(.body)
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(2)
        }
    }
}

private struct TipCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("for the best results, take a progress photo **every 2 weeks**")
                .font(.body)
            Text("We'll remind you when it's time for each check in")
                .font(.footnote)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

#Preview {
    JourneyDetailView(product: SkincareProduct.samples[0], onStart: {})
}
