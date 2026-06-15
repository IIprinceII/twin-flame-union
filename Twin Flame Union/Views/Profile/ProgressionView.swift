//
//  ProgressionView.swift
//  Twin Flame Union
//
//  Main gamification hub — vibrational score, skill trees, achievements, activity feed.
//

import SwiftUI
import SwiftData

struct ProgressionView: View {
    @Environment(GamificationService.self) private var gamification
    @State private var selectedFramework: SacredFramework?

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Vibrational Score Hero
                    if let profile = gamification.profile {
                        VibrationalScoreCard(profile: profile)
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                    }

                    // MARK: - Daily Challenge
                    if let challenge = gamification.todayChallenge {
                        DailyChallengeCard(challenge: challenge)
                            .padding(.horizontal, 20)
                    }

                    // MARK: - Three Framework Cards
                    VStack(spacing: 4) {
                        Text("SACRED SKILL TREES")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .tracking(2.5)
                            .foregroundStyle(AppColors.lavender.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                    }

                    ForEach(SacredFramework.allCases) { fw in
                        Button {
                            selectedFramework = fw
                        } label: {
                            FrameworkCard(
                                framework: fw,
                                level: gamification.frameworkLevel(for: fw),
                                xp: frameworkXP(fw)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }

                    // MARK: - Achievements Link
                    NavigationLink {
                        AchievementsView()
                    } label: {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(AppColors.gold)
                            Text("Achievements")
                                .font(AppFont.body(15, weight: .semibold))
                                .foregroundStyle(AppColors.cream)
                            Spacer()
                            Text("\(gamification.unlockedAchievementCount()) / \(AchievementCatalog.all.count)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.lavender.opacity(0.4))
                        }
                        .padding(18)
                        .background(AppColors.deepViolet.opacity(0.75), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Recent Activity
                    VStack(alignment: .leading, spacing: 10) {
                        Text("RECENT ACTIVITY")
                            .font(.system(size: 9, weight: .heavy, design: .rounded))
                            .tracking(2.5)
                            .foregroundStyle(AppColors.lavender.opacity(0.5))
                            .padding(.horizontal, 24)

                        ForEach(gamification.recentEvents(limit: 8)) { event in
                            HStack(spacing: 10) {
                                Text("+\(event.amount)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppColors.gold)
                                    .frame(width: 44, alignment: .trailing)
                                Text(event.detail.isEmpty ? event.source : event.detail)
                                    .font(AppFont.body(13))
                                    .foregroundStyle(AppColors.lavender)
                                    .lineLimit(1)
                                Spacer()
                                Text(event.createdAt, style: .relative)
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundStyle(AppColors.lavender.opacity(0.4))
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Sacred Progress")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(item: $selectedFramework) { fw in
            SkillTreeView(framework: fw)
        }
    }

    private func frameworkXP(_ fw: SacredFramework) -> Int {
        guard let profile = gamification.profile else { return 0 }
        switch fw {
        case .vibrationalGame:   return profile.vibrationalGameXP
        case .energyEnhancement: return profile.energyEnhancementXP
        case .apollux:           return profile.apolluxXP
        }
    }
}

// MARK: - Framework Card

private struct FrameworkCard: View {
    let framework: SacredFramework
    let level: Int
    let xp: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(framework.color.opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: framework.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(framework.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(framework.title)
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(framework.subtitle)
                    .font(AppFont.caption(11))
                    .foregroundStyle(framework.color.opacity(0.75))
                Text("Level \(level) · \(xp) XP")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.lavender.opacity(0.4))
        }
        .padding(18)
        .background(AppColors.deepViolet.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(framework.color.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Daily Challenge Card

private struct DailyChallengeCard: View {
    let challenge: DailyChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: challenge.isCompleted ? "checkmark.seal.fill" : "star.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(challenge.isCompleted ? Color(hex: "43A047") : AppColors.gold)
                Text("DAILY CHALLENGE")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(AppColors.gold.opacity(0.8))
                Spacer()
                Text("+\(challenge.xpReward) XP")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(challenge.isCompleted ? Color(hex: "43A047") : AppColors.gold)
            }

            Text(challenge.title)
                .font(AppFont.body(15, weight: .semibold))
                .foregroundStyle(AppColors.cream)

            Text(challenge.detail)
                .font(AppFont.body(13))
                .foregroundStyle(AppColors.lavender)

            if challenge.isCompleted {
                Text("Completed!")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "43A047"))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [AppColors.gold.opacity(0.08), AppColors.deepViolet.opacity(0.8)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
