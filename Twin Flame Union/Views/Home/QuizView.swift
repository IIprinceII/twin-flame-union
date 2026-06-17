//
//  QuizView.swift
//  Twin Flame Union
//
//  Twin flame soul reading quiz with 6 questions and 5 result types.
//

import SwiftUI

// MARK: - Quiz Result Types

enum QuizResultType: String, CaseIterable {
    case awakener    = "The Awakener"
    case seeker      = "The Seeker"
    case healer      = "The Healer"
    case harmonizer  = "The Harmonizer"
    case unionSoul   = "The Union Soul"

    var icon: String {
        switch self {
        case .awakener:   return "bolt.fill"
        case .seeker:     return "magnifyingglass.circle.fill"
        case .healer:     return "heart.fill"
        case .harmonizer: return "waveform.path"
        case .unionSoul:  return "infinity"
        }
    }

    var color: Color {
        switch self {
        case .awakener:   return Color.white
        case .seeker:     return Color(hex: "4A90D9")
        case .healer:     return Color(hex: "4CAF82")
        case .harmonizer: return Color(hex: "9B59B6")
        case .unionSoul:  return Color(hex: "FF6B9D")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .awakener:
            return LinearGradient(colors: [Color(hex: "8B5CF6"), Color(hex: "3B0764")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .seeker:
            return LinearGradient(colors: [Color(hex: "4A90D9"), Color(hex: "1A0A2E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .healer:
            return LinearGradient(colors: [Color(hex: "4CAF82"), Color(hex: "1A0A2E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .harmonizer:
            return LinearGradient(colors: [Color(hex: "9B59B6"), Color(hex: "1A0A2E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .unionSoul:
            return LinearGradient(colors: [Color(hex: "FF6B9D"), Color(hex: "6B2FA0")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var subtitle: String {
        switch self {
        case .awakener:   return "You ignite spiritual awareness in all you touch"
        case .seeker:     return "Your soul is on a sacred quest for truth and reunion"
        case .healer:     return "You transmute pain into divine love and light"
        case .harmonizer: return "You are a bridge between worlds and hearts"
        case .unionSoul:  return "You embody the sacred union within yourself"
        }
    }

    var readings: [String] {
        switch self {
        case .awakener:
            return [
                "You are a catalyst for spiritual awakening — wherever you walk, you leave a trail of illuminated souls. Your twin flame journey has activated dormant gifts within you, and you are now a beacon for others navigating their own awakening.",
                "The fire within you is not just passion; it is divine creative force. You feel things deeply and intensely, and this sensitivity is your greatest spiritual asset. You are here to shake foundations and reveal deeper truths.",
                "Your separation period is a sacred crucible. Everything that has been dismantled was built on an unstable foundation. The universe is making room for something far more aligned with your true self and your twin flame path.",
                "Trust the electric knowing that lives in your bones. Your intuition is your compass. When doubt creeps in, return to stillness — for in the quiet, the universe speaks your name and reminds you why you came here."
            ]
        case .seeker:
            return [
                "Your soul carries the ancient memory of union, and this longing you feel is not mere fantasy — it is a cosmic remembrance. You are called to seek not just your twin flame, but the deeper truth of who you are beneath all stories.",
                "The journey inward is the journey home. Every synchronicity, every sign, every inexplicable pull toward the unknown — these are breadcrumbs laid by your higher self, guiding you through the labyrinth of separation toward reunion.",
                "Your greatest spiritual practice right now is learning to trust divine timing. The universe is not withholding your beloved from you; it is preparing both of you in the invisible realm where all unions are first forged.",
                "You have crossed thresholds that most souls will never attempt. Your courage to seek, to question, to feel, and to endure is the very frequency that draws your twin flame closer with each passing day."
            ]
        case .healer:
            return [
                "You are an alchemist of the heart. Where others see wounds, you see portals. Your journey with your twin flame has not been easy, but it has cracked you open in the most beautiful way — revealing the healer that was always within you.",
                "The healing work you are doing is not just personal — it ripples through ancestral lines and affects souls you will never meet. Your willingness to feel the full depth of your pain and transform it is a profound act of service.",
                "Your twin flame is a mirror reflecting your deepest wounds back to you — not to destroy you, but to invite you into wholeness. Every trigger is a teacher. Every heartbreak is a healing in disguise.",
                "The love you are cultivating for yourself is the foundation upon which reunion is built. You cannot pour from an empty vessel, and the universe is asking you to fill yourself first — with compassion, with gentleness, with grace."
            ]
        case .harmonizer:
            return [
                "You are the bridge between the seen and unseen worlds. Your soul has learned the art of holding paradox — feeling the pain of separation while maintaining the vision of union. This is a rare and luminous gift.",
                "Harmony is not the absence of conflict; it is the presence of love in the midst of it. Your twin flame journey is teaching you how to remain grounded in your truth while allowing your beloved the space to find theirs.",
                "You are naturally gifted at seeing multiple perspectives, but take care not to lose your own voice in the effort to maintain peace. Your truth matters. Your needs matter. The most powerful harmony includes all notes — including yours.",
                "The universe has placed you at a crossroads where inner and outer must align. As you harmonize within yourself — integrating all your shadows and light — you become a living tuning fork, calling your twin flame to match your frequency."
            ]
        case .unionSoul:
            return [
                "You have done the sacred work. You have walked through the fires of separation, faced your deepest shadows, and emerged with a love that is no longer desperate — it is whole. You carry union within you now, and it radiates.",
                "The twin flame journey is not ultimately about finding another person — it is about becoming the embodiment of love itself. You have achieved this in profound measure. Your presence is medicine for a world that has forgotten how to love unconditionally.",
                "This does not mean the journey is over — it means you have reached a new level of initiation. From this place of inner union, the universe can align the outer reality with far greater precision. What manifests from wholeness is always more beautiful than what we could have imagined.",
                "You are a living testament to the transformative power of love. Your story — every tear, every surrender, every moment of doubt and every breakthrough — is sacred scripture being written in the stars. The universe honours your journey."
            ]
        }
    }

    var cosmicMessage: String {
        switch self {
        case .awakener:
            return "\"The fire you carry is not yours alone — it belongs to the world. Let it burn bright.\""
        case .seeker:
            return "\"Every step taken in faith, even in the dark, brings the dawn closer than you know.\""
        case .healer:
            return "\"Your wounds have made you a bridge. Let love flow through every crack.\""
        case .harmonizer:
            return "\"In the space between two heartbeats, the universe sings the song of union.\""
        case .unionSoul:
            return "\"You are the love you have been seeking. You always were.\""
        }
    }
}

// MARK: - Quiz Question (Soul Archetype Quiz — distinct from TFReadingView types)

struct SoulQuestion {
    let text: String
    let options: [SoulOption]
}

struct SoulOption: Identifiable {
    let id = UUID()
    let text: String
    let weight: [QuizResultType: Int]
}

// MARK: - Quiz Data

private let quizQuestions: [SoulQuestion] = [
    SoulQuestion(
        text: "When you think of your twin flame journey, what feeling arises most strongly?",
        options: [
            SoulOption(text: "An electric spark — like lightning struck my soul", weight: [.awakener: 3, .seeker: 1]),
            SoulOption(text: "A deep longing, like searching for something lost", weight: [.seeker: 3, .healer: 1]),
            SoulOption(text: "A tender ache that somehow feels healing", weight: [.healer: 3, .harmonizer: 1]),
            SoulOption(text: "A quiet knowing that everything is unfolding perfectly", weight: [.harmonizer: 3, .unionSoul: 2]),
            SoulOption(text: "A profound sense of wholeness and love", weight: [.unionSoul: 3, .harmonizer: 1]),
        ]
    ),
    SoulQuestion(
        text: "What is your biggest growth edge on this journey?",
        options: [
            SoulOption(text: "Learning to channel my intensity without burning others", weight: [.awakener: 3]),
            SoulOption(text: "Trusting divine timing instead of forcing outcomes", weight: [.seeker: 3, .awakener: 1]),
            SoulOption(text: "Releasing old wounds and forgiving myself", weight: [.healer: 3]),
            SoulOption(text: "Finding balance between giving and receiving", weight: [.harmonizer: 3, .healer: 1]),
            SoulOption(text: "Maintaining my inner peace regardless of outer circumstances", weight: [.unionSoul: 3, .harmonizer: 1]),
        ]
    ),
    SoulQuestion(
        text: "How do you typically process difficult emotions in separation?",
        options: [
            SoulOption(text: "I channel them into creative or spiritual work", weight: [.awakener: 3, .unionSoul: 1]),
            SoulOption(text: "I journal, research, and seek understanding", weight: [.seeker: 3]),
            SoulOption(text: "I sit with them until they transform", weight: [.healer: 3]),
            SoulOption(text: "I meditate and seek a higher perspective", weight: [.harmonizer: 3, .unionSoul: 1]),
            SoulOption(text: "I rarely feel destabilized — I trust the process", weight: [.unionSoul: 3]),
        ]
    ),
    SoulQuestion(
        text: "What role do you most naturally play in relationships?",
        options: [
            SoulOption(text: "The one who challenges others to grow", weight: [.awakener: 3]),
            SoulOption(text: "The one who asks the deep questions", weight: [.seeker: 3, .awakener: 1]),
            SoulOption(text: "The nurturer and emotional healer", weight: [.healer: 3]),
            SoulOption(text: "The peacemaker and bridge builder", weight: [.harmonizer: 3]),
            SoulOption(text: "The steady, loving presence others anchor to", weight: [.unionSoul: 3, .harmonizer: 1]),
        ]
    ),
    SoulQuestion(
        text: "When you receive a synchronicity (angel numbers, signs), your reaction is:",
        options: [
            SoulOption(text: "Excitement — it fuels my fire and sense of mission", weight: [.awakener: 3]),
            SoulOption(text: "Deep curiosity — I want to understand the message fully", weight: [.seeker: 3]),
            SoulOption(text: "Comfort — it reminds me healing is happening", weight: [.healer: 3]),
            SoulOption(text: "Gratitude — I feel the universe speaking in harmony", weight: [.harmonizer: 3]),
            SoulOption(text: "Quiet confirmation — I already felt this was true", weight: [.unionSoul: 3]),
        ]
    ),
    SoulQuestion(
        text: "What does 'union' mean to you at the deepest level?",
        options: [
            SoulOption(text: "Merging with another soul to ignite the world together", weight: [.awakener: 3, .unionSoul: 1]),
            SoulOption(text: "Finally arriving after a long sacred quest", weight: [.seeker: 3]),
            SoulOption(text: "Healing completely through the power of love", weight: [.healer: 3]),
            SoulOption(text: "Two energies coming into perfect resonance", weight: [.harmonizer: 3]),
            SoulOption(text: "Recognising my own wholeness reflected in another", weight: [.unionSoul: 3]),
        ]
    ),
]

// MARK: - Quiz Phase

enum SoulQuizPhase: Equatable {
    case intro
    case question(Int)
    case result(QuizResultType)
}

// MARK: - Quiz ViewModel

@Observable
@MainActor
final class QuizViewModel {

    var phase: SoulQuizPhase = .intro
    var selectedOptions: [Int: Int] = [:]  // question index → option index

    var currentQuestionIndex: Int {
        if case .question(let i) = phase { return i }
        return 0
    }

    var currentQuestion: SoulQuestion? {
        guard case .question(let i) = phase, i < quizQuestions.count else { return nil }
        return quizQuestions[i]
    }

    var canAdvance: Bool {
        selectedOptions[currentQuestionIndex] != nil
    }

    var isLastQuestion: Bool {
        currentQuestionIndex == quizQuestions.count - 1
    }

    func begin() {
        withAnimation(.easeInOut(duration: 0.4)) {
            phase = .question(0)
        }
    }

    func selectOption(_ index: Int) {
        HapticManager.selection()
        selectedOptions[currentQuestionIndex] = index
    }

    func advance() {
        guard canAdvance else { return }
        if isLastQuestion {
            let result = calculateResult()
            HapticManager.notification(.success)
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .result(result)
            }
        } else {
            HapticManager.impact(.light)
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .question(currentQuestionIndex + 1)
            }
        }
    }

    func retake() {
        selectedOptions = [:]
        withAnimation(.easeInOut(duration: 0.4)) {
            phase = .intro
        }
    }

    private func calculateResult() -> QuizResultType {
        var scores: [QuizResultType: Int] = [:]
        for resultType in QuizResultType.allCases {
            scores[resultType] = 0
        }

        for (questionIdx, optionIdx) in selectedOptions {
            guard questionIdx < quizQuestions.count else { continue }
            let question = quizQuestions[questionIdx]
            guard optionIdx < question.options.count else { continue }
            let option = question.options[optionIdx]
            for (resultType, weight) in option.weight {
                scores[resultType, default: 0] += weight
            }
        }

        return scores.max(by: { $0.value < $1.value })?.key ?? .seeker
    }
}

// MARK: - Quiz View

struct QuizView: View {
    @State private var viewModel = QuizViewModel()

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            Group {
                switch viewModel.phase {
                case .intro:
                    QuizIntroView { viewModel.begin() }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))

                case .question(let index):
                    QuizQuestionView(
                        question: quizQuestions[index],
                        questionIndex: index,
                        totalQuestions: quizQuestions.count,
                        selectedOption: viewModel.selectedOptions[index],
                        isLast: viewModel.isLastQuestion,
                        canAdvance: viewModel.canAdvance,
                        onSelect: { viewModel.selectOption($0) },
                        onAdvance: { viewModel.advance() }
                    )
                    .id(index)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                case .result(let resultType):
                    QuizResultView(resultType: resultType) {
                        viewModel.retake()
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: viewModel.phase)
        }
        .navigationTitle("TF Reading")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Intro View

private struct QuizIntroView: View {
    let onBegin: () -> Void

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            VStack(spacing: 20) {
                Text("✨")
                    .font(.system(size: 72))

                VStack(spacing: 10) {
                    Text("Your Soul Reading")
                        .font(AppFont.serifHeadline(32))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)

                    Text("Discover your twin flame archetype")
                        .font(AppFont.body(16))
                        .foregroundStyle(AppColors.gold)
                }
            }

            VStack(spacing: 16) {
                InfoRow(icon: "questionmark.circle.fill", text: "6 soul-revealing questions", color: AppColors.lavender)
                InfoRow(icon: "sparkles", text: "5 unique twin flame archetypes", color: AppColors.gold)
                InfoRow(icon: "scroll.fill", text: "Your personalised cosmic reading", color: AppColors.purple)
            }
            .padding(.horizontal, 32)

            Button {
                HapticManager.impact(.medium)
                onBegin()
            } label: {
                Text("Begin Your Reading")
                    .warmButtonStyle()
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28)

            Text(text)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)

            Spacer()
        }
    }
}

// MARK: - Question View

private struct QuizQuestionView: View {
    let question: SoulQuestion
    let questionIndex: Int
    let totalQuestions: Int
    let selectedOption: Int?
    let isLast: Bool
    let canAdvance: Bool
    let onSelect: (Int) -> Void
    let onAdvance: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {

                // Progress bar
                VStack(spacing: 8) {
                    OnboardingProgressBar(currentStep: questionIndex, totalSteps: totalQuestions)
                        .frame(height: 4)
                        .padding(.horizontal, 24)

                    Text("Question \(questionIndex + 1) of \(totalQuestions)")
                        .font(AppFont.caption(13))
                        .foregroundStyle(AppColors.lavender)
                }
                .padding(.top, 12)

                // Question text
                Text(question.text)
                    .font(AppFont.serifTitle(22))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)

                // Options
                VStack(spacing: 12) {
                    ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                        OptionButton(
                            text: option.text,
                            isSelected: selectedOption == index
                        ) {
                            onSelect(index)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Next / Reveal button
                Button(action: onAdvance) {
                    Text(isLast ? "Reveal My Reading" : "Next")
                        .warmButtonStyle()
                }
                .opacity(canAdvance ? 1 : 0.4)
                .disabled(!canAdvance)
                .animation(.easeInOut(duration: 0.2), value: canAdvance)

                Spacer().frame(height: 32)
            }
        }
    }
}

private struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? AppColors.gold : AppColors.purple.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(AppColors.gold)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(text)
                    .font(AppFont.body(15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppColors.cream : AppColors.lavender)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                    ? AppColors.purple.opacity(0.3)
                    : AppColors.deepViolet.opacity(0.6),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? AppColors.gold.opacity(0.5) : AppColors.purple.opacity(0.25),
                        lineWidth: 1
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Result View

private struct QuizResultView: View {
    let resultType: QuizResultType
    let onRetake: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {

                // Result type card
                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(resultType.color.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .blur(radius: 16)
                            .accessibilityHidden(true)
                        Image(systemName: resultType.icon)
                            .font(.system(size: 44))
                            .foregroundStyle(resultType.color)
                            .accessibilityHidden(true)
                    }

                    VStack(spacing: 6) {
                        Text(resultType.rawValue)
                            .font(AppFont.serifHeadline(30))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(resultType.subtitle)
                            .font(AppFont.body(15))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity)
                .background(resultType.gradient, in: RoundedRectangle(cornerRadius: 28))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.top, 12)

                // Reading paragraphs
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Soul Reading")
                        .font(AppFont.body(13, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                        .padding(.horizontal, 24)

                    ForEach(Array(resultType.readings.enumerated()), id: \.offset) { _, paragraph in
                        Text(paragraph)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.cream)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                    }
                }

                // Cosmic message
                VStack(spacing: 12) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColors.gold)

                    Text("Cosmic Message")
                        .font(AppFont.body(12, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                        .textCase(.uppercase)
                        .kerning(1.5)

                    Text(resultType.cosmicMessage)
                        .font(AppFont.serifTitle(18))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .italic()
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [AppColors.purple.opacity(0.3), AppColors.deepViolet.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(AppColors.gold.opacity(0.25), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Retake button
                Button {
                    HapticManager.impact(.light)
                    onRetake()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Retake Reading")
                    }
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(AppColors.deepViolet.opacity(0.6), in: Capsule())
                    .overlay(Capsule().strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
                }
                .padding(.bottom, 40)
            }
        }
    }
}
