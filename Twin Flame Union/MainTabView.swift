//
//  MainTabView.swift
//  Twin Flame Union
//
//  Root tab bar — five tabs with cosmic styling.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(ToneGenerator.self) private var toneGenerator

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.02, blue: 0.13, alpha: 0.97)

        // Selected item
        appearance.stackedLayoutAppearance.selected.iconColor    = UIColor(AppColors.gold)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.gold),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]
        // Unselected item
        let unselectedColor = UIColor(AppColors.lavender).withAlphaComponent(0.55)
        appearance.stackedLayoutAppearance.normal.iconColor    = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: unselectedColor,
            .font: UIFont.systemFont(ofSize: 10),
        ]
        // Sacred gold top line
        appearance.shadowColor = UIColor(AppColors.gold).withAlphaComponent(0.22)

        // Selected — true gold
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.gold)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppColors.gold),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
        ]

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: Home  — Hestia's hearth
            NavigationStack {
                ContentView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            // MARK: Journey  — Psyche's path
            NavigationStack {
                JourneyView()
            }
            .tabItem { Label("Journey", systemImage: "scroll.fill") }
            .tag(1)

            // MARK: Coach  — Seraphina / Divine Council
            NavigationStack {
                CoachView()
            }
            .tabItem { Label("Seraphina", systemImage: "sparkles") }
            .tag(2)

            // MARK: Meditate  — Hypnos & Nyx
            NavigationStack {
                MeditationView()
            }
            .tabItem { Label("Meditate", systemImage: "moon.stars.fill") }
            .tag(3)

            // MARK: Profile  — Seshat's sacred record
            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
            .tag(4)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if toneGenerator.isPlaying {
                MiniFrequencyPlayer(generator: toneGenerator)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4), value: toneGenerator.isPlaying)
        .onAppear { StreakTracker.checkIn() }
        .onChange(of: selectedTab) {
            HapticManager.impact(.light)
        }
        .overlay { GamificationOverlay() }
    }
}

// MARK: - Mini Frequency Player

private struct MiniFrequencyPlayer: View {
    let generator: ToneGenerator
    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func formatTime(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Animated waveform dot
            ZStack {
                Circle()
                    .fill(generator.currentFrequencyColor.opacity(0.25))
                    .frame(width: 36, height: 36)
                    .scaleEffect(pulse ? (reduceMotion ? 1.0 : 1.2) : 1.0)
                    .animation(Animation.calm(reduceMotion, .easeInOut(duration: 1.2).repeatForever(autoreverses: true)), value: pulse)
                    .accessibilityHidden(true)
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                    .foregroundStyle(generator.currentFrequencyColor)
                    .symbolEffect(.variableColor)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(generator.currentFrequencyName)
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(formatTime(generator.elapsedSeconds))
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender)
            }

            Spacer()

            Button {
                generator.stop()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.cream)
                    .frame(width: 36, height: 36)
                    .background(AppColors.purple.opacity(0.3), in: Circle())
            }
            .accessibilityLabel("Stop frequency")
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(generator.currentFrequencyColor.opacity(0.4))
                .frame(height: 1),
            alignment: .top
        )
        .onAppear { pulse = true }
    }
}

// MARK: - Gamification Feedback Overlay

/// Surfaces GamificationService celebration signals (XP gains, level-ups,
/// achievement unlocks) as transient overlays. Attached once at the tab root.
private struct GamificationOverlay: View {
    @State private var gam = GamificationService.shared
    @State private var xpToken = 0

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear.allowsHitTesting(false)

            if gam.recentXPGain > 0 {
                XPGainIndicator(amount: gam.recentXPGain)
                    .id(xpToken)
                    .padding(.top, 72)
                    .allowsHitTesting(false)
            }

            if gam.showLevelUp {
                LevelUpBanner(level: gam.newLevel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
                    .zIndex(3)
            }

            // Toast keeps default hit-testing so tap-to-dismiss works.
            if let achievement = gam.showAchievement {
                AchievementToast(achievement: achievement) {
                    gam.showAchievement = nil
                }
                .id(achievement.key)
                .padding(.top, 12)
                .zIndex(4)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: gam.showAchievement?.key)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: gam.showLevelUp)
        .animation(.easeOut(duration: 0.3), value: gam.recentXPGain)
        .onChange(of: gam.recentXPGain) { _, newValue in
            guard newValue > 0 else { return }
            xpToken += 1
            let token = xpToken
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_600_000_000)
                if token == xpToken { gam.recentXPGain = 0 }
            }
        }
        .onChange(of: gam.showLevelUp) { _, isUp in
            guard isUp else { return }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation { gam.showLevelUp = false }
            }
        }
    }
}

private struct LevelUpBanner: View {
    let level: Int
    @State private var appear = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.gold)
                .accessibilityHidden(true)
            Text("LEVEL UP")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .tracking(4)
                .foregroundStyle(AppColors.gold.opacity(0.9))
            Text("Level \(level)")
                .font(AppFont.title(28))
                .foregroundStyle(AppColors.cream)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(AppColors.deepViolet.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(AppColors.gold.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(color: AppColors.gold.opacity(0.35), radius: 20)
        )
        .scaleEffect(appear ? 1 : (reduceMotion ? 1 : 0.7))
        .opacity(appear ? 1 : 0)
        .onAppear {
            if reduceMotion {
                appear = true
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { appear = true }
            }
        }
    }
}
