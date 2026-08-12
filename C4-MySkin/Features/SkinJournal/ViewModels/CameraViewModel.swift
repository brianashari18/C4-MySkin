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
    var isFaceCentered: Bool = false
    var capturedImage: UIImage?
    var selectedPhoto: PhotosPickerItem?

    var canUsePhoto: Bool {
        capturedImage != nil
    }

    func setCapturedImage(_ image: UIImage) {
        capturedImage = image
        step = .confirm
    }

    func retake() {
        capturedImage = nil
        isFaceCentered = false
        step = .guide
    }

    /// Simpan foto ke Documents/Photos/ (persisten) dan kembalikan imageName.
    /// Nama file memuat timestamp (yyyyMMdd_HHmmss) supaya urut berdasarkan waktu.
    func usePhoto() -> String? {
        guard let capturedImage = capturedImage else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let imageName = "captured_face_\(formatter.string(from: Date()))_\(UUID().uuidString.prefix(8))"
        guard let data = capturedImage.pngData(),
              let url = Self.imageURL(for: imageName) else {
            return nil
        }
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: url)
        return imageName
    }

    // MARK: - Persistence helpers

    static func photosDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
    }

    static func imageURL(for imageName: String) -> URL? {
        guard !imageName.isEmpty else { return nil }
        return photosDirectory().appendingPathComponent("\(imageName).png")
    }

    /// Load foto hasil capture dari Documents. Fallback ke asset catalog.
    static func loadImage(named imageName: String) -> UIImage? {
        guard !imageName.isEmpty else { return nil }
        if let url = imageURL(for: imageName),
           FileManager.default.fileExists(atPath: url.path),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }
        return UIImage(named: imageName)
    }
}
