//
//  JourneyDetailView.swift
//  C4-MySkin
//

import SwiftUI

struct JourneyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let product: SkincareProduct
    let onStart: () -> Void

    @State private var viewModel: JourneyDetailViewModel?

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
                // Top bar with Back button
                HStack {
                    BackButton {
                        dismiss()
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Selected Product")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                            .padding(.top, 12)

                        SelectedProductCard(product: product)

                        Text("You'll go through 2 milestones")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(Milestone.defaultMilestones) { milestone in
                                MilestoneDetailRow(milestone: milestone)
                            }
                        }

                        Spacer(minLength: 24)

                        TipCard()
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                PillButton(title: "Start Journey") {
                    viewModel?.startJourney()
                    onStart()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel = JourneyDetailViewModel(product: product, store: .shared)
        }
    }
}

private struct SelectedProductCard: View {
    let product: SkincareProduct

    var body: some View {
        HStack(spacing: 16) {
            JarIconView()

            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand == "detail" || product.brand.lowercased().starts(with: "brand") ? "Oil Face Wash" : product.brand)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                Text("Niacinamide, AHA, Panthenol")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(red: 0.35, green: 0.58, blue: 0.85))
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

private struct MilestoneDetailRow: View {
    let milestone: Milestone

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Milestone \(milestone.order)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

            Text(milestone.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

            Text("to see the\nblablabla\nblablabla")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color(red: 0.45, green: 0.52, blue: 0.60))
                .lineSpacing(2)
                .padding(.top, 2)
        }
    }
}

private struct TipCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("for the best results, take\na progress photo \(Text("every 2 weeks").font(.system(size: 16, weight: .bold)).foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42)))")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
            .lineSpacing(2)

            Text("We'll remind you when it's time for each check in")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color(red: 0.60, green: 0.65, blue: 0.72))
                .padding(.top, 2)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.29, green: 0.56, blue: 0.89), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    JourneyDetailView(product: SkincareProduct.samples[0], onStart: {})
}

