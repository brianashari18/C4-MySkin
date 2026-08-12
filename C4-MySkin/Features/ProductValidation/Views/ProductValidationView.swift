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

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProductValidationViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerBar

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
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            BackButton(action: { dismiss() })
                .padding(.leading, 8)

            Spacer()

            // Bookmark icon from ValidationResultView product card
            Image(systemName: "bookmark.fill")
                .font(.system(size: 13))
                .foregroundStyle(Color.gray.opacity(0.6))
                .padding(8)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(Color(red: 0.94, green: 0.97, blue: 1.0))
    }
}

// MARK: - Preview
#Preview {
    ProductValidationView()
}
