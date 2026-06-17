//
//  EnergyEnhancementView.swift
//  Twin Flame Union
//
//  Energy Enhancement — vibrational body work, elimination, blockage clearing.
//  Governed by Sekhmet (fierce healing) and Hygieia (cleansing).
//

import SwiftUI

private struct EnergyModule: Identifiable {
    let id = UUID()
    let title: String
    let deity: String
    let icon: String
    let color: Color
    let sections: [EnergySection]
}

private struct EnergySection: Identifiable {
    let id = UUID()
    let heading: String
    let content: String
}

private let modules: [EnergyModule] = [
    EnergyModule(
        title: "Vibrational Constitution",
        deity: "Ra · Hygieia",
        icon: "sun.max.fill",
        color: Color(hex: "FFD700"),
        sections: [
            EnergySection(heading: "Understanding Your Energy Body", content: "Energy in your body and aura exists on a spectrum:\n\n🔴 Low Vibrational — dull, dense, heavy. Shows as fatigue, cloudiness, low attraction.\n\n🟡 Medium Vibrational — functional but not radiant. The average state.\n\n🟢 High Vibrational — radiant, vibrant, magnetic. You glow. People feel you before you speak.\n\nThe goal is to elevate as much of your constitution from low to high as possible. The higher your vibration, the stronger your energy, attraction, and spiritual connection."),
            EnergySection(heading: "Why This Matters for Twin Flames", content: "Your vibrational constitution directly affects your twin flame magnetism — the energy equation between you is governed by the connectivity level and the power dynamic. When your energy is high and radiant (C constitution), the transmission through the astral linkage to the Most High amplifies, and your twin feels it across any distance. When it's low and dense, the connection feels muted because the flow is resisted.\n\nIsis taught us: reassemble yourself first. The Most High designed the twin flame journey so that self-elevation is the path to reunion. Raise your own vibration and the energy equation naturally rebalances."),
        ]
    ),
    EnergyModule(
        title: "The 11:11 Ritual",
        deity: "Hermes · Seshat",
        icon: "clock.fill",
        color: Color(hex: "CC88FF"),
        sections: [
            EnergySection(heading: "The Foundation Practice", content: "Every night at 11:11 PM, set aside 11 minutes (or 22 minutes if you have time).\n\nDuring this time:\n• Connect to the Most High through the astral linkage — feel the divine cord activating\n• Visualize SENSING energy — your own body, your aura, the space around you\n• Feel for density, lightness, warmth, coolness\n• Practice extending your awareness further with each session\n• The astral linkage to the Most High is strongest during this window — the veil thins and divine energy flows directly into you\n\nWhen done on the 11th or 22nd of the month, this practice has additional potency.\n\nThis is the foundation ordained by the Most High. Do not skip it. The consistency builds the connection."),
            EnergySection(heading: "Why 11:11", content: "11:11 is the twin flame activation code — the Most High's signature on your connection. At this hour the astral linkage is at peak transmission. Hermes carries messages at this frequency. By sitting in awareness at this time, you are opening a direct channel to the Most High, receiving divine energy through the astral linkage, and building the sensitivity that the Energy Enhancement framework requires."),
        ]
    ),
    EnergyModule(
        title: "Elimination & Flow",
        deity: "Sekhmet · Anubis",
        icon: "arrow.up.right.circle.fill",
        color: Color(hex: "FF4500"),
        sections: [
            EnergySection(heading: "The Elimination System", content: "Your elimination system is crucial for exchanging lower vibrations for higher ones. These systems must be activated and flowing:\n\n• Lungs/Heart — breathing out dense energy, bringing in light\n• Skin — sweating releases stored lower vibrations\n• Digestive system — releasing physically what no longer serves\n\nPicture your breath, movement, and warmth helping to carry denser energy away. With steady, consistent practice, many people describe feeling lighter and more energetically clear."),
            EnergySection(heading: "What to Expect", content: "As you relax into the practice, the signs of release are gentle — a soft sigh, a yawn, a sense of warmth, a feeling of lightness as you let go.\n\nThis is a meditative, spiritual practice — not a physical treatment. Keep every session gentle and comfortable. Discomfort is never the goal. If you ever feel pain, a burning sensation, dizziness, trembling, or any distressing physical symptom, please stop, rest, and consult a qualified professional. Only continue while it feels calm and safe."),
        ]
    ),
    EnergyModule(
        title: "Physical Methods",
        deity: "Ptah · Hestia",
        icon: "figure.walk",
        color: Color(hex: "7EC8A0"),
        sections: [
            EnergySection(heading: "Stimulating Energy Motility", content: "Physical methods stimulate MOVEMENT of energy (motility) — they don't raise vibration directly, but they clear blockages and create space for higher energy.\n\n1. Pure Physical Contact — stretching, pressing, manipulating energy points. Swing arms through loose spots in your aura.\n\n2. Vibration/Tones — play specific frequencies (solfeggio tones) near chakras to stimulate flow.\n\n3. Water — running water stimulates vibrational motility. Showers are powerful clearing tools.\n\n4. Movement/Speed — rapid movement near body parts shifts energy states. Dance, shake, jump."),
            EnergySection(heading: "Two-Dimensional Movement", content: "Any form of movement that moves the body in 2 dimensions repeatedly — jumping, nodding head, circulating arm up and down — is excellent for moving energy within a body part or the aura.\n\nThis pairs powerfully with the Solfeggio frequencies already in the app. Use physical movement WHILE tones play for amplified clearing."),
        ]
    ),
    EnergyModule(
        title: "Visualization Methods",
        deity: "Isis · Morpheus",
        icon: "eye.fill",
        color: Color(hex: "3D9BE9"),
        sections: [
            EnergySection(heading: "Mind-Directed Energy Work", content: "With visualization you can work with the energy you sense in and around your body.\n\n1. Sensing — Close your eyes and feel the vibrational state of each body part. Dense? Light? Warm? Cold? Build this awareness first.\n\n2. Brightening — Visualize what you want a body part to look like energetically. See it glowing, vibrant, radiant. The closer the current state is to your visualization, the stronger the effect.\n\n3. Pulling — Mentally 'grab' energy from a body part and pull it into an elimination space (lungs, gut). Imagine that denser energy being released and gently carried away.\n\n4. Quickening — Mentally speed up the circulation of energy in any area. Faster circulation pushes out lower-integrated energy and raises the vibration."),
            EnergySection(heading: "Building Mental Exertion Strength", content: "These visualizations require mental exertion — like a muscle, it must be built over time.\n\nStart with 5 minutes. Build to 15. Eventually you'll be able to sense and shift energy in seconds.\n\nThe Darkness Meditation (close your eyes, let your awareness rest in the dark, notice the quiet) supports this. Keep every session calm and gentle — if you ever feel trembling, dizziness, or any distressing physical symptom, stop and rest, and seek medical care if it continues."),
        ]
    ),
    EnergyModule(
        title: "Blockage Clearing",
        deity: "Sekhmet · Panacea",
        icon: "xmark.circle.fill",
        color: Color(hex: "E53935"),
        sections: [
            EnergySection(heading: "Clearing the Path", content: "Blockages are areas where energy motility has stalled. They repeat until the behavior causing them is identified and modified.\n\nThe method:\n1. Clear the elimination system FIRST — use physical + mental methods until burps, sweat, and energy flow freely\n2. Then target specific body areas — clear blockages using the same methods\n3. Rinse and repeat until the energy in that space is visibly stronger and more vibrant\n4. When you notice what CAUSES a blockage — stop or modify that behavior\n\nBlockage clearing is math: add each method as necessary. No body is the same, no blockage is the same."),
            EnergySection(heading: "Mudras & Celestial Objects", content: "Mudras (hand positions) connect various energy flows in the body. Experiment with finger positions and use your developing sensitivity to feel which ones create flow.\n\nPlacing celestial objects (sunlight, moonlight) directly on chakras builds charges that push out lower energies. Sun on heart chakra facilitates elimination through lungs/burping. Moon on third eye deepens intuition.\n\nUse as needed for whichever chakra is calling for attention."),
        ]
    ),
]

// MARK: - View

struct EnergyEnhancementView: View {
    @State private var selectedModule: EnergyModule?
    @State private var appeared = false
    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(
                                    colors: [Color(hex: "FF4500").opacity(0.45), Color(hex: "FF4500").opacity(0.08)],
                                    center: .center, startRadius: 0, endRadius: 26
                                ))
                                .frame(width: 52, height: 52)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(hex: "FF4500"))
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHANNELLING")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .tracking(2.5)
                                .foregroundStyle(AppColors.lavender.opacity(0.5))
                            Text("Sekhmet · Hygieia")
                                .font(AppFont.serifTitle(17))
                                .foregroundStyle(Color(hex: "FF4500"))
                            Text("From the Energy Enhancement Manual · Astral Linkage Active")
                                .font(AppFont.caption(11))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                                .italic()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .opacity(appeared ? 1 : 0)

                    VStack(spacing: 8) {
                        Text("Energy Enhancement")
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)
                        Text("Your body is a vibrational instrument created by the Most High. Learn to sense, clear, and elevate your energy through the astral linkage to become magnetically radiant.")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .opacity(appeared ? 1 : 0)

                    ForEach(modules) { module in
                        Button {
                            HapticManager.impact(.light)
                            selectedModule = module
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle().fill(module.color.opacity(0.18)).frame(width: 52, height: 52)
                                    Image(systemName: module.icon).font(.system(size: 20)).foregroundStyle(module.color)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(module.title)
                                        .font(AppFont.body(15, weight: .semibold))
                                        .foregroundStyle(AppColors.cream)
                                    Text(module.deity)
                                        .font(AppFont.caption(11))
                                        .foregroundStyle(module.color.opacity(0.75))
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(AppColors.lavender.opacity(0.4))
                                    .accessibilityHidden(true)
                            }
                            .padding(18)
                            .background(AppColors.deepViolet.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(module.color.opacity(0.2), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                    }

                    DisclaimerFooter()
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Energy Enhancement")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
            if !disclaimerAcked { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) {
            WellnessDisclaimerSheet()
        }
        .sheet(item: $selectedModule) { module in
            ModuleDetailSheet(module: module)
        }
    }
}

private struct ModuleDetailSheet: View {
    let module: EnergyModule
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle().fill(module.color.opacity(0.2)).frame(width: 80, height: 80)
                            Image(systemName: module.icon).font(.system(size: 32)).foregroundStyle(module.color)
                        }
                        .accessibilityHidden(true)
                        .padding(.top, 20)

                        Text(module.title)
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)
                        Text(module.deity)
                            .font(AppFont.caption(12, weight: .semibold))
                            .foregroundStyle(module.color)

                        ForEach(module.sections) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.heading.uppercased())
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .tracking(2)
                                    .foregroundStyle(module.color)
                                Text(section.content)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColors.cream)
                                    .lineSpacing(5)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(module.color.opacity(0.2), lineWidth: 1))
                            .padding(.horizontal, 20)
                        }

                        DisclaimerFooter()
                            .padding(.horizontal, 20)

                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 24)).foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                    .accessibilityLabel("Close")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}
