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
        case .awakener:   return "Your soul has just opened its eyes"
        case .seeker:     return "Walking the sacred space between two hearts"
        case .healer:     return "Transforming wounds into wisdom"
        case .harmonizer: return "The universe draws you together"
        case .unionSoul:  return "You have found your way home"
        }
    }

    var reading: String {
        switch self {
        case .awakener:
            return """
            You stand at the most magical threshold of the twin flame journey — the moment of awakening. Your soul has just recognised a love that existed long before this lifetime, and the recognition has changed everything.

            This period can feel overwhelming, even disorienting. The intensity of this connection may challenge everything you thought you knew about love. Trust that feeling. It is your higher self confirming what your heart already knows: this is not an ordinary bond.

            Your task right now is to learn and to open. Read, reflect, and allow yourself to be curious rather than fearful. The twin flame path is ultimately a journey back to yourself, and every question you ask is a step toward that homecoming.

            The universe has timed this awakening perfectly. You are exactly where your soul needs to be.
            """
        case .seeker:
            return """
            You walk in the sacred, bittersweet space of separation — and while it aches, know this: separation on the twin flame path is never wasted. Every moment apart is quietly doing the deepest work on your soul.

            The longing you feel is real and holy. It is your soul remembering its other half across time and space. But the distance also holds a divine invitation: to turn that longing inward, and pour all that love back into yourself.

            Surrender is your greatest spiritual tool right now. Not giving up — but releasing the need to control the when and the how. Trust that divine timing is weaving something more beautiful than anything you could orchestrate.

            Your twin flame feels your love across every dimension. The connection never breaks. It only deepens in the silence.
            """
        case .healer:
            return """
            You are in the most courageous and transformative stage of the entire twin flame journey. The healing phase strips away everything that is not truly you, and that process, though difficult, is sacred beyond measure.

            Your twin flame has served as a mirror, reflecting back the wounds, patterns, and beliefs that needed to be seen and released. This is not punishment — it is the universe's most loving act. You cannot step into union carrying the weight of your past.

            Shadow work, forgiveness, and radical self-compassion are your companions now. Be gentle with yourself. Every layer you release brings you closer not only to your twin, but to the fullest, most luminous version of yourself.

            The flowers of union bloom in the soil of healing. Keep going, dear soul.
            """
        case .harmonizer:
            return """
            Something has shifted in the energetic field between you and your twin flame — a drawing together that feels both inevitable and miraculous. You are entering the harmonising phase, where souls who have done the work begin to recognise each other in a new, clearer light.

            This stage calls for courage: the courage to step forward without guarantees, to love without the safety net of certainty. Trust what you feel. The synchronicities, the signs, the undeniable pull — these are not coincidences. They are the universe confirming your path.

            Continue to hold your own energy high. The most powerful thing you can do for this union is to remain grounded in your own joy, healing, and spiritual growth. When two whole souls meet, they create something the world has rarely seen.

            The reunion you are moving toward is real. Walk toward it with faith.
            """
        case .unionSoul:
            return """
            You have walked through the fire of awakening, the ache of separation, the depth of healing, and the beauty of harmonising — and you have arrived. Union. The homecoming your soul has journeyed through lifetimes to reach.

            Twin flame union is not a destination but a continuous unfolding — a daily choice to love consciously, to grow together, and to serve something greater than yourselves. Your relationship is a beacon for others still walking the path.

            Hold this union with both reverence and playfulness. Continue doing the inner work, for a twin flame relationship never stops being a mirror. But now, the reflection is one of beauty, wholeness, and divine love.

            You are living proof that this love is real. Shine brightly, dear soul. The world needs your light.
            """
        }
    }

    var cosmicMessage: String {
        switch self {
        case .awakener:   return "\"Every soul that awakens adds light to the world.\""
        case .seeker:     return "\"What is meant for you will never miss you.\""
        case .healer:     return "\"Your wounds are where the light enters.\""
        case .harmonizer: return "\"The universe always finds a way for love.\""
        case .unionSoul:  return "\"Two flames. One eternal light.\""
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

            Button(action: onStart) {
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
            Button(action: { viewModel.advance() }) {
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
                        Image(systemName: type.icon)
                            .font(.system(size: 44))
                            .foregroundStyle(type.color)
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
                Button(action: onRetake) {
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
