//
//  PhotoTimelapseCard.swift
//  C4-MySkin
//

import SwiftUI

/// Kartu timelapse INLINE (bukan halaman terpisah) — foto progress wajah
/// berputar otomatis (crossfade fade in/out MURNI, tanpa zoom) di speed 2×
/// (interval 1.0 detik). Label tanggal foto di KANAN BAWAH, nama produk
/// terpilih di KIRI ATAS.
struct PhotoTimelapseCard: View {
    let photos: [ProgressPhoto]
    let productName: String

    @State private var index = 0

    /// Speed 2× = interval 1.0 detik (auto-play).
    private let interval: TimeInterval = 1.0
    private var fadeDuration: TimeInterval { min(0.8, interval * 0.5) }

    private var frames: [(photo: ProgressPhoto, image: UIImage)] {
        photos
            .sorted { $0.date < $1.date }
            .compactMap { photo in
                guard let image = CameraViewModel.loadImage(named: photo.imageName) else { return nil }
                return (photo, image)
            }
    }

    var body: some View {
        ZStack {
            if frames.isEmpty {
                // Fallback kalau foto belum ada / tidak bisa dimuat
                RoundedRectangle(cornerRadius: 26)
                    .fill(Color(red: 0.84, green: 0.84, blue: 0.84))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        VStack(spacing: 4) {
                            Text("no photos")
                                .font(.system(size: 22, weight: .medium))
                            Text("yet")
                                .font(.system(size: 22, weight: .medium))
                        }
                        .foregroundStyle(Color(red: 0.20, green: 0.38, blue: 0.56))
                    )
            } else {
                // Crossfade semua frame — foto aktif opacity 1 menutupi sisanya
                ForEach(Array(frames.enumerated()), id: \.element.photo.id) { i, frame in
                    Image(uiImage: frame.image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .opacity(i == index ? 1 : 0)
                        .allowsHitTesting(false)
                }

                // Produk terpilih — KIRI ATAS
                VStack {
                    HStack {
                        Text(productName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    Spacer()
                }
                .padding(12)
                .allowsHitTesting(false)

                // Tanggal foto — KANAN BAWAH
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(dateString(frames[index].photo.date))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(red: 0.11, green: 0.27, blue: 0.42))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                    }
                }
                .padding(12)
                .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .task(id: frames.count) {
            // Auto-play: loop crossfade. task(id:) restart otomatis saat
            // jumlah foto berubah (mis. foto baru setelah journaling).
            guard frames.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { break }
                // Crossfade halus: foto lama fade out + foto baru fade in
                withAnimation(.easeInOut(duration: fadeDuration)) {
                    index = (index + 1) % frames.count
                }
            }
        }
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy • HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    PhotoTimelapseCard(photos: [], productName: "Serum")
        .padding()
}
