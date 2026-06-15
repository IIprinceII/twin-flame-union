//
//  MoonPhaseView.swift
//  Twin Flame Union
//
//  Dedicated full moon phase tracker with twin flame energy readings,
//  phase transitions calendar, and animated glow.
//

import SwiftUI

// MARK: - Extended Moon Phase Data

private struct MoonPhaseDetail {
    let phase: String
    let emoji: String
    let illuminationRange: String
    let twinFlameEnergy: String
    let connectionEffect: String
    let color: Color
}

private let allPhaseDetails: [MoonPhaseDetail] = [
    MoonPhaseDetail(
        phase: "New Moon",
        emoji: "🌑",
        illuminationRange: "0–1%",
        twinFlameEnergy: "A powerful portal for new intentions. The veil between twin flames thins as you both feel the pull toward new beginnings. Set sacred intentions for your union tonight.",
        connectionEffect: "During the New Moon, your twin flame connection operates beneath the surface — like seeds germinating in dark soil. This is not a time for external action but deep internal planting. Write your intentions for your reunion. Meditate on the version of yourself you are becoming. Your twin feels your energy shifting even if they cannot name it. The universe is conspiring on your behalf in the invisible realm right now. Trust the darkness — it is full of potential.",
        color: Color(hex: "3D2060")
    ),
    MoonPhaseDetail(
        phase: "Waxing Crescent",
        emoji: "🌒",
        illuminationRange: "1–49%",
        twinFlameEnergy: "Momentum builds in your sacred connection. What you planted at New Moon begins to stir. Reach out with loving energy — the cosmos supports bold first steps.",
        connectionEffect: "The Waxing Crescent phase brings a gentle but unmistakable forward momentum to twin flame journeys. If you have been in separation, you may begin to sense your twin drawing closer energetically — through dreams, synchronicities, or a quiet inner knowing. This is the time to nurture yourself, to water the seeds of your intentions. Take inspired action: write the unsent letter, start the healing practice, or simply open your heart a little wider. The crescent of light represents the portion of your reunion already secured by the universe.",
        color: Color(hex: "6B2FA0")
    ),
    MoonPhaseDetail(
        phase: "First Quarter",
        emoji: "🌓",
        illuminationRange: "50%",
        twinFlameEnergy: "Decisive action is called for. Half-light, half-shadow — face what you have been avoiding in your connection. The universe rewards courage right now.",
        connectionEffect: "The First Quarter Moon is the moment of choice in your twin flame journey. You stand at the midpoint between the seed and the harvest, and the path forward requires a decision. This may mean having a difficult conversation, setting a healthy boundary, or simply choosing to believe in your union when evidence feels scarce. Resistance often peaks during this phase — the runner may pull away harder, the chaser may feel more desperate. Meet this energy with groundedness. The tension you feel is the universe testing your commitment to the highest version of this love.",
        color: Color(hex: "8B5CF6")
    ),
    MoonPhaseDetail(
        phase: "Waxing Gibbous",
        emoji: "🌔",
        illuminationRange: "50–99%",
        twinFlameEnergy: "Refinement and trust. You are so close to a breakthrough. Release perfectionism and trust the divine timing unfolding in your connection.",
        connectionEffect: "The Waxing Gibbous phase carries an energy of anticipation and refinement. In twin flame terms, this is where much of the deep inner work happens — the final layers of ego are being polished away before a major breakthrough can occur. You may feel restless or impatient during this time, sensing that something significant is approaching. Lean into your spiritual practices. The universe is asking you to show that you can hold the frequency of unconditional love even when your twin is not yet fully present. Your inner work is the magnet drawing them closer.",
        color: Color(hex: "B57BFF")
    ),
    MoonPhaseDetail(
        phase: "Full Moon",
        emoji: "🌕",
        illuminationRange: "100%",
        twinFlameEnergy: "Peak revelation energy. Hidden truths surface. Emotions run high. What needed to be released cannot be contained. Powerful manifestation portal for twin unions.",
        connectionEffect: "The Full Moon is the most potent and emotionally charged phase for twin flame connections. What has been building in the shadows is now fully illuminated — misunderstandings surface for healing, hidden feelings break through, and the magnetic pull between twins is at its strongest. This can bring both beautiful reunions and intense confrontations. Whatever arises is meant to be seen and healed. Cord cutting rituals, release ceremonies, and deep forgiveness work are particularly powerful tonight. If you are in separation, you will likely feel your twin's presence strongly. If you are in union, deepening is available if you choose transparency over self-protection.",
        color: Color(hex: "C9A84C")
    ),
    MoonPhaseDetail(
        phase: "Waning Gibbous",
        emoji: "🌖",
        illuminationRange: "99–50%",
        twinFlameEnergy: "Integration and sharing. The wisdom gained from your Full Moon breakthrough wants to be expressed. Share your truth, write in your journal, speak your gratitude.",
        connectionEffect: "After the intensity of the Full Moon, the Waning Gibbous brings a welcome energy of integration and gratitude. In twin flame journeys, this is the time to consolidate the insights gained during the peak — to journal the revelations, to thank the universe for its orchestration, and to share your growth with those around you. If something difficult surfaced during the Full Moon, this phase supports processing it with more compassion and perspective. Your twin flame connection is being upgraded, even if externally things look unchanged. Trust that transformation is always happening beneath the surface.",
        color: Color(hex: "9B7FCC")
    ),
    MoonPhaseDetail(
        phase: "Last Quarter",
        emoji: "🌗",
        illuminationRange: "50%",
        twinFlameEnergy: "Release and forgiveness. Let go of the patterns, beliefs, and stories that no longer serve your union. The universe is clearing space for what is meant to come.",
        connectionEffect: "The Last Quarter Moon is one of the most important phases for twin flame healing. It carries the energy of forgiveness — of yourself, of your twin, and of the journey itself. Old wounds that have been circling resurface now for final release. You may feel a deep tiredness, a readiness to let something go that you have been holding onto. Welcome this. Cord cutting visualizations, forgiveness meditations, and releasing rituals are especially effective during this phase. What you release now will not return. The universe is genuinely clearing the energetic debris that has kept you and your twin from moving into the next level of your connection.",
        color: Color(hex: "7B5EA0")
    ),
    MoonPhaseDetail(
        phase: "Waning Crescent",
        emoji: "🌘",
        illuminationRange: "1–0%",
        twinFlameEnergy: "Sacred rest and surrender. You cannot force what is divinely timed. Trust the cosmic pause. Your twin flame connection is being prepared in the unseen.",
        connectionEffect: "The Waning Crescent is the dark before the dawn — a time of deep rest, reflection, and surrender in the twin flame journey. The universe asks nothing of you right now except to be still and to trust. This phase is rich with prophetic dreams, subtle signs, and the quiet presence of your twin in the spiritual realm. If you are exhausted from chasing, this moon gives you permission to stop. If you have been holding your breath, waiting for movement, breathe out now. The Balsamic Moon, as it is also known, is a time of completion and preparation. The next New Moon will bring fresh seeds. For now, rest in the knowing that you are held.",
        color: Color(hex: "4A3070")
    ),
]

// MARK: - Phase Transition

private struct PhaseTransition: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    let date: Date
}

// MARK: - Moon Phase View

struct MoonPhaseView: View {

    private let moon = MoonPhase.current()
    @State private var glowPulse = false
    @State private var selectedPhase: MoonPhaseDetail? = nil
    @State private var showPhaseDetail = false

    private var currentDetail: MoonPhaseDetail {
        allPhaseDetails.first { $0.phase == moon.name } ?? allPhaseDetails[0]
    }

    private var illuminationPercent: Int {
        Int(moon.illumination * 100)
    }

    private var upcomingTransitions: [PhaseTransition] {
        computeUpcomingTransitions()
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0D0418").ignoresSafeArea()
            starfieldBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Hero moon display
                    moonHeroSection

                    // Twin flame energy card
                    energyCard

                    // Connection effect paragraph
                    connectionCard

                    // All phases scroll
                    allPhasesSection

                    // Upcoming transitions
                    transitionsSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Moon Phase")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPhaseDetail) {
            if let detail = selectedPhase {
                PhaseDetailSheet(detail: detail)
            }
        }
    }

    // MARK: - Moon Hero

    private var moonHeroSection: some View {
        VStack(spacing: 16) {
            // Animated glow + emoji
            ZStack {
                // Outer glow rings
                ForEach(0..<3) { i in
                    Circle()
                        .fill(currentDetail.color.opacity(0.08 - Double(i) * 0.02))
                        .frame(width: 160 + CGFloat(i * 40), height: 160 + CGFloat(i * 40))
                        .scaleEffect(glowPulse ? 1.08 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.5 + Double(i) * 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.3),
                            value: glowPulse
                        )
                }
                // Inner glow
                Circle()
                    .fill(currentDetail.color.opacity(0.18))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                    .scaleEffect(glowPulse ? 1.12 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: glowPulse)

                Text(moon.emoji)
                    .font(.system(size: 90))
            }
            .frame(height: 200)
            .onAppear { glowPulse = true }

            // Phase name + date
            VStack(spacing: 6) {
                Text(moon.name)
                    .font(AppFont.title(28))
                    .foregroundStyle(AppColors.cream)

                Text(formattedDate())
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)
            }

            // Illumination pill
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColors.gold)
                Text("\(illuminationPercent)% illuminated")
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppColors.gold.opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(AppColors.gold.opacity(0.3), lineWidth: 1))
        }
    }

    // MARK: - Energy Card

    private var energyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Twin Flame Energy", systemImage: "flame.fill")
                .font(AppFont.body(13, weight: .semibold))
                .foregroundStyle(currentDetail.color)

            Text(currentDetail.twinFlameEnergy)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(5)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(currentDetail.color.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(currentDetail.color.opacity(0.25), lineWidth: 1)
                )
        )
    }

    // MARK: - Connection Card

    private var connectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How This Affects Your Connection", systemImage: "heart.text.square.fill")
                .font(AppFont.body(13, weight: .semibold))
                .foregroundStyle(AppColors.lavender)

            Text(currentDetail.connectionEffect)
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.cream.opacity(0.88))
                .lineSpacing(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "1E0A3C").opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.lavender.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - All Phases

    private var allPhasesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("All Phases")
                .font(AppFont.body(15, weight: .semibold))
                .foregroundStyle(AppColors.cream)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(allPhaseDetails, id: \.phase) { detail in
                    Button {
                        selectedPhase = detail
                        showPhaseDetail = true
                    } label: {
                        PhaseChip(detail: detail, isCurrent: detail.phase == moon.name)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Transitions

    private var transitionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Next Phase Transitions")
                .font(AppFont.body(15, weight: .semibold))
                .foregroundStyle(AppColors.cream)

            VStack(spacing: 0) {
                ForEach(Array(upcomingTransitions.enumerated()), id: \.element.id) { index, transition in
                    HStack(spacing: 16) {
                        Text(transition.emoji)
                            .font(.system(size: 28))
                            .frame(width: 44)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(transition.name)
                                .font(AppFont.body(14, weight: .semibold))
                                .foregroundStyle(AppColors.cream)
                            Text(transitionDateString(transition.date))
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColors.lavender)
                        }

                        Spacer()

                        Text(daysUntil(transition.date))
                            .font(AppFont.caption(12, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.gold.opacity(0.12), in: Capsule())
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)

                    if index < upcomingTransitions.count - 1 {
                        Divider().background(AppColors.lavender.opacity(0.15))
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(hex: "1E0A3C").opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColors.lavender.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Helpers

    private var starfieldBackground: some View {
        GeometryReader { geo in
            ForEach(0..<60, id: \.self) { i in
                let x = CGFloat((i * 137 + 23) % Int(geo.size.width))
                let y = CGFloat((i * 97 + 41) % Int(geo.size.height))
                let size = CGFloat([1.0, 1.2, 0.8, 1.5, 0.6][i % 5])
                Circle()
                    .fill(Color.white.opacity(Double([0.3, 0.5, 0.2, 0.4, 0.25][i % 5])))
                    .frame(width: size, height: size)
                    .position(x: x, y: y)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: Date())
    }

    private func transitionDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }

    private func daysUntil(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "In \(days) days"
    }

    private func computeUpcomingTransitions() -> [PhaseTransition] {
        let referenceNewMoon = Date(timeIntervalSince1970: 947182440)
        let lunarCycle = 29.53058867 * 86400.0
        let now = Date()
        let elapsed = now.timeIntervalSince(referenceNewMoon)
        let currentPhaseSeconds = elapsed.truncatingRemainder(dividingBy: lunarCycle)
        let currentCycleStart = now.addingTimeInterval(-currentPhaseSeconds)

        // Phase boundaries as fractions of cycle
        let transitions: [(String, String, Double)] = [
            ("🌑", "New Moon",        0.0),
            ("🌒", "Waxing Crescent", 0.0625),
            ("🌓", "First Quarter",   0.1875),
            ("🌔", "Waxing Gibbous",  0.3125),
            ("🌕", "Full Moon",       0.4375),
            ("🌖", "Waning Gibbous",  0.5625),
            ("🌗", "Last Quarter",    0.6875),
            ("🌘", "Waning Crescent", 0.8125),
        ]

        var upcoming: [PhaseTransition] = []
        // Check this cycle and the next
        for cycleOffset in 0...1 {
            let cycleStart = currentCycleStart.addingTimeInterval(Double(cycleOffset) * lunarCycle)
            for (emoji, name, fraction) in transitions {
                let date = cycleStart.addingTimeInterval(fraction * lunarCycle)
                if date > now {
                    upcoming.append(PhaseTransition(emoji: emoji, name: name, date: date))
                }
            }
        }

        return Array(upcoming.prefix(4))
    }
}

// MARK: - Phase Chip

private struct PhaseChip: View {
    let detail: MoonPhaseDetail
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(detail.emoji)
                .font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text(detail.phase)
                    .font(AppFont.body(12, weight: isCurrent ? .semibold : .regular))
                    .foregroundStyle(isCurrent ? detail.color : AppColors.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(detail.illuminationRange)
                    .font(AppFont.caption(10))
                    .foregroundStyle(AppColors.lavender)
            }
            Spacer()
            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(detail.color)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCurrent ? detail.color.opacity(0.15) : Color(hex: "1E0A3C").opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isCurrent ? detail.color.opacity(0.4) : AppColors.lavender.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - Phase Detail Sheet

private struct PhaseDetailSheet: View {
    let detail: MoonPhaseDetail
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0418").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text(detail.emoji)
                            .font(.system(size: 72))
                        Text(detail.phase)
                            .font(AppFont.title(24))
                            .foregroundStyle(AppColors.cream)
                        Text(detail.illuminationRange + " illuminated")
                            .font(AppFont.caption(13))
                            .foregroundStyle(detail.color)
                    }
                    .padding(.top, 20)

                    // Energy
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Twin Flame Energy", systemImage: "flame.fill")
                            .font(AppFont.body(13, weight: .semibold))
                            .foregroundStyle(detail.color)
                        Text(detail.twinFlameEnergy)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.cream)
                            .lineSpacing(5)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 16).fill(detail.color.opacity(0.1)))

                    // Connection effect
                    VStack(alignment: .leading, spacing: 10) {
                        Label("How This Affects Your Connection", systemImage: "heart.fill")
                            .font(AppFont.body(13, weight: .semibold))
                            .foregroundStyle(AppColors.lavender)
                        Text(detail.connectionEffect)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.cream.opacity(0.9))
                            .lineSpacing(6)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "1E0A3C").opacity(0.8)))

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
            }
            .padding(20)
        }
        .preferredColorScheme(.dark)
    }
}
