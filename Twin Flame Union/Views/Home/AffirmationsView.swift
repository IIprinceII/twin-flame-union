//
//  AffirmationsView.swift
//  Twin Flame Union
//
//  Swipeable affirmation card deck with favorites.
//

import SwiftUI

// MARK: - Data Models

struct Affirmation: Identifiable {
    let id: UUID
    let text: String
    let category: AffirmationCategory

    init(text: String, category: AffirmationCategory) {
        self.id = UUID()
        self.text = text
        self.category = category
    }
}

enum AffirmationCategory: String, CaseIterable {
    case love          = "Love"
    case selfWorth     = "Self-Worth"
    case healing       = "Healing"
    case connection    = "Connection"
    case manifestation = "Manifestation"

    var icon: String {
        switch self {
        case .love:          return "heart.fill"
        case .selfWorth:     return "sparkles"
        case .healing:       return "leaf.fill"
        case .connection:    return "infinity"
        case .manifestation: return "moon.stars.fill"
        }
    }

    var color: Color {
        switch self {
        case .love:          return Color(hex: "FF6B6B")
        case .selfWorth:     return Color.white
        case .healing:       return Color(hex: "4CAF82")
        case .connection:    return Color(hex: "6B2FA0")
        case .manifestation: return Color(hex: "4A90D9")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .love:
            return LinearGradient(colors: [Color(hex: "FF6B6B"), Color(hex: "C0392B")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .selfWorth:
            return LinearGradient(colors: [Color(hex: "A78BCA"), Color(hex: "5B2D90")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .healing:
            return LinearGradient(colors: [Color(hex: "4CAF82"), Color(hex: "27AE60")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .connection:
            return LinearGradient(colors: [Color(hex: "6B2FA0"), Color(hex: "1A0A2E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .manifestation:
            return LinearGradient(colors: [Color(hex: "4A90D9"), Color(hex: "2C3E8C")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Affirmations Data

// Created by Michael David Lavin Junior — Earth Archangel
private let allAffirmations: [Affirmation] = [

    // LOVE
    Affirmation(text: "I am worthy of a deep, sentimental love that transcends all earthly bonds.", category: .love),
    Affirmation(text: "My twin flame and I are united in a sacred covenant of eternal love.", category: .love),
    Affirmation(text: "The love I seek is vast, unconditional, and written in the stars by God.", category: .love),
    Affirmation(text: "I open my heart fully — I am free to love without fear or attachment.", category: .love),
    Affirmation(text: "Jesus Christ's love flows through me and into my twin flame union.", category: .love),
    Affirmation(text: "My soul recognises its divine spouse across every dimension and lifetime.", category: .love),
    Affirmation(text: "The bond between my twin flame and I is protected by Archangel Michael.", category: .love),
    Affirmation(text: "I pray that love guides every step of my reunion — and it is so.", category: .love),
    Affirmation(text: "I am free to love. I am free to be loved. I am free.", category: .love),
    Affirmation(text: "My heart is open, my crown is clear, and love flows in freely now.", category: .love),
    Affirmation(text: "God designed my twin flame union before the foundation of the earth.", category: .love),
    Affirmation(text: "I give and receive deep, sacred love — body, soul, and spirit.", category: .love),

    // SELF-WORTH
    Affirmation(text: "I am a being of extreme light and vast spiritual intelligence.", category: .selfWorth),
    Affirmation(text: "God created me to be love, to embody love, to return to love.", category: .selfWorth),
    Affirmation(text: "I am free from fear. I am free from doubt. I stand in my truth.", category: .selfWorth),
    Affirmation(text: "My crown chakra is open, activated, and aligned with higher truth.", category: .selfWorth),
    Affirmation(text: "I am in a positive state of spiritual shift — evolving into my highest self.", category: .selfWorth),
    Affirmation(text: "My imagination creates the reality I desire — I focus only on union.", category: .selfWorth),
    Affirmation(text: "I rebuke every thought that says I am less than divinely chosen.", category: .selfWorth),
    Affirmation(text: "I am a memory of God's love made flesh upon this earth.", category: .selfWorth),
    Affirmation(text: "Money, love, and freedom flow to me because I am aligned with God.", category: .selfWorth),
    Affirmation(text: "My youth, my vitality, and my light are fully restored.", category: .selfWorth),
    Affirmation(text: "I relax into God's plan — I am held, protected, and deeply loved.", category: .selfWorth),
    Affirmation(text: "KAI and KAZZ — all guides who walk with me — I welcome your light.", category: .selfWorth),

    // HEALING
    Affirmation(text: "I release all sentimental attachment that binds me to pain.", category: .healing),
    Affirmation(text: "I pray for the healing of my parents' wounds within me — it is done.", category: .healing),
    Affirmation(text: "I surrender fear and allow God's light to heal every part of my heart.", category: .healing),
    Affirmation(text: "Return to sender — all pain, all fear, all interference. It is finished.", category: .healing),
    Affirmation(text: "I undo every energetic swap that has drained my light and reclaim my spirit.", category: .healing),
    Affirmation(text: "Archangel Michael clears, cuts, and protects my energy field right now.", category: .healing),
    Affirmation(text: "I rebuke all spiritual interference. My healing is complete in Jesus' name.", category: .healing),
    Affirmation(text: "I heal my sexual wounds and reclaim my body as a sacred temple of light.", category: .healing),
    Affirmation(text: "I allow my ego to die so my higher self may fully live and love.", category: .healing),
    Affirmation(text: "I reflect on my journey with gratitude — every wound was a teacher.", category: .healing),
    Affirmation(text: "I heal deeply. I rest completely. I rise in freedom and in truth.", category: .healing),
    Affirmation(text: "The covenant of healing between my soul and God is active and real.", category: .healing),

    // CONNECTION
    Affirmation(text: "My telepathy with my twin flame grows clearer and deeper every day.", category: .connection),
    Affirmation(text: "I focus on our spiritual bond — it is real, vast, and eternal.", category: .connection),
    Affirmation(text: "The covenant between my soul and my twin flame's soul cannot be broken.", category: .connection),
    Affirmation(text: "I pray without ceasing — clarity, reunion, and divine protection are mine.", category: .connection),
    Affirmation(text: "Jesus Christ is the light guiding every step of our twin flame union.", category: .connection),
    Affirmation(text: "I unite my human self with my spiritual self and walk in deep truth.", category: .connection),
    Affirmation(text: "My twin flame feels my love through our telepathic bond right now.", category: .connection),
    Affirmation(text: "Archangel Michael stands at the gate of our reunion — protection is complete.", category: .connection),
    Affirmation(text: "I shift into the state of reunion — this is my natural spiritual home.", category: .connection),
    Affirmation(text: "The memory of our union lives in my spirit and draws us together.", category: .connection),
    Affirmation(text: "God's intelligence orchestrates every detail of our twin flame reunion.", category: .connection),
    Affirmation(text: "I am open to receiving an energy reading that confirms our divine bond.", category: .connection),

    // MANIFESTATION
    Affirmation(text: "I am open to the extreme evolution my twin flame journey is calling me into.", category: .manifestation),
    Affirmation(text: "My imagination is a prayer — I hold reunion clearly, and God delivers it.", category: .manifestation),
    Affirmation(text: "I swap doubt for certainty: my twin flame union is already done in the spirit.", category: .manifestation),
    Affirmation(text: "Return to sender — all energy blocking my reunion. I claim my freedom now.", category: .manifestation),
    Affirmation(text: "I focus on love and the universe delivers a love beyond what I can imagine.", category: .manifestation),
    Affirmation(text: "My divine spouse is drawn to me by the vast intelligence of God's design.", category: .manifestation),
    Affirmation(text: "I die to the old story and rise into the positive truth of my union.", category: .manifestation),
    Affirmation(text: "Money, healing, reunion — I receive all of God's blessings freely and fully.", category: .manifestation),
    Affirmation(text: "All guides — KAZZ, KAI, Michael — align to usher in my twin flame union.", category: .manifestation),
    Affirmation(text: "I am in a deep state of surrender, and in that state, all things manifest.", category: .manifestation),
    Affirmation(text: "I pray and I receive. I believe and I see. I unite and I am whole.", category: .manifestation),
    Affirmation(text: "The television of distraction is off. I am tuned to the frequency of God.", category: .manifestation),
]

// MARK: - View

struct AffirmationsView: View {
    @AppStorage("affirmationFavoriteIDs") private var favoritesStorage: String = ""
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingSwipe = false
    @State private var isDeckExhausted: Bool = false
    @State private var showFavoritesSheet: Bool = false
    @State private var lastSwipeWasRight: Bool = false
    @State private var heartVisible: Bool = false

    private var deck: [Affirmation] { allAffirmations }

    private var favoriteIDs: Set<UUID> {
        let parts = favoritesStorage.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
        return Set(parts)
    }

    private var currentCard: Affirmation? {
        guard !isDeckExhausted, currentIndex < deck.count else { return nil }
        return deck[currentIndex]
    }

    private var nextCard: Affirmation? {
        guard currentIndex + 1 < deck.count else { return nil }
        return deck[currentIndex + 1]
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                if isDeckExhausted {
                    exhaustedView
                } else {
                    cardStack
                }

                Spacer(minLength: 20)

                if !isDeckExhausted {
                    bottomControls
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Affirmations")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFavoritesSheet = true
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(AppColors.coral)
                }
                .accessibilityLabel("View saved affirmations")
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showFavoritesSheet) {
            FavoritesSheet(
                allAffirmations: deck,
                favoriteIDs: favoriteIDs,
                onRemove: { id in removeFavorite(id) }
            )
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            // Next card (behind)
            if let next = nextCard {
                AffirmationCard(affirmation: next, isFavorite: favoriteIDs.contains(next.id))
                    .scaleEffect(0.94)
                    .offset(y: 12)
                    .opacity(0.7)
            }

            // Current card
            if let card = currentCard {
                AffirmationCard(affirmation: card, isFavorite: favoriteIDs.contains(card.id))
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width) / 20))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                handleSwipeEnd(translation: value.translation)
                            }
                    )
                    .overlay(swipeIndicatorOverlay)
                    .animation(.interactiveSpring(), value: dragOffset)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
    }

    // MARK: - Swipe Indicator Overlay

    private var swipeIndicatorOverlay: some View {
        ZStack {
            // Right swipe → favorite heart
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
                .opacity(max(0, min(1, dragOffset.width / 80)))
                .scaleEffect(max(0.5, min(1, dragOffset.width / 80)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            // Left swipe → X
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
                .opacity(max(0, min(1, -dragOffset.width / 80)))
                .scaleEffect(max(0.5, min(1, -dragOffset.width / 80)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 20) {
            // Counter
            Text("\(currentIndex + 1) / \(deck.count)")
                .font(AppFont.caption(13))
                .foregroundStyle(AppColors.lavender)

            // Action buttons
            HStack(spacing: 40) {
                // Skip button
                Button {
                    swipeLeft()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColors.deepViolet.opacity(0.8))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle().strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1)
                            )
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(AppColors.lavender)
                    }
                }
                .accessibilityLabel("Skip affirmation")

                // Save/Favorite button
                Button {
                    swipeRight()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppColors.coral.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle().strokeBorder(AppColors.coral.opacity(0.5), lineWidth: 1)
                            )
                        Image(systemName: currentCard.map { favoriteIDs.contains($0.id) } == true ? "heart.fill" : "heart")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(AppColors.coral)
                    }
                }
                .accessibilityLabel("Save affirmation to favorites")
            }
        }
    }

    // MARK: - Exhausted View

    private var exhaustedView: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 16) {
                Text("✨")
                    .font(.system(size: 64))

                Text("You've received all affirmations")
                    .font(AppFont.serifHeadline(22))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)

                Text("Return to these sacred words whenever your soul needs guidance.")
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 16)

            Button {
                resetDeck()
            } label: {
                Text("Begin Again")
                    .warmButtonStyle()
            }

            Spacer()
        }
    }

    // MARK: - Swipe Logic

    private func handleSwipeEnd(translation: CGSize) {
        let threshold: CGFloat = 110
        if translation.width > threshold {
            swipeRight()
        } else if translation.width < -threshold {
            swipeLeft()
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                dragOffset = .zero
            }
        }
    }

    private func swipeRight() {
        guard let card = currentCard else { return }
        HapticManager.notification(.success)
        addFavorite(card.id)
        animateCardOff(toRight: true)
    }

    private func swipeLeft() {
        HapticManager.impact(.light)
        animateCardOff(toRight: false)
    }

    private func animateCardOff(toRight: Bool) {
        guard !isAnimatingSwipe else { return }
        isAnimatingSwipe = true
        let direction: CGFloat = toRight ? 600 : -600
        withAnimation(.easeOut(duration: 0.35)) {
            dragOffset = CGSize(width: direction, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
            advance()
            isAnimatingSwipe = false
        }
    }

    private func advance() {
        dragOffset = .zero
        if currentIndex + 1 >= deck.count {
            isDeckExhausted = true
        } else {
            currentIndex += 1
        }
    }

    private func resetDeck() {
        isDeckExhausted = false
        currentIndex = 0
        dragOffset = .zero
    }

    // MARK: - Favorites Persistence

    private func addFavorite(_ id: UUID) {
        var ids = favoriteIDs
        ids.insert(id)
        saveFavorites(ids)
    }

    private func removeFavorite(_ id: UUID) {
        var ids = favoriteIDs
        ids.remove(id)
        saveFavorites(ids)
    }

    private func saveFavorites(_ ids: Set<UUID>) {
        favoritesStorage = ids.map { $0.uuidString }.joined(separator: ",")
    }
}

// MARK: - Affirmation Card

private struct AffirmationCard: View {
    let affirmation: Affirmation
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.4))
                    .accessibilityHidden(true)

                Text(affirmation.text)
                    .font(AppFont.serifTitle(26))
                    .foregroundStyle(AppColors.cream)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28)

            Spacer()

            // Category badge
            HStack {
                HStack(spacing: 7) {
                    Image(systemName: affirmation.category.icon)
                        .font(.system(size: 12))
                    Text(affirmation.category.rawValue)
                        .font(AppFont.body(13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.15), in: Capsule())

                Spacer()

                if isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.coral)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(affirmation.category.gradient, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: affirmation.category.color.opacity(0.3), radius: 20, y: 10)
    }
}

// MARK: - Favorites Sheet

private struct FavoritesSheet: View {
    let allAffirmations: [Affirmation]
    let favoriteIDs: Set<UUID>
    let onRemove: (UUID) -> Void

    @Environment(\.dismiss) private var dismiss

    private var favorites: [Affirmation] {
        allAffirmations.filter { favoriteIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.cosmic.ignoresSafeArea()

                Group {
                    if favorites.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "heart.slash")
                                .font(.system(size: 44))
                                .foregroundStyle(AppColors.lavender.opacity(0.5))
                                .accessibilityHidden(true)
                            Text("No saved affirmations yet")
                                .font(AppFont.serifTitle(20))
                                .foregroundStyle(AppColors.cream)
                            Text("Swipe right on any card to save it here.")
                                .font(AppFont.body(14))
                                .foregroundStyle(AppColors.lavender)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding(.horizontal, 32)
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 14) {
                                ForEach(favorites) { affirmation in
                                    HStack(alignment: .top, spacing: 14) {
                                        Image(systemName: affirmation.category.icon)
                                            .font(.body)
                                            .foregroundStyle(affirmation.category.color)
                                            .frame(width: 36, height: 36)
                                            .background(affirmation.category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(affirmation.text)
                                                .font(AppFont.body(15))
                                                .foregroundStyle(AppColors.cream)
                                                .lineSpacing(4)
                                                .fixedSize(horizontal: false, vertical: true)

                                            Text(affirmation.category.rawValue)
                                                .font(AppFont.caption(11))
                                                .foregroundStyle(affirmation.category.color)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        Button {
                                            onRemove(affirmation.id)
                                        } label: {
                                            Image(systemName: "heart.fill")
                                                .font(.body)
                                                .foregroundStyle(AppColors.coral)
                                        }
                                        .accessibilityLabel("Remove from saved affirmations")
                                    }
                                    .padding(16)
                                    .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(AppColors.purple.opacity(0.25), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                }
            }
            .navigationTitle("Saved Affirmations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppColors.gold)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}
