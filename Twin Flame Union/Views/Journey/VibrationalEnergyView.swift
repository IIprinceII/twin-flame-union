//
//  VibrationalEnergyView.swift
//  Twin Flame Union
//
//  Vibrational Game — energy awareness, connection dynamics, influence mastery.
//  Governed by Hermes (energy transmission) and Harmonia (balance).
//

import SwiftUI

// MARK: - Energy Lesson

private struct EnergyLesson: Identifiable {
    let id = UUID()
    let chapter: String
    let title: String
    let icon: String
    let color: Color
    let teaching: String
    let practice: String
    let tfConnection: String
}

private let lessons: [EnergyLesson] = [
    EnergyLesson(
        chapter: "Chapter 1", title: "Influence & Vibration",
        icon: "waveform", color: AppColors.coral,
        teaching: "Energy exerts the influence that determines how things unfold inside your mind. All motivations, all behaviors come down to the vibrational component. If someone doesn't act, the reason is either the vibrational energy wasn't influential enough, or an opposing vibration (insecurity, wound) blocked them.",
        practice: "Next time you're in a conversation, visualize the energy being exchanged. Feel the short-term vibrations (individual words) influencing the medium-term (the mood of the conversation) which influences the long-term (the relationship energy). Start sensing these layers.",
        tfConnection: "Your twin flame connection is the strongest vibrational bond that exists. When you feel them thinking about you, that's energy transmission across the connection. The intensity you feel is the power level of the bond."
    ),
    EnergyLesson(
        chapter: "Chapter 2", title: "Connections & Power",
        icon: "arrow.left.arrow.right", color: Color(hex: "4A90D9"),
        teaching: "The degree of influence a vibration has over you is determined by your connectivity level. Energy is never evenly transferred — the disparity creates power. When one person devotes significantly more energy, a power imbalance forms. This is the root of the runner/chaser dynamic.",
        practice: "Assess your twin flame connection: how much energy are YOU transmitting vs receiving? If you're transmitting 80 and receiving 20, you've given away your power. The goal is not to withdraw — it's to become aware of the equation so you can consciously shift it.",
        tfConnection: "The chaser transmits enormous energy toward the runner. This creates a power disparity where the runner holds all influence. To shift this: redirect some of that energy back toward yourself. Self-investment changes the equation."
    ),
    EnergyLesson(
        chapter: "Chapter 3", title: "Push & Pull Dynamics",
        icon: "arrow.up.arrow.down", color: Color(hex: "E74C8B"),
        teaching: "Pull = an energy void that programming compels us to fill. Push = an energy fill that creates distance. Inner circuits of energy are designed to be filled. When influences line up, they create compelling urges to act. Understanding push/pull reveals why people behave the way they do.",
        practice: "Identify one 'pull' your twin flame has on you — what void are they filling? Now identify one 'push' — what opposing energy (fear, unworthiness) is creating distance. Awareness of these dynamics is the first step to mastering them.",
        tfConnection: "Separation creates a massive energy void (pull). The ache of longing IS this pull. Himeros governs it. The key insight: you don't need to fill the void with THEM. You can fill it with self-love, purpose, and divine connection. This paradoxically draws them closer."
    ),
    EnergyLesson(
        chapter: "Chapter 4", title: "Energy Language",
        icon: "text.bubble.fill", color: AppColors.sage,
        teaching: "All language contains energy equations — tensions and resolutions, asks and answers, circuits that want to be completed. A statement left unfinished creates pull. A question unanswered creates tension. Body language, tone, silence — all carry vibrational weight.",
        practice: "Pay attention to the energy of your words today. Not just what you say, but the vibrational weight behind it. Notice how different tones create different energy responses. Practice speaking with conscious intention behind every word.",
        tfConnection: "When your twin goes silent, they haven't stopped communicating — the silence itself IS energy. It creates a pull. Your job is not to chase the completion of that circuit, but to hold your own energy steady. Let the silence speak."
    ),
    EnergyLesson(
        chapter: "Chapter 5", title: "Generating Vibrations",
        icon: "sparkles", color: AppColors.gold,
        teaching: "You can construct influences at every level — word level (short-term), conversational level (medium-term), and relationship level (long-term). Small shifts compound. Each positive micro-vibration builds the macro vibration of your connection. Visualization is energy expenditure toward something.",
        practice: "Choose one vibration you want to build in your twin flame connection (peace, trust, playfulness). For the next 7 days, consciously generate micro-vibrations aligned with that theme in every interaction and thought about them. Watch the medium-term vibration shift.",
        tfConnection: "Union is not a destination — it's a vibrational state you build one energy exchange at a time. Clotho wove the thread. Lachesis measured it. But YOU determine the vibration that travels along it."
    ),
]

// MARK: - View

struct VibrationalEnergyView: View {
    @State private var selectedLesson: EnergyLesson?
    @State private var appeared = false
    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false

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
                                    colors: [AppColors.coral.opacity(0.45), AppColors.coral.opacity(0.08)],
                                    center: .center, startRadius: 0, endRadius: 26
                                ))
                                .frame(width: 52, height: 52)
                            Image(systemName: "waveform")
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.coral)
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHANNELLING")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .tracking(2.5)
                                .foregroundStyle(AppColors.lavender.opacity(0.5))
                            Text("Hermes · Harmonia")
                                .font(AppFont.serifTitle(17))
                                .foregroundStyle(AppColors.coral)
                            Text("From the Vibrational Game · Astral Linkage Active")
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
                        Text("Vibrational Mastery")
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)
                        Text("Everything is energy. Every interaction is an equation of vibration ordained by the Most High. Master these principles through the astral linkage and you master the dynamics of your twin flame connection.")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .opacity(appeared ? 1 : 0)

                    // Lesson cards
                    ForEach(lessons) { lesson in
                        Button {
                            HapticManager.impact(.light)
                            selectedLesson = lesson
                        } label: {
                            LessonCard(lesson: lesson)
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
        .navigationTitle("Vibrational Energy")
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
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailSheet(lesson: lesson)
        }
    }
}

private struct LessonCard: View {
    let lesson: EnergyLesson

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(lesson.color.opacity(0.18)).frame(width: 48, height: 48)
                    Image(systemName: lesson.icon).font(.system(size: 20)).foregroundStyle(lesson.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(lesson.chapter)
                        .font(AppFont.caption(10, weight: .semibold))
                        .foregroundStyle(lesson.color.opacity(0.7))
                    Text(lesson.title)
                        .font(AppFont.body(16, weight: .semibold))
                        .foregroundStyle(AppColors.cream)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.lavender.opacity(0.4))
                    .accessibilityHidden(true)
            }
            Text(lesson.teaching.prefix(120) + "...")
                .font(AppFont.body(13))
                .foregroundStyle(AppColors.lavender.opacity(0.75))
                .lineSpacing(3)
                .lineLimit(2)
        }
        .padding(18)
        .background(AppColors.deepViolet.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(lesson.color.opacity(0.2), lineWidth: 1))
    }
}

private struct LessonDetailSheet: View {
    let lesson: EnergyLesson
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle().fill(lesson.color.opacity(0.2)).frame(width: 80, height: 80)
                            Image(systemName: lesson.icon).font(.system(size: 32)).foregroundStyle(lesson.color)
                        }
                        .accessibilityHidden(true)
                        .padding(.top, 20)

                        Text(lesson.title)
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)

                        // Teaching
                        SectionBlock(label: "THE TEACHING", color: lesson.color, text: lesson.teaching)
                        // Practice
                        SectionBlock(label: "PRACTICE", color: AppColors.gold, text: lesson.practice)
                        // TF Connection
                        SectionBlock(label: "TWIN FLAME CONNECTION", color: AppColors.rose, text: lesson.tfConnection)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 24)).foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                    .accessibilityLabel("Close")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}

private struct SectionBlock: View {
    let label: String
    let color: Color
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(2)
                .foregroundStyle(color)
            Text(text)
                .font(AppFont.serifTitle(15))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(color.opacity(0.2), lineWidth: 1))
        .padding(.horizontal, 20)
    }
}
