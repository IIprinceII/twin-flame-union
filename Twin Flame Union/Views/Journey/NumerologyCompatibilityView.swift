//
//  NumerologyCompatibilityView.swift
//  Twin Flame Union
//
//  Numerology compatibility between you and your twin flame.
//

import SwiftUI

// MARK: - Local Numerology Engine (self-contained)

private enum NumCalc {
    static let chart: [Character: Int] = {
        var m = [Character: Int]()
        Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").enumerated().forEach { m[$1] = ($0 % 9) + 1 }
        return m
    }()

    static func reduce(_ n: Int) -> Int {
        var v = n
        while v > 9 && v != 11 && v != 22 && v != 33 {
            v = String(v).compactMap { $0.wholeNumberValue }.reduce(0, +)
        }
        return v
    }

    static func lifePath(from date: Date) -> Int {
        let c = Calendar.current
        let y = c.component(.year, from: date)
        let m = c.component(.month, from: date)
        let d = c.component(.day, from: date)
        let total = (String(y) + String(format: "%02d", m) + String(format: "%02d", d))
            .compactMap { $0.wholeNumberValue }.reduce(0, +)
        return reduce(total)
    }
}

// MARK: - Compatibility Data

private struct LifePathPair {
    let summary: String
    let strength: String
    let challenge: String
    let score: Int
}

private func pairInfo(_ a: Int, _ b: Int) -> LifePathPair {
    let key = "\(min(a,b))-\(max(a,b))"
    return pairings[key] ?? defaultPair(a, b)
}

private func defaultPair(_ a: Int, _ b: Int) -> LifePathPair {
    if a == b {
        return .init(
            summary: "Two \(a)s together — you understand each other on a soul level. The mirror dynamic runs deep.",
            strength: "Instant soul recognition and shared life purpose.",
            challenge: "Your shared patterns are amplified. What you haven't healed in yourself shows up doubled in each other.",
            score: 78
        )
    }
    return .init(
        summary: "Life Paths \(a) and \(b) create a dynamic, complementary bond with powerful growth potential.",
        strength: "You each bring what the other lacks, creating a complete partnership.",
        challenge: "Your different rhythms will require conscious communication and mutual respect.",
        score: 72
    )
}

private let pairings: [String: LifePathPair] = [
    "1-2": .init(summary: "The Pioneer and the Diplomat — a complementary match of strength and sensitivity.",
                 strength: "1 provides vision and drive; 2 provides heart and harmony. Together you create and sustain.",
                 challenge: "1 may feel 2 is too passive; 2 may feel 1 is too aggressive. Balance is the lesson.",
                 score: 80),
    "1-5": .init(summary: "Two independent souls drawn together by a shared hunger for freedom and experience.",
                 strength: "Electric chemistry, adventure, and mutual respect for individual space.",
                 challenge: "Commitment may feel limiting to both. The journey requires anchoring love.",
                 score: 75),
    "2-9": .init(summary: "The Diplomat and the Sage — one of the most spiritually resonant twin flame combinations.",
                 strength: "9 has universal compassion; 2 has intimate love. Together they create profound, healing love.",
                 challenge: "9 can be emotionally detached; 2 needs closeness. Deep communication is essential.",
                 score: 88),
    "1-9": .init(summary: "The Pioneer and the Sage — an ancient, powerful soul pairing with collective mission.",
                 strength: "Both are natural leaders in different arenas. Together you can change the world.",
                 challenge: "Both have strong wills. Learning to lead together rather than competing is the key.",
                 score: 82),
    "2-6": .init(summary: "The Diplomat and the Nurturer — one of the most loving and harmonious twin flame pairings.",
                 strength: "Both are natural givers. Your home together will be a sanctuary of beauty and love.",
                 challenge: "Both may sacrifice themselves too much. Honor your individual needs.",
                 score: 92),
    "3-9": .init(summary: "The Creator and the Sage — a beautifully artistic and spiritually luminous pairing.",
                 strength: "Creative expression meets universal wisdom. Your love inspires the world.",
                 challenge: "Both can be scattered. Grounding your shared vision into practical reality takes intention.",
                 score: 85),
    "4-8": .init(summary: "The Builder and the Powerhouse — a formidable, earth-moving partnership.",
                 strength: "Together you build empires — of love, legacy, and material abundance.",
                 challenge: "Both can be controlling. Learning to lead with love rather than fear is the sacred work.",
                 score: 83),
    "6-9": .init(summary: "The Nurturer and the Sage — a twin flame connection of immense healing power.",
                 strength: "The most healing combination in numerology. Your love restores broken things.",
                 challenge: "9 must not use 6's devotion without reciprocating. 6 must learn to receive.",
                 score: 90),
    "11-22": .init(summary: "Two master numbers — a cosmic, rare, and powerfully destined twin flame bond.",
                   strength: "You carry complementary master missions. Together you can literally change the world.",
                   challenge: "Immense energy requires immense grounding. Do your inner work diligently.",
                   score: 95),
    "2-11": .init(summary: "The Diplomat and the Illuminator — a spiritually charged and deeply intuitive pairing.",
                  strength: "Both are deeply empathic. Your spiritual communication is profound and effortless.",
                  challenge: "Extreme sensitivity may make conflict overwhelming. Gentle truth is the path.",
                  score: 88),
]

// MARK: - View

struct NumerologyCompatibilityView: View {
    @AppStorage("userName")           private var myName   = ""
    @AppStorage("partnerName")        private var tfName   = ""
    @AppStorage("userBirthDate")      private var myBD: Double = 0
    @AppStorage("partnerBirthDate")   private var tfBD: Double = 0

    @State private var myNameInput    = ""
    @State private var tfNameInput    = ""
    @State private var myDate         = Date()
    @State private var tfDate         = Date()
    @State private var hasCalculated  = false
    @State private var myLP           = 0
    @State private var tfLP           = 0
    @State private var pair: LifePathPair? = nil

    // Prefer unified keys; fall back to legacy keys for existing users.
    private var effectiveMyBD: Double {
        if myBD > 0 { return myBD }
        let ts = UserDefaults.standard.double(forKey: "userBirthDateTS")
        if ts > 0 { return ts }
        return UserDefaults.standard.double(forKey: "numeroBirthdate")
    }
    private var effectiveTfBD: Double {
        if tfBD > 0 { return tfBD }
        return UserDefaults.standard.double(forKey: "tfBirthdate")
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    inputCard
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    if hasCalculated, let p = pair {
                        // Life path numbers
                        HStack(spacing: 0) {
                            lpCircle(number: myLP, label: myNameInput.isEmpty ? "You" : myNameInput, color: Color(hex: "8B5CF6"))
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color(hex: "E74C8B"))
                                .accessibilityHidden(true)
                            Spacer()
                            lpCircle(number: tfLP, label: tfNameInput.isEmpty ? "Twin" : tfNameInput, color: Color(hex: "E74C8B"))
                        }
                        .padding(.horizontal, 24)

                        compatibilityCard(pair: p)
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer().frame(height: 32)
                }
            }
        }
        .navigationTitle("Numerology Match")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            if myBD == 0, effectiveMyBD > 0 { myBD = effectiveMyBD }
            if tfBD == 0, effectiveTfBD > 0 { tfBD = effectiveTfBD }
            myNameInput = myName
            tfNameInput = tfName
            if effectiveMyBD != 0 { myDate = Date(timeIntervalSince1970: effectiveMyBD) }
            if effectiveTfBD != 0 { tfDate = Date(timeIntervalSince1970: effectiveTfBD) }
        }
    }

    // MARK: Input Card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Enter Birth Details", systemImage: "numbers")
                .font(AppFont.body(14, weight: .semibold))
                .foregroundStyle(AppColors.lavender)

            // My info
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Name & Birthdate")
                    .font(AppFont.caption(11, weight: .semibold))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                TextField("Your full birth name", text: $myNameInput)
                    .inputFieldStyle()
                DatePicker("", selection: $myDate, displayedComponents: .date)
                    .datePickerStyle(.compact).labelsHidden().colorScheme(.dark).tint(AppColors.purple)
            }

            Divider().background(AppColors.purple.opacity(0.3))

            // TF info
            VStack(alignment: .leading, spacing: 6) {
                Text("Twin Flame Name & Birthdate")
                    .font(AppFont.caption(11, weight: .semibold))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                TextField("Their full birth name (optional)", text: $tfNameInput)
                    .inputFieldStyle()
                DatePicker("", selection: $tfDate, displayedComponents: .date)
                    .datePickerStyle(.compact).labelsHidden().colorScheme(.dark).tint(Color(hex: "E74C8B"))
            }

            Button { calculate() } label: {
                Text("Calculate Compatibility")
                    .frame(maxWidth: .infinity)
            }
            .warmButtonStyle()
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }

    private func lpCircle(number: Int, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 80, height: 80)
                Circle()
                    .strokeBorder(color.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 80, height: 80)
                Text("\(number)")
                    .font(AppFont.serifHeadline(32))
                    .foregroundStyle(color)
            }
            Text("Life Path")
                .font(AppFont.caption(10))
                .foregroundStyle(AppColors.lavender)
            Text(label)
                .font(AppFont.body(13, weight: .semibold))
                .foregroundStyle(AppColors.cream)
                .lineLimit(1)
        }
    }

    private func compatibilityCard(pair: LifePathPair) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Score ring
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(AppColors.purple.opacity(0.2), lineWidth: 8)
                        .frame(width: 88, height: 88)
                        .accessibilityHidden(true)
                    Circle()
                        .trim(from: 0, to: CGFloat(pair.score) / 100)
                        .stroke(AppGradients.warm, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(-90))
                        .accessibilityHidden(true)
                    VStack(spacing: 1) {
                        Text("\(pair.score)%")
                            .font(AppFont.serifHeadline(22))
                            .foregroundStyle(AppColors.cream)
                        Text("Match")
                            .font(AppFont.caption(9))
                            .foregroundStyle(AppColors.lavender)
                    }
                }
                Spacer()
            }

            Text(pair.summary)
                .font(AppFont.serifTitle(16))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            Divider().background(AppColors.purple.opacity(0.3))

            infoRow(icon: "star.fill", label: "Your Strength", text: pair.strength, color: AppColors.gold)
            infoRow(icon: "bolt.fill", label: "Your Growth Edge", text: pair.challenge, color: Color(hex: "D97B4A"))
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }

    private func infoRow(icon: String, label: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
                .frame(width: 14)
                .padding(.top, 3)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppFont.caption(11, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                Text(text)
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColors.cream.opacity(0.85))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func calculate() {
        HapticManager.impact(.medium)
        myBD = myDate.timeIntervalSince1970
        tfBD = tfDate.timeIntervalSince1970
        myLP = NumCalc.lifePath(from: myDate)
        tfLP = NumCalc.lifePath(from: tfDate)
        pair = pairInfo(myLP, tfLP)
        withAnimation(.spring(response: 0.5)) { hasCalculated = true }
    }
}

private extension View {
    func inputFieldStyle() -> some View {
        self
            .font(AppFont.body(15))
            .foregroundStyle(AppColors.cream)
            .padding(12)
            .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
    }
}
