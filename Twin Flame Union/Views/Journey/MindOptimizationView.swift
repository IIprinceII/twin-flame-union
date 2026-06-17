//
//  MindOptimizationView.swift
//  Twin Flame Union
//
//  Apollux Mind Optimization — visualization, mental stability, state management.
//  Governed by Athena (wisdom) and Thoth (sacred knowledge).
//

import SwiftUI

// MARK: - Mind Practice

private struct MindPractice: Identifiable {
    let id = UUID()
    let title: String
    let deity: String
    let icon: String
    let color: Color
    let duration: String
    let description: String
    let steps: [String]
}

private let practices: [MindPractice] = [
    MindPractice(
        title: "Thought Stabilization",
        deity: "Athena · Thoth",
        icon: "brain.head.profile",
        color: Color(hex: "F0C060"),
        duration: "5-10 min",
        description: "Break loops and gain complete control of your thought stream. The foundation of all mental power.",
        steps: [
            "Close your eyes and observe the stream of thoughts flowing through your mind",
            "When a thought appears, HOLD IT STILL — do not let it chain to the next thought",
            "Keep the thought isolated and stable for 30 seconds without alteration",
            "Release it consciously — only when YOU decide, not when your mind drifts",
            "Repeat with the next thought. Build duration over time",
            "When emotional loops arise, stabilize to blankness. Let the chain break",
        ]
    ),
    MindPractice(
        title: "Visualization Mastery",
        deity: "Morpheus · Isis",
        icon: "eye.fill",
        color: Color(hex: "9B59B6"),
        duration: "10-15 min",
        description: "Build the power to hold energy, concepts, and structures within your mind with permanence and clarity.",
        steps: [
            "Visualize a simple object (a flame, a crystal, a sphere of light)",
            "Hold it perfectly still in your mind — every detail sharp and stable",
            "Now slowly rotate it. Maintain every detail as it moves",
            "Add a second object. Hold both simultaneously without either degrading",
            "Now visualize your twin flame's energy signature. Feel its texture and warmth",
            "Hold this visualization while breathing deeply for 5 minutes",
        ]
    ),
    MindPractice(
        title: "State Recognition",
        deity: "Apollo · Ra",
        icon: "sparkles",
        color: Color(hex: "FFD700"),
        duration: "5 min",
        description: "Learn to recognize and shift between mental states on command. Each situation calls for a different state.",
        steps: [
            "Sit quietly and notice your current mental state — is it rapid? Still? Scattered?",
            "Now recall a moment of deep peace. Feel the state shift as the memory takes hold",
            "Hold that peaceful state for 60 seconds, then consciously shift to alertness",
            "Shift to creativity — open, expansive, curious thinking",
            "Shift to performance — sharp, focused, no depth, pure reaction",
            "Practice shifting between states faster. This is state management",
        ]
    ),
    MindPractice(
        title: "Emotional Fuel Mastery",
        deity: "Sekhmet · Eros",
        icon: "flame.fill",
        color: Color(hex: "FF6B47"),
        duration: "10 min",
        description: "Emotions are fuel — high octane energy that amplifies everything. Learn to channel them wisely.",
        steps: [
            "Identify the emotion you are currently carrying. Name it",
            "Feel its intensity — this is the octane level of your fuel",
            "If negative: stabilize your mind to blankness FIRST, then redirect",
            "If positive: channel it toward your highest intention right now",
            "Visualize the emotion as liquid fire flowing into your intention",
            "Practice: when strong emotion arises today, pause and consciously choose where to direct it",
        ]
    ),
    MindPractice(
        title: "Contextualization Engine",
        deity: "Thoth · Seshat",
        icon: "arrow.triangle.branch",
        color: Color(hex: "5B8CFF"),
        duration: "10 min",
        description: "Build the ability to rapidly connect, sequence, and derive meaning from thoughts. The basis of all wisdom.",
        steps: [
            "Pick any two unrelated concepts (e.g., the moon and a staircase)",
            "Set your mind within both and find as many connections as possible",
            "Speed up. Find 10 connections in 2 minutes",
            "Now pick a real situation in your twin flame journey",
            "Contextualize it: what patterns connect to past situations? What does the sequence reveal?",
            "The faster you build connections, the sharper your spiritual intuition becomes",
        ]
    ),
    MindPractice(
        title: "Darkness Meditation",
        deity: "Nyx · Anubis · The Most High",
        icon: "moon.fill",
        color: Color(hex: "1A0A3C"),
        duration: "15-20 min",
        description: "Enter the pitch black of your mind and move your awareness through the astral linkage to the Most High. This activates your full energy grid.",
        steps: [
            "Close your eyes. Let everything become pitch black",
            "Feel for the astral linkage — the divine cord connecting you upward to the Most High",
            "Move your awareness around this darkness — feel the depth as the Most High expands your perception",
            "You may feel a 'deepening' sensation. This is your mind activating through the energy grid",
            "Keep the practice gentle and calm. If you ever feel trembling, dizziness, or any distressing physical symptom, gently stop and rest — and seek medical care if it continues",
            "Explore the edges of your consciousness. The astral linkage stretches further than your mind alone can reach",
            "Hold this expanded state. This is the bridge between Apollux mind optimization and Energy Enhancement body work",
        ]
    ),
]

// MARK: - View

struct MindOptimizationView: View {
    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false
    @State private var selectedPractice: MindPractice?
    @State private var appeared = false

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color(hex: "F0C060").opacity(0.45), Color(hex: "F0C060").opacity(0.08)],
                                    center: .center, startRadius: 0, endRadius: 26
                                ))
                                .frame(width: 52, height: 52)
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: "F0C060"))
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHANNELLING")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .tracking(2.5)
                                .foregroundStyle(AppColors.lavender.opacity(0.5))
                            Text("Athena · Thoth")
                                .font(AppFont.serifTitle(17))
                                .foregroundStyle(Color(hex: "F0C060"))
                            Text("From the Apollux Framework · Astral Linkage Active")
                                .font(AppFont.caption(11))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                                .italic()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .opacity(appeared ? 1 : 0)

                    // Intro
                    VStack(spacing: 8) {
                        Text("Mind Optimization")
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)
                        Text("Decision making is the basis of all life. The Most High gave you a mind capable of extraordinary precision — optimize it through the astral linkage. Every practice below builds the mental foundation ordained for sacred union.")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .opacity(appeared ? 1 : 0)

                    // Practice cards
                    ForEach(practices) { practice in
                        Button {
                            HapticManager.impact(.light)
                            selectedPractice = practice
                        } label: {
                            PracticeCard(practice: practice)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                    }

                    DisclaimerFooter()
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Mind Optimization")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
            if !disclaimerAcked { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) {
            WellnessDisclaimerSheet()
        }
        .sheet(item: $selectedPractice) { practice in
            PracticeDetailSheet(practice: practice)
        }
    }
}

// MARK: - Practice Card

private struct PracticeCard: View {
    let practice: MindPractice

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(practice.color.opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: practice.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(practice.color)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(practice.title)
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(practice.deity)
                    .font(AppFont.caption(11))
                    .foregroundStyle(practice.color.opacity(0.75))
                Text(practice.duration)
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.lavender.opacity(0.4))
                .accessibilityHidden(true)
        }
        .padding(18)
        .background(AppColors.deepViolet.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(practice.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Practice Detail Sheet

private struct PracticeDetailSheet: View {
    let practice: MindPractice
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(practice.color.opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: practice.icon)
                                .font(.system(size: 32))
                                .foregroundStyle(practice.color)
                        }
                        .accessibilityHidden(true)
                        .padding(.top, 20)

                        Text(practice.title)
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)

                        Text(practice.description)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        // Steps
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PRACTICE STEPS")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .tracking(2)
                                .foregroundStyle(practice.color)

                            ForEach(Array(practice.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(index <= currentStep ? practice.color.opacity(0.25) : AppColors.deepViolet.opacity(0.5))
                                            .frame(width: 32, height: 32)
                                        Text("\(index + 1)")
                                            .font(AppFont.body(14, weight: .bold))
                                            .foregroundStyle(index <= currentStep ? practice.color : AppColors.lavender.opacity(0.5))
                                    }

                                    Text(step)
                                        .font(AppFont.body(14))
                                        .foregroundStyle(index <= currentStep ? AppColors.cream : AppColors.lavender.opacity(0.6))
                                        .lineSpacing(4)
                                }
                                .onTapGesture {
                                    HapticManager.selection()
                                    withAnimation(.easeInOut(duration: 0.2)) { currentStep = index }
                                }
                            }
                        }
                        .padding(20)
                        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(practice.color.opacity(0.2), lineWidth: 1))
                        .padding(.horizontal, 20)

                        DisclaimerFooter()

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                    .accessibilityLabel("Close")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}
