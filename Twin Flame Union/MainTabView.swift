//
//  MainTabView.swift
//  Twin Flame Union
//
//  Root tab bar — five tabs with cosmic styling.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

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
        // Top separator
        appearance.shadowColor = UIColor(AppColors.purple).withAlphaComponent(0.4)

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: Home
            NavigationStack {
                ContentView()
            }
            .tabItem { Label("Home",    systemImage: "house.fill") }
            .tag(0)

            // MARK: Journey
            NavigationStack {
                JourneyView()
            }
            .tabItem { Label("Journey", systemImage: "book.fill") }
            .tag(1)

            // MARK: Coach
            NavigationStack {
                CoachView()
            }
            .tabItem { Label("Coach",   systemImage: "message.fill") }
            .tag(2)

            // MARK: Meditate
            NavigationStack {
                MeditationView()
            }
            .tabItem { Label("Meditate", systemImage: "moon.stars.fill") }
            .tag(3)

            // MARK: Profile
            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.fill") }
            .tag(4)
        }
        .onAppear { StreakTracker.checkIn() }
    }
}
