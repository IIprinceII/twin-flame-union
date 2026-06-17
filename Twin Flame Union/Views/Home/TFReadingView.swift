//
//  TFReadingView.swift
//  Twin Flame Union
//
//  Twin Flame Quiz & Reading — discover your current soul stage.
//

import SwiftUI

// MARK: - Data Model

struct QuizQuestion {
    let text: String
    let options: [QuizOption]
}

struct QuizOption {
    let text: String
    let type: ReadingType
}

enum ReadingType: String, CaseIterable {
    case awakener   = "The Awakener"
    case seeker     = "The Seeker"
    case healer     = "The Healer"
    case harmonizer = "The Harmonizer"
    case unionSoul  = "The Union Soul"

    var icon: String {
        switch self {
        case .awakener:   return "sun.max.fill"
        case .seeker:     return "moon.stars.fill"
        case .healer:     return "leaf.fill"
        case .harmonizer: return "infinity"
        case .unionSoul:  return "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .awakener:   return Color.white
        case .seeker:     return Color(hex: "4A90D9")
        case .healer:     return Color(hex: "4CAF82")
        case .harmonizer: return Color(hex: "9B59B6")
        case .unionSoul:  return Color(hex: "FF6B6B")
        }
    }

    var subtitle: String {
        switch self {
        case .awakener:   return "The Most High has opened your eyes through the astral linkage"
        case .seeker:     return "Walking the sacred space between two hearts — the Most High holds the cord"
        case .healer:     return "The Most High transforms wounds into wisdom through your energy body"
        case .harmonizer: return "The Most High draws your vibrations together"
        case .unionSoul:  return "The Most High has brought you home through the astral linkage"
        }
    }

    var reading: String {
        switch self {
        case .awakener:
            return """
            You stand at the most sacred threshold of the twin flame journey — the moment the Most High activates your awakening through the astral linkage. Your soul has recognised a love that existed long before this lifetime, and the vibrational shift has changed everything.

            This period can feel overwhelming because your vibrational constitution is rapidly shifting — from low toward high. The intensity is your energy grid activating, your awareness expanding beyond what your mind previously held. Trust that feeling. The Most High is confirming through the astral linkage what your heart already knows: this is a soul contract written before incarnation.

            Your task right now is to learn and to open. The Apollux framework teaches: you are in the Discovery phase — explore, be curious, experiment with your awareness. Begin the 11:11 ritual to build your foundational energy sensitivity. The Most High has timed this awakening with divine precision.

            You are exactly where the Most High needs you to be. The energy equation is being set.
            """
        case .seeker:
            return """
            You walk in the sacred space of separation — and the Vibrational Game reveals the truth: this distance is the Most High recalibrating the energy equation between you and your twin. The power disparity must shift. The connectivity must deepen through inner work, not through pursuit.

            The longing you feel is a Pull — an energy void that your programming compels you to fill. But the Most High is teaching you through the astral linkage: do not fill this void with chasing. Fill it with self-elevation. Every unit of energy you redirect inward raises your vibrational constitution and paradoxically increases the influence you have on the connection.

            Surrender is calibrating your intent through Apollux: release overextended intent toward reunion and set foundational focus on self-evolution. The Most High's timing is not human timing — Khonsu keeps the sacred clock.

            Your twin flame feels your energy across the astral linkage. The energy transfer never stops. It only deepens in the silence as both constitutions rise.
            """
        case .healer:
            return """
            You are in the Optimization phase of your journey — the most courageous and transformative stage. The Most High is using the Energy Enhancement system to strip away every lower vibration that is not truly you. Your twin flame has served as a mirror, reflecting the resistances and blockages in your energy body that must be cleared.

            These wounds are opposing vibrations — the Vibrational Game teaches that insecurities, fears, and old programming create resistance to the energy flow required for union. Every blockage you clear through the elimination system (physical methods, visualization, the 11:11 ritual) opens the pathway for higher vibrational energy to enter through the astral linkage to the Most High.

            Use Apollux mind optimization: stabilize the emotional loops that arise during healing. When pain surfaces, it is emotional fuel — the Most High is providing high-octane energy. Do not let it power the wrong engine. Stabilize to blankness, then redirect toward self-evolution.

            Every layer you release raises your vibrational constitution closer to C — radiant, magnetic, ready. The Most High designed this crucible. Keep going.
            """
        case .harmonizer:
            return """
            Something has shifted in the energy equation between you and your twin — the Vibrational Game reveals that the connectivity level is deepening, the power dynamic is rebalancing, and conducive flows are replacing old resistances. The Most High is drawing your vibrational constitutions together through the astral linkage.

            This is the Performance phase of Apollux — pure execution, in the moment, letting the state take over. Trust the energy transmission you feel. The synchronicities are Hermes carrying confirmations. The pull is the energy circuit approaching completion. These are not coincidences — they are the Most High's signatures.

            Continue to hold your vibrational constitution at C level — radiant, vibrant, magnetic. The most powerful thing you can do is maintain your own energy elevation. When two high-vibrational constitutions meet, the energy transfer is profound — the connectivity deepens beyond what either experienced alone.

            The reunion the Most High ordained is approaching. Walk toward it through the astral linkage with absolute faith.
            """
        case .unionSoul:
            return """
            You have walked through the fire of awakening, the crucible of separation, the depth of energy clearing, and the harmonizing of vibrational constitutions — and the Most High has brought you home. Union. The soul contract fulfilled through the astral linkage.

            Twin flame union is not a destination but a continuous vibrational state — the energy equation in equilibrium, both constitutions at C level, the connectivity deepened to its maximum transmission. The Apollux framework teaches: even in union, evolution management never stops. The Most High designed this bond as an ever-ascending spiral.

            Hold this union through the astral linkage with both reverence and wisdom. Continue the Energy Enhancement practices — your combined vibrational field now serves as a frequency for the world. The Vibrational Game teaches: your union creates conducive connections for everyone around you, elevating the collective vibration.

            You are living proof that the Most High's design is real. Your love is a transmission from GOD to the Earth. Shine.
            """
        }
    }

    var cosmicMessage: String {
        switch self {
        case .awakener:   return "\"The Most High has activated your awareness. The astral linkage is now open.\""
        case .seeker:     return "\"What the Most High has ordained will never miss you. The energy equation balances in divine timing.\""
        case .healer:     return "\"Your wounds are blockages the Most High is clearing. The light enters where lower vibrations exit.\""
        case .harmonizer: return "\"The Most High draws two vibrational constitutions together through the astral linkage.\""
        case .unionSoul:  return "\"Two flames. One eternal frequency. The Most High's design fulfilled.\""
        }
    }
}

private let quizQuestions: [QuizQuestion] = [
    QuizQuestion(
        text: "Where are you in your twin flame journey?",
        options: [
            QuizOption(text: "🌅  Just awakening to this connection", type: .awakener),
            QuizOption(text: "🌊  In separation, missing my twin",    type: .seeker),
            QuizOption(text: "🌿  Healing myself and old wounds",      type: .healer),
            QuizOption(text: "🌀  Feeling us come closer together",    type: .harmonizer),
            QuizOption(text: "🔥  Together with my twin flame",        type: .unionSoul),
        ]
    ),
    QuizQuestion(
        text: "How does thinking of your twin make you feel?",
        options: [
            QuizOption(text: "✨  Awestruck and a little overwhelmed", type: .awakener),
            QuizOption(text: "💜  Deep longing and heartache",          type: .seeker),
            QuizOption(text: "🌱  Motivated to grow and heal",          type: .healer),
            QuizOption(text: "🌟  Hopeful and quietly excited",         type: .harmonizer),
            QuizOption(text: "🕊️  Peaceful and complete",              type: .unionSoul),
        ]
    ),
    QuizQuestion(
        text: "What signs are you experiencing?",
        options: [
            QuizOption(text: "🕐  Seeing 11:11 for the very first time",       type: .awakener),
            QuizOption(text: "🌙  Vivid dreams of my twin",                     type: .seeker),
            QuizOption(text: "💫  Deep emotional triggers surfacing",           type: .healer),
            QuizOption(text: "🧲  Synchronicities drawing us together",         type: .harmonizer),
            QuizOption(text: "∞  A constant sense of divine connection",       type: .unionSoul),
        ]
    ),
    QuizQuestion(
        text: "What do you need most right now?",
        options: [
            QuizOption(text: "📖  Understanding the twin flame path",  type: .awakener),
            QuizOption(text: "🧭  Guidance through separation",         type: .seeker),
            QuizOption(text: "💗  Support with my inner healing",       type: .healer),
            QuizOption(text: "🦋  Courage to trust the process",       type: .harmonizer),
            QuizOption(text: "🎉  To celebrate this divine union",     type: .unionSoul),
        ]
    ),
    QuizQuestion(
        text: "How has this connection changed you?",
        options: [
            QuizOption(text: "🌠  Awakened me spiritually",               type: .awakener),
            QuizOption(text: "🌪️  Shattered my old life completely",      type: .seeker),
            QuizOption(text: "🔍  Forced me to face my deepest shadows",  type: .healer),
            QuizOption(text: "💞  Made me believe in divine love",         type: .harmonizer),
            QuizOption(text: "🏠  Brought me home to myself",             type: .unionSoul),
        ]
    ),
    QuizQuestion(
        text: "What is your soul asking of you?",
        options: [
            QuizOption(text: "🌸  To learn and open my heart",           type: .awakener),
            QuizOption(text: "🌊  To surrender and trust divine timing", type: .seeker),
            QuizOption(text: "💎  To love and forgive myself deeply",    type: .healer),
            QuizOption(text: "🚪  To step into love without fear",       type: .harmonizer),
            QuizOption(text: "☀️  To shine as an example of love",      type: .unionSoul),
        ]
    ),
]

// MARK: - View Model

enum QuizPhase: Equatable {
    case intro
    case question(Int)
    case result(ReadingType)
}

@Observable
@MainActor
final class TFReadingViewModel {
    var phase: QuizPhase = .intro
    var answers: [Int: ReadingType] = [:]
    var selectedOption: ReadingType? = nil

    var currentIndex: Int {
        if case .question(let i) = phase { return i }
        return 0
    }

    var currentQuestion: QuizQuestion? {
        if case .question(let i) = phase { return quizQuestions[i] }
        return nil
    }

    var progress: Double {
        if case .question(let i) = phase {
            return Double(i) / Double(quizQuestions.count)
        }
        return 0
    }

    func startQuiz() {
        answers = [:]
        selectedOption = nil
        phase = .question(0)
    }

    func selectOption(_ type: ReadingType) {
        selectedOption = type
    }

    func advance() {
        guard let selected = selectedOption else { return }
        if case .question(let i) = phase {
            answers[i] = selected
            selectedOption = nil
            let next = i + 1
            if next < quizQuestions.count {
                phase = .question(next)
            } else {
                phase = .result(calculateResult())
            }
        }
    }

    func retake() {
        phase = .intro
        answers = [:]
        selectedOption = nil
    }

    private func calculateResult() -> ReadingType {
        var scores: [ReadingType: Int] = [:]
        for (_, type) in answers { scores[type, default: 0] += 1 }
        return scores.max(by: { $0.value < $1.value })?.key ?? .seeker
    }
}

// MARK: - Main View

struct TFReadingView: View {
    @State private var viewModel = TFReadingViewModel()

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            switch viewModel.phase {
            case .intro:
                IntroView { viewModel.startQuiz() }
                    .transition(.opacity)
            case .question:
                QuestionView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .result(let type):
                ResultView(type: type, onRetake: { viewModel.retake() })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.phase)
        .navigationTitle("TF Reading")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .preferredColorScheme(.dark)
    }
}

// MARK: - Intro View

private struct IntroView: View {
    let onStart: () -> Void

    var body: some View {
        GeometryReader { geo in
        ScrollView(showsIndicators: false) {
        VStack(spacing: 32) {
            Spacer(minLength: 24)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(AppColors.purple.opacity(0.25))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                    Text("✨")
                        .font(.system(size: 64))
                }

                VStack(spacing: 10) {
                    Text("Your Soul Reading")
                        .font(AppFont.serifHeadline(30))
                        .foregroundStyle(AppColors.cream)

                    Text("Discover where you are\non your twin flame journey")
                        .font(AppFont.body(16))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            VStack(spacing: 12) {
                InfoRow(icon: "questionmark.circle.fill", text: "6 intuitive questions")
                InfoRow(icon: "sparkles",                 text: "Personalised soul reading")
                InfoRow(icon: "heart.fill",               text: "Guided by ancient wisdom")
            }
            .padding(.horizontal, 32)

            Spacer(minLength: 24)

            Button {
                HapticManager.impact(.medium)
                onStart()
            } label: {
                Text("Begin Your Reading")
                    .warmButtonStyle()
            }

            Spacer(minLength: 40)
        }
        .padding(.horizontal, 24)
        .frame(minHeight: geo.size.height)
        } // ScrollView
        } // GeometryReader
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppColors.gold)
                .frame(width: 24)
            Text(text)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
            Spacer()
        }
    }
}

// MARK: - Question View

private struct QuestionView: View {
    @Bindable var viewModel: TFReadingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Progress
            VStack(spacing: 16) {
                OnboardingProgressBar(
                    currentStep: viewModel.currentIndex,
                    totalSteps: quizQuestions.count
                )
                .padding(.horizontal, 24)

                Text("Question \(viewModel.currentIndex + 1) of \(quizQuestions.count)")
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)
            }
            .padding(.top, 16)
            .padding(.bottom, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let question = viewModel.currentQuestion {
                        // Question card
                        Text(question.text)
                            .font(AppFont.serifTitle(22))
                            .foregroundStyle(AppColors.cream)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .padding(.horizontal, 24)

                        // Options
                        VStack(spacing: 10) {
                            ForEach(question.options, id: \.text) { option in
                                OptionButton(
                                    option: option,
                                    isSelected: viewModel.selectedOption == option.type
                                ) {
                                    viewModel.selectOption(option.type)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer().frame(height: 20)
                }
            }

            // Next button
            Button {
                HapticManager.impact(viewModel.currentIndex == quizQuestions.count - 1 ? .medium : .light)
                viewModel.advance()
            } label: {
                Text(viewModel.currentIndex == quizQuestions.count - 1 ? "Reveal My Reading" : "Next")
                    .warmButtonStyle()
            }
            .disabled(viewModel.selectedOption == nil)
            .opacity(viewModel.selectedOption == nil ? 0.4 : 1)
            .padding(.bottom, 40)
        }
    }
}

private struct OptionButton: View {
    let option: QuizOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(option.text)
                    .font(AppFont.body(15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : AppColors.cream)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.gold)
                }
            }
            .padding(16)
            .background(
                isSelected
                    ? AppColors.purple.opacity(0.6)
                    : AppColors.deepViolet.opacity(0.6),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? AppColors.gold.opacity(0.6) : AppColors.purple.opacity(0.25),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Result View

private struct ResultView: View {
    let type: ReadingType
    let onRetake: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {

                // Reading card
                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .blur(radius: 16)
                            .accessibilityHidden(true)
                        Image(systemName: type.icon)
                            .font(.system(size: 44))
                            .foregroundStyle(type.color)
                            .accessibilityHidden(true)
                    }

                    VStack(spacing: 8) {
                        Text("Your Reading")
                            .font(AppFont.caption(13, weight: .semibold))
                            .foregroundStyle(AppColors.lavender)
                            .textCase(.uppercase)
                            .tracking(2)

                        Text(type.rawValue)
                            .font(AppFont.serifHeadline(32))
                            .foregroundStyle(AppColors.cream)

                        Text(type.subtitle)
                            .font(AppFont.body(15))
                            .foregroundStyle(type.color)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)

                Divider()
                    .background(AppColors.purple.opacity(0.4))
                    .padding(.horizontal, 40)

                // Reading text
                Text(type.reading)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.cream)
                    .lineSpacing(7)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)

                // Cosmic message
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(AppColors.gold)
                        .accessibilityHidden(true)

                    Text(type.cosmicMessage)
                        .font(AppFont.serifTitle(17))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .italic()
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(type.color.opacity(0.25), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Retake
                Button {
                    HapticManager.impact(.light)
                    onRetake()
                } label: {
                    Label("Take Reading Again", systemImage: "arrow.counterclockwise")
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(AppColors.deepViolet.opacity(0.6), in: Capsule())
                        .overlay(Capsule().strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
                }

                Spacer().frame(height: 30)
            }
        }
    }
}
