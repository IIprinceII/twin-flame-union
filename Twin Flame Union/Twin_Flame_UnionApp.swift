//
//  Twin_Flame_UnionApp.swift
//  Twin Flame Union
//
//  Created by j on 3/25/26.
//

import SwiftUI
import SwiftData

@main
struct Twin_Flame_UnionApp: App {
    @State private var showLaunch      = true
    @State private var showOnboarding  = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([JournalEntry.self, DreamEntry.self, SynchronicityEntry.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if showLaunch {
                LaunchAnimationView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showLaunch        = false
                        showOnboarding    = !hasCompletedOnboarding
                    }
                }
                .transition(.opacity)
            } else if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
