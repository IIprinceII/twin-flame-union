//
//  AchievementToast.swift
//  Twin Flame Union
//
//  Toast notification for achievement unlocks.
//

import SwiftUI

struct AchievementToast: View {
    let achievement: AchievementDef
    let onDismiss: () -> Void

    private var rarityColor: Color {
        switch achievement.rarity {
        case "legendary": return AppColors.gold
        case "epic":      return Color(hex: "9B59B6")
        case "rare":      return Color(hex: "4A90D9")
        default:          return AppColors.lavender
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)
                Image(systemName: achievement.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(rarityColor)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("ACHIEVEMENT UNLOCKED")
                    .font(.system(size: 8, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(rarityColor.opacity(0.8))
                Text(achievement.title)
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text("+\(achievement.xpReward) XP")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.gold)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.deepViolet.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(rarityColor.opacity(0.4), lineWidth: 1.5)
                )
                .shadow(color: rarityColor.opacity(0.3), radius: 12)
        )
        .padding(.horizontal, 20)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onDismiss()
                }
            }
        }
        .onTapGesture { withAnimation { onDismiss() } }
    }
}
