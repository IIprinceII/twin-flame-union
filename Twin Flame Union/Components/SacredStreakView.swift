//
//  SacredStreakView.swift
//  Twin Flame Union
//
//  Enhanced streak tracker with weekly view, animated flame, and best streak.
//

import SwiftUI

struct SacredStreakView: View {
    let streak: Int
    @State private var animateFlame = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var flameColor: Color {
        streak == 0 ? AppColors.lavender.opacity(0.3) :
        streak < 7  ? AppColors.gold :
        streak < 14 ? AppColors.ember :
                      Color(hex: "FF6B3D")
    }

    private var streakMessage: String {
        switch streak {
        case 0:       return "Light the flame — show up for your sacred journey"
        case 1:       return "The sacred flame is lit. Keep it burning"
        case 2...6:   return "Building momentum on your path"
        case 7...13:  return "A week of devotion. Your energy is shifting"
        case 14...29: return "Unstoppable sacred practice"
        case 30...99: return "Goddess-level consistency"
        default:      return "Legendary devotion. Heaven watches in awe"
        }
    }

    private var bestStreak: Int {
        UserDefaults.standard.integer(forKey: "bestStreakCount")
    }

    private var currentDayOfWeek: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday + 5) % 7 // Mon=0, Sun=6
    }

    private var hasCheckedInToday: Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: "lastOpenDate") as? Date else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Top row: label + flame counter
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 9))
                            .foregroundStyle(flameColor)
                        Text("SACRED STREAK")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .tracking(2.2)
                            .foregroundStyle(flameColor.opacity(0.9))
                    }

                    Text(streakMessage)
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                        .lineSpacing(2)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: streak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            streak > 0
                                ? LinearGradient(colors: [flameColor, flameColor.opacity(0.6)],
                                                 startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [AppColors.lavender.opacity(0.3)],
                                                 startPoint: .top, endPoint: .bottom)
                        )
                        .scaleEffect(animateFlame && streak > 0 ? 1.12 : 1.0)
                        .accessibilityHidden(true)

                    Text("\(streak)")
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(flameColor)
                }
            }

            // Week view — day dots
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let isToday = dayOffset == currentDayOfWeek
                    let isPast = dayOffset < currentDayOfWeek
                    let isCompleted = isPast && dayOffset >= (currentDayOfWeek - min(streak, currentDayOfWeek))
                    let isTodayCompleted = isToday && hasCheckedInToday

                    VStack(spacing: 6) {
                        Text(dayLabel(for: dayOffset))
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.lavender.opacity(0.5))

                        ZStack {
                            Circle()
                                .fill(
                                    (isCompleted || isTodayCompleted)
                                        ? flameColor
                                        : isToday
                                            ? AppColors.purple.opacity(0.3)
                                            : AppColors.deepViolet.opacity(0.6)
                                )
                                .frame(width: 30, height: 30)

                            if isCompleted || isTodayCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            } else if isToday {
                                Circle()
                                    .stroke(flameColor.opacity(0.6), lineWidth: 1.5)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // Bottom row: best streak + total
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.gold.opacity(0.7))
                        .accessibilityHidden(true)
                    Text("Best: \(bestStreak) days")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppColors.lavender.opacity(0.6))
                }
                Spacer()
                if hasCheckedInToday {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(AppColors.sage)
                        Text("Today complete")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(AppColors.sage.opacity(0.8))
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    streak > 0 ? flameColor.opacity(0.08) : Color.clear,
                    AppColors.deepViolet.opacity(0.75)
                ],
                startPoint: .leading, endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(flameColor.opacity(streak > 0 ? 0.28 : 0.12), lineWidth: 1)
        )
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    animateFlame = true
                }
            }
        }
    }

    private func dayLabel(for index: Int) -> String {
        ["M", "T", "W", "T", "F", "S", "S"][index]
    }
}
