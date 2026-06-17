//
//  CosmicBackground.swift
//  Twin Flame Union
//
//  The sacred cosmos — alive, breathing, divine.
//  Hygieia's cleansing sky. Aphrodite's star-jewelled night.
//

import SwiftUI

// MARK: - Cosmic Background

struct CosmicBackground: View {
    var body: some View {
        ZStack {
            // Deep void base
            AppGradients.cosmic
                .ignoresSafeArea()

            // Radial glow from center — the sacred flame
            RadialGradient(
                colors: [
                    Color(hex: "4A1A80").opacity(0.35),
                    Color(hex: "2A0850").opacity(0.20),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            // Nebula wisps — Aphrodite's veil
            nebulaLayer

            // Breathing star field — Hygieia's living cosmos
            BreathingStarField()
                .ignoresSafeArea()
        }
        .accessibilityHidden(true)
    }

    private var nebulaLayer: some View {
        GeometryReader { geo in
            // Top-left violet nebula
            Ellipse()
                .fill(Color(hex: "6B2FA0").opacity(0.06))
                .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.4)
                .offset(x: -geo.size.width * 0.15, y: geo.size.height * 0.05)
                .blur(radius: 60)

            // Bottom-right blue nebula
            Ellipse()
                .fill(Color(hex: "1A3A80").opacity(0.05))
                .frame(width: geo.size.width * 0.6, height: geo.size.height * 0.35)
                .offset(x: geo.size.width * 0.45, y: geo.size.height * 0.60)
                .blur(radius: 55)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Breathing Star Field

struct BreathingStarField: View {
    @State private var phase: Bool = false

    // 28 hand-placed stars with individual twinkle speeds
    struct StarSpec {
        let x, y, size, baseOpacity, twinkleSpeed: CGFloat
        let color: Color
    }

    private let specs: [StarSpec] = [
        StarSpec(x: 0.08, y: 0.06, size: 2.2, baseOpacity: 0.65, twinkleSpeed: 2.8, color: .white),
        StarSpec(x: 0.88, y: 0.04, size: 2.8, baseOpacity: 0.80, twinkleSpeed: 3.2, color: AppColors.gold),
        StarSpec(x: 0.42, y: 0.09, size: 1.6, baseOpacity: 0.50, twinkleSpeed: 2.1, color: .white),
        StarSpec(x: 0.73, y: 0.15, size: 2.4, baseOpacity: 0.70, twinkleSpeed: 3.6, color: AppColors.coral),
        StarSpec(x: 0.25, y: 0.19, size: 1.2, baseOpacity: 0.40, twinkleSpeed: 2.5, color: .white),
        StarSpec(x: 0.94, y: 0.25, size: 1.8, baseOpacity: 0.55, twinkleSpeed: 4.0, color: .white),
        StarSpec(x: 0.06, y: 0.32, size: 1.4, baseOpacity: 0.45, twinkleSpeed: 3.1, color: AppColors.lavender),
        StarSpec(x: 0.58, y: 0.29, size: 2.0, baseOpacity: 0.35, twinkleSpeed: 2.7, color: .white),
        StarSpec(x: 0.80, y: 0.38, size: 2.6, baseOpacity: 0.72, twinkleSpeed: 3.8, color: AppColors.gold),
        StarSpec(x: 0.16, y: 0.45, size: 1.0, baseOpacity: 0.38, twinkleSpeed: 2.3, color: .white),
        StarSpec(x: 0.67, y: 0.50, size: 1.8, baseOpacity: 0.52, twinkleSpeed: 3.4, color: AppColors.coral),
        StarSpec(x: 0.33, y: 0.58, size: 1.4, baseOpacity: 0.60, twinkleSpeed: 2.9, color: .white),
        StarSpec(x: 0.90, y: 0.60, size: 2.2, baseOpacity: 0.42, twinkleSpeed: 4.2, color: AppColors.lavender),
        StarSpec(x: 0.04, y: 0.68, size: 1.8, baseOpacity: 0.48, twinkleSpeed: 3.0, color: .white),
        StarSpec(x: 0.50, y: 0.72, size: 1.2, baseOpacity: 0.30, twinkleSpeed: 2.6, color: .white),
        StarSpec(x: 0.77, y: 0.78, size: 2.8, baseOpacity: 0.62, twinkleSpeed: 3.5, color: AppColors.gold),
        StarSpec(x: 0.20, y: 0.84, size: 1.6, baseOpacity: 0.44, twinkleSpeed: 2.2, color: .white),
        StarSpec(x: 0.60, y: 0.89, size: 1.4, baseOpacity: 0.50, twinkleSpeed: 3.7, color: AppColors.coral),
        StarSpec(x: 0.38, y: 0.13, size: 1.0, baseOpacity: 0.35, twinkleSpeed: 2.4, color: .white),
        StarSpec(x: 0.96, y: 0.72, size: 1.6, baseOpacity: 0.55, twinkleSpeed: 3.3, color: .white),
        StarSpec(x: 0.12, y: 0.56, size: 2.0, baseOpacity: 0.42, twinkleSpeed: 2.8, color: AppColors.lavender),
        StarSpec(x: 0.85, y: 0.88, size: 1.2, baseOpacity: 0.38, twinkleSpeed: 2.0, color: .white),
        StarSpec(x: 0.44, y: 0.40, size: 1.6, baseOpacity: 0.28, twinkleSpeed: 3.9, color: .white),
        StarSpec(x: 0.63, y: 0.66, size: 2.4, baseOpacity: 0.58, twinkleSpeed: 2.6, color: AppColors.gold),
        StarSpec(x: 0.29, y: 0.76, size: 1.0, baseOpacity: 0.33, twinkleSpeed: 3.2, color: .white),
        StarSpec(x: 0.71, y: 0.33, size: 1.8, baseOpacity: 0.48, twinkleSpeed: 2.9, color: AppColors.coral),
        StarSpec(x: 0.52, y: 0.95, size: 1.4, baseOpacity: 0.40, twinkleSpeed: 3.6, color: .white),
        StarSpec(x: 0.18, y: 0.02, size: 3.0, baseOpacity: 0.85, twinkleSpeed: 4.1, color: AppColors.gold),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(specs.enumerated()), id: \.offset) { idx, star in
                    TwinkleStarView(spec: star, phaseOffset: Double(idx) * 0.38)
                        .position(
                            x: geo.size.width  * star.x,
                            y: geo.size.height * star.y
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Individual Twinkling Star

private struct TwinkleStarView: View {
    let spec: BreathingStarField.StarSpec
    let phaseOffset: Double
    @State private var bright = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Soft outer glow (only for larger stars)
            if spec.size > 2.0 {
                Circle()
                    .fill(spec.color.opacity(bright ? spec.baseOpacity * 0.35 : spec.baseOpacity * 0.12))
                    .frame(width: spec.size * 4, height: spec.size * 4)
                    .blur(radius: spec.size)
            }
            // Star core
            Circle()
                .fill(spec.color)
                .frame(width: spec.size, height: spec.size)
                .opacity(bright ? spec.baseOpacity : spec.baseOpacity * 0.38)
        }
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + phaseOffset) {
                withAnimation(
                    .easeInOut(duration: spec.twinkleSpeed)
                    .repeatForever(autoreverses: true)
                ) {
                    bright = true
                }
            }
        }
    }
}
