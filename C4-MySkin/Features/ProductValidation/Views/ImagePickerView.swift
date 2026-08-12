//
//  ImagePickerView.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI

/// Screen 1 — Image Picker
/// Entry point for the validation flow.
/// Popup menu: "Camera" → CameraScannerView | "Other…" → ProductSearchView
struct ImagePickerView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductValidationViewModel

    // Controls the popup menu visibility
    @State private var showMenu: Bool = false

    // Controls history sheets
    @State private var showPickedProductSheet: Bool = false
    @State private var showComparisonHistorySheet: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Background
            Color.App.backgroundGray
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack {
                    // MARK: - Navigation Bar
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        Spacer()
                        HStack(spacing: 10) {
                            PickedProductButton {
                                showPickedProductSheet = true
                            }
                            ComparisonHistoryButton {
                                showComparisonHistorySheet = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Spacer()

                    // MARK: - Placeholder Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.App.lightBlue.opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.App.lightBlue.opacity(0.5), lineWidth: 1.5)
                            )

                        VStack(spacing: 12) {
                            Image(systemName: "camera")
                                .font(.system(size: 52, weight: .light))
                                .foregroundStyle(Color.App.mediumBlue.opacity(0.6))
                            Text("Ketuk untuk menambahkan produk")
                                .font(Font.App.nunitoRounded(size: 14, weight: .medium))
                                .foregroundStyle(Color.App.mediumBlue.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.58)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showMenu.toggle()
                        }
                    }

                    Spacer()
                }
            }

            // MARK: - Popup Menu
            if showMenu {
                popupMenu
                    .padding(.trailing, 24)
                    .padding(.bottom, 60)
                    .transition(.scale(scale: 0.85, anchor: .bottomTrailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showMenu)
        .contentShape(Rectangle())
        .onTapGesture {
            if showMenu {
                withAnimation { showMenu = false }
            }
        }
        .sheet(isPresented: $showPickedProductSheet) {
            PickedProductHistoryView()
        }
        .sheet(isPresented: $showComparisonHistorySheet) {
            ComparisonHistoryView()
        }
    }

    // MARK: - Popup Menu View
    @ViewBuilder
    private var popupMenu: some View {
        VStack(spacing: 0) {
            // Camera option
            Button {
                showMenu = false
                viewModel.openCamera()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera")
                        .font(.system(size: 15))
                    Text("Kamera")
                        .font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            Divider()

            // Lainnya… → navigates to ProductSearchView
            Button {
                showMenu = false
                viewModel.openOther()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                    Text("Lainnya...")
                        .font(Font.App.nunitoRounded(size: 16, weight: .medium))
                }
                .foregroundStyle(Color.App.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.97))
                .shadow(color: Color.App.darkBlue.opacity(0.15), radius: 12, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Action Buttons for Top Bar

struct PickedProductButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .stroke(Color(red: 0.11, green: 0.27, blue: 0.42), lineWidth: 1.8)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Picked Product History")
    }
}

struct ComparisonHistoryButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .stroke(Color(red: 0.11, green: 0.27, blue: 0.42), lineWidth: 1.8)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Comparison History")
    }
}

// MARK: - Preview
#Preview {
    ImagePickerView(viewModel: ProductValidationViewModel())
}
