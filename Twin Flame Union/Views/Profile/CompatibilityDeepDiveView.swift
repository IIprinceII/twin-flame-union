//
//  CompatibilityDeepDiveView.swift
//  Twin Flame Union
//
//  Deep astrological compatibility analysis beyond sun/moon/rising.
//

import SwiftUI

// MARK: - Modality

private enum Modality: String {
    case cardinal = "Cardinal"
    case fixed    = "Fixed"
    case mutable  = "Mutable"

    var description: String {
        switch self {
        case .cardinal: return "Initiator — starts things, drives change"
        case .fixed:    return "Sustainer — persistent, determined, loyal"
        case .mutable:  return "Adapter — flexible, communicative, open"
        }
    }
}

// MARK: - Ruling Planet

private struct Planet {
    let name: String
    let symbol: String
    let theme: String
}

// MARK: - Sign Extensions

private extension ZodiacSign {
    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn:           return .cardinal
        case .taurus, .leo, .scorpio, .aquarius:            return .fixed
        case .gemini, .virgo, .sagittarius, .pisces:        return .mutable
        }
    }

    var rulingPlanet: Planet {
        switch self {
        case .aries:       return Planet(name: "Mars",    symbol: "♂", theme: "Action, desire, drive")
        case .taurus:      return Planet(name: "Venus",   symbol: "♀", theme: "Love, beauty, values")
        case .gemini:      return Planet(name: "Mercury", symbol: "☿", theme: "Communication, thought")
        case .cancer:      return Planet(name: "Moon",    symbol: "☽", theme: "Emotion, nurture, home")
        case .leo:         return Planet(name: "Sun",     symbol: "☀", theme: "Identity, vitality, pride")
        case .virgo:       return Planet(name: "Mercury", symbol: "☿", theme: "Analysis, service, detail")
        case .libra:       return Planet(name: "Venus",   symbol: "♀", theme: "Harmony, partnership, beauty")
        case .scorpio:     return Planet(name: "Pluto",   symbol: "♇", theme: "Transformation, depth, power")
        case .sagittarius: return Planet(name: "Jupiter", symbol: "♃", theme: "Expansion, wisdom, adventure")
        case .capricorn:   return Planet(name: "Saturn",  symbol: "♄", theme: "Structure, ambition, mastery")
        case .aquarius:    return Planet(name: "Uranus",  symbol: "⛢", theme: "Innovation, freedom, collective")
        case .pisces:      return Planet(name: "Neptune", symbol: "♆", theme: "Mysticism, dreams, compassion")
        }
    }

    var polarity: String {
        switch element {
        case .fire, .air:   return "Masculine (Yang)"
        case .earth, .water: return "Feminine (Yin)"
        }
    }
}

// MARK: - Compatibility Logic

private struct CompatibilityScore {
    let category: String
    let score: Int      // 0–100
    let icon: String
    let color: Color
    let explanation: String
}

private func elementScore(_ a: Element, _ b: Element) -> (Int, String) {
    switch (a, b) {
    case (.fire, .fire), (.earth, .earth), (.air, .air), (.water, .water):
        return (75, "Same element — you understand each other intuitively, though you may amplify each other's extremes.")
    case (.fire, .air), (.air, .fire):
        return (92, "Fire and Air — a natural, electrifying combination. Air fuels Fire's passion; Fire inspires Air's ideas.")
    case (.earth, .water), (.water, .earth):
        return (90, "Earth and Water — deeply nurturing. Water flows into Earth's stability; Earth gives Water's emotion a home.")
    case (.fire, .earth), (.earth, .fire):
        return (60, "Fire and Earth — tension that builds. Earth grounds Fire's impulses; Fire energizes Earth's steadiness.")
    case (.fire, .water), (.water, .fire):
        return (65, "Fire and Water — intense and transformative. The heat creates steam — powerful, but requires care.")
    case (.air, .water), (.water, .air):
        return (68, "Air and Water — poetic and emotionally rich. Air brings clarity to Water's depths; Water brings feeling to Air's thoughts.")
    case (.air, .earth), (.earth, .air):
        return (62, "Air and Earth — complementary but different. Earth grounds Air's flights; Air refreshes Earth's routines.")
    }
}

private func modalityScore(_ a: Modality, _ b: Modality) -> (Int, String) {
    switch (a, b) {
    case (.cardinal, .cardinal):
        return (70, "Two initiators — full of energy and ideas, but may clash over who leads. Take turns.")
    case (.fixed, .fixed):
        return (72, "Two sustainers — immense loyalty and depth, but both can be stubborn. Flexibility is the key.")
    case (.mutable, .mutable):
        return (74, "Two adapters — flowing and open, but may struggle with consistency. Anchor together.")
    case (.cardinal, .fixed), (.fixed, .cardinal):
        return (80, "Cardinal initiates; Fixed sustains. A powerful creative-to-completion partnership.")
    case (.cardinal, .mutable), (.mutable, .cardinal):
        return (78, "Cardinal starts; Mutable evolves. Great adaptability in the journey together.")
    case (.fixed, .mutable), (.mutable, .fixed):
        return (82, "Fixed provides the anchor; Mutable provides the flow. Balance of stability and change.")
    }
}

private func planetScore(_ a: ZodiacSign, _ b: ZodiacSign) -> (Int, String) {
    let pA = a.rulingPlanet.name
    let pB = b.rulingPlanet.name
    if pA == pB {
        return (88, "Shared planetary ruler (\(pA)) — you speak the same cosmic language and share deep values.")
    }
    let harmonious: Set<Set<String>> = [
        ["Venus", "Mars"], ["Sun", "Moon"], ["Jupiter", "Venus"],
        ["Mercury", "Jupiter"], ["Saturn", "Sun"], ["Neptune", "Moon"],
        ["Pluto", "Mars"], ["Uranus", "Mercury"]
    ]
    if harmonious.contains([pA, pB]) {
        return (85, "\(pA) and \(pB) are harmonious planetary energies — a natural, supportive resonance.")
    }
    return (65, "\(pA) and \(pB) create a dynamic tension that, when navigated consciously, catalyzes extraordinary growth.")
}

private func polarityScore(_ a: ZodiacSign, _ b: ZodiacSign) -> (Int, String) {
    if a.polarity == b.polarity {
        return (72, "Shared polarity (\(a.polarity)) — you approach life from the same energetic orientation, creating deep understanding.")
    }
    return (88, "Opposite polarities — the classic divine masculine/feminine balance. You complete each other.")
}

// MARK: - View

struct CompatibilityDeepDiveView: View {
    @AppStorage("mySunSign")        private var mySunRaw      = ""
    @AppStorage("myMoonSign")       private var myMoonRaw     = ""
    @AppStorage("myRisingSign")     private var myRisingRaw   = ""
    @AppStorage("partnerSunSign")   private var partnerSunRaw = ""
    @AppStorage("partnerMoonSign")  private var partnerMoonRaw = ""
    @AppStorage("partnerRisingSign") private var partnerRisingRaw = ""
    @AppStorage("partnerName")      private var partnerName   = ""

    private var mySun:      ZodiacSign? { ZodiacSign(rawValue: mySunRaw) }
    private var myMoon:     ZodiacSign? { ZodiacSign(rawValue: myMoonRaw) }
    private var partnerSun: ZodiacSign? { ZodiacSign(rawValue: partnerSunRaw) }
    private var partnerMoon: ZodiacSign? { ZodiacSign(rawValue: partnerMoonRaw) }

    private var tfName: String { partnerName.isEmpty ? "Your Twin Flame" : partnerName }

    var body: some View {
        ZStack {
            CosmicBackground()

            if mySun == nil || partnerSun == nil {
                missingDataView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Signs header
                        signsHeader
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        // Compatibility scores
                        if let mS = mySun, let pS = partnerSun {
                            scoresSection(mySun: mS, partnerSun: pS)
                                .padding(.horizontal, 24)
                        }

                        // Moon compatibility
                        if let mM = myMoon, let pM = partnerMoon {
                            moonCompatibilityCard(myMoon: mM, partnerMoon: pM)
                                .padding(.horizontal, 24)
                        }

                        // Individual profiles
                        if let mS = mySun, let pS = partnerSun {
                            HStack(spacing: 14) {
                                signProfileCard(sign: mS, label: "Your Sun", isMe: true)
                                signProfileCard(sign: pS, label: "\(tfName)'s Sun", isMe: false)
                            }
                            .padding(.horizontal, 24)
                        }

                        Spacer().frame(height: 32)
                    }
                }
            }
        }
        .navigationTitle("Compatibility")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: Sub-views

    private var missingDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 52))
                .foregroundStyle(AppColors.purple.opacity(0.5))
            Text("Birth Charts Needed")
                .font(AppFont.serifTitle(22))
                .foregroundStyle(AppColors.cream)
            Text("Set your sun sign and your twin flame's sun sign in Profile to unlock the deep dive.")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var signsHeader: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                Text(mySun?.symbol ?? "?")
                    .font(.system(size: 36))
                Text("You")
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(mySun?.rawValue ?? "")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender)
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "infinity")
                .font(.system(size: 28))
                .foregroundStyle(AppColors.purple)

            VStack(spacing: 4) {
                Text(partnerSun?.symbol ?? "?")
                    .font(.system(size: 36))
                Text(tfName)
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                    .lineLimit(1)
                Text(partnerSun?.rawValue ?? "")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }

    private func scoresSection(mySun: ZodiacSign, partnerSun: ZodiacSign) -> some View {
        let (elemScore, elemExp) = elementScore(mySun.element, partnerSun.element)
        let (modScore, modExp)   = modalityScore(mySun.modality, partnerSun.modality)
        let (planScore, planExp) = planetScore(mySun, partnerSun)
        let (polScore, polExp)   = polarityScore(mySun, partnerSun)
        let overall = (elemScore + modScore + planScore + polScore) / 4

        return VStack(spacing: 16) {
            // Overall ring
            overallScore(overall)

            // Individual scores
            VStack(spacing: 12) {
                ScoreRow(label: "Elemental Harmony",  score: elemScore, icon: "leaf.fill",      color: Color(hex: "43A047"), explanation: elemExp)
                ScoreRow(label: "Modality Match",     score: modScore,  icon: "arrow.triangle.2.circlepath", color: Color(hex: "4A90D9"), explanation: modExp)
                ScoreRow(label: "Planetary Resonance", score: planScore, icon: "sparkles",      color: Color(hex: "F0C040"), explanation: planExp)
                ScoreRow(label: "Polarity Balance",   score: polScore,  icon: "yin.yang",       color: AppColors.coral, explanation: polExp)
            }
        }
    }

    private func overallScore(_ score: Int) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(AppColors.purple.opacity(0.2), lineWidth: 10)
                    .frame(width: 110, height: 110)
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(AppGradients.warm, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(score)%")
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(AppColors.cream)
                    Text("Compatible")
                        .font(AppFont.caption(10))
                        .foregroundStyle(AppColors.lavender)
                }
            }
            Text(compatibilityLabel(score))
                .font(AppFont.serifTitle(17))
                .foregroundStyle(AppColors.cream)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }

    private func compatibilityLabel(_ score: Int) -> String {
        switch score {
        case 85...: return "Celestially Aligned — a rare and powerful soul pairing"
        case 75...: return "Deeply Compatible — natural harmony and growth"
        case 65...: return "Dynamically Charged — growth through beautiful tension"
        default:    return "Transformatively Paired — evolution through difference"
        }
    }

    private func moonCompatibilityCard(myMoon: ZodiacSign, partnerMoon: ZodiacSign) -> some View {
        let (score, explanation) = elementScore(myMoon.element, partnerMoon.element)
        return VStack(alignment: .leading, spacing: 14) {
            Label("Moon Sign Compatibility", systemImage: "moon.fill")
                .font(AppFont.body(14, weight: .semibold))
                .foregroundStyle(AppColors.lavender)

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(myMoon.symbol).font(.system(size: 28))
                    Text(myMoon.rawValue).font(AppFont.caption(11)).foregroundStyle(AppColors.lavender)
                    Text("Your Moon").font(AppFont.caption(10)).foregroundStyle(AppColors.lavender.opacity(0.6))
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("\(score)%")
                        .font(AppFont.serifHeadline(24))
                        .foregroundStyle(score >= 75 ? Color(hex: "43A047") : Color(hex: "D97B4A"))
                    Text("Emotional Sync")
                        .font(AppFont.caption(10))
                        .foregroundStyle(AppColors.lavender)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text(partnerMoon.symbol).font(.system(size: 28))
                    Text(partnerMoon.rawValue).font(AppFont.caption(11)).foregroundStyle(AppColors.lavender)
                    Text("Their Moon").font(AppFont.caption(10)).foregroundStyle(AppColors.lavender.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }

            Text(explanation)
                .font(AppFont.body(13))
                .foregroundStyle(AppColors.lavender)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color(hex: "5E35B1").opacity(0.35), lineWidth: 1))
    }

    private func signProfileCard(sign: ZodiacSign, label: String, isMe: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(AppFont.caption(11, weight: .semibold))
                .foregroundStyle(AppColors.lavender)

            HStack(spacing: 8) {
                Text(sign.symbol)
                    .font(.system(size: 24))
                Text(sign.rawValue)
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
            }

            Divider().background(sign.element.color.opacity(0.3))

            profileRow(icon: sign.element.icon, label: "Element", value: sign.element.rawValue, color: sign.element.color)
            profileRow(icon: "arrow.triangle.2.circlepath", label: "Modality", value: sign.modality.rawValue, color: AppColors.lavender)
            profileRow(icon: "sparkle", label: "Ruler", value: sign.rulingPlanet.name, color: Color(hex: "F0C040"))
            profileRow(icon: "circle.lefthalf.filled", label: "Polarity", value: sign.polarity == "Masculine (Yang)" ? "Yang" : "Yin", color: AppColors.coral)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(sign.element.color.opacity(0.3), lineWidth: 1))
    }

    private func profileRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
                .frame(width: 14)
            Text(label)
                .font(AppFont.caption(11))
                .foregroundStyle(AppColors.lavender)
            Spacer()
            Text(value)
                .font(AppFont.caption(11, weight: .semibold))
                .foregroundStyle(AppColors.cream)
        }
    }
}

// MARK: - Score Row

private struct ScoreRow: View {
    let label: String
    let score: Int
    let icon: String
    let color: Color
    let explanation: String

    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35)) { isExpanded.toggle() }
        } label: {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(color)
                        .frame(width: 20)

                    Text(label)
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundStyle(AppColors.cream)

                    Spacer()

                    Text("\(score)%")
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundStyle(color)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(color.opacity(0.15)).frame(height: 5)
                        Capsule().fill(color).frame(width: geo.size.width * CGFloat(score) / 100, height: 5)
                            .animation(.spring(response: 0.6), value: score)
                    }
                }
                .frame(height: 5)

                if isExpanded {
                    Text(explanation)
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(color.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
