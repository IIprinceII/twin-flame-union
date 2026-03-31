//
//  LaunchAnimationView.swift
//  Twin Flame Union
//
//  Animated launch: two flames orbit, merge, then reveal the title.
//

import SwiftUI

struct LaunchAnimationView: View {
    // Animation phases
    @State private var phase: AnimationPhase = .start
    @State private var flameAngle: Double = 0        // orbit rotation
    @State private var orbitRadius: CGFloat = 140     // shrinks as flames converge
    @State private var mergedScale: CGFloat = 0       // unified flame scale
    @State private var mergedOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var individualOpacity: Double = 1
    @State private var particleBurst: Bool = false
    @State private var isFinished = false

    var onFinished: () -> Void

    private enum AnimationPhase {
        case start, orbiting, merging, revealing, done
    }

    var body: some View {
        ZStack {
            // Background
            AppColors.deepViolet
                .ignoresSafeArea()

            // Ambient particles
            AmbientParticles()

            // Merge burst particles
            if particleBurst {
                BurstParticles()
            }

            // Twin flames
            ZStack {
                // Flame A — starts on the left
                FlameParticle(color1: AppColors.gold, color2: AppColors.coral)
                    .offset(
                        x: -orbitRadius * cos(flameAngle),
                        y: -orbitRadius * sin(flameAngle) * 0.5
                    )
                    .opacity(individualOpacity)

                // Flame B — starts on the right (opposite side)
                FlameParticle(color1: AppColors.coral, color2: AppColors.gold)
                    .offset(
                        x: orbitRadius * cos(flameAngle),
                        y: orbitRadius * sin(flameAngle) * 0.5
                    )
                    .opacity(individualOpacity)

                // Unified flame (hidden until merge)
                UnifiedFlame()
                    .scaleEffect(mergedScale)
                    .opacity(mergedOpacity)
            }
            .offset(y: -60)

            // Title text
            VStack(spacing: 8) {
                Spacer()

                Text("Twin Flame")
                    .font(AppFont.headline(36))
                    .foregroundStyle(AppColors.gold)

                Text("Union")
                    .font(AppFont.title(28))
                    .foregroundStyle(AppColors.cream)

                Spacer()
                    .frame(height: 160)
            }
            .opacity(titleOpacity)
            // Golden glow behind text
            .background(
                Ellipse()
                    .fill(AppColors.gold.opacity(0.15))
                    .frame(width: 280, height: 100)
                    .blur(radius: 40)
                    .offset(y: 30)
                    .opacity(glowOpacity)
            )
        }
        .onAppear { startAnimation() }
    }

    // MARK: - Animation Sequence

    private func startAnimation() {
        // Phase 1: Orbit (0 – 1.5s)
        phase = .orbiting
        withAnimation(.linear(duration: 1.5).repeatCount(1, autoreverses: false)) {
            flameAngle = .pi * 3  // 1.5 full rotations
        }
        withAnimation(.easeIn(duration: 1.5)) {
            orbitRadius = 10
        }

        // Phase 2: Merge (at 1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            phase = .merging
            withAnimation(.easeOut(duration: 0.3)) {
                individualOpacity = 0
            }
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                mergedScale = 1
                mergedOpacity = 1
            }
            particleBurst = true
        }

        // Phase 3: Reveal title (at 2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            phase = .revealing
            withAnimation(.easeIn(duration: 0.8)) {
                titleOpacity = 1
                glowOpacity = 1
            }
        }

        // Done (at 3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            phase = .done
            withAnimation(.easeIn(duration: 0.4)) {
                isFinished = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onFinished()
            }
        }
    }
}

// MARK: - Flame Particle

private struct FlameParticle: View {
    let color1: Color
    let color2: Color
    @State private var flicker = false

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color1.opacity(0.6), color1.opacity(0)],
                        center: .center,
                        startRadius: 2,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(flicker ? 1.2 : 0.9)

            // Core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, color2, color1.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 14
                    )
                )
                .frame(width: 28, height: 28)
                .scaleEffect(flicker ? 1.1 : 0.95)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                flicker = true
            }
        }
    }
}

// MARK: - Unified Flame

private struct UnifiedFlame: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Wide glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.gold.opacity(0.5),
                            AppColors.coral.opacity(0.3),
                            AppColors.purple.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(pulse ? 1.15 : 1.0)

            // Flame icon
            Image(systemName: "flame.fill")
                .font(.system(size: 52))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.gold, AppColors.coral],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: AppColors.gold.opacity(0.8), radius: 20)
                .scaleEffect(pulse ? 1.05 : 0.95)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Ambient Background Particles

private struct AmbientParticles: View {
    private let particles: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (0.1, 0.15, 2, 0.0), (0.85, 0.1, 2.5, 0.3), (0.5, 0.08, 1.5, 0.6),
        (0.25, 0.4, 2, 0.2), (0.75, 0.35, 1.5, 0.5), (0.9, 0.55, 2, 0.1),
        (0.15, 0.65, 1.5, 0.4), (0.6, 0.7, 2.5, 0.7), (0.4, 0.85, 2, 0.3),
        (0.8, 0.8, 1.5, 0.8), (0.3, 0.25, 1, 0.5), (0.65, 0.5, 2, 0.2),
    ]

    @State private var shimmer = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<particles.count, id: \.self) { i in
                let p = particles[i]
                Circle()
                    .fill(Color.white)
                    .frame(width: p.size, height: p.size)
                    .opacity(shimmer ? 0.6 : 0.15)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(p.delay),
                        value: shimmer
                    )
                    .position(x: geo.size.width * p.x, y: geo.size.height * p.y)
            }
        }
        .onAppear { shimmer = true }
    }
}

// MARK: - Burst Particles on Merge

private struct BurstParticles: View {
    @State private var expand = false

    private let rays = 12

    var body: some View {
        ZStack {
            ForEach(0..<rays, id: \.self) { i in
                let angle = Double(i) / Double(rays) * 2 * .pi
                Circle()
                    .fill(
                        [AppColors.gold, AppColors.coral, Color.white][i % 3]
                    )
                    .frame(width: expand ? 3 : 5, height: expand ? 3 : 5)
                    .offset(
                        x: expand ? cos(angle) * 100 : 0,
                        y: expand ? sin(angle) * 100 : 0
                    )
                    .opacity(expand ? 0 : 0.9)
            }
        }
        .offset(y: -60)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                expand = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LaunchAnimationView(onFinished: {})
}
