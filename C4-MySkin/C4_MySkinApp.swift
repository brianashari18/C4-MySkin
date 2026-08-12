//
//  C4_MySkinApp.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 07/08/26.
//

import SwiftUI
import SwiftData

@main
struct C4_MySkinApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var dataService = AppDataService.shared

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                SkinJournalRootView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(dataService.modelContainer)
        .environment(dataService)
    }
}
