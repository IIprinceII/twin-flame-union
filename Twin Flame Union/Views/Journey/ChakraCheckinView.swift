//
//  ChakraCheckinView.swift
//  Twin Flame Union
//
//  Daily chakra alignment check-in with balance guidance.
//

import SwiftUI
import SwiftData

// MARK: - Chakra Definition

private struct Chakra: Identifiable {
    let id: Int
    let name: String
    let sanskrit: String
    let location: String
    let color: Color
    let emoji: String
    let keywords: [String]
    let blockedSign: String
    let overactiveSign: String
    let healingPractice: String
    let twinFlameConnection: String
}

private let chakras: [Chakra] = [
    .init(id: 0, name: "Root", sanskrit: "Muladhara", location: "Base of spine",
          color: Color(hex: "E53935"), emoji: "🔴",
          keywords: ["Safety", "Grounding", "Stability"],
          blockedSign: "Anxiety, fear, financial stress, feeling ungrounded",
          overactiveSign: "Greed, materialism, aggression, resistance to change",
          healingPractice: "Walk barefoot on earth, eat red foods, practice grounding meditation",
          twinFlameConnection: "Your root governs your sense of safety in the connection. Heal here to stop running from love."),
    .init(id: 1, name: "Sacral", sanskrit: "Svadhisthana", location: "Below navel",
          color: Color(hex: "FF7043"), emoji: "🟠",
          keywords: ["Creativity", "Pleasure", "Emotion"],
          blockedSign: "Emotional numbness, creative blocks, intimacy issues",
          overactiveSign: "Codependency, emotional volatility, obsessive thoughts",
          healingPractice: "Dance freely, spend time near water, journal your feelings",
          twinFlameConnection: "The seat of your twin flame magnetism. Open this center to allow deep emotional intimacy."),
    .init(id: 2, name: "Solar Plexus", sanskrit: "Manipura", location: "Upper abdomen",
          color: Color(hex: "FDD835"), emoji: "🟡",
          keywords: ["Power", "Confidence", "Will"],
          blockedSign: "Low self-esteem, victim mentality, indecision",
          overactiveSign: "Control, manipulation, aggression, perfectionism",
          healingPractice: "Core exercises, breathwork, set and hold healthy boundaries",
          twinFlameConnection: "Your personal power center. Healing here ends the chaser-runner dynamic — you stop seeking validation from your twin."),
    .init(id: 3, name: "Heart", sanskrit: "Anahata", location: "Center of chest",
          color: Color(hex: "43A047"), emoji: "💚",
          keywords: ["Love", "Compassion", "Connection"],
          blockedSign: "Grief, inability to forgive, isolation, fear of love",
          overactiveSign: "People-pleasing, poor boundaries, losing yourself in love",
          healingPractice: "Forgiveness practice, gratitude, giving and receiving love freely",
          twinFlameConnection: "The epicenter of your twin flame connection. As your heart heals, your union becomes possible."),
    .init(id: 4, name: "Throat", sanskrit: "Vishuddha", location: "Throat",
          color: Color(hex: "1E88E5"), emoji: "💙",
          keywords: ["Truth", "Expression", "Communication"],
          blockedSign: "Inability to speak truth, fear of judgment, suppressing feelings",
          overactiveSign: "Talking over others, gossip, harsh words without compassion",
          healingPractice: "Sing, chant, speak your truth in small ways daily, use blue stones",
          twinFlameConnection: "Authenticity is key in twin flame union. What are you not saying to yourself — or your twin?"),
    .init(id: 5, name: "Third Eye", sanskrit: "Ajna", location: "Between eyebrows",
          color: Color(hex: "5E35B1"), emoji: "💜",
          keywords: ["Intuition", "Vision", "Clarity"],
          blockedSign: "Confusion, lack of intuition, overthinking, feeling disconnected",
          overactiveSign: "Fantasy over reality, obsession with the spiritual, ignoring physical needs",
          healingPractice: "Meditation, dream journaling, trust your inner knowing",
          twinFlameConnection: "Your twin flame telepathy lives here. Open this center to receive messages and guidance from your twin across any distance."),
    .init(id: 6, name: "Crown", sanskrit: "Sahasrara", location: "Top of head",
          color: Color(hex: "AB47BC"), emoji: "🪷",
          keywords: ["Divine Connection", "Surrender", "Oneness"],
          blockedSign: "Spiritual disconnection, cynicism, feeling alone in the universe",
          overactiveSign: "Spiritual bypass, avoiding real life, disconnection from body",
          healingPractice: "Prayer, silence, nature, meditation on divine love and surrender",
          twinFlameConnection: "Your connection to God and the higher plan for your union. When this opens, you trust the timing completely."),
]

// MARK: - View

struct ChakraCheckinView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ChakraEntry.date, order: .reverse) private var entries: [ChakraEntry]

    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false
    @State private var ratings: [Int] = Array(repeating: 3, count: 7)
    @State private var note = ""
    @State private var isSaved = false
    @State private var selectedChakra: Int? = nil
    @State private var showHealingPlan = false
    @State private var showPaywall = false

    private var todayEntry: ChakraEntry? {
        let cal = Calendar.current
        return entries.first { cal.isDateInToday($0.date) }
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Header
                    VStack(spacing: 6) {
                        Text("How are your energy centers?")
                            .font(AppFont.serifTitle(20))
                            .foregroundStyle(AppColors.cream)
                            .multilineTextAlignment(.center)
                        Text("Rate each chakra from 1 (blocked) to 5 (overactive). 3 is balanced.")
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                    // Chakra sliders
                    VStack(spacing: 12) {
                        ForEach(chakras) { chakra in
                            ChakraRow(
                                chakra: chakra,
                                rating: $ratings[chakra.id],
                                isSelected: selectedChakra == chakra.id,
                                onTap: {
                                    HapticManager.impact(.light)
                                    withAnimation(.spring(response: 0.4)) {
                                        selectedChakra = selectedChakra == chakra.id ? nil : chakra.id
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Detail panel for selected chakra
                    if let id = selectedChakra {
                        chakraDetailPanel(for: chakras[id], rating: ratings[id])
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // Note field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optional)")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender.opacity(0.7))
                        TextField("How are you feeling energetically today?", text: $note, axis: .vertical)
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.cream)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)

                    // Save button
                    Button {
                        saveCheckin()
                    } label: {
                        HStack {
                            Image(systemName: isSaved ? "checkmark.circle.fill" : "wand.and.stars")
                            Text(isSaved ? "Check-in Saved" : "Save Today's Check-in")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .warmButtonStyle()
                    .padding(.horizontal, 24)

                    // Healing Plan button (premium)
                    Button {
                        HapticManager.impact(.medium)
                        if StoreService.shared.isPremium {
                            showHealingPlan = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                            Text("Get Personalized Healing Plan")
                                .font(AppFont.body(15, weight: .semibold))
                        }
                        .foregroundStyle(AppColors.gold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.gold.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(AppColors.gold.opacity(0.35), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)

                    DisclaimerFooter()
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 32)
                }
            }
        }
        .navigationTitle("Chakra Check-in")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            loadTodayIfExists()
            if !disclaimerAcked { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) {
            WellnessDisclaimerSheet()
        }
        .sheet(isPresented: $showHealingPlan) {
            let chakraNames = ["Root", "Sacral", "Solar Plexus", "Heart", "Throat", "Third Eye", "Crown"]
            let summary = zip(chakraNames, ratings).map { "\($0): \($1)/5" }.joined(separator: "\n")
            SacredInsightSheet(
                type: .chakraHealing,
                content: "Chakra Check-in Results:\n\(summary)\n\nNotes: \(note)"
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: Detail Panel

    private func chakraDetailPanel(for chakra: Chakra, rating: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text(chakra.emoji)
                    .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text(chakra.name + " Chakra")
                        .font(AppFont.body(16, weight: .semibold))
                        .foregroundStyle(AppColors.cream)
                    Text(chakra.sanskrit + " · " + chakra.location)
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender)
                }
            }

            Divider().background(chakra.color.opacity(0.3))

            if rating < 3 {
                infoRow(icon: "exclamationmark.triangle.fill", label: "Signs of Blocking", text: chakra.blockedSign, color: Color(hex: "4A90D9"))
            } else if rating > 3 {
                infoRow(icon: "bolt.fill", label: "Signs of Overactivity", text: chakra.overactiveSign, color: Color(hex: "D97B4A"))
            } else {
                infoRow(icon: "checkmark.seal.fill", label: "Balanced", text: "Your \(chakra.name) chakra is flowing harmoniously.", color: Color(hex: "43A047"))
            }

            infoRow(icon: "leaf.fill", label: "Healing Practice", text: chakra.healingPractice, color: chakra.color)
            infoRow(icon: "flame.fill", label: "Twin Flame Wisdom", text: chakra.twinFlameConnection, color: AppColors.coral)
        }
        .padding(18)
        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(chakra.color.opacity(0.35), lineWidth: 1))
    }

    private func infoRow(icon: String, label: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
                .frame(width: 18)
                .padding(.top, 2)
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

    // MARK: Data

    private func loadTodayIfExists() {
        guard let entry = todayEntry else { return }
        ratings = [entry.root, entry.sacral, entry.solarPlexus,
                   entry.heart, entry.throat, entry.thirdEye, entry.crown]
        note = entry.note
        isSaved = true
    }

    private func saveCheckin() {
        HapticManager.impact(.medium)
        if let existing = todayEntry {
            existing.root = ratings[0]; existing.sacral = ratings[1]
            existing.solarPlexus = ratings[2]; existing.heart = ratings[3]
            existing.throat = ratings[4]; existing.thirdEye = ratings[5]
            existing.crown = ratings[6]; existing.note = note
        } else {
            let entry = ChakraEntry(
                root: ratings[0], sacral: ratings[1], solarPlexus: ratings[2],
                heart: ratings[3], throat: ratings[4], thirdEye: ratings[5],
                crown: ratings[6], note: note
            )
            context.insert(entry)
            GamificationService.shared.awardXP(amount: 25, source: "chakra", framework: .energyEnhancement, skillKey: "ee_constitution", detail: "Chakra check-in")
        }
        withAnimation { isSaved = true }
        HapticManager.notification(.success)
    }
}

// MARK: - Chakra Row

private struct ChakraRow: View {
    let chakra: Chakra
    @Binding var rating: Int
    let isSelected: Bool
    let onTap: () -> Void

    private var stateLabel: String {
        switch rating {
        case 1: return "Blocked"
        case 2: return "Low"
        case 3: return "Balanced"
        case 4: return "High"
        case 5: return "Overactive"
        default: return ""
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Text(chakra.emoji)
                        .font(.system(size: 22))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chakra.name)
                            .font(AppFont.body(15, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                        Text(chakra.keywords.joined(separator: " · "))
                            .font(AppFont.caption(11))
                            .foregroundStyle(AppColors.lavender)
                    }
                    Spacer()
                    Text(stateLabel)
                        .font(AppFont.caption(12, weight: .semibold))
                        .foregroundStyle(rating == 3 ? Color(hex: "43A047") : chakra.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background((rating == 3 ? Color(hex: "43A047") : chakra.color).opacity(0.15), in: Capsule())
                }

                // Rating dots
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { i in
                        Button {
                            HapticManager.selection()
                            withAnimation(.spring(response: 0.3)) { rating = i }
                        } label: {
                            Circle()
                                .fill(i <= rating ? chakra.color : AppColors.deepViolet)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle().strokeBorder(chakra.color.opacity(0.5), lineWidth: 1)
                                )
                                .overlay(
                                    Text("\(i)")
                                        .font(AppFont.caption(11, weight: .semibold))
                                        .foregroundStyle(i <= rating ? .white : AppColors.lavender.opacity(0.5))
                                )
                        }
                        .buttonStyle(.plain)
                        if i < 5 { Spacer() }
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(16)
            .background(
                isSelected ? chakra.color.opacity(0.1) : AppColors.deepViolet.opacity(0.6),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? chakra.color.opacity(0.5) : AppColors.purple.opacity(0.2),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
