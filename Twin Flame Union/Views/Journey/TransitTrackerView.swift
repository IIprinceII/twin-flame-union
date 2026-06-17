//
//  TransitTrackerView.swift
//  Twin Flame Union
//
//  Current planetary transit themes and their effect on the twin flame journey.
//

import SwiftUI

// MARK: - Transit Model

private struct PlanetaryTransit: Identifiable {
    let id = UUID()
    let planet: String
    let symbol: String
    let currentSign: String
    let signSymbol: String
    let color: Color
    let theme: String
    let twinFlameEffect: String
    let guidance: String
    let affirmation: String
    let intensity: Int   // 1–5
}

// MARK: - Transit Data (rotates seasonally by month)

private func currentTransits() -> [PlanetaryTransit] {
    let month = Calendar.current.component(.month, from: Date())

    // Outer planets move slowly — we give them seasonal assignments
    // Inner planets cycle through signs quickly, so we rotate by week
    let week = Calendar.current.component(.weekOfYear, from: Date())

    let sunSigns    = ["Aries","Taurus","Gemini","Cancer","Leo","Virgo","Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"]
    let sunSymbols  = ["♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓"]
    let sunSign     = sunSigns[(month - 1) % 12]
    let sunSymbol   = sunSymbols[(month - 1) % 12]

    let mercurySigns = sunSigns
    let mercurySign  = mercurySigns[week % 12]
    let mercurySymbol = sunSymbols[week % 12]

    let venusSigns  = sunSigns
    let venusSign   = venusSigns[(week + 2) % 12]
    let venusSymbol = sunSymbols[(week + 2) % 12]

    let marsSigns   = sunSigns
    let marsSign    = marsSigns[(month + 1) % 12]
    let marsSymbol  = sunSymbols[(month + 1) % 12]

    let jupiterSigns = ["Taurus","Taurus","Gemini","Gemini","Gemini","Cancer","Cancer","Leo","Leo","Virgo","Virgo","Libra"]
    let jupiterSign  = jupiterSigns[(month - 1) % 12]
    let jupiterSymbol = sunSymbols[(sunSigns.firstIndex(of: jupiterSign) ?? 0) % 12]

    let saturnSigns  = ["Pisces","Pisces","Pisces","Aries","Aries","Aries","Aries","Aries","Aries","Pisces","Pisces","Pisces"]
    let saturnSign   = saturnSigns[(month - 1) % 12]
    let saturnSymbol = sunSymbols[max(0, sunSigns.firstIndex(of: saturnSign) ?? 0)]

    return [
        .init(planet: "Sun", symbol: "☀️", currentSign: sunSign, signSymbol: sunSymbol,
              color: Color(hex: "F0C040"), theme: "Identity & Vitality",
              twinFlameEffect: "The Sun illuminates wherever it transits. In \(sunSign), your sense of identity and authentic self-expression is highlighted. Your twin flame is being called to step into their light.",
              guidance: "Shine without apologizing. The more authentically you express yourself this month, the more magnetic you become to your twin.",
              affirmation: "I shine in my full authentic light. My twin flame is drawn to this radiance.",
              intensity: 4),

        .init(planet: "Venus", symbol: "♀️", currentSign: venusSign, signSymbol: venusSymbol,
              color: Color(hex: "E74C8B"), theme: "Love & Attraction",
              twinFlameEffect: "Venus governs love, beauty, and magnetic attraction. In \(venusSign), the energy of romantic love and divine union is being amplified. Venus whispers: love is drawing closer.",
              guidance: "Open your heart to receive love. Do things that make you feel beautiful and alive. Venus rewards those who celebrate love even before it arrives.",
              affirmation: "I am magnetic to love. My twin flame feels Venus's pull toward me now.",
              intensity: 5),

        .init(planet: "Mercury", symbol: "☿️", currentSign: mercurySign, signSymbol: mercurySymbol,
              color: AppColors.sage, theme: "Communication & Truth",
              twinFlameEffect: "Mercury rules communication — including the telepathic communication between twin flames. In \(mercurySign), messages sent from the heart travel powerfully.",
              guidance: "Speak and write your truth. Journal your feelings to your twin. The energetic transmission of your words is heightened under this transit.",
              affirmation: "My words carry divine power. My twin hears my heart.",
              intensity: 3),

        .init(planet: "Mars", symbol: "♂️", currentSign: marsSign, signSymbol: marsSymbol,
              color: Color(hex: "E53935"), theme: "Action & Desire",
              twinFlameEffect: "Mars activates desire, drive, and the courage to pursue what you love. In \(marsSign), your twin flame's masculine energy (regardless of gender) is being activated and directed.",
              guidance: "Take one bold step toward your union today. Mars rewards action. Do not wait — move in the direction of love.",
              affirmation: "I act boldly from love. My twin flame's courage is awakening.",
              intensity: 4),

        .init(planet: "Jupiter", symbol: "♃", currentSign: jupiterSign, signSymbol: jupiterSymbol,
              color: Color(hex: "D97B4A"), theme: "Expansion & Blessings",
              twinFlameEffect: "Jupiter is the planet of abundance, expansion, and divine blessings. In \(jupiterSign), it is expanding the territory of love and blessing twin flame journeys with miraculous acceleration.",
              guidance: "Expect more than you have been asking for. Jupiter expands whatever it touches — let it expand your faith and your vision for your union.",
              affirmation: "God is expanding my love story beyond what I can imagine. Blessings overflow.",
              intensity: 5),

        .init(planet: "Saturn", symbol: "♄", currentSign: saturnSign, signSymbol: saturnSymbol,
              color: Color(hex: "4A90D9"), theme: "Discipline & Soul Contracts",
              twinFlameEffect: "Saturn governs soul contracts, discipline, and the long-term structure of your life. In \(saturnSign), Saturn is testing the foundations of your twin flame journey — revealing what is built to last.",
              guidance: "Do not be discouraged by Saturn's challenges. Every test it brings is strengthening the foundation of your union. What survives Saturn is eternal.",
              affirmation: "My union is built on eternal foundations. I endure with grace.",
              intensity: 3),

        .init(planet: "Uranus", symbol: "⛢", currentSign: "Taurus", signSymbol: "♉",
              color: AppColors.coral, theme: "Sudden Change & Awakening",
              twinFlameEffect: "Uranus in Taurus is revolutionizing values, physical reality, and the material world. Twin flames under this transit often experience sudden, unexpected breakthroughs and rapid shifts toward union.",
              guidance: "Stay open to the unexpected. Uranus specializes in plot twists. The reunion you've been praying for may arrive in a form you didn't predict.",
              affirmation: "I welcome the unexpected. My breakthrough arrives in divine surprise.",
              intensity: 4),

        .init(planet: "Neptune", symbol: "♆", currentSign: "Pisces", signSymbol: "♓",
              color: Color(hex: "5E35B1"), theme: "Mysticism & Soul Bonds",
              twinFlameEffect: "Neptune in Pisces — its home sign — is at peak power for spiritual connection, soul bonds, and psychic communication between twins. Telepathy, dreams, and signs are especially potent now.",
              guidance: "Pay close attention to your dreams and meditations. Neptune is making the veil between you and your twin almost transparent. Your soul is receiving transmissions.",
              affirmation: "My soul communicates freely with my twin's soul. I receive every message.",
              intensity: 5),

        .init(planet: "Pluto", symbol: "♇", currentSign: "Aquarius", signSymbol: "♒",
              color: Color(hex: "8B5CF6"), theme: "Transformation & Collective Love",
              twinFlameEffect: "Pluto in Aquarius is transforming collective consciousness and redefining love for a new era. Twin flame relationships are at the forefront of this evolution. Your union is part of the new earth blueprint.",
              guidance: "See your journey as part of something greater than yourself. Pluto is using twin flames to upgrade humanity's understanding of love. Your healing contributes to the collective.",
              affirmation: "Our love is part of the new earth. We are transforming love for humanity.",
              intensity: 5),
    ]
}

// MARK: - View

struct TransitTrackerView: View {
    @State private var transits: [PlanetaryTransit] = []
    @State private var selectedTransit: PlanetaryTransit? = nil

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Header
                    VStack(spacing: 6) {
                        Text("Current Planetary Weather")
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)
                            .padding(.top, 16)
                        Text("How the cosmos is affecting your twin flame journey right now")
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // Transit cards
                    VStack(spacing: 12) {
                        ForEach(transits) { transit in
                            TransitCard(
                                transit: transit,
                                isSelected: selectedTransit?.id == transit.id,
                                onTap: {
                                    withAnimation(.spring(response: 0.4)) {
                                        selectedTransit = selectedTransit?.id == transit.id ? nil : transit
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)
                }
            }
        }
        .navigationTitle("Astrology Transits")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { transits = currentTransits() }
    }
}

// MARK: - Transit Card

private struct TransitCard: View {
    let transit: PlanetaryTransit
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            onTap()
        }) {
            VStack(spacing: 0) {

                HStack(spacing: 14) {
                    // Planet symbol circle
                    ZStack {
                        Circle()
                            .fill(transit.color.opacity(0.2))
                            .frame(width: 52, height: 52)
                        Text(transit.symbol)
                            .font(.system(size: 24))
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(transit.planet)
                                .font(AppFont.body(16, weight: .semibold))
                                .foregroundStyle(AppColors.cream)
                            Text("in \(transit.currentSign) \(transit.signSymbol)")
                                .font(AppFont.body(13))
                                .foregroundStyle(transit.color)
                        }
                        Text(transit.theme)
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender)
                    }

                    Spacer()

                    // Intensity dots
                    HStack(spacing: 3) {
                        ForEach(1...5, id: \.self) { i in
                            Circle()
                                .fill(i <= transit.intensity ? transit.color : transit.color.opacity(0.2))
                                .frame(width: 5, height: 5)
                        }
                    }
                    .accessibilityHidden(true)

                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppColors.lavender.opacity(0.4))
                        .accessibilityHidden(true)
                }
                .padding(18)

                if isSelected {
                    VStack(alignment: .leading, spacing: 14) {
                        Divider().background(transit.color.opacity(0.25)).padding(.horizontal, 18)

                        sectionView("Twin Flame Effect", text: transit.twinFlameEffect, icon: "flame.fill")
                        sectionView("Guidance", text: transit.guidance, icon: "map.fill")

                        Text("\"\(transit.affirmation)\"")
                            .font(AppFont.serifTitle(14))
                            .foregroundStyle(AppColors.cream)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                            .padding(12)
                            .background(transit.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 18)
                            .padding(.bottom, 14)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                isSelected ? transit.color.opacity(0.08) : AppColors.deepViolet.opacity(0.65),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? transit.color.opacity(0.5) : AppColors.purple.opacity(0.2), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionView(_ label: String, text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(transit.color)
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
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 18)
    }
}
