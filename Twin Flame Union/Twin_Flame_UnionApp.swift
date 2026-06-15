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
    @State private var showRitual      = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var toneGenerator   = ToneGenerator()
    @State private var gamification    = GamificationService.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            DreamEntry.self,
            SynchronicityEntry.self,
            ChakraEntry.self,
            ManifestationItem.self,
            ConnectionMoment.self,
            PrayerEntry.self,
            GratitudeEntry.self,
            SoulProfile.self,
            XPEvent.self,
            Achievement.self,
            DailyChallenge.self,
        ])
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
                        showLaunch     = false
                        showOnboarding = !hasCompletedOnboarding
                        if hasCompletedOnboarding {
                            showRitual = !ritualCompletedToday()
                        }
                    }
                }
                .transition(.opacity)
            } else if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showOnboarding = false
                        showRitual     = !ritualCompletedToday()
                    }
                }
                .transition(.opacity)
            } else if showRitual {
                DailyRitualLockView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showRitual = false
                    }
                }
                .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
                    .onAppear {
                        gamification.configure(with: sharedModelContainer.mainContext)
                    }
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(toneGenerator)
        .environment(gamification)
        .onChange(of: hasCompletedOnboarding) { _, completed in
            // Account deletion resets this flag to false — return to onboarding live.
            if !completed && !showLaunch {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showRitual     = false
                    showOnboarding = true
                }
            }
        }
    }

    private func ritualCompletedToday() -> Bool {
        guard let date = UserDefaults.standard.object(forKey: "dailyRitualCompletedDate") as? Date else {
            return false
        }
        return Calendar.current.isDateInToday(date)
    }
}
