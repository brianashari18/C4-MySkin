//
//  CameraScannerView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 2 — Camera Scanner
/// Live AVCaptureSession preview with scan-frame overlay and a capture button.
struct CameraScannerView: View {

    @ObservedObject var viewModel: ProductValidationViewModel

    // Button tap scale animation
    @State private var isCaptureTapped: Bool = false

    var body: some View {
        ZStack {
            // Background (visible only before session starts)
            Color.black.ignoresSafeArea()

            GeometryReader { geometry in
                VStack(spacing: 0) {

                    // MARK: - Navigation Bar (overlaid on top of preview)
                    HStack {
                        Button {
                            viewModel.stopCamera()
                            viewModel.currentStep = .imagePicker
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(Font.App.nunitoRounded(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(Circle().fill(Color.black.opacity(0.35)))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .zIndex(1)

                    // MARK: - Camera Preview Area
                    ZStack {
                        // Always show the preview layer — it's black until
                        // the session starts, which is standard camera UX.
                        ProductCameraPreviewView(session: viewModel.cameraService.session)
                            .clipShape(RoundedRectangle(cornerRadius: 24))

                        // Only overlay an error if permission was explicitly denied
                        if viewModel.cameraService.error == .notAuthorized {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.App.lightBlue.opacity(0.15))
                            VStack(spacing: 12) {
                                Image(systemName: "camera.slash")
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.App.mediumBlue.opacity(0.7))
                                Text("Camera access denied.\nPlease enable it in Settings.")
                                    .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                                    .foregroundStyle(Color.App.mediumBlue.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }

                        // Scan frame always on top
                        ScanFrameOverlay()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.60)
                    .padding(.horizontal, 20)

                    Spacer()

                    // MARK: - Capture Button
                    Button {
                        guard viewModel.cameraService.isAuthorized else { return }
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isCaptureTapped = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            isCaptureTapped = false
                            viewModel.capturePhoto()
                        }
                    } label: {
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 3)
                                .frame(width: 80, height: 80)
                            // Inner filled circle
                            Circle()
                                .fill(Color.App.mediumBlue)
                                .frame(width: 64, height: 64)
                                .shadow(color: Color.App.mediumBlue.opacity(0.5), radius: 14, x: 0, y: 6)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .scaleEffect(isCaptureTapped ? 0.88 : 1.0)
                        .animation(.easeInOut(duration: 0.12), value: isCaptureTapped)
                    }
                    .padding(.bottom, 44)
                }
            }

            // MARK: - Product Not Found Modal
            if viewModel.showProductNotFoundModal {
                ProductNotFoundModalView {
                    viewModel.scanAnotherProduct()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.showProductNotFoundModal)
        // MARK: - Lifecycle
        .onAppear {
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }
}

// MARK: - Preview
#Preview {
    CameraScannerView(viewModel: ProductValidationViewModel())
}
