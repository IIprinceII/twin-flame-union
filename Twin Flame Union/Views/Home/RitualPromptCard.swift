//
//  RitualPromptCard.swift
//  Twin Flame Union
//
//  Optional, dismissible "Begin Today's Ritual" card on Home (replaces the old hard gate).
//

import SwiftUI

enum RitualPrompt {
    static let completedKey = "dailyRitualCompletedDate"
    static let dismissedKey = "ritualCardDismissedDate"

    /// The card shows unless the ritual was already completed today or dismissed today.
    static func shouldShow(completedAt: Date?, dismissedAt: Date?, now: Date, calendar: Calendar) -> Bool {
        if let c = completedAt, calendar.isDate(c, inSameDayAs: now) { return false }
        if let d = dismissedAt, calendar.isDate(d, inSameDayAs: now) { return false }
        return true
    }
}

struct RitualPromptCard: View {
    let onBegin: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundStyle(AppColors.gold)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Begin Today's Ritual ✨")
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text("A moment to center before your day")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender)
            }
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                    .padding(8)
            }
            .accessibilityLabel("Dismiss today's ritual reminder")
        }
        .padding(16)
        .background(AppColors.purple.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(AppColors.purple.opacity(0.35), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { onBegin() }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Opens today's ritual")
    }
}
