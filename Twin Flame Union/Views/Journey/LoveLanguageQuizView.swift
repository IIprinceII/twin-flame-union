//
//  LoveLanguageQuizView.swift
//  Twin Flame Union
//
//  Twin flame love language quiz — discover how you give and receive divine love.
//

import SwiftUI

// MARK: - Love Language

private enum LoveLanguage: String, CaseIterable {
    case wordsOfAffirmation = "Words of Affirmation"
    case qualityTime        = "Quality Time"
    case physicalTouch      = "Physical Touch"
    case actsOfService      = "Acts of Service"
    case gifts              = "Receiving Gifts"
    case energetic          = "Energetic Connection"

    var icon: String {
        switch self {
        case .wordsOfAffirmation: return "quote.bubble.fill"
        case .qualityTime:        return "clock.fill"
        case .physicalTouch:      return "hand.raised.fill"
        case .actsOfService:      return "hammer.fill"
        case .gifts:              return "gift.fill"
        case .energetic:          return "waveform.path.ecg"
        }
    }

    var color: Color {
        switch self {
        case .wordsOfAffirmation: return Color(hex: "8B5CF6")
        case .qualityTime:        return Color(hex: "4A90D9")
        case .physicalTouch:      return Color(hex: "E74C8B")
        case .actsOfService:      return Color(hex: "43A047")
        case .gifts:              return Color(hex: "F0C040")
        case .energetic:          return AppColors.coral
        }
    }

    var description: String {
        switch self {
        case .wordsOfAffirmation:
            return "You are deeply moved by spoken and written expressions of love. Affirmations, declarations, and spiritual truth-speaking resonate in your soul. Silence from your twin feels like rejection; their words are balm."
        case .qualityTime:
            return "Undivided presence is your deepest love language. You need your twin to be fully *with* you — no distractions, no distance. Sacred shared time nourishes you more than any grand gesture."
        case .physicalTouch:
            return "Touch is your primary love channel. You feel connection through physical closeness, holds, and the sacred energy exchanged through skin. The absence of your twin's physical presence can be especially painful."
        case .actsOfService:
            return "Love expressed through action speaks to your soul. When your twin does things for you — practical, thoughtful, mission-aligned — you feel profoundly cherished and seen."
        case .gifts:
            return "Symbolic tokens of love speak directly to your heart. These need not be expensive — they must be intentional. Sacred objects, surprise gestures, and thoughtful symbols tell you: I was thinking of you."
        case .energetic:
            return "Your primary love language transcends the physical. You feel loved through telepathic connection, shared meditation, synchronized signs, and the invisible thread of soul communication. Distance doesn't break this."
        }
    }

    var twinFlameGuidance: String {
        switch self {
        case .wordsOfAffirmation:
            return "In separation, write love letters even if unsent. Speak your twin's name with love each day. Their higher self receives every declaration."
        case .qualityTime:
            return "Create sacred rituals of inner connection: meditate together in your mind. Visualize quality time with your twin's higher self during prayer."
        case .physicalTouch:
            return "Ground your body in the present. Hugging yourself, placing a hand on your heart, and somatic healing work will bridge the physical gap until reunion."
        case .actsOfService:
            return "Serve others in the name of your twin flame's love. Acts of service in the world are acts of love sent energetically to your twin."
        case .gifts:
            return "Create a sacred space with objects that represent your union. Each meaningful item keeps the frequency alive and anchors the reunion energy."
        case .energetic:
            return "Trust every sign, synchronicity, and dream. Your twin's soul is actively communicating. The energetic bond between you is real and growing stronger."
        }
    }
}

// MARK: - Quiz Question

private struct LLQuestion {
    let text: String
    let optionA: (text: String, language: LoveLanguage)
    let optionB: (text: String, language: LoveLanguage)
}

private let questions: [LLQuestion] = [
    .init(text: "When your twin flame says nothing but shows up for you in difficult moments, what matters most?",
          optionA: ("Them holding me close", .physicalTouch),
          optionB: ("Them saying 'I'm here for you'", .wordsOfAffirmation)),
    .init(text: "What feels like the most meaningful gift your twin could give you?",
          optionA: ("An entire uninterrupted day together", .qualityTime),
          optionB: ("A small meaningful object that says 'I thought of you'", .gifts)),
    .init(text: "During separation, what brings you the most comfort?",
          optionA: ("Sensing their energy or receiving a sign", .energetic),
          optionB: ("A heartfelt message or voicenote from them", .wordsOfAffirmation)),
    .init(text: "You feel most loved when your twin…",
          optionA: ("Takes care of something for you without being asked", .actsOfService),
          optionB: ("Looks into your eyes and really sees you", .qualityTime)),
    .init(text: "What type of connection feels most sacred to you?",
          optionA: ("Shared meditation, prayer, or spiritual practice", .energetic),
          optionB: ("Holding hands and being close physically", .physicalTouch)),
    .init(text: "When you imagine perfect reunion, what is the first thing that happens?",
          optionA: ("They run to hold me", .physicalTouch),
          optionB: ("They tell me everything they've been feeling", .wordsOfAffirmation)),
    .init(text: "You feel disconnected from your twin when…",
          optionA: ("They stop doing the small things they used to do", .actsOfService),
          optionB: ("The energetic thread between you goes quiet", .energetic)),
    .init(text: "The deepest wound in this journey for you is…",
          optionA: ("Not being together in the same space", .qualityTime),
          optionB: ("Not hearing words of love and commitment", .wordsOfAffirmation)),
    .init(text: "In union, which would fill your cup the most each morning?",
          optionA: ("Them making you coffee before you ask", .actsOfService),
          optionB: ("A surprise meaningful gift that shows they know you", .gifts)),
    .init(text: "What do you believe love ultimately IS at its deepest level?",
          optionA: ("An invisible sacred bond that no distance can break", .energetic),
          optionB: ("Being fully present with each other in this moment", .qualityTime)),
]

// MARK: - View

struct LoveLanguageQuizView: View {
    @AppStorage("llQuizResult") private var savedResult = ""
    @State private var currentQ      = 0
    @State private var scores        = [LoveLanguage: Int]()
    @State private var result: LoveLanguage? = nil
    @State private var isAnimating   = false

    private var progress: Double { Double(currentQ) / Double(questions.count) }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            if let res = result {
                resultView(language: res)
            } else {
                questionView
            }
        }
        .navigationTitle("Love Language Quiz")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            if let saved = LoveLanguage(rawValue: savedResult) { result = saved }
        }
    }

    // MARK: Question View

    private var questionView: some View {
        VStack(spacing: 24) {
            // Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(currentQ + 1) of \(questions.count)")
                        .font(AppFont.caption(13))
                        .foregroundStyle(AppColors.lavender)
                    Spacer()
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColors.purple.opacity(0.2)).frame(height: 4)
                        Capsule().fill(AppGradients.warm).frame(width: geo.size.width * progress, height: 4)
                            .animation(.spring(response: 0.5), value: progress)
                    }
                }
                .frame(height: 4)
                .accessibilityHidden(true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Question card
            let q = questions[currentQ]
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AppGradients.warm)
                    .accessibilityHidden(true)

                Text(q.text)
                    .font(AppFont.serifTitle(20))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 24)

            // Options
            VStack(spacing: 14) {
                answerButton(text: q.optionA.text, language: q.optionA.language)
                answerButton(text: q.optionB.text, language: q.optionB.language)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func answerButton(text: String, language: LoveLanguage) -> some View {
        Button {
            HapticManager.impact(.light)
            scores[language, default: 0] += 1
            withAnimation(.easeInOut(duration: 0.3)) {
                if currentQ + 1 < questions.count {
                    currentQ += 1
                } else {
                    computeResult()
                }
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: language.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(language.color)
                    .frame(width: 28)
                Text(text)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                Spacer()
            }
            .padding(18)
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(AppColors.purple.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: Result View

    private func resultView(language: LoveLanguage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(language.color.opacity(0.2))
                            .frame(width: 100, height: 100)
                        Image(systemName: language.icon)
                            .font(.system(size: 44))
                            .foregroundStyle(language.color)
                    }
                    .accessibilityHidden(true)
                    .padding(.top, 28)
                    Text("Your Love Language")
                        .font(AppFont.body(13, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                    Text(language.rawValue)
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Label("What This Means", systemImage: "heart.fill")
                        .font(AppFont.caption(12, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                    Text(language.description)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.cream)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(language.color.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 14) {
                    Label("Twin Flame Guidance", systemImage: "flame.fill")
                        .font(AppFont.caption(12, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                    Text(language.twinFlameGuidance)
                        .font(AppFont.serifTitle(15))
                        .foregroundStyle(AppColors.cream)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .background(language.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(language.color.opacity(0.4), lineWidth: 1))
                .padding(.horizontal, 24)

                Button {
                    HapticManager.impact(.medium)
                    withAnimation(.spring(response: 0.4)) {
                        result = nil
                        currentQ = 0
                        scores = [:]
                        savedResult = ""
                    }
                } label: {
                    Text("Retake Quiz")
                        .frame(maxWidth: .infinity)
                }
                .warmButtonStyle()
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func computeResult() {
        let top = scores.max { $0.value < $1.value }?.key ?? .energetic
        result = top
        savedResult = top.rawValue
    }
}
