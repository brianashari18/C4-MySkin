//
//  CameraViewModel.swift
//  C4-MySkin
//

import Observation
import Foundation
import SwiftUI
import PhotosUI

@MainActor
@Observable
final class CameraViewModel {
    enum CameraStep: Equatable {
        case guide
        case preview
        case confirm
    }

    var step: CameraStep = .guide
    var capturedImage: UIImage?
    var selectedPhoto: PhotosPickerItem?

    var canUsePhoto: Bool {
        capturedImage != nil
    }

    func takePhoto() {
        // In a real app this would use AVCaptureSession.
        // For the MVP we simulate a captured placeholder image.
        capturedImage = UIImage(systemName: "face.smiling")
        step = .confirm
    }

    func retake() {
        capturedImage = nil
        step = .guide
    }

    func usePhoto() -> String? {
        // Returns a stable image identifier.
        // Real implementation should persist the image to disk.
        capturedImage?.accessibilityIdentifier ?? UUID().uuidString
    }
}
