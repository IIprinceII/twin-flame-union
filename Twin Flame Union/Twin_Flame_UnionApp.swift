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

    let sharedModelContainer: ModelContainer = Persistence.makeContainer()

    @AppStorage(Persistence.didRecoverKey) private var didRecoverStore = false
    @State private var showRecoveryNotice = false

    var body: some Scene {
        WindowGroup {
            Group {
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
                            // Show the recovery notice once the main UI is up (not over the launch animation).
                            if didRecoverStore { showRecoveryNotice = true }
                        }
                }
            }
            .alert("Your data was recovered", isPresented: $showRecoveryNotice) {
                Button("OK") { didRecoverStore = false }
            } message: {
                Text("We had trouble opening your saved data, so we started fresh to keep the app working. Your previous data was safely backed up.")
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
