//
//  ValidationResultView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 4 — Validation Result
/// Displays product validation details using expandable accordion cards (Insight, Ingredients, Key Ingredients, Benefits, Concerns).
/// Supports single product layout and side-by-side comparison mode with ingredient match checkmarks and rich descriptions.
struct ValidationResultView: View {

    @ObservedObject var viewModel: ProductValidationViewModel
    @State private var showAddMenu: Bool = false
    @State private var isIngredientsExpanded: Bool = false
    @State private var isBenefitsExpanded: Bool = false
    @State private var isConcernsExpanded: Bool = false

    private let result: ValidationResult

    init(viewModel: ProductValidationViewModel, result: ValidationResult) {
        self.viewModel = viewModel
        self.result = result
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.App.backgroundGray.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                HStack {
                    Button { viewModel.goBackFromResult() } label: {
                        Image(systemName: "chevron.left")
                            .font(Font.App.nunitoRounded(size: 18, weight: .semibold))
                            .foregroundStyle(Color.App.textDark)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.85)))
                    }

                    Spacer()

                    // Show "+" only when not yet in comparison mode
                    if !viewModel.isComparisonMode {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showAddMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(Font.App.nunitoRounded(size: 18, weight: .semibold))
                                .foregroundStyle(Color.App.textDark)
                                .padding(10)
                                .background(Circle().fill(Color.white.opacity(0.85)))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // MARK: - Scrollable Content
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.isComparisonMode, let secondResult = viewModel.secondValidationResult {
                            // ── Mode Komparasi (2 Produk) ──
                            comparisonProductCards(first: result, second: secondResult)

                            // 1. Insight Section Structure
                            insightComparisonCard(first: result, second: secondResult)

                            // 2. Ingredients Section (with ✓ / ✗ checkmarks)
                            ingredientsComparisonCard(first: result, second: secondResult)

                            // 3. Key Ingredients Section (with Best For)
                            keyIngredientsComparisonCard(first: result, second: secondResult)

                            // 4. Benefits Section
                            benefitsComparisonCard(first: result, second: secondResult)

                            // 5. Concerns Section
                            concernsComparisonCard(first: result, second: secondResult)

                        } else {
                            // ── Mode Single Product ──
                            singleProductHeader(result: result)

                            insightSingleCard(result: result)

                            ingredientsSingleCard(result: result)

                            keyIngredientsSingleCard(result: result)

                            benefitsSingleCard(result: result)

                            concernsSingleCard(result: result)
                        }

                        Spacer().frame(height: 90) // Room for Selesai button
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                // MARK: - Selesai Button (pinned)
                Button { viewModel.finish() } label: {
                    Text("Selesai")
                        .font(Font.App.nunitoRounded(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.App.mediumBlue)
                                .shadow(color: Color.App.mediumBlue.opacity(0.45), radius: 12, x: 0, y: 5)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(Color.App.backgroundGray)
            }

            // MARK: - "+" Popup Menu
            if showAddMenu {
                addPopupMenu
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                    .transition(.scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showAddMenu)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isComparisonMode)
        .contentShape(Rectangle())
        .onTapGesture {
            if showAddMenu { withAnimation { showAddMenu = false } }
        }
        .sheet(isPresented: $viewModel.showIngredientSheet) {
            IngredientDetailSheetView(
                ingredientName: viewModel.selectedIngredientName ?? "",
                detail: viewModel.selectedIngredientDetail,
                isLoading: viewModel.isLoadingIngredientDetail,
                errorMessage: viewModel.ingredientDetailError
            )
        }
    }

    // MARK: - Single Product Header Image & Brand/Title

    @ViewBuilder
    private func singleProductHeader(result: ValidationResult) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.App.lightBlue.opacity(0.15))

                if let image = viewModel.firstSelectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                } else if let imageURL = result.imageURL, let url = URL(string: imageURL) {
                    CachedAsyncImage(url: url) {
                        placeholderImage
                    }
                    .scaledToFit()
                    .padding(12)
                } else {
                    placeholderImage
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.App.lightBlue.opacity(0.5), lineWidth: 1.5)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(result.brand)
                    .font(Font.App.nunitoRounded(size: 13, weight: .semibold))
                    .foregroundStyle(Color.gray)
                Text(result.productName)
                    .font(Font.App.nunitoRounded(size: 18, weight: .bold))
                    .foregroundStyle(Color.App.darkBlue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
    }

    // MARK: - Comparison Header: Product Cards (Brand + Title)

    @ViewBuilder
    private func comparisonProductCards(first: ValidationResult, second: ValidationResult) -> some View {
        HStack(alignment: .top, spacing: 12) {
            productCard(image: viewModel.firstSelectedImage, brand: first.brand, name: first.productName)
            productCard(image: viewModel.secondSelectedImage, brand: second.brand, name: second.productName)
        }
    }

    @ViewBuilder
    private func productCard(image: UIImage?, brand: String, name: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.App.lightBlue.opacity(0.15))

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                    } else if let imageURL = comparisonImageURL(for: name), let url = URL(string: imageURL) {
                        CachedAsyncImage(url: url) {
                            comparisonPlaceholder
                        }
                        .scaledToFit()
                        .padding(8)
                    } else {
                        comparisonPlaceholder
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.App.sunnyYellow, lineWidth: 2)
                )

                // Bookmark / Heart icon
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.gray.opacity(0.6))
                    .padding(8)
            }

            Text(brand)
                .font(Font.App.nunitoRounded(size: 12, weight: .medium))
                .foregroundStyle(Color.gray)

            Text(name)
                .font(Font.App.nunitoRounded(size: 14, weight: .bold))
                .foregroundStyle(Color.App.darkBlue)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 1. Insight Section

    @ViewBuilder
    private func insightSingleCard(result: ValidationResult) -> some View {
        ValidationCardView(title: "Insight") {
            VStack(alignment: .leading, spacing: 10) {
                insightRow(title: "Brand Reputation", text: result.brandReputation.ifEmpty("Established skincare brand with strong market presence."))
                insightRow(title: "Review", text: result.reviewSummary.ifEmpty("Users appreciate effective cleansing performance."))
                insightRow(title: "Price", text: result.priceSummary.ifEmpty("Affordable option for daily skincare use."))
                insightRow(title: "Ingredients Match", text: result.ingredientsMatchSummary.ifEmpty("Contains active ingredients targeting skin concerns."))
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func insightComparisonCard(first: ValidationResult, second: ValidationResult) -> some View {
        ValidationCardView(title: "Insight") {
            HStack(alignment: .top, spacing: 0) {
                // Product 1
                VStack(alignment: .leading, spacing: 10) {
                    insightRow(title: "Brand Reputation", text: first.brandReputation.ifEmpty("Established skincare brand with strong market presence."))
                    insightRow(title: "Review", text: first.reviewSummary.ifEmpty("Users appreciate effective cleansing performance."))
                    insightRow(title: "Price", text: first.priceSummary.ifEmpty("Affordable option for daily skincare use."))
                    insightRow(title: "Ingredients Match", text: first.ingredientsMatchSummary.ifEmpty("Contains active ingredients targeting skin concerns."))
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(Color.App.sunnyYellow.opacity(0.6))
                    .frame(width: 1.5)

                // Product 2
                VStack(alignment: .leading, spacing: 10) {
                    insightRow(title: "Brand Reputation", text: second.brandReputation.ifEmpty("Growing skincare brand with increasing popularity."))
                    insightRow(title: "Review", text: second.reviewSummary.ifEmpty("Users report refreshing feel and gentle cleansing."))
                    insightRow(title: "Price", text: second.priceSummary.ifEmpty("Competitive price point in category."))
                    insightRow(title: "Ingredients Match", text: second.ingredientsMatchSummary.ifEmpty("Focuses on balanced oil control and hydration."))
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func insightRow(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                .foregroundStyle(Color.App.darkBlue)
            Text(text)
                .font(Font.App.nunitoRounded(size: 12, weight: .medium))
                .foregroundStyle(Color.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - 2. Ingredients Section (with ✓ / ✗, row alignment, View More, and Tappable Sheet)

    @ViewBuilder
    private func ingredientsSingleCard(result: ValidationResult) -> some View {
        let displayLimit = 6
        let visibleChecks = isIngredientsExpanded ? result.ingredientChecks : Array(result.ingredientChecks.prefix(displayLimit))

        ValidationCardView(title: "Ingredients") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(visibleChecks) { item in
                    Button {
                        viewModel.inspectIngredient(name: item.name)
                    } label: {
                        HStack {
                            Text(item.name)
                                .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                                .foregroundStyle(Color.App.darkBlue)
                            Spacer()
                            Image(systemName: item.isPresent ? "checkmark" : "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(item.isPresent ? Color.App.darkBlue : Color.gray.opacity(0.5))
                        }
                    }
                    .buttonStyle(.plain)
                }

                if result.ingredientChecks.count > displayLimit {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isIngredientsExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text(isIngredientsExpanded ? "Tampilkan Lebih Sedikit" : "Lihat Selengkapnya (\(result.ingredientChecks.count - displayLimit)+)")
                                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                            Image(systemName: isIngredientsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func ingredientsComparisonCard(first: ValidationResult, second: ValidationResult) -> some View {
        let set1 = Set(first.ingredientChecks.filter(\.isPresent).map { $0.name.lowercased() })
        let set2 = Set(second.ingredientChecks.filter(\.isPresent).map { $0.name.lowercased() })
        let displayLimit = 6
        let totalMasterCount = countMasterNames(first: first, second: second)
        let visibleMasterNames = buildMasterNames(first: first, second: second)

        ValidationCardView(title: "Ingredients") {
            VStack(spacing: 10) {
                HStack(alignment: .top, spacing: 0) {
                    // Product 1 Column
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(visibleMasterNames, id: \.self) { name in
                            let isPresentInFirst = set1.contains(name.lowercased())
                            let isMatchInBoth = isPresentInFirst && set2.contains(name.lowercased())

                            Button {
                                viewModel.inspectIngredient(name: name)
                            } label: {
                                HStack {
                                    Text(name)
                                        .font(Font.App.nunitoRounded(size: 13, weight: isMatchInBoth ? .bold : .medium))
                                        .foregroundStyle(isMatchInBoth ? Color.App.darkBlue : (isPresentInFirst ? Color.App.darkBlue : Color.gray.opacity(0.6)))
                                    Spacer()
                                    Image(systemName: isPresentInFirst ? "checkmark" : "xmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(isPresentInFirst ? Color.App.darkBlue : Color.gray.opacity(0.4))
                                }
                                .background(isMatchInBoth ? Color.gray.opacity(0.12) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle()
                        .fill(Color.App.sunnyYellow.opacity(0.6))
                        .frame(width: 1.5)

                    // Product 2 Column
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(visibleMasterNames, id: \.self) { name in
                            let isPresentInSecond = set2.contains(name.lowercased())
                            let isMatchInBoth = isPresentInSecond && set1.contains(name.lowercased())

                            Button {
                                viewModel.inspectIngredient(name: name)
                            } label: {
                                HStack {
                                    Text(name)
                                        .font(Font.App.nunitoRounded(size: 13, weight: isMatchInBoth ? .bold : .medium))
                                        .foregroundStyle(isMatchInBoth ? Color.App.darkBlue : (isPresentInSecond ? Color.App.darkBlue : Color.gray.opacity(0.6)))
                                    Spacer()
                                    Image(systemName: isPresentInSecond ? "checkmark" : "xmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(isPresentInSecond ? Color.App.darkBlue : Color.gray.opacity(0.4))
                                }
                                .background(isMatchInBoth ? Color.gray.opacity(0.12) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if totalMasterCount > displayLimit {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isIngredientsExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text(isIngredientsExpanded ? "Tampilkan Lebih Sedikit" : "Lihat Selengkapnya (\(totalMasterCount - displayLimit)+)")
                                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                            Image(systemName: isIngredientsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func countMasterNames(first: ValidationResult, second: ValidationResult) -> Int {
        var seen = Set<String>()
        for item in first.ingredientChecks where item.isPresent {
            seen.insert(item.name.lowercased())
        }
        for item in second.ingredientChecks where item.isPresent {
            seen.insert(item.name.lowercased())
        }
        return seen.count
    }

    private func buildMasterNames(first: ValidationResult, second: ValidationResult) -> [String] {
        var masterNames: [String] = []
        var seen = Set<String>()

        for item in first.ingredientChecks where item.isPresent {
            let key = item.name.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                masterNames.append(item.name)
            }
        }

        for item in second.ingredientChecks where item.isPresent {
            let key = item.name.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                masterNames.append(item.name)
            }
        }

        let displayLimit = 6
        return isIngredientsExpanded ? masterNames : Array(masterNames.prefix(displayLimit))
    }

    // MARK: - 3. Key Ingredients Section (with Best For)

    @ViewBuilder
    private func keyIngredientsSingleCard(result: ValidationResult) -> some View {
        ValidationCardView(title: "Key Ingredients") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(result.keyIngredientItems) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(Font.App.nunitoRounded(size: 14, weight: .bold))
                            .foregroundStyle(Color.App.darkBlue)
                        Text(item.description)
                            .font(Font.App.nunitoRounded(size: 12, weight: .medium))
                            .foregroundStyle(Color.gray)
                    }
                }

                if !result.bestForSummary.isEmpty {
                    Divider().padding(.vertical, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Best For")
                            .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                            .foregroundStyle(Color.App.darkBlue)
                        Text(result.bestForSummary)
                            .font(Font.App.nunitoRounded(size: 12, weight: .medium))
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func keyIngredientsComparisonCard(first: ValidationResult, second: ValidationResult) -> some View {
        ValidationCardView(title: "Key Ingredients") {
            HStack(alignment: .top, spacing: 0) {
                // Product 1 Column
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(first.keyIngredientItems) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                .foregroundStyle(Color.App.darkBlue)
                            Text(item.description)
                                .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                .foregroundStyle(Color.gray)
                        }
                    }

                    if !first.bestForSummary.isEmpty {
                        Divider().padding(.vertical, 2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Best For")
                                .font(Font.App.nunitoRounded(size: 12, weight: .bold))
                                .foregroundStyle(Color.App.darkBlue)
                            Text(first.bestForSummary)
                                .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(Color.App.sunnyYellow.opacity(0.6))
                    .frame(width: 1.5)

                // Product 2 Column
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(second.keyIngredientItems) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                .foregroundStyle(Color.App.darkBlue)
                            Text(item.description)
                                .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                .foregroundStyle(Color.gray)
                        }
                    }

                    if !second.bestForSummary.isEmpty {
                        Divider().padding(.vertical, 2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Best For")
                                .font(Font.App.nunitoRounded(size: 12, weight: .bold))
                                .foregroundStyle(Color.App.darkBlue)
                            Text(second.bestForSummary)
                                .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - 4. Benefits Section

    @ViewBuilder
    private func benefitsSingleCard(result: ValidationResult) -> some View {
        let displayLimit = 2
        let visibleItems = isBenefitsExpanded ? result.benefitItems : Array(result.benefitItems.prefix(displayLimit))

        ZStack(alignment: .center) {
            ValidationCardView(title: "Benefits") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(visibleItems) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(Font.App.nunitoRounded(size: 14, weight: .bold))
                                .foregroundStyle(Color.App.darkBlue)
                            Text(item.description)
                                .font(Font.App.nunitoRounded(size: 12, weight: .medium))
                                .foregroundStyle(Color.gray)
                        }
                    }

                    if result.benefitItems.count > displayLimit {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                isBenefitsExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                Text(isBenefitsExpanded ? "Tampilkan Lebih Sedikit" : "Lihat Selengkapnya (\(result.benefitItems.count - displayLimit)+)")
                                    .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                    .foregroundStyle(Color.App.mediumBlue)
                                Image(systemName: isBenefitsExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.App.mediumBlue)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .opacity(result.isSuited ? 1.0 : 0.45)

            if !result.isSuited {
                quizOverlayPill
            }
        }
    }

    @ViewBuilder
    private func benefitsComparisonCard(first: ValidationResult, second: ValidationResult) -> some View {
        let displayLimit = 2
        let visibleFirst = isBenefitsExpanded ? first.benefitItems : Array(first.benefitItems.prefix(displayLimit))
        let visibleSecond = isBenefitsExpanded ? second.benefitItems : Array(second.benefitItems.prefix(displayLimit))

        let maxCount = max(first.benefitItems.count, second.benefitItems.count)

        ZStack(alignment: .center) {
            ValidationCardView(title: "Benefits") {
                VStack(spacing: 10) {
                    HStack(alignment: .top, spacing: 0) {
                        // Left Column
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(visibleFirst) { item in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                        .foregroundStyle(Color.App.darkBlue)
                                    Text(item.description)
                                        .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Rectangle()
                            .fill(Color.App.sunnyYellow.opacity(0.6))
                            .frame(width: 1.5)

                        // Right Column
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(visibleSecond) { item in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                        .foregroundStyle(Color.App.darkBlue)
                                    Text(item.description)
                                        .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                        .foregroundStyle(Color.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if maxCount > displayLimit {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                isBenefitsExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                Text(isBenefitsExpanded ? "Tampilkan Lebih Sedikit" : "Lihat Selengkapnya (\(maxCount - displayLimit)+)")
                                    .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                    .foregroundStyle(Color.App.mediumBlue)
                                Image(systemName: isBenefitsExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.App.mediumBlue)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .opacity(first.isSuited && second.isSuited ? 1.0 : 0.45)

            if !first.isSuited || !second.isSuited {
                quizOverlayPill
            }
        }
    }

    // MARK: - 5. Concerns / Kekurangan Section

    @ViewBuilder
    private func concernsSingleCard(result: ValidationResult) -> some View {
        let displayLimit = 2
        let visibleItems = isConcernsExpanded ? result.concernItems : Array(result.concernItems.prefix(displayLimit))

        ValidationCardView(title: "Concerns") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(visibleItems) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(Font.App.nunitoRounded(size: 14, weight: .bold))
                            .foregroundStyle(Color.App.darkBlue)
                        Text(item.description)
                            .font(Font.App.nunitoRounded(size: 12, weight: .medium))
                            .foregroundStyle(Color.gray)
                    }
                }

                if result.concernItems.count > displayLimit {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isConcernsExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text(isConcernsExpanded ? "Tampilkan Lebih Sedikit" : "Lihat Selengkapnya (\(result.concernItems.count - displayLimit)+)")
                                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                            Image(systemName: isConcernsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func concernsComparisonCard(first: ValidationResult, second: ValidationResult) -> some View {
        let displayLimit = 2
        let visibleFirst = isConcernsExpanded ? first.concernItems : Array(first.concernItems.prefix(displayLimit))
        let visibleSecond = isConcernsExpanded ? second.concernItems : Array(second.concernItems.prefix(displayLimit))

        let maxCount = max(first.concernItems.count, second.concernItems.count)

        ValidationCardView(title: "Concerns") {
            VStack(spacing: 10) {
                HStack(alignment: .top, spacing: 0) {
                    // Left Column
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(visibleFirst) { item in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                    .foregroundStyle(Color.App.darkBlue)
                                Text(item.description)
                                    .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle()
                        .fill(Color.App.sunnyYellow.opacity(0.6))
                        .frame(width: 1.5)

                    // Right Column
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(visibleSecond) { item in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                    .foregroundStyle(Color.App.darkBlue)
                                Text(item.description)
                                    .font(Font.App.nunitoRounded(size: 11, weight: .medium))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if maxCount > displayLimit {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isConcernsExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Text(isConcernsExpanded ? "Tampilkan Lebih Sedikit" : "Lihat Selengkapnya (\(maxCount - displayLimit)+)")
                                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                            Image(systemName: isConcernsExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.App.mediumBlue)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helpers & Placeholders

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .font(.system(size: 40, weight: .light))
            .foregroundStyle(Color.App.mediumBlue.opacity(0.5))
    }

    private var comparisonPlaceholder: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.App.mediumBlue.opacity(0.3))
                .frame(width: 50, height: 20)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.9))
                .frame(width: 70, height: 52)
                .offset(y: -3)
        }
    }

    private func comparisonImageURL(for name: String) -> String? {
        if result.productName == name {
            return result.imageURL
        }
        if viewModel.secondValidationResult?.productName == name {
            return viewModel.secondValidationResult?.imageURL
        }
        return nil
    }

    private var quizOverlayPill: some View {
        Button {
            // Navigate to personal quiz flow
        } label: {
            Text("Selesaikan Kuis Personalisasi")
                .font(Font.App.nunitoRounded(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(Color.App.mediumBlue)
                        .shadow(color: Color.App.mediumBlue.opacity(0.35), radius: 8, x: 0, y: 4)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - "+" Add Popup Menu

    @ViewBuilder
    private var addPopupMenu: some View {
        VStack(spacing: 0) {
            Button {
                showAddMenu = false
                viewModel.openCamera()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera").font(.system(size: 15))
                    Text("Kamera").font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            Divider()

            Button {
                showAddMenu = false
                viewModel.openOther()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").font(.system(size: 15))
                    Text("Lainnya...").font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .frame(width: 190)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.97))
                .shadow(color: Color.App.darkBlue.opacity(0.15), radius: 12, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : self
    }
}

// MARK: - Preview
#Preview("Single") {
    let vm = ProductValidationViewModel()
    ValidationResultView(viewModel: vm, result: ValidationResult.stub)
}

#Preview("Comparison") {
    let vm = ProductValidationViewModel()
    vm.secondValidationResult = ValidationResult.stub2
    return ValidationResultView(viewModel: vm, result: ValidationResult.stub)
}
