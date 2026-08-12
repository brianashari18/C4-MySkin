//
//  CameraPreviewView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI
import AVFoundation

/// A UIViewRepresentable that renders the live camera preview
/// from an existing AVCaptureSession into a SwiftUI view.
struct ProductValidationCameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> ProductValidationPreviewUIView {
        let view = ProductValidationPreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: ProductValidationPreviewUIView, context: Context) {
        // Layout happens in layoutSubviews inside ProductValidationPreviewUIView
    }
}

// MARK: - ProductValidationPreviewUIView
/// A UIView whose backing layer is AVCaptureVideoPreviewLayer.
final class ProductValidationPreviewUIView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}
