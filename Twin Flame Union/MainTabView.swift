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
        appearance.shadowColor = UIColor(Color(hex: "F0C060")).withAlphaComponent(0.22)

        // Selected — true gold
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "F0C060"))
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "F0C060")),
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
    }
}

// MARK: - Mini Frequency Player

private struct MiniFrequencyPlayer: View {
    let generator: ToneGenerator
    @State private var pulse = false

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
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                    .foregroundStyle(generator.currentFrequencyColor)
                    .symbolEffect(.variableColor)
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
            .buttonStyle(.plain)
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
