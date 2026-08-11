//
//  MascotLottieView.swift
//  C4-MySkin
//
//  Created by Codex on 10/08/26.
//

import Lottie
import SwiftUI

struct MascotLottieView: UIViewRepresentable {
    let animation: MascotAnimation
    var loops: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.loopMode = loops ? .loop : .playOnce
        animationView.animation = MascotLottieCache.animation(for: animation)
        context.coordinator.currentAnimation = animation
        animationView.play()
        return animationView
    }

    func updateUIView(_ animationView: LottieAnimationView, context: Context) {
        if context.coordinator.currentAnimation != animation {
            animationView.animation = MascotLottieCache.animation(for: animation)
            context.coordinator.currentAnimation = animation
        }

        animationView.loopMode = loops ? .loop : .playOnce

        if !animationView.isAnimationPlaying {
            animationView.play()
        }
    }

    final class Coordinator {
        var currentAnimation: MascotAnimation?
    }
}

@MainActor
enum MascotLottieCache {
    private static var animations: [MascotAnimation: LottieAnimation] = [:]
    private static var hasPreloaded = false

    static func animation(for animation: MascotAnimation) -> LottieAnimation? {
        if let cachedAnimation = animations[animation] {
            return cachedAnimation
        }

        guard let loadedAnimation = LottieAnimation.named(animation.rawValue) else {
            return nil
        }

        animations[animation] = loadedAnimation
        return loadedAnimation
    }

    static func preloadAllOnce() {
        guard !hasPreloaded else { return }
        hasPreloaded = true

        for animation in MascotAnimation.allCases {
            _ = self.animation(for: animation)
        }
    }

    static func prepare(_ animation: MascotAnimation?) {
        guard let animation else { return }
        _ = self.animation(for: animation)
    }
}
