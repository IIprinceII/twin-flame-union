//
//  VibrationalScoreCard.swift
//  Twin Flame Union
//
//  Compact vibrational score display with animated ring, level, and constitution.
//

import SwiftUI

struct VibrationalScoreCard: View {
    let profile: SoulProfile
    var compact: Bool = false

    private var scoreColor: Color {
        switch profile.constitutionRating {
        case "C": return Color(hex: "43A047")
        case "B": return Color(hex: "F0C060")
        default:  return Color(hex: "E53935")
        }
    }

    private var gradientColors: [Color] {
        switch profile.constitutionRating {
        case "C": return [Color(hex: "43A047"), Color(hex: "A5D6A7")]
        case "B": return [Color(hex: "F0C060"), Color(hex: "FFE082")]
        default:  return [Color(hex: "E53935"), Color(hex: "EF9A9A")]
        }
    }

    var body: some View {
        HStack(spacing: compact ? 14 : 18) {
            // Score Ring
            ZStack {
                Circle()
                    .stroke(scoreColor.opacity(0.15), lineWidth: compact ? 4 : 6)
                    .frame(width: compact ? 56 : 80, height: compact ? 56 : 80)

                Circle()
                    .trim(from: 0, to: profile.vibrationalScore / 1000.0)
                    .stroke(
                        AngularGradient(colors: gradientColors, center: .center),
                        style: StrokeStyle(lineWidth: compact ? 4 : 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: compact ? 56 : 80, height: compact ? 56 : 80)

                VStack(spacing: 0) {
                    Text("\(Int(profile.vibrationalScore))")
                        .font(.system(size: compact ? 16 : 22, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                    if !compact {
                        Text(profile.constitutionRating)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(scoreColor.opacity(0.7))
                    }
                }
            }

            // Info
            VStack(alignment: .leading, spacing: compact ? 4 : 6) {
                Text("Level \(profile.currentLevel)")
                    .font(.system(size: compact ? 11 : 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.gold)

                Text(profile.title)
                    .font(compact ? AppFont.body(14, weight: .semibold) : AppFont.serifTitle(18))
                    .foregroundStyle(AppColors.cream)

                if !compact {
                    // XP Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppColors.deepViolet)
                                .frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * profile.levelProgress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(profile.xpForCurrentLevel) / \(profile.xpToNextLevel) XP")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.lavender.opacity(0.6))
                }
            }

            Spacer()
        }
        .padding(compact ? 14 : 18)
        .background(
            RoundedRectangle(cornerRadius: compact ? 16 : 22)
                .fill(
                    LinearGradient(
                        colors: [scoreColor.opacity(0.08), AppColors.deepViolet.opacity(0.8)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: compact ? 16 : 22)
                        .strokeBorder(scoreColor.opacity(0.25), lineWidth: 1)
                )
        )
    }
}
