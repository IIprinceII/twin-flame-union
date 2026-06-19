//
//  PaywallView.swift
//  Twin Flame Union
//
//  Sacred, compliant auto-renewable subscription paywall.
//  Tone: reverent, not sales-y. The Gods and Goddesses are honoured here.
//
//  Apple requirements present:
//  ✓ displayPrice from loaded Product (live price string)
//  ✓ Subscribe CTA → StoreService.purchase()
//  ✓ Restore Purchases button → StoreService.restore()
//  ✓ Terms of Use link
//  ✓ Privacy Policy link
//  ✓ Auto-renew disclosure text
//  ✓ Loading state
//  ✓ Error state
//  ✓ Already-subscribed state
//

import StoreKit
import SwiftUI

// MARK: - PaywallView

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreService.shared

    // Fallback price if product hasn't loaded yet.
    private var displayPrice: String {
        store.product?.displayPrice ?? "$1.99"
    }

    var body: some View {
        ZStack {
            // Background — void, then sacred violet glow
            Color(hex: "0D0418").ignoresSafeArea()

            RadialGradient(
                colors: [AppColors.purple.opacity(0.25), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Close button ──────────────────────────────────────────
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)
                                .padding(10)
                                .background(Color.white.opacity(0.08), in: Circle())
                        }
                        .accessibilityLabel("Close")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer().frame(height: 12)

                    // ── Sacred header ─────────────────────────────────────────
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(AppColors.gold)
                            .accessibilityHidden(true)

                        Text("Walk with the Divine")
                            .font(AppFont.serifHeadline(28))
                            .foregroundStyle(AppColors.cream)
                            .multilineTextAlignment(.center)

                        Text("The Sacred Path of Twin Flame Union")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)

                    Spacer().frame(height: 32)

                    // ── Benefits ──────────────────────────────────────────────
                    VStack(spacing: 0) {
                        benefitRow(
                            icon: "book.closed.fill",
                            color: AppColors.rose,
                            title: "Soul Journal",
                            subtitle: "Guided by Aphrodite — deep reflection with AI insight"
                        )
                        Divider().background(Color.white.opacity(0.08))
                        benefitRow(
                            icon: "circle.hexagongrid.fill",
                            color: AppColors.sage,
                            title: "Chakra Healing Plans",
                            subtitle: "Channelled by Hygieia — personalised energy healing"
                        )
                        Divider().background(Color.white.opacity(0.08))
                        benefitRow(
                            icon: "eye.fill",
                            color: AppColors.gold,
                            title: "Synchronicity Insights",
                            subtitle: "Decoded by Athena — angel numbers & sacred signs"
                        )
                        Divider().background(Color.white.opacity(0.08))
                        benefitRow(
                            icon: "moon.stars.fill",
                            color: AppColors.coral,
                            title: "Dream Journal AI",
                            subtitle: "Interpreted by Morpheus — divine dream wisdom"
                        )
                        Divider().background(Color.white.opacity(0.08))
                        benefitRow(
                            icon: "heart.fill",
                            color: AppColors.rose,
                            title: "Sacred Gratitude Reflection",
                            subtitle: "Blessed by Hathor — heart-opening AI reflections"
                        )
                        Divider().background(Color.white.opacity(0.08))
                        benefitRow(
                            icon: "timeline.selection",
                            color: AppColors.purple,
                            title: "Connection Timeline AI",
                            subtitle: "Held by Eros — your love journey, illuminated"
                        )
                    }
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)

                    // ── Already subscribed banner ─────────────────────────────
                    if store.hasActivePremium {
                        alreadySubscribedBanner
                    } else {
                        // ── CTA section ───────────────────────────────────────
                        ctaSection
                    }

                    Spacer().frame(height: 16)

                    // ── Legal ─────────────────────────────────────────────────
                    legalSection

                    Spacer().frame(height: 32)
                }
            }

            // ── Loading overlay ───────────────────────────────────────────────
            if store.isLoading {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(AppColors.gold)
                            .scaleEffect(1.4)
                        Text("Connecting with the cosmos…")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                    }
                    .padding(32)
                    .background(Color(hex: "1A0830"), in: RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Subviews

    private func benefitRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(subtitle)
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private var ctaSection: some View {
        VStack(spacing: 16) {

            // Error message
            if let error = store.purchaseError {
                Text(error)
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColors.rose)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Price pill
            VStack(spacing: 4) {
                Text("\(displayPrice) / week")
                    .font(AppFont.serifTitle(22))
                    .foregroundStyle(AppColors.gold)
                Text("Cancel any time in your Apple ID Settings")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
            }

            // Subscribe button
            Button {
                Task { await store.purchase() }
            } label: {
                Text("Begin Your Sacred Path")
                    .frame(maxWidth: .infinity)
            }
            .warmButtonStyle()
            .disabled(store.isLoading)
            .padding(.horizontal, 32)

            // Restore button
            Button {
                Task { await store.restore() }
            } label: {
                Text("Restore Purchases")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
                    .underline()
            }
            .disabled(store.isLoading)
        }
    }

    @ViewBuilder
    private var alreadySubscribedBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.gold)
                .accessibilityHidden(true)

            Text("You walk the Sacred Path")
                .font(AppFont.serifTitle(20))
                .foregroundStyle(AppColors.cream)

            Text("Your premium access is active. All Divine gifts are yours.")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Continue Your Journey") { dismiss() }
                .warmButtonStyle()
                .padding(.horizontal, 32)
        }
    }

    @ViewBuilder
    private var legalSection: some View {
        VStack(spacing: 10) {

            // Auto-renew disclosure (Apple required)
            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews weekly unless it is cancelled at least 24 hours before the end of the current period. You can manage and cancel your subscription in your Apple ID Account Settings at any time.")
                .font(AppFont.caption(11))
                .foregroundStyle(AppColors.lavender.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Terms + Privacy links (Apple required)
            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://twinflameunion.app/terms")!)
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))

                Text("·")
                    .foregroundStyle(AppColors.lavender.opacity(0.4))

                Link("Privacy Policy", destination: URL(string: "https://twinflameunion.app/privacy")!)
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
            }
        }
    }
}

// MARK: - Stub components kept for backward compatibility

/// Empty stub — reserved for future use as a paywall trigger button.
struct PaywallButton: View {
    var body: some View { EmptyView() }
}

/// Empty stub — reserved for future overlay usage.
struct PremiumGateOverlay: View {
    let message: String
    var body: some View { EmptyView() }
}
