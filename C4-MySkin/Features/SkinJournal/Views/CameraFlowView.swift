//
//  CameraFlowView.swift
//  C4-MySkin
//

import SwiftUI

struct CameraFlowView: View {
    @State private var viewModel = CameraViewModel()
    let onComplete: (String) -> Void

    var body: some View {
        Group {
            switch viewModel.step {
            case .guide:
                CameraGuideView(
                    isFaceCentered: $viewModel.isFaceCentered,
                    onTakePhoto: { image in
                        viewModel.setCapturedImage(image)
                    },
                    onBack: { onComplete("") }
                )

            case .preview, .confirm:
                PhotoConfirmationView(
                    capturedImage: viewModel.capturedImage,
                    onRetake: { viewModel.retake() },
                    onUsePhoto: {
                        if let imageName = viewModel.usePhoto() {
                            onComplete(imageName)
                        }
                    }
                )
            }
        }
        .onDisappear {
            // Lepas kamera saat keluar dari alur kamera — cegah session
            // menumpuk & kamera tetap menyala di background.
            CameraSessionManager.shared.stop()
        }
    }
}

#Preview {
    CameraFlowView { _ in }
}

