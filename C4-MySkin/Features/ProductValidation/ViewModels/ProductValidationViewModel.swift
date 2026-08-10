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

    // MARK: - Validation State
    /// Result for product 1
    @Published var validationResult: ValidationResult? = nil
    /// Result for product 2 — non-nil triggers comparison layout
    @Published var secondValidationResult: ValidationResult? = nil
    @Published var isLoading: Bool = false

    // MARK: - Search State
    @Published var searchText: String = ""
    @Published var searchResults: [ProductSearchItem] = []
    @Published var searchErrorMessage: String? = nil

    // MARK: - Request State
    @Published var isSearching: Bool = false
    @Published var isLoadingResult: Bool = false
    @Published var hasLoadedBrowseProducts: Bool = false

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
        Task { await cameraService.checkAuthorizationAndSetup() }
        cameraService.startSession()
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

    // MARK: - Validate
    /// First call  → stores product 1 image + result, navigates to result screen.
    /// Second call → stores product 2 image + result, switches to comparison layout.
    func validate() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.isLoading = false

            if self.validationResult == nil {
                self.firstSelectedImage = self.selectedImage
                self.validationResult = ValidationResult.stub
            } else {
                self.secondSelectedImage = self.selectedImage
                self.secondValidationResult = ValidationResult.stub2
            }

            self.currentStep = .result
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
            var groupedResults: [ProductSearchItem] = []
            for query in browseQueries {
                let products = try await fetchProducts(for: query)
                groupedResults.append(contentsOf: products)
            }

            var seenIDs = Set<String>()
            searchResults = groupedResults.filter { product in
                seenIDs.insert(product.id).inserted
            }
            hasLoadedBrowseProducts = true
        } catch {
            searchResults = []
            searchErrorMessage = error.localizedDescription
        }

        isSearching = false
    }

    private func fetchProducts(for query: String) async throws -> [ProductSearchItem] {
        let response = try await apiClient.searchProducts(query: query)
        return try await enrichProducts(response.results)
    }

    private func enrichProducts(_ products: [ProductSearchItem]) async throws -> [ProductSearchItem] {
        try await withThrowingTaskGroup(of: ProductSearchItem.self) { group in
            for product in products {
                group.addTask { [apiClient] in
                    guard product.imageURL == nil || product.highlights.isEmpty else {
                        return product
                    }

                    guard let slug = product.slug else {
                        return product
                    }

                    let dossier = try await apiClient.getProductDossier(slug: slug, enrich: true)

                    return ProductSearchItem(
                        name: product.name,
                        url: product.url,
                        imageURL: dossier.product.imageURL,
                        highlights: dossier.product.highlights
                    )
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

        isLoadingResult = true
        searchErrorMessage = nil

        do {
            let dossier = try await apiClient.getProductDossier(slug: slug, enrich: true)
            let result = ValidationResult(dossier: dossier)

            if validationResult == nil {
                validationResult = result
            } else {
                secondValidationResult = result
            }

            currentStep = .result
        } catch {
            searchErrorMessage = error.localizedDescription
        }

        isLoadingResult = false
    }

    func leaveSearch() {
        currentStep = validationResult == nil ? .imagePicker : .result
    }

    // MARK: - Retake (returns to camera)
    func retake() {
        selectedImage = nil
        cameraService.capturedImage = nil
        currentStep = .camera
    }

    // MARK: - Full Reset (back to start)
    func reset() {
        selectedImage = nil
        firstSelectedImage = nil
        secondSelectedImage = nil
        validationResult = nil
        secondValidationResult = nil
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
}
