//
//  MascotGIFView.swift
//  C4-MySkin
//

import SwiftUI
import ImageIO
import UIKit
import Combine

/// Animasi mascot berbasis GIF (`main.gif`).
///
/// Memutar GIF secara looping menggunakan Timer-based frame stepping.
/// Jauh lebih andal di SwiftUI daripada UIImageView.animationImages.
/// HIG compliant: menghormati `reduceMotion` (tampil frame statis).
struct MascotGIFView: View {
    var width: CGFloat = 180
    var name: String = "main"

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var player = GIFPlayer()

    var body: some View {
        ZStack {
            if let frame = player.currentFrame {
                Image(uiImage: frame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: width * (760.0 / 895.0))
            } else {
                // Placeholder saat loading
                Color.clear
                    .frame(width: width, height: width * (760.0 / 895.0))
            }
        }
        .onAppear {
            player.load(name: name)
            if !reduceMotion {
                player.play()
            }
        }
        .onDisappear {
            player.stop()
        }
        .onChange(of: reduceMotion) { _, newValue in
            if newValue {
                player.stop()
            } else {
                player.play()
            }
        }
    }
}

// MARK: - GIFPlayer

@MainActor
final class GIFPlayer: ObservableObject {
    @Published var currentFrame: UIImage?

    private var frames: [UIImage] = []
    private var frameDurations: [Double] = []
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var isLoaded = false

    func load(name: String) {
        guard !isLoaded else { return }
        isLoaded = true

        guard let url = findGIFURL(name: name) else {
            print("[MascotGIFView] GIF not found: \(name)")
            return
        }

        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            print("[MascotGIFView] Cannot create image source from: \(url)")
            return
        }

        let count = CGImageSourceGetCount(source)
        print("[MascotGIFView] Loading \(count) frames from \(url.lastPathComponent)")

        var loadedFrames: [UIImage] = []
        var loadedDurations: [Double] = []

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            loadedFrames.append(UIImage(cgImage: cgImage))

            let props = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
            let gifProps = props?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
            let delay = gifProps?[kCGImagePropertyGIFUnclampedDelayTime as String] as? Double
                ?? gifProps?[kCGImagePropertyGIFDelayTime as String] as? Double
                ?? 0.138
            loadedDurations.append(delay > 0.01 ? delay : 0.138)
        }

        self.frames = loadedFrames
        self.frameDurations = loadedDurations
        self.currentFrame = loadedFrames.first
        print("[MascotGIFView] Loaded \(loadedFrames.count) frames successfully")
    }

    func play() {
        guard !frames.isEmpty else { return }
        stop()
        scheduleNext()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func scheduleNext() {
        guard currentIndex < frameDurations.count else { return }
        let delay = frameDurations[currentIndex]
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.advance()
            }
        }
    }

    private func advance() {
        guard !frames.isEmpty else { return }
        currentIndex = (currentIndex + 1) % frames.count
        currentFrame = frames[currentIndex]
        scheduleNext()
    }

    private func findGIFURL(name: String) -> URL? {
        if let url = Bundle.main.url(forResource: name, withExtension: "gif") {
            return url
        }
        // Fallback untuk development (simulator direct file access)
        let fallbackPath = "/Users/ibal/Documents/C4-MySkin/C4-MySkin/Features/SkinJournal/Lotti/\(name).gif"
        if FileManager.default.fileExists(atPath: fallbackPath) {
            return URL(fileURLWithPath: fallbackPath)
        }
        return nil
    }
}

#Preview {
    MascotGIFView(width: 180)
        .background(Color.blue.opacity(0.1))
}
