//
//  AchievementsView.swift
//  Twin Flame Union
//
//  Grid of all achievements with unlock status.
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query(sort: \Achievement.unlockedAt, order: .reverse) private var unlocked: [Achievement]

    private var unlockedKeys: Set<String> {
        Set(unlocked.map(\.key))
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Stats header
                    VStack(spacing: 6) {
                        Text("\(unlocked.count) / \(AchievementCatalog.all.count)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.gold)
                        Text("Achievements Unlocked")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                    }
                    .padding(.top, 12)

                    // Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementCatalog.all, id: \.key) { def in
                            AchievementTile(
                                def: def,
                                isUnlocked: unlockedKeys.contains(def.key)
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Achievement Tile

private struct AchievementTile: View {
    let def: AchievementDef
    let isUnlocked: Bool

    private var rarityColor: Color {
        switch def.rarity {
        case "legendary": return AppColors.gold
        case "epic":      return Color(hex: "9B59B6")
        case "rare":      return Color(hex: "4A90D9")
        default:          return AppColors.lavender.opacity(0.5)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? rarityColor.opacity(0.2) : Color.gray.opacity(0.08))
                    .frame(width: 48, height: 48)
                if isUnlocked {
                    Image(systemName: def.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(rarityColor)
                } else {
                    Image(systemName: "questionmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }

            Text(isUnlocked ? def.title : "???")
                .font(AppFont.caption(11, weight: .semibold))
                .foregroundStyle(isUnlocked ? AppColors.cream : AppColors.lavender.opacity(0.3))
                .lineLimit(1)

            Text(isUnlocked ? def.detail : "Keep exploring...")
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(AppColors.lavender.opacity(isUnlocked ? 0.6 : 0.2))
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if isUnlocked {
                Text("+\(def.xpReward) XP")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.gold.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? AppColors.deepViolet.opacity(0.75) : AppColors.deepViolet.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isUnlocked ? rarityColor.opacity(0.35) : Color.gray.opacity(0.08),
                            lineWidth: isUnlocked ? 1.5 : 0.5
                        )
                )
        )
        .opacity(isUnlocked ? 1 : 0.5)
    }
}
