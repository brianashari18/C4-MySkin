//
//  CachedAsyncImage.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import SwiftUI
import Combine

// MARK: - Memory & Disk Image Cache Manager
final class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let memoryCache = NSCache<NSString, UIImage>()

    private init() {
        memoryCache.countLimit = 200 // Max 200 images in memory
        memoryCache.totalCostLimit = 120 * 1024 * 1024 // 120 MB memory limit

        // Configure shared URLCache for disk storage
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 250 * 1024 * 1024,
            diskPath: "skincare_image_cache"
        )
        URLCache.shared = cache
    }

    func image(forKey key: String) -> UIImage? {
        memoryCache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
    }
}

// MARK: - Image Loader ViewModel
@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false

    private var currentURL: URL?

    func load(url: URL?) {
        guard let url else { return }

        // 1. Instant check in memory cache
        let cacheKey = url.absoluteString
        if let cached = ImageCacheManager.shared.image(forKey: cacheKey) {
            self.image = cached
            return
        }

        self.currentURL = url
        self.isLoading = true

        Task {
            var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
            request.setValue("image/*", forHTTPHeaderField: "Accept")

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    self.isLoading = false
                    return
                }

                if let downloadedImage = UIImage(data: data) {
                    ImageCacheManager.shared.setImage(downloadedImage, forKey: cacheKey)
                    if self.currentURL == url {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.image = downloadedImage
                        }
                    }
                }
            } catch {
                // Auto retry once after short delay if request failed/cancelled
                try? await Task.sleep(nanoseconds: 400_000_000)
                if let (retryData, _) = try? await URLSession.shared.data(for: request),
                   let retryImage = UIImage(data: retryData) {
                    ImageCacheManager.shared.setImage(retryImage, forKey: cacheKey)
                    if self.currentURL == url {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.image = retryImage
                        }
                    }
                }
            }
            self.isLoading = false
        }
    }
}

// MARK: - CachedAsyncImage Component
struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let placeholder: () -> Placeholder

    @StateObject private var loader = ImageLoader()

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load(url: url)
        }
        .onChange(of: url) { _, newURL in
            loader.load(url: newURL)
        }
    }
}
