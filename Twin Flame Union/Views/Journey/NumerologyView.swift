//
//  NumerologyView.swift
//  Twin Flame Union
//
//  Numerology calculator: Life Path, Soul Urge, and Expression numbers.
//

import SwiftUI

// MARK: - Numerology Engine

private enum Numerology {
    // Pythagorean chart A=1 … Z=8 (wrapping 1–9)
    static let chart: [Character: Int] = {
        var map = [Character: Int]()
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        for (i, ch) in letters.enumerated() { map[ch] = (i % 9) + 1 }
        return map
    }()

    static let vowels: Set<Character> = ["A","E","I","O","U"]

    /// Reduce to single digit or master number (11, 22, 33)
    static func reduce(_ n: Int) -> Int {
        var v = n
        while v > 9 && v != 11 && v != 22 && v != 33 {
            v = String(v).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return v
    }

    /// Life Path: sum all digits of birthdate, then reduce
    static func lifePath(from date: Date) -> Int {
        let cal   = Calendar.current
        let y     = cal.component(.year,  from: date)
        let m     = cal.component(.month, from: date)
        let d     = cal.component(.day,   from: date)
        let raw   = String(y) + String(format: "%02d", m) + String(format: "%02d", d)
        let total = raw.compactMap { $0.wholeNumberValue }.reduce(0, +)
        return reduce(total)
    }

    /// Soul Urge: sum vowel values in name
    static func soulUrge(from name: String) -> Int {
        let total = name.uppercased().filter { vowels.contains($0) }
            .compactMap { chart[$0] }.reduce(0, +)
        return reduce(total)
    }

    /// Expression/Destiny: sum all letter values in name
    static func expression(from name: String) -> Int {
        let total = name.uppercased().filter { $0.isLetter }
            .compactMap { chart[$0] }.reduce(0, +)
        return reduce(total)
    }
}

// MARK: - Number Meanings

private struct NumberInfo {
    let title: String
    let keywords: String
    let meaning: String
    let twinFlameMeaning: String
}

private let numberMeanings: [Int: NumberInfo] = [
    1:  .init(title: "The Pioneer",    keywords: "Leadership · Independence · Initiation",
              meaning: "You are a natural-born leader walking an original path. Your journey demands courage and self-reliance.",
              twinFlameMeaning: "You and your twin flame are trailblazers — your union is meant to inspire others and carve new spiritual territory."),
    2:  .init(title: "The Diplomat",   keywords: "Partnership · Intuition · Balance",
              meaning: "You thrive in union and understand the sacred dance between two souls. Sensitivity is your superpower.",
              twinFlameMeaning: "The twin flame number of deep soul contracts. Your connection is marked by extraordinary empathy and mirroring."),
    3:  .init(title: "The Creator",    keywords: "Expression · Joy · Communication",
              meaning: "You carry the energy of creative manifestation. Joy, art, and authentic expression are your vehicles.",
              twinFlameMeaning: "Your twin flame journey will be expressed through creative collaboration — music, writing, art, or teaching."),
    4:  .init(title: "The Builder",    keywords: "Stability · Discipline · Foundation",
              meaning: "You are here to build something lasting. Structure, integrity, and steady work define your path.",
              twinFlameMeaning: "Your union is a sacred foundation — built to last, grounded in love, and meant to create lasting spiritual legacy."),
    5:  .init(title: "The Adventurer", keywords: "Freedom · Change · Experience",
              meaning: "You are the seeker of truth through lived experience. Change and variety feed your soul.",
              twinFlameMeaning: "Your twin flame connection liberates both of you. The journey will be dynamic, transformative, and deeply freeing."),
    6:  .init(title: "The Nurturer",   keywords: "Love · Service · Harmony",
              meaning: "You carry the vibration of unconditional love and family. Your heart is your greatest gift.",
              twinFlameMeaning: "Yours is a healing union. You and your twin are called to create a sanctuary of love and to serve others through it."),
    7:  .init(title: "The Seeker",     keywords: "Wisdom · Mysticism · Solitude",
              meaning: "You are a spiritual philosopher drawn to the mysteries of existence. Inner wisdom guides you.",
              twinFlameMeaning: "Your twin flame connection is profoundly spiritual — marked by psychic bonds, shared visions, and divine downloads."),
    8:  .init(title: "The Powerhouse", keywords: "Abundance · Mastery · Authority",
              meaning: "You are here to master the material and spiritual planes simultaneously. Power used in love is your lesson.",
              twinFlameMeaning: "Your union carries immense spiritual authority. Together you are called to build abundance that blesses the world."),
    9:  .init(title: "The Sage",       keywords: "Completion · Compassion · Universal Love",
              meaning: "You are the wise elder of the soul family. Compassion, release, and universal service define you.",
              twinFlameMeaning: "Your twin flame journey is one of completion and cosmic love. You are here to demonstrate unconditional love to all."),
    11: .init(title: "The Illuminator", keywords: "Intuition · Inspiration · Spiritual Messenger",
              meaning: "You are a master number — an intuitive channel for divine light. Your sensitivity is a sacred gift.",
              twinFlameMeaning: "Your twin flame bond is a master-level soul contract. You carry a collective mission of spiritual awakening."),
    22: .init(title: "The Master Builder", keywords: "Vision · Manifestation · Global Impact",
              meaning: "You are here to turn spiritual vision into tangible reality on a grand scale. Your potential is extraordinary.",
              twinFlameMeaning: "Your union is destined to manifest something monumental — a shared vision that uplifts humanity."),
    33: .init(title: "The Master Teacher", keywords: "Healing · Compassion · Selfless Love",
              meaning: "The rarest master number. You are a beacon of divine love and healing for the world.",
              twinFlameMeaning: "The most sacred twin flame vibration. Your union is a vessel of Christ-consciousness love — pure, selfless, divine."),
]

// MARK: - View

struct NumerologyView: View {
    @AppStorage("userName")       private var userName   = ""
    @AppStorage("userBirthDate") private var birthdateDouble: Double = 0

    @State private var inputName      = ""
    @State private var inputDate      = Date()
    @State private var hasCalculated  = false
    @State private var lifePathNum    = 0
    @State private var soulUrgeNum    = 0
    @State private var expressionNum  = 0
    @State private var selectedNumber: Int? = nil

    // Prefer unified key; fall back to legacy numeroBirthdate for existing users.
    private var effectiveBirthDate: Double {
        if birthdateDouble > 0 { return birthdateDouble }
        return UserDefaults.standard.double(forKey: "numeroBirthdate")
    }

    private var birthdate: Date {
        effectiveBirthDate == 0 ? Date() : Date(timeIntervalSince1970: effectiveBirthDate)
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Input card
                    inputCard
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    if hasCalculated {
                        // Three numbers row
                        HStack(spacing: 14) {
                            NumberPill(label: "Life Path",   number: lifePathNum,   color: Color(hex: "8B5CF6")) { HapticManager.impact(.light); selectedNumber = lifePathNum }
                            NumberPill(label: "Soul Urge",   number: soulUrgeNum,   color: Color(hex: "4A90D9")) { HapticManager.impact(.light); selectedNumber = soulUrgeNum }
                            NumberPill(label: "Expression",  number: expressionNum, color: Color(hex: "D97B4A")) { HapticManager.impact(.light); selectedNumber = expressionNum }
                        }
                        .padding(.horizontal, 24)

                        // Detail card for selected number
                        if let n = selectedNumber, let info = numberMeanings[n] {
                            numberDetailCard(number: n, info: info)
                                .padding(.horizontal, 24)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            Text("Tap a number above to reveal its meaning")
                                .font(AppFont.body(13))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                                .padding(.top, 8)
                        }
                    }

                    Spacer().frame(height: 32)
                }
            }
        }
        .navigationTitle("Numerology")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            if birthdateDouble == 0, effectiveBirthDate > 0 { birthdateDouble = effectiveBirthDate }
            inputName = userName
            if effectiveBirthDate != 0 { inputDate = birthdate }
        }
    }

    // MARK: Input Card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Calculate Your Numbers", systemImage: "numbers")
                .font(AppFont.body(14, weight: .semibold))
                .foregroundStyle(AppColors.lavender)

            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name at Birth")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                TextField("Enter your full name", text: $inputName)
                    .font(AppFont.body(16))
                    .foregroundStyle(AppColors.cream)
                    .padding(12)
                    .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Date of Birth")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                DatePicker("", selection: $inputDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    .labelsHidden()
                    .tint(AppColors.purple)
            }

            Button {
                calculate()
            } label: {
                Text("Reveal My Numbers")
                    .frame(maxWidth: .infinity)
            }
            .warmButtonStyle()
            .disabled(inputName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }

    // MARK: Number Detail Card

    private func numberDetailCard(number: Int, info: NumberInfo) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("\(number)")
                    .font(AppFont.serifHeadline(48))
                    .foregroundStyle(AppColors.gold)
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.title)
                        .font(AppFont.serifTitle(20))
                        .foregroundStyle(AppColors.cream)
                    Text(info.keywords)
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                }
            }

            Divider().background(AppColors.purple.opacity(0.3))

            Text(info.meaning)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Label("Twin Flame Meaning", systemImage: "flame.fill")
                .font(AppFont.caption(12, weight: .semibold))
                .foregroundStyle(AppColors.lavender)

            Text(info.twinFlameMeaning)
                .font(AppFont.serifTitle(15))
                .foregroundStyle(AppColors.cream.opacity(0.9))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(14)
                .background(AppColors.purple.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppColors.purple.opacity(0.25), lineWidth: 1))
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
        .animation(.easeInOut(duration: 0.25), value: number)
    }

    // MARK: Calculate

    private func calculate() {
        HapticManager.impact(.medium)
        let name = inputName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        birthdateDouble   = inputDate.timeIntervalSince1970
        lifePathNum       = Numerology.lifePath(from: inputDate)
        soulUrgeNum       = Numerology.soulUrge(from: name)
        expressionNum     = Numerology.expression(from: name)
        selectedNumber    = lifePathNum
        withAnimation(.spring(response: 0.5)) { hasCalculated = true }
    }
}

// MARK: - Number Pill

private struct NumberPill: View {
    let label: String
    let number: Int
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text("\(number)")
                    .font(AppFont.serifHeadline(32))
                    .foregroundStyle(color)
                Text(label)
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(color.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
