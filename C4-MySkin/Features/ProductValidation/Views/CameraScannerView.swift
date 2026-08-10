//
//  CameraScannerView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 2 — Camera Scanner
/// Grey placeholder preview area with scan-frame overlay + blue capture button.
/// Camera integration (AVCaptureSession) is wired in a future sprint.
struct CameraScannerView: View {

    @ObservedObject var viewModel: ProductValidationViewModel

    // Button tap scale animation
    @State private var isCaptureTapped: Bool = false

    var body: some View {
        ZStack {
            // Background
            Color.App.backgroundGray
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // MARK: - Navigation Bar
                    HStack {
                        Button {
                            viewModel.currentStep = .imagePicker
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(Font.App.nunitoRounded(size: 18, weight: .semibold))
                                .foregroundStyle(Color.App.textDark)
                                .padding(10)
                                .background(Circle().fill(Color.white.opacity(0.85)))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // MARK: - Camera Preview Area
                    ZStack {
                        // Placeholder for AVCaptureSession preview
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.App.lightBlue.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.App.lightBlue.opacity(0.5), lineWidth: 1.5)
                            )

                        // Scan frame overlay centered on the preview
                        ScanFrameOverlay()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.60)
                    .padding(.horizontal, 20)

                    Spacer()

                    // MARK: - Capture Button
                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isCaptureTapped = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            isCaptureTapped = false
                            viewModel.capturePhoto()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.App.mediumBlue)
                                .frame(width: 72, height: 72)
                                .shadow(color: Color.App.mediumBlue.opacity(0.45), radius: 14, x: 0, y: 6)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .scaleEffect(isCaptureTapped ? 0.88 : 1.0)
                    }
                    .padding(.bottom, 44)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CameraScannerView(viewModel: ProductValidationViewModel())
}
