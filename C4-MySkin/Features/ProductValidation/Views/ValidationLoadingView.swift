//
//  ValidationLoadingView.swift
//  C4-MySkin
//

import SwiftUI

/// Dedicated loading screen shown during product validation analysis
struct ValidationLoadingView: View {
    @ObservedObject var viewModel: ProductValidationViewModel

    @State private var loadingTextIndex = 0
    private let loadingMessages = [
        "Menganalisis kandungan produk...",
        "Mencocokkan dengan profil kulitmu...",
        "Menghitung skor keamanan bahan...",
        "Menyiapkan ringkasan rekomendasi..."
    ]

    var body: some View {
        ZStack {
            // Soft ice blue background gradient matching app theme
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.97, blue: 1.0),
                    Color(red: 0.90, green: 0.95, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Mascot animation container
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 180, height: 180)
                        .shadow(color: Color(red: 0.38, green: 0.61, blue: 0.93).opacity(0.2), radius: 16, x: 0, y: 6)

                    MascotLottieView(width: 130)
                        .frame(width: 130, height: 130)
                }

                // Progress view & message
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color(red: 0.29, green: 0.56, blue: 0.89))

                    Text("Memvalidasi Produk")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))

                    Text(loadingMessages[loadingTextIndex])
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 0.40, green: 0.52, blue: 0.64))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .id(loadingTextIndex)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            // Cycle loading messages smoothly while waiting
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                withAnimation(.easeInOut(duration: 0.4)) {
                    loadingTextIndex = (loadingTextIndex + 1) % loadingMessages.count
                }
            }
        }
    }
}

#Preview {
    ValidationLoadingView(viewModel: ProductValidationViewModel())
}
