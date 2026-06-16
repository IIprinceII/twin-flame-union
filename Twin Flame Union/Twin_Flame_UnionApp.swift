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

    @AppStorage(Persistence.recoveryModeKey) private var recoveryModeRaw = Persistence.RecoveryMode.normal.rawValue
    @State private var showRecoveredAlert = false
    @State private var showInMemoryWarning = false

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
                            // Surface the recovery state once the main UI is up (not over the launch animation).
                            switch Persistence.RecoveryMode(rawValue: recoveryModeRaw) ?? .normal {
                            case .normal:                  break
                            case .recoveredFromCorruption: showRecoveredAlert = true
                            case .temporaryInMemory:       showInMemoryWarning = true
                            }
                        }
                }
            }
            // Corruption recovery: a one-time, honest notice. The mode naturally resets to
            // `.normal` on the next clean launch, so this won't nag.
            .alert("Your data space was reset", isPresented: $showRecoveredAlert) {
                Button("OK") { recoveryModeRaw = Persistence.RecoveryMode.normal.rawValue }
            } message: {
                Text("Your saved data couldn't be opened, so we set up a fresh space to keep the app working. Your previous data file was preserved on this device and was not deleted.")
            }
            // In-memory fallback: saving is genuinely unavailable. This recurs every launch
            // until storage works again — we do NOT pretend anything was backed up.
            .alert("Saving is unavailable", isPresented: $showInMemoryWarning) {
                Button("OK") { }
            } message: {
                Text("We can't access storage on this device right now, so new entries won't be saved this session. Try restarting the app or freeing up space. Your existing data has not been deleted.")
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
