//
//  JourneyView.swift
//  Twin Flame Union
//
//  Journey tab — categorised with horizontal tabs to reduce overwhelm.
//

import SwiftUI

// MARK: - Category

private enum JourneyCategory: String, CaseIterable {
    case journal   = "Journal"
    case healing   = "Healing"
    case guidance  = "Guidance"
    case explore   = "Explore"

    var icon: String {
        switch self {
        case .journal:  return "book.fill"
        case .healing:  return "heart.fill"
        case .guidance: return "sparkles"
        case .explore:  return "globe"
        }
    }
}

// MARK: - Item Model

private struct JourneyItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let deity: String      // governing deity name
    let color: Color
    let accent: Color
    let destination: AnyView
}

// MARK: - Journey View

struct JourneyView: View {
    @State private var selectedCategory: JourneyCategory = .journal

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                // Category pill bar
                categoryBar
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Content for selected category
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 14
                    ) {
                        ForEach(items(for: selectedCategory)) { item in
                            NavigationLink(destination: item.destination) {
                                JourneyTile(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .animation(.easeInOut(duration: 0.2), value: selectedCategory)
            }
        }
        .navigationTitle("Your Journey")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: - Category Bar

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(JourneyCategory.allCases, id: \.self) { cat in
                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = cat
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12))
                            Text(cat.rawValue)
                                .font(AppFont.body(14, weight: selectedCategory == cat ? .semibold : .regular))
                        }
                        .foregroundStyle(selectedCategory == cat ? Color(hex: "0D0418") : AppColors.lavender)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            selectedCategory == cat
                                ? AnyShapeStyle(AppColors.gold)
                                : AnyShapeStyle(Color(hex: "1E0A3C").opacity(0.8)),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().stroke(
                                selectedCategory == cat ? Color.clear : AppColors.lavender.opacity(0.2),
                                lineWidth: 1
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Items per Category

    private func items(for category: JourneyCategory) -> [JourneyItem] {
        switch category {

        case .journal:
            return [
                JourneyItem(icon: "book.fill",             title: "Soul Journal",        deity: "Thoth · Psyche",      color: AppColors.purple,       accent: Color(hex: "9B59B6"), destination: AnyView(SoulJournalView())),
                JourneyItem(icon: "moon.zzz.fill",          title: "Dream Journal",       deity: "Morpheus · Hypnos",   color: Color(hex: "4A90D9"),   accent: Color(hex: "7BB8F0"), destination: AnyView(DreamJournalView())),
                JourneyItem(icon: "sparkles",               title: "Synchronicity Log",   deity: "Iris · Hermes",       color: Color(hex: "9B59B6"),   accent: Color(hex: "C39BD3"), destination: AnyView(SynchronicityLogView())),
                JourneyItem(icon: "hand.thumbsup.fill",     title: "Gratitude Log",       deity: "Hathor · Renenutet",  color: Color(hex: "F0C060"),   accent: Color(hex: "FFE082"), destination: AnyView(GratitudeLogView())),
                JourneyItem(icon: "hands.sparkles.fill",    title: "Prayer Journal",      deity: "Ra · Amun",           color: Color(hex: "CC88FF"),   accent: Color(hex: "E0B3FF"), destination: AnyView(PrayerJournalView())),
                JourneyItem(icon: "timeline.selection",     title: "Connection Timeline", deity: "Clotho · Lachesis",   color: Color(hex: "E74C8B"),   accent: Color(hex: "F48FB1"), destination: AnyView(ConnectionTimelineView())),
            ]

        case .healing:
            return [
                JourneyItem(icon: "bolt.fill",              title: "Energy Enhancement",   deity: "Sekhmet · Hygieia",   color: Color(hex: "FF4500"),   accent: Color(hex: "FF7043"), destination: AnyView(EnergyEnhancementView())),
                JourneyItem(icon: "scissors",               title: "Cord Cutting",        deity: "Atropos · Hecate",    color: Color(hex: "1E88E5"),   accent: Color(hex: "64B5F6"), destination: AnyView(CordCuttingView())),
                JourneyItem(icon: "rays",                   title: "Chakra Check-in",     deity: "Sekhmet · Imhotep",   color: Color(hex: "43A047"),   accent: Color(hex: "7EC8A0"), destination: AnyView(ChakraCheckinView())),
                JourneyItem(icon: "waveform",               title: "Solfeggio",            deity: "Apollo · Hygieia",    color: Color(hex: "43A047"),   accent: Color(hex: "7EC8A0"), destination: AnyView(SolfeggioView())),
                JourneyItem(icon: "star.fill",              title: "Sacred Geometry",      deity: "Ptah · Athena",       color: Color(hex: "CC88FF"),   accent: Color(hex: "E0B3FF"), destination: AnyView(SacredGeometryView())),
                JourneyItem(icon: "moon.fill",              title: "Ritual Planner",       deity: "Hecate · Isis",       color: Color(hex: "5E35B1"),   accent: Color(hex: "9575CD"), destination: AnyView(RitualPlannerView())),
                JourneyItem(icon: "sparkles.rectangle.stack.fill", title: "Manifestation Board", deity: "Hathor · Aphrodite", color: Color(hex: "F0C060"), accent: Color(hex: "FFE082"), destination: AnyView(ManifestationBoardView())),
            ]

        case .guidance:
            return [
                JourneyItem(icon: "brain.head.profile",     title: "Mind Optimization",    deity: "Athena · Thoth",      color: Color(hex: "F0C060"),   accent: Color(hex: "FFE082"), destination: AnyView(MindOptimizationView())),
                JourneyItem(icon: "waveform.path",          title: "Vibrational Energy",   deity: "Hermes · Harmonia",   color: Color(hex: "CC88FF"),   accent: Color(hex: "E0B3FF"), destination: AnyView(VibrationalEnergyView())),
                JourneyItem(icon: "sparkles",               title: "TF Reading",           deity: "Seraphina · Thoth",   color: Color(hex: "7B3F9E"),   accent: Color(hex: "B06CE6"), destination: AnyView(TFReadingView())),
                JourneyItem(icon: "rectangle.portrait.fill",title: "Daily Oracle",          deity: "Apollo · Hecate",     color: Color(hex: "CC88FF"),   accent: Color(hex: "E0B3FF"), destination: AnyView(TarotOracleView())),
                JourneyItem(icon: "questionmark.circle.fill",title: "Soul Archetype Quiz",  deity: "Psyche · Seshat",     color: Color(hex: "8B5CF6"),   accent: Color(hex: "C4B5FD"), destination: AnyView(QuizView())),
                JourneyItem(icon: "arrow.up.forward.circle.fill", title: "TF Stages",       deity: "Persephone · Osiris", color: Color(hex: "8B5CF6"),   accent: Color(hex: "C4B5FD"), destination: AnyView(TFStagesView())),
                JourneyItem(icon: "moon.stars.fill",        title: "Moon Phases",            deity: "Selene · Khonsu",     color: Color(hex: "3D2060"),   accent: Color(hex: "B57BFF"), destination: AnyView(MoonPhaseView())),
                JourneyItem(icon: "globe.americas.fill",    title: "Astrology Transits",     deity: "Nyx · Hermes",        color: Color(hex: "8B5CF6"),   accent: Color(hex: "C4B5FD"), destination: AnyView(TransitTrackerView())),
            ]

        case .explore:
            return [
                JourneyItem(icon: "heart.text.square.fill", title: "Love Languages",       deity: "Eros · Anteros",      color: Color(hex: "E74C8B"),   accent: Color(hex: "F48FB1"), destination: AnyView(LoveLanguageQuizView())),
                JourneyItem(icon: "number.circle.fill",     title: "Numerology Match",      deity: "Lachesis · Thoth",    color: Color(hex: "4A90D9"),   accent: Color(hex: "7BB8F0"), destination: AnyView(NumerologyCompatibilityView())),
                JourneyItem(icon: "numbers",                title: "Numerology",             deity: "Seshat · Hermes",     color: Color(hex: "4A90D9"),   accent: Color(hex: "7BB8F0"), destination: AnyView(NumerologyView())),
                JourneyItem(icon: "person.2.fill",          title: "Compatibility",          deity: "Harmonia · Maat",     color: Color(hex: "D97B4A"),   accent: Color(hex: "FFAB76"), destination: AnyView(CompatibilityDeepDiveView())),
                JourneyItem(icon: "square.and.arrow.up.fill",title: "Share Affirmations",   deity: "Iris · Nefertem",     color: Color(hex: "D97B4A"),   accent: Color(hex: "FFAB76"), destination: AnyView(ShareableAffirmationsView())),
            ]
        }
    }
}

// MARK: - Journey Tile (square grid card)

private struct JourneyTile: View {
    let item: JourneyItem
    @State private var glow = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Deity glow ring
                RoundedRectangle(cornerRadius: 18)
                    .fill(item.color.opacity(glow ? 0.24 : 0.14))
                    .frame(width: 60, height: 60)
                    .animation(.calm(reduceMotion, .easeInOut(duration: 2.5).repeatForever(autoreverses: true)), value: glow)
                RoundedRectangle(cornerRadius: 18)
                    .stroke(item.color.opacity(0.30), lineWidth: 1)
                    .frame(width: 60, height: 60)
                Image(systemName: item.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(item.accent)
                    .accessibilityHidden(true)
            }

            Text(item.title)
                .font(AppFont.body(13, weight: .semibold))
                .foregroundStyle(AppColors.cream)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            // Deity attribution
            Text(item.deity)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(item.accent.opacity(0.65))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A0830").opacity(0.80))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(item.color.opacity(glow ? 0.30 : 0.18), lineWidth: 1)
                        .animation(.calm(reduceMotion, .easeInOut(duration: 2.5).repeatForever(autoreverses: true)), value: glow)
                )
        )
        .onAppear { glow = true }
    }
}
