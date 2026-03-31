//
//  JourneyView.swift
//  Twin Flame Union
//
//  Journey tab — hub for Soul Journal and TF Reading.
//

import SwiftUI

struct JourneyView: View {
    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Soul Journal card
                    NavigationLink(destination: SoulJournalView()) {
                        JourneyCard(
                            icon: "book.fill",
                            title: "Soul Journal",
                            subtitle: "Write your thoughts, feelings, and reflections",
                            color: AppColors.purple,
                            accent: Color(hex: "9B59B6")
                        )
                    }
                    .buttonStyle(.plain)

                    // TF Reading card
                    NavigationLink(destination: TFReadingView()) {
                        JourneyCard(
                            icon: "sparkles",
                            title: "TF Reading",
                            subtitle: "Discover your current twin flame soul stage",
                            color: Color(hex: "7B3F9E"),
                            accent: Color(hex: "B06CE6")
                        )
                    }
                    .buttonStyle(.plain)

                    // Twin Flame Quiz card
                    NavigationLink(destination: QuizView()) {
                        JourneyCard(
                            icon: "questionmark.circle.fill",
                            title: "Soul Archetype Quiz",
                            subtitle: "Discover your twin flame archetype in 6 questions",
                            color: Color(hex: "8B5CF6"),
                            accent: Color(hex: "C4B5FD")
                        )
                    }
                    .buttonStyle(.plain)

                    // Dream Journal card
                    NavigationLink(destination: DreamJournalView()) {
                        JourneyCard(
                            icon: "moon.zzz.fill",
                            title: "Dream Journal",
                            subtitle: "Capture your nightly messages from the cosmos",
                            color: Color(hex: "4A90D9"),
                            accent: Color(hex: "7BB8F0")
                        )
                    }
                    .buttonStyle(.plain)

                    // Synchronicity Log card
                    NavigationLink(destination: SynchronicityLogView()) {
                        JourneyCard(
                            icon: "sparkles",
                            title: "Synchronicity Log",
                            subtitle: "Track the signs the universe sends you",
                            color: Color(hex: "9B59B6"),
                            accent: Color(hex: "C39BD3")
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Your Journey")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Journey Card

private struct JourneyCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let accent: Color

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(AppFont.body(17, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(subtitle)
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColors.lavender)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.lavender.opacity(0.5))
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}
