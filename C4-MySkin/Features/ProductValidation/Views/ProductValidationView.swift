//
//  ProductValidationView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Root coordinator for the Product Validation feature.
/// Uses a @State step enum to switch between the 5 screens without a NavigationStack.
struct ProductValidationView: View {

    @StateObject private var viewModel = ProductValidationViewModel()

    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .imagePicker:
                ImagePickerView(viewModel: viewModel)
                    .transition(.opacity)

            case .camera:
                CameraScannerView(viewModel: viewModel)
                    .transition(.opacity)

            case .review:
                PhotoReviewView(viewModel: viewModel)
                    .transition(.opacity)

            case .result:
                if let result = viewModel.validationResult {
                    ValidationResultView(viewModel: viewModel, result: result)
                        .transition(.opacity)
                } else {
                    ImagePickerView(viewModel: viewModel)
                        .transition(.opacity)
                }

            case .search:
                ProductSearchView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.currentStep)
    }
}

// MARK: - Preview
#Preview {
    ProductValidationView()
}
