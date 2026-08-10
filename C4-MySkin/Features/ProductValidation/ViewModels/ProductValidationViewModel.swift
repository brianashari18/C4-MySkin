//
//  ProductValidationViewModel.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
final class ProductValidationViewModel: ObservableObject {

    // MARK: - Navigation State
    @Published var currentStep: ValidationStep = .imagePicker

    // MARK: - Image State
    @Published var selectedImage: UIImage? = nil
    @Published var photoPickerItem: PhotosPickerItem? = nil {
        didSet { Task { await loadPickedPhoto() } }
    }

    // MARK: - Validation State
    @Published var validationResult: ValidationResult? = nil
    @Published var isLoading: Bool = false

    // MARK: - Search State
    @Published var searchText: String = ""

    // MARK: - Actions

    /// Called when the user picks "Camera" — moves to camera scanner screen
    func openCamera() {
        currentStep = .camera
    }

    /// Called when the user picks "Other…" — moves to search/picker screen
    func openOther() {
        currentStep = .search
    }

    /// Called after a photo is confirmed from search / photo library
    func confirmImage(_ image: UIImage) {
        selectedImage = image
        currentStep = .review
    }

    /// Called after capture button is tapped on camera screen
    func capturePhoto() {
        // Stub: in real implementation this triggers AVCaptureSession
        // For now, transition to review with a placeholder
        currentStep = .review
    }

    /// Called when "Validate" is tapped on the review screen
    func validate() {
        isLoading = true
        // Stub: simulate async API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.validationResult = ValidationResult.stub
            self?.isLoading = false
            self?.currentStep = .result
        }
    }

    /// Called when "Retake" is tapped — returns to image picker
    func retake() {
        selectedImage = nil
        validationResult = nil
        currentStep = .imagePicker
    }

    /// Called when "Finish" is tapped on the result screen
    func finish() {
        selectedImage = nil
        validationResult = nil
        currentStep = .imagePicker
    }

    // MARK: - Private

    private func loadPickedPhoto() async {
        guard let item = photoPickerItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
            currentStep = .review
        }
    }
}
