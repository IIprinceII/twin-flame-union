//
//  RitualPlannerView.swift
//  Twin Flame Union
//
//  Moon phase–based ritual suggestions with daily completion tracking.
//

import SwiftUI

// MARK: - Ritual Model

private struct Ritual: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let icon: String
    let description: String
    let steps: [String]
}

private func rituals(for phase: String) -> [Ritual] {
    switch phase {
    case "New Moon", "Waxing Crescent" where phase == "New Moon":
        return newMoonRituals
    case "Waxing Crescent", "First Quarter", "Waxing Gibbous":
        return waxingRituals
    case "Full Moon":
        return fullMoonRituals
    default:
        return waningRituals
    }
}

private let newMoonRituals: [Ritual] = [
    .init(title: "Intention Setting", duration: "15 min",
          icon: "pencil.and.sparkles",
          description: "The new moon is a blank slate — the perfect moment to plant the seeds of your twin flame reunion.",
          steps: [
              "Light a white or purple candle",
              "Sit quietly and breathe until you feel centered",
              "Write 3 specific intentions for your twin flame journey",
              "Speak each intention aloud with conviction",
              "Seal by saying: 'This or something greater, for the highest good of all'"
          ]),
    .init(title: "Sacred Bath", duration: "30 min",
          icon: "drop.fill",
          description: "Cleanse your energy field and open yourself to receive the love you are calling in.",
          steps: [
              "Add rose petals, sea salt, and lavender to your bath",
              "Set the intention to release what no longer serves you",
              "Visualize your aura being cleansed and restored",
              "Speak your twin flame's name three times with love",
              "After, dress in white or light colors to seal the ritual"
          ]),
    .init(title: "Vision Scripting", duration: "20 min",
          icon: "text.book.closed.fill",
          description: "Write your reunion story in present tense as if it has already occurred.",
          steps: [
              "Use a dedicated journal or beautiful paper",
              "Write in first person, present tense ('I am..., We are...')",
              "Include sensory details: what you feel, see, hear",
              "End with gratitude: 'Thank you God for this union'",
              "Fold the paper and place it under your pillow"
          ]),
]

private let waxingRituals: [Ritual] = [
    .init(title: "Love Magnet Meditation", duration: "20 min",
          icon: "rays",
          description: "As the moon grows, so does your magnetic pull. Activate your love frequency.",
          steps: [
              "Sit comfortably with your spine straight",
              "Visualize a golden light in your heart center",
              "With each inhale, expand this light further",
              "See your energy radiating outward, calling your twin home",
              "Hold the image of reunion for 5 minutes"
          ]),
    .init(title: "Abundance Activation", duration: "15 min",
          icon: "sparkles",
          description: "Call in all the blessings that accompany your twin flame union.",
          steps: [
              "Write a list of everything you are grateful for now",
              "Add 5 things you are grateful for in advance (future vision)",
              "Hold your hands over your heart and feel the gratitude",
              "Say: 'I am a magnet for divine love and divine union'",
              "Take one aligned action toward your vision today"
          ]),
    .init(title: "Twin Flame Letter", duration: "25 min",
          icon: "envelope.fill",
          description: "Write an unsent letter to your twin flame from your highest self.",
          steps: [
              "Light a pink or red candle",
              "Address your letter 'Dear [twin's name]' or 'Dear Twin Flame'",
              "Express what you feel from your soul, without editing",
              "Tell them how you've grown, what you've healed, what you see",
              "End with love and a blessing for their journey"
          ]),
]

private let fullMoonRituals: [Ritual] = [
    .init(title: "Full Moon Release", duration: "20 min",
          icon: "moon.fill",
          description: "The full moon amplifies everything — use it to release what blocks your union.",
          steps: [
              "Write down fears, blocks, or resentments on paper",
              "Read each one aloud, then say: 'I release this now'",
              "Safely burn the paper (or tear it into pieces)",
              "Watch it release and feel yourself lighter",
              "Say: 'I am free. Love has room to enter now'"
          ]),
    .init(title: "Charge Your Sacred Objects", duration: "10 min",
          icon: "wand.and.stars",
          description: "Crystals, jewelry, and sacred tools absorb the moon's amplifying energy.",
          steps: [
              "Gather rose quartz, amethyst, or any crystals you use",
              "Place them on a windowsill or outdoors under the moon",
              "Set the intention: 'This crystal holds the frequency of union'",
              "Leave overnight",
              "In the morning, hold each one and speak your intentions into it"
          ]),
    .init(title: "Gratitude Ceremony", duration: "30 min",
          icon: "heart.fill",
          description: "The full moon rewards those who are grateful. Celebrate how far you've come.",
          steps: [
              "Create a sacred space with candles and flowers",
              "Read aloud your gratitude list — past and present blessings",
              "Dance, sing, or move your body in joy",
              "Offer a prayer of thanksgiving for your twin flame connection",
              "Say: 'What God has begun in me, God will complete'"
          ]),
]

private let waningRituals: [Ritual] = [
    .init(title: "Shadow Work Journaling", duration: "30 min",
          icon: "moon.zzz.fill",
          description: "The waning moon supports turning inward. Face and integrate your shadow.",
          steps: [
              "Choose one recurring pattern or fear to explore",
              "Write: 'When I feel [emotion], I believe...'",
              "Follow the thread deeper with compassion, not judgment",
              "Ask: what is the gift hidden in this shadow?",
              "Close with an affirmation of self-acceptance and love"
          ]),
    .init(title: "Cord-Cutting Meditation", duration: "25 min",
          icon: "scissors",
          description: "Release energetic cords tied to pain, past versions, and unhealthy attachments.",
          steps: [
              "Ground yourself with deep breaths",
              "Visualize cords of light connecting you to old pain",
              "Call Archangel Michael to cut what is not of love",
              "See the cords dissolve in violet flame",
              "Fill the space with golden light and say: 'I am free'"
          ]),
    .init(title: "Rest & Receive", duration: "20 min",
          icon: "bed.double.fill",
          description: "The waning moon asks you to rest. Restoration is part of the journey.",
          steps: [
              "Create a calm, dark, comfortable space",
              "Play soft ambient music or silence",
              "Set the intention to receive divine guidance in dreams",
              "Write any questions you want answered in your dream journal",
              "Sleep with rose quartz near your bed"
          ]),
]

// MARK: - View

struct RitualPlannerView: View {
    private let moon = MoonPhase.current()
    @AppStorage("completedRitualKeys") private var completedKeysRaw = ""

    private var completedKeys: Set<String> {
        Set(completedKeysRaw.split(separator: ",").map(String.init))
    }

    private func todayKey(for ritual: Ritual) -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return "\(day)-\(ritual.title)"
    }

    private func toggle(_ ritual: Ritual) {
        let key = todayKey(for: ritual)
        var keys = completedKeys
        if keys.contains(key) { keys.remove(key) } else { keys.insert(key) }
        completedKeysRaw = keys.joined(separator: ",")
    }

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Moon header
                    VStack(spacing: 6) {
                        Text(moon.emoji)
                            .font(.system(size: 56))
                        Text(moon.name)
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)
                        Text(moon.meaning)
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.vertical, 24)

                    // Today's rituals
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Rituals")
                            .font(AppFont.body(14, weight: .semibold))
                            .foregroundStyle(AppColors.lavender)
                            .padding(.horizontal, 24)

                        ForEach(rituals(for: moon.name)) { ritual in
                            RitualCard(
                                ritual: ritual,
                                isCompleted: completedKeys.contains(todayKey(for: ritual)),
                                onToggle: { toggle(ritual) }
                            )
                            .padding(.horizontal, 24)
                        }
                    }

                    DisclaimerFooter()

                    Spacer().frame(height: 32)
                }
            }
        }
        .navigationTitle("Ritual Planner")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Ritual Card

private struct RitualCard: View {
    let ritual: Ritual
    let isCompleted: Bool
    let onToggle: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Button {
                withAnimation(.spring(response: 0.4)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppColors.purple.opacity(0.2))
                            .frame(width: 52, height: 52)
                        Image(systemName: ritual.icon)
                            .font(.system(size: 22))
                            .foregroundStyle(isCompleted ? AppColors.gold : AppColors.coral)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(ritual.title)
                            .font(AppFont.body(16, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(ritual.duration)
                                .font(AppFont.caption(12))
                        }
                        .foregroundStyle(AppColors.lavender)
                    }

                    Spacer()

                    Button(action: onToggle) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundStyle(isCompleted ? AppColors.gold : AppColors.lavender.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(18)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Divider().background(AppColors.purple.opacity(0.3))
                        .padding(.horizontal, 18)

                    Text(ritual.description)
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.cream)
                        .lineSpacing(5)
                        .padding(.horizontal, 18)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Steps")
                            .font(AppFont.caption(12, weight: .semibold))
                            .foregroundStyle(AppColors.lavender)
                        ForEach(Array(ritual.steps.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(i + 1)")
                                    .font(AppFont.body(13, weight: .semibold))
                                    .foregroundStyle(AppColors.purple)
                                    .frame(width: 20)
                                Text(step)
                                    .font(AppFont.body(13))
                                    .foregroundStyle(AppColors.cream.opacity(0.85))
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                }
            }
        }
        .background(
            isCompleted
                ? AppColors.gold.opacity(0.08)
                : AppColors.deepViolet.opacity(0.7),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isCompleted ? AppColors.gold.opacity(0.35) : AppColors.purple.opacity(0.25),
                    lineWidth: 1
                )
        )
    }
}
