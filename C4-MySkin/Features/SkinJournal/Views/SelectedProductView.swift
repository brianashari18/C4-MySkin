//
//  SelectedProductView.swift
//  C4-MySkin
//

import SwiftUI

struct SelectedProductView: View {
    @Environment(\.dismiss) private var dismiss
    let product: SkincareProduct
    let onStartJourney: () -> Void

    @State private var viewModel: SelectedProductViewModel
    @State private var selectedValidationResult: ValidationResult? = nil
    @State private var showValidationResultSheet: Bool = false
    @State private var isFetchingDetails: Bool = false

    init(product: SkincareProduct, onStartJourney: @escaping () -> Void) {
        self.product = product
        self.onStartJourney = onStartJourney
        _viewModel = State(initialValue: SelectedProductViewModel(product: product))
    }

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
                // Top Bar with Back Button & Title (matching Main Page header top padding)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        Spacer()
                    }

                    Text("Selected Product")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                }
                .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // 1. Selected Product Card (Tappable for Product Details)
                        Button {
                            guard !isFetchingDetails else { return }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            isFetchingDetails = true
                            Task {
                                let result = await viewModel.fetchValidationResult()
                                selectedValidationResult = result
                                isFetchingDetails = false
                                showValidationResultSheet = true
                            }
                        } label: {
                            SelectedProductCard(
                                product: product,
                                keyIngredients: viewModel.keyIngredients,
                                isLoading: viewModel.isLoading,
                                isFetchingDetails: isFetchingDetails
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isFetchingDetails)
                        .padding(.top, 16)

                        // 2. You'll go through 2 milestones section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("You'll go through 2 milestones")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                            // Milestone 1
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Milestone 1\nCompatibility Check")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                                Text("to see if your skin has any reaction like purging or breakout")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color(red: 0.45, green: 0.55, blue: 0.65))
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            // Milestone 2
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Milestone 2\nResults Check")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                                Text("to see the progress and improvements on your skin condition")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color(red: 0.45, green: 0.55, blue: 0.65))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Spacer(minLength: 12)

                        // 3. Progress Photo Reminder Card
                        VStack(alignment: .leading, spacing: 6) {
                            Text("for the best results, take\na progress photo \(Text("every 2 weeks").bold())")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                            Text("We'll remind you when it's time for each check in")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color(red: 0.55, green: 0.62, blue: 0.70))
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(red: 0.38, green: 0.61, blue: 0.93), lineWidth: 1.5)
                        )
                        .offset(y: 90)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 16)

                // 4. Start Journey Bottom CTA Button
                PillButton(
                    title: "Open Camera",
                    isEnabled: true
                ) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onStartJourney()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadDetails()
        }
        .sheet(isPresented: $showValidationResultSheet) {
            if let result = selectedValidationResult {
                ValidationResultView(result: result, allowsComparison: false)
            }
        }
    }
}

// MARK: - Selected Product Card View
private struct SelectedProductCard: View {
    let product: SkincareProduct
    let keyIngredients: [String]
    let isLoading: Bool
    var isFetchingDetails: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Product image / placeholder
            Group {
                if let imageURL = product.imageURL, let url = URL(string: imageURL) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)

                        CachedAsyncImage(url: url) {
                            jarPlaceholder
                        }
                        .scaledToFit()
                        .padding(6)
                    }
                    .frame(width: 64, height: 64)
                } else {
                    jarPlaceholder
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                    .lineLimit(2)

                Text(product.brand)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 0.38, green: 0.61, blue: 0.93))
                    .lineLimit(1)

                if isLoading {
                    Text("Loading ingredients…")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(red: 0.55, green: 0.62, blue: 0.70))
                } else if !keyIngredients.isEmpty {
                    Text(keyIngredients.prefix(3).joined(separator: ", "))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(red: 0.45, green: 0.55, blue: 0.65))
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(red: 0.38, green: 0.61, blue: 0.93), lineWidth: 1.5)
        )
        .overlay(
            Group {
                if isFetchingDetails {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.92))

                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(Color(red: 0.29, green: 0.56, blue: 0.89))
                            Text("Loading product details…")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                        }
                    }
                    .transition(.opacity)
                }
            }
        )
    }

    private var jarPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.88, green: 0.91, blue: 0.94))
                .frame(width: 64, height: 64)

            Image(systemName: product.iconName ?? "jar.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color(red: 0.45, green: 0.55, blue: 0.65))
        }
    }
}

#Preview {
    SelectedProductView(
        product: SkincareProduct.samples[0],
        onStartJourney: {}
    )
}
