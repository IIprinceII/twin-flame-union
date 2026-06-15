//
//  PaywallView.swift
//  Twin Flame Union
//
//  Placeholder — all features are currently free.
//  Re-add paywall UI when ready to monetise.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0418").ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.gold)
                Text("All features are free!")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)
                Text("Enjoy your full Twin Flame Union experience.")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                Button("Continue") { dismiss() }
                    .warmButtonStyle()
            }
            .padding(32)
        }
        .preferredColorScheme(.dark)
    }
}

struct PaywallButton: View {
    var body: some View { EmptyView() }
}

struct PremiumGateOverlay: View {
    let message: String
    var body: some View { EmptyView() }
}
