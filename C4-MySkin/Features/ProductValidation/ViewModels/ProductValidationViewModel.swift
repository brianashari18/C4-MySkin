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

    // MARK: - Computed
    var isComparisonMode: Bool { secondValidationResult != nil }

    // MARK: - Init

    init() {
        // When the camera captures a photo, store it and navigate to review
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
                // — First product —
                self.firstSelectedImage = self.selectedImage
                self.validationResult = ValidationResult.stub
            } else {
                // — Second product —
                self.secondSelectedImage = self.selectedImage
                self.secondValidationResult = ValidationResult.stub2
            }

            self.currentStep = .result
        }
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
        cameraService.capturedImage = nil
        currentStep = .imagePicker
    }

    // MARK: - Finish
    func finish() {
        reset()
    }
}
