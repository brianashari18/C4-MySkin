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
                    onTakePhoto: { viewModel.takePhoto() },
                    onBack: { onComplete("") }
                )

            case .preview, .confirm:
                PhotoConfirmationView(
                    onRetake: { viewModel.retake() },
                    onUsePhoto: {
                        if let imageName = viewModel.usePhoto() {
                            onComplete(imageName)
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    CameraFlowView { _ in }
}
