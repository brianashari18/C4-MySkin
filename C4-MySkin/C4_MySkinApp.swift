//
//  C4_MySkinApp.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 07/08/26.
//

import SwiftUI

@main
struct C4_MySkinApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                SkinJournalRootView()
            } else {
                OnboardingView()
            }
        }
    }
}
