//
//  WellnessDisclaimer.swift
//  Twin Flame Union
//
//  Single source of truth for the wellness/medical disclaimer (App Store 1.4.1).
//  Consumed by SolfeggioView, EnergyEnhancementView, and Settings → About.
//

import SwiftUI

enum WellnessDisclaimer {
    /// UserDefaults flag: has the user acknowledged the first-run disclaimer?
    static let ackKey = "hasAcknowledgedWellnessDisclaimer"

    /// Full disclaimer shown in the first-run sheet and Settings.
    static let text = "Twin Flame Union is a spiritual and self-reflection app for entertainment and personal-growth purposes. It is not medical, psychological, or health advice and is not a substitute for professional care. Sound frequencies and energy practices are offered as meditative experiences, not treatments. If you have a health concern, please consult a qualified professional."

    /// One-line footer for feature screens.
    static let footerShort = "For spiritual & entertainment purposes only — not medical advice."
}

/// First-run acknowledgment sheet. The button records acknowledgment.
struct WellnessDisclaimerSheet: View {
    @AppStorage(WellnessDisclaimer.ackKey) private var acknowledged = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0418").ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.lavender)
                Text("A Gentle Note")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)
                ScrollView {
                    Text(WellnessDisclaimer.text)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                Button("I understand") {
                    acknowledged = true
                    dismiss()
                }
                .warmButtonStyle()
            }
            .padding(32)
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(true)
    }
}

/// Read-only presentation for Settings → About.
struct WellnessDisclaimerDetail: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0418").ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Wellness Disclaimer")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)
                ScrollView {
                    Text(WellnessDisclaimer.text)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                }
                Button("Done") { dismiss() }
                    .warmButtonStyle()
            }
            .padding(32)
        }
        .preferredColorScheme(.dark)
    }
}

/// Small persistent footer for feature screens.
struct DisclaimerFooter: View {
    var body: some View {
        Text(WellnessDisclaimer.footerShort)
            .font(AppFont.caption(11))
            .italic()
            .foregroundStyle(AppColors.lavender.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
    }
}
