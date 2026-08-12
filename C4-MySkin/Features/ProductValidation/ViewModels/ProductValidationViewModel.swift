//
//  ProductValidationViewModel.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI
import Combine

@MainActor
final class ProductValidationViewModel: ObservableObject {
    private let apiClient: SkincareAPIClient
    private let browseQueries = ["cleanser", "serum", "sunscreen", "toner", "moisturizer", "kahf", "wardah"]

    // MARK: - Navigation State
    @Published var currentStep: ValidationStep = .imagePicker

    // MARK: - Image State
    /// Image currently being reviewed (used by PhotoReviewView)
    @Published var selectedImage: UIImage? = nil
    /// Locked-in image for product 1 (set when first validation completes)
    @Published var firstSelectedImage: UIImage? = nil
    /// Locked-in image for product 2 (set when second validation completes)
    @Published var secondSelectedImage: UIImage? = nil

    // MARK: - Camera Service
    let cameraService = CameraService()
    private var cameraCancellable: AnyCancellable?

    enum ProductSource {
        case camera
        case search
    }

    // MARK: - Validation State
    /// Result for product 1
    @Published var validationResult: ValidationResult? = nil
    /// Result for product 2 — non-nil triggers comparison layout
    @Published var secondValidationResult: ValidationResult? = nil
    @Published var isLoading: Bool = false
    @Published var showProductNotFoundModal: Bool = false

    @Published var firstProductSource: ProductSource = .camera
    @Published var secondProductSource: ProductSource = .camera

    // MARK: - Search State
    @Published var searchText: String = ""
    @Published var searchResults: [ProductSearchItem] = []
    @Published var searchErrorMessage: String? = nil

    // MARK: - Request State
    @Published var isSearching: Bool = false
    @Published var isLoadingResult: Bool = false
    @Published var loadingProductID: String? = nil
    @Published var hasLoadedBrowseProducts: Bool = false

    // MARK: - Ingredient Detail Sheet State
    @Published var selectedIngredientName: String? = nil
    @Published var selectedIngredientDetail: IngredientDetailResponse? = nil
    @Published var isLoadingIngredientDetail: Bool = false
    @Published var ingredientDetailError: String? = nil
    @Published var showIngredientSheet: Bool = false

    // MARK: - Computed
    var isComparisonMode: Bool { secondValidationResult != nil }

    // MARK: - Init

    init(apiClient: SkincareAPIClient = SkincareAPIClient()) {
        self.apiClient = apiClient

        cameraCancellable = cameraService.$capturedImage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] image in
                guard let self else { return }
                self.selectedImage = image
                self.currentStep = .review
            }
    }

    // MARK: - Navigation Actions

    /// "Camera" tapped → CameraScannerView
    func openCamera() { currentStep = .camera }

    /// "Other…" tapped → ProductSearchView
    func openOther() { currentStep = .search }

    // MARK: - Camera Actions

    func startCamera() {
        Task {
            // Wait for auth + session config to complete BEFORE starting the feed
            await cameraService.checkAuthorizationAndSetup()
            cameraService.startSession()
        }
    }

    func stopCamera() {
        cameraService.stopSession()
    }

    func capturePhoto() {
        cameraService.capturePhoto()
        // Navigation happens automatically via the cameraCancellable sink
    }

    // MARK: - Image Confirmed from Search Screen

    func confirmImage(_ image: UIImage) {
        selectedImage = image
        currentStep = .review
    }

    // MARK: - Validate (Photo OCR + Resolve API)
    /// Runs Vision OCR on the captured image to extract label text,
    /// then resolves product via GET /api/products/resolve.
    /// Shows Product Not Found modal if OCR fails or no matching product is found.
    func validate() {
        guard let image = selectedImage else {
            showProductNotFoundModal = true
            return
        }

        isLoading = true
        showProductNotFoundModal = false

        Task {
            if let recognizedText = await OCRService.extractText(from: image) {
                await resolveProductFromText(query: recognizedText)
            } else {
                isLoading = false
                showProductNotFoundModal = true
            }
        }
    }

    func searchProducts() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            await loadBrowseProducts(forceReload: false)
            return
        }

        isSearching = true
        searchErrorMessage = nil

        do {
            searchResults = try await fetchProducts(for: query)
        } catch {
            searchResults = []
            searchErrorMessage = error.localizedDescription
        }

        isSearching = false
    }

    func loadBrowseProducts(forceReload: Bool = false) async {
        guard forceReload || !hasLoadedBrowseProducts else { return }

        isSearching = true
        searchErrorMessage = nil

        do {
            let queries = browseQueries
            let allProducts = try await withThrowingTaskGroup(of: [ProductSearchItem].self) { group in
                for query in queries {
                    group.addTask { [weak self] in
                        guard let self else { return [] }
                        return (try? await self.fetchProducts(for: query)) ?? []
                    }
                }

                var results: [ProductSearchItem] = []
                for try await items in group {
                    results.append(contentsOf: items)
                }
                return results
            }

            var seenIDs = Set<String>()
            searchResults = allProducts.filter { product in
                seenIDs.insert(product.id).inserted
            }
            hasLoadedBrowseProducts = true
        } catch {
            searchResults = []
            searchErrorMessage = error.localizedDescription
        }

        isSearching = false
    }

    private func getProductDossierWithProfile(slug: String) async throws -> ProductDossierResponse {
        let profile = AppDataService.shared.fetchOrCreateProfile()
        return try await apiClient.getProductDossier(
            slug: slug,
            enrich: true,
            skinType: profile.skinTypeRaw,
            skinSensitivity: profile.skinSensitivityRaw,
            concernAcnePore: nil,
            concernSkinTone: nil,
            concernSunDamage: nil
        )
    }

    private func fetchProducts(for query: String) async throws -> [ProductSearchItem] {
        let response = try await apiClient.searchProducts(query: query)
        return try await enrichProducts(response.results)
    }

    private func enrichProducts(_ products: [ProductSearchItem]) async throws -> [ProductSearchItem] {
        try await withThrowingTaskGroup(of: ProductSearchItem.self) { group in
            for product in products {
                let name = product.name
                let brand = product.brand
                let url = product.url
                let imageURL = product.imageURL
                let highlights = product.highlights
                let slug = product.slug
                group.addTask { [apiClient] in
                    // If search API already provided image_url, return immediately (fast cache path)
                    guard imageURL == nil else {
                        return product
                    }

                    guard let slug else {
                        return product
                    }

                    do {
                        let dossier = try await self.getProductDossierWithProfile(slug: slug)
                        return ProductSearchItem(
                            name: name,
                            brand: brand ?? dossier.product.brand,
                            url: url,
                            imageURL: dossier.product.imageURL,
                            highlights: highlights
                        )
                    } catch {
                        return product
                    }
                }
            }

            var enriched: [ProductSearchItem] = []
            enriched.reserveCapacity(products.count)

            for try await product in group {
                enriched.append(product)
            }

            return products.compactMap { original in
                enriched.first(where: { $0.id == original.id })
            }
        }
    }

    func selectProduct(_ product: ProductSearchItem) async {
        guard let slug = product.slug else {
            searchErrorMessage = "Unable to read product slug from API response."
            return
        }

        loadingProductID = product.id
        isLoadingResult = true
        searchErrorMessage = nil

        do {
            let dossier = try await getProductDossierWithProfile(slug: slug)
            let result = ValidationResult(dossier: dossier)

            if validationResult == nil {
                firstProductSource = .search
                validationResult = result
            } else {
                secondProductSource = .search
                secondValidationResult = result
            }

            currentStep = .result
        } catch {
            searchErrorMessage = error.localizedDescription
        }

        isLoadingResult = false
        loadingProductID = nil
    }

    // MARK: - Product Resolution (GET /api/products/resolve)
    /// Resolves OCR / complex product queries via GET /api/products/resolve.
    /// On success, loads the product dossier and navigates to the result screen.
    /// On failure or no match, triggers the Product Not Found modal overlay.
    func resolveProductFromText(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else {
            showProductNotFoundModal = true
            return
        }

        isLoading = true
        showProductNotFoundModal = false

        do {
            let resolveResponse = try await apiClient.resolveProduct(query: trimmed)
            if let resolvedProduct = resolveResponse.product, let slug = resolvedProduct.slug {
                let dossier = try await getProductDossierWithProfile(slug: slug)
                let result = ValidationResult(dossier: dossier)

                if validationResult == nil {
                    firstProductSource = .camera
                    firstSelectedImage = selectedImage
                    validationResult = result
                } else {
                    secondProductSource = .camera
                    secondSelectedImage = selectedImage
                    secondValidationResult = result
                }

                currentStep = .result
            } else {
                showProductNotFoundModal = true
            }
        } catch {
            showProductNotFoundModal = true
        }

        isLoading = false
    }

    func leaveSearch() {
        currentStep = validationResult == nil ? .imagePicker : .result
    }

    // MARK: - Back Navigation from Result Screen

    func goBackFromResult() {
        if isComparisonMode {
            let source = secondProductSource
            secondValidationResult = nil
            secondSelectedImage = nil
            if source == .search {
                currentStep = .search
            } else {
                currentStep = .result
            }
        } else {
            let source = firstProductSource
            validationResult = nil
            firstSelectedImage = nil
            selectedImage = nil
            if source == .search {
                currentStep = .search
            } else {
                currentStep = .imagePicker
            }
        }
    }

    // MARK: - Retake (returns to camera)
    func retake() {
        selectedImage = nil
        cameraService.capturedImage = nil
        showProductNotFoundModal = false
        currentStep = .camera
    }

    // MARK: - Scan Another Product (resets scanner from Product Not Found modal)
    func scanAnotherProduct() {
        showProductNotFoundModal = false
        selectedImage = nil
        cameraService.capturedImage = nil
        currentStep = .camera
        startCamera()
    }

    // MARK: - Full Reset (back to start)
    func reset() {
        selectedImage = nil
        firstSelectedImage = nil
        secondSelectedImage = nil
        validationResult = nil
        secondValidationResult = nil
        firstProductSource = .camera
        secondProductSource = .camera
        searchText = ""
        searchResults = []
        searchErrorMessage = nil
        isSearching = false
        isLoadingResult = false
        hasLoadedBrowseProducts = false
        cameraService.capturedImage = nil
        currentStep = .imagePicker
    }

    // MARK: - Finish
    func finish() {
        reset()
    }

    // MARK: - Ingredient Inspection
    func inspectIngredient(name: String) {
        selectedIngredientName = name
        showIngredientSheet = true
        Task {
            await fetchIngredientDetail(name: name)
        }
    }

    private func fetchIngredientDetail(name: String) async {
        isLoadingIngredientDetail = true
        ingredientDetailError = nil
        selectedIngredientDetail = nil

        do {
            let searchRes = try await apiClient.searchIngredients(query: name)
            if let firstMatch = searchRes.results.first {
                let detail = try await apiClient.getIngredient(slug: firstMatch.slug)
                selectedIngredientDetail = detail
            } else {
                let slug = name.lowercased().replacingOccurrences(of: " ", with: "-")
                let detail = try await apiClient.getIngredient(slug: slug)
                selectedIngredientDetail = detail
            }
        } catch {
            ingredientDetailError = "Informasi mendalam untuk '\(name)' belum tersedia dari database."
        }
        isLoadingIngredientDetail = false
    }
}
