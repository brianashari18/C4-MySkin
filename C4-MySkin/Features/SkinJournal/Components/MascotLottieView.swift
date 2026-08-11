//
//  MascotLottieView.swift
//  C4-MySkin
//

import Lottie
import SwiftUI

/// Animasi mascot (Lottie) untuk main page.
///
/// Memutar `main.lottie` secara looping (mata berkedip, ekspresi halus).
/// Lebar di-custom via `width` — boleh melebihi lebar layar; bagian tepi
/// terpotong secara natural di pinggir layar (dekoratif).
///
/// Penting: mascot dirender sebagai `.background` dari kontainer yang terkunci
/// selebar area tersedia, sehingga ukurannya TIDAK memengaruhi layout —
/// elemen lain di halaman tidak ikut melebar/tergeser.
/// Sesuai HIG: menghormati Reduce Motion — jika diaktifkan, tampil sebagai
/// frame statis (tidak beranimasi). Bersifat dekoratif, disembunyikan dari VoiceOver.
struct MascotLottieView: View {
    /// Lebar mascot dalam pt. Aspect ratio animasi 1:1 (512x512),
    /// jadi tinggi mengikuti lebar otomatis. Boleh > lebar layar.
    var width: CGFloat = 400

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var animationView: some View {
        if reduceMotion {
            LottieView {
                try? await DotLottieFile.named("main")
            }
            .paused(at: .currentFrame)
            .resizable()
            .scaledToFit()
            .frame(width: width)
        } else {
            LottieView {
                try? await DotLottieFile.named("main")
            }
            .looping()
            .resizable()
            .scaledToFit()
            .frame(width: width)
        }
    }

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: width)
            .background(animationView)
            .clipped()
    }
}

#Preview {
    MascotLottieView(width: 500)
        .background(Color.gray.opacity(0.2))
}
