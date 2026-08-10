//
//  CameraService.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import AVFoundation
import UIKit
import Combine

/// Manages the AVCaptureSession lifecycle, live preview, and photo capture.
/// AVFoundation operations run on `sessionQueue`; UI-bound @Published
/// properties are always updated on the main thread explicitly.
final class CameraService: NSObject, ObservableObject {

    // MARK: - Published State (always set on main thread)
    @Published var capturedImage: UIImage? = nil
    @Published var isRunning: Bool = false
    @Published var error: CameraError? = nil
    @Published var isAuthorized: Bool = false

    // MARK: - AVFoundation
    /// Exposed so CameraPreviewView can attach its preview layer.
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoInput: AVCaptureDeviceInput?

    // MARK: - Session Queue
    private let sessionQueue = DispatchQueue(
        label: "com.c4myskin.cameraSession",
        qos: .userInitiated
    )

    // MARK: - Authorization & Setup

    func checkAuthorizationAndSetup() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            await MainActor.run { self.isAuthorized = true }
            configureSession()

        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run { self.isAuthorized = granted }
            if granted { configureSession() }

        case .denied, .restricted:
            await MainActor.run {
                self.isAuthorized = false
                self.error = .notAuthorized
            }

        @unknown default:
            break
        }
    }

    // MARK: - Session Configuration (runs on sessionQueue)

    private func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // — Input —
            guard
                let device = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back
                ),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                DispatchQueue.main.async { self.error = .configurationFailed }
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)
            self.videoInput = input

            // — Output —
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }

            self.session.commitConfiguration()
        }
    }

    // MARK: - Start / Stop

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async { self.isRunning = true }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async { self.isRunning = false }
        }
    }

    // MARK: - Capture Photo

    func capturePhoto() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            let settings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard
            error == nil,
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else { return }

        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
        }
    }
}

// MARK: - Camera Error
enum CameraError: LocalizedError {
    case notAuthorized
    case configurationFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Camera access was denied. Please enable it in Settings."
        case .configurationFailed:
            return "Unable to configure the camera. Please try again."
        }
    }
}
