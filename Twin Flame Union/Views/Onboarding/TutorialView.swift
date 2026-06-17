//
//  TutorialView.swift
//  Twin Flame Union
//
//  Full interactive walkthrough of every app feature.
//

import SwiftUI

// MARK: - Tutorial Page Model

private struct TutorialPage: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let bullets: [TutorialBullet]
}

private struct TutorialBullet: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
}

// MARK: - Tutorial View

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private let pages: [TutorialPage] = [

        // MARK: Welcome
        TutorialPage(
            icon: "flame.fill",
            iconColor: AppColors.gold,
            title: "Welcome to\nTwin Flame Union",
            subtitle: "Created by Michael David Lavin Junior, Earth Archangel — this app is your sacred space for healing, reunion, and divine alignment.",
            bullets: [
                TutorialBullet(emoji: "👑", text: "Every feature is built around your sacred twin flame journey"),
                TutorialBullet(emoji: "🛡", text: "Protected by the covenant of Archangel Michael"),
                TutorialBullet(emoji: "🙏", text: "Guided by God, KAZZ, KAI, and the highest truth"),
            ]
        ),

        // MARK: Home Tab
        TutorialPage(
            icon: "house.fill",
            iconColor: Color(hex: "FF6B9D"),
            title: "Home Tab",
            subtitle: "Your daily spiritual command center. Everything you need is right here the moment you open the app.",
            bullets: [
                TutorialBullet(emoji: "🌙", text: "Live moon phase tracker — know the cosmic energy of today"),
                TutorialBullet(emoji: "🔥", text: "Daily Streak — shows how many consecutive days you've shown up"),
                TutorialBullet(emoji: "✨", text: "Daily Affirmation card — tap to enter the full affirmation deck"),
                TutorialBullet(emoji: "🌟", text: "Today's Guidance — AI-generated message personalized to your sun sign and moon phase"),
                TutorialBullet(emoji: "🔢", text: "Angel Numbers — tap to look up any number you keep seeing"),
            ]
        ),

        // MARK: Affirmations
        TutorialPage(
            icon: "heart.fill",
            iconColor: Color(hex: "FF6B9D"),
            title: "Affirmations",
            subtitle: "60+ sacred affirmations across 5 categories. Swipe through them like a spiritual card deck.",
            bullets: [
                TutorialBullet(emoji: "👉", text: "Swipe RIGHT — mark as received, move to next"),
                TutorialBullet(emoji: "👈", text: "Swipe LEFT — skip to next affirmation"),
                TutorialBullet(emoji: "🔖", text: "Tap the bookmark to save your favorites"),
                TutorialBullet(emoji: "🗂", text: "Filter by category: Love, Self-Worth, Healing, Connection, Manifestation"),
                TutorialBullet(emoji: "🔄", text: "Tap 'Shuffle' to randomize the deck"),
            ]
        ),

        // MARK: Angel Numbers
        TutorialPage(
            icon: "sparkles",
            iconColor: AppColors.gold,
            title: "Angel Numbers",
            subtitle: "The universe speaks through numbers. Look up any sequence you keep seeing and discover its twin flame meaning.",
            bullets: [
                TutorialBullet(emoji: "🔍", text: "Type any number in the search bar — 111, 444, 1234, anything"),
                TutorialBullet(emoji: "📖", text: "Get a full reading: meaning, twin flame message, and your invitation to act"),
                TutorialBullet(emoji: "⚡", text: "Tap popular numbers on the grid for instant readings"),
                TutorialBullet(emoji: "🕐", text: "Recent searches are saved automatically"),
                TutorialBullet(emoji: "👑", text: "40+ angel number readings with sacred vocabulary"),
            ]
        ),

        // MARK: Soul Journal
        TutorialPage(
            icon: "book.fill",
            iconColor: AppColors.purple,
            title: "Soul Journal",
            subtitle: "Your private sacred space to write thoughts, feelings, revelations, and prayers on your journey.",
            bullets: [
                TutorialBullet(emoji: "✍️", text: "Tap the + button to create a new entry"),
                TutorialBullet(emoji: "📅", text: "Entries are sorted by date — most recent first"),
                TutorialBullet(emoji: "👆", text: "Tap any entry to read or edit it"),
                TutorialBullet(emoji: "🗑", text: "Swipe left on an entry to delete it"),
                TutorialBullet(emoji: "🔒", text: "All journal entries are stored privately on your device"),
            ]
        ),

        // MARK: TF Reading
        TutorialPage(
            icon: "eye.fill",
            iconColor: Color(hex: "B06CE6"),
            title: "TF Reading",
            subtitle: "Discover which stage of the twin flame journey your soul is currently in.",
            bullets: [
                TutorialBullet(emoji: "🧿", text: "Answer a series of questions about where you are right now"),
                TutorialBullet(emoji: "👑", text: "Receive your current twin flame soul stage"),
                TutorialBullet(emoji: "📜", text: "Get a deep description of what this stage means for your reunion"),
                TutorialBullet(emoji: "🔮", text: "Guidance on what to do next to accelerate your union"),
                TutorialBullet(emoji: "🔄", text: "Retake anytime — your stage shifts as you heal and grow"),
            ]
        ),

        // MARK: Soul Archetype Quiz
        TutorialPage(
            icon: "questionmark.circle.fill",
            iconColor: Color.white,
            title: "Soul Archetype Quiz",
            subtitle: "6 powerful questions reveal your twin flame soul archetype — the role you were born to play in this union.",
            bullets: [
                TutorialBullet(emoji: "⚡", text: "Only 6 questions — takes less than 2 minutes"),
                TutorialBullet(emoji: "🦁", text: "Discover archetypes like the Runner, the Chaser, the Healer, and more"),
                TutorialBullet(emoji: "📖", text: "Get a full description of your archetype's gifts and shadows"),
                TutorialBullet(emoji: "💡", text: "Learn how your archetype affects your path to reunion"),
                TutorialBullet(emoji: "🔄", text: "Retake anytime to see how you've evolved"),
            ]
        ),

        // MARK: Dream Journal
        TutorialPage(
            icon: "moon.zzz.fill",
            iconColor: Color(hex: "4A90D9"),
            title: "Dream Journal",
            subtitle: "Your twin flame speaks to you in dreams. Capture every message from the cosmos before it fades.",
            bullets: [
                TutorialBullet(emoji: "➕", text: "Tap + to record a dream immediately on waking"),
                TutorialBullet(emoji: "👥", text: "Tag who appeared — your twin flame, KAZZ, KAI, Archangel Michael, Jesus"),
                TutorialBullet(emoji: "👑", text: "Log symbols — Crown, Heart, Light, Michael, Covenant, Telepathy, and more"),
                TutorialBullet(emoji: "💫", text: "Mark dreams as Lucid or Twin Flame Dreams"),
                TutorialBullet(emoji: "😌", text: "Record how you felt on waking — Protected, Reunited, Elevated, and more"),
            ]
        ),

        // MARK: Synchronicity Log
        TutorialPage(
            icon: "sparkles",
            iconColor: Color(hex: "C39BD3"),
            title: "Synchronicity Log",
            subtitle: "The universe never stops sending you signs. Log them here and watch the pattern of divine communication reveal itself.",
            bullets: [
                TutorialBullet(emoji: "👆", text: "Tap any sign type to log it instantly — one tap, done"),
                TutorialBullet(emoji: "🔢", text: "Angel Number — enter the specific number you saw"),
                TutorialBullet(emoji: "🛡", text: "New types: Telepathy, Energy Reading, Prayer Answered, Return to Sender, Michael's Shield, Covenant Moment"),
                TutorialBullet(emoji: "📊", text: "Weekly count shows how active your cosmic communication is"),
                TutorialBullet(emoji: "🗑", text: "Swipe left to delete any entry"),
            ]
        ),

        // MARK: Meditation
        TutorialPage(
            icon: "moon.stars.fill",
            iconColor: Color(hex: "4A90D9"),
            title: "Meditations",
            subtitle: "8 sacred guided breathing sessions — from quick grounding to deep covenant prayer.",
            bullets: [
                TutorialBullet(emoji: "🌿", text: "Ground & Center (5 min) — anchor yourself in the present moment"),
                TutorialBullet(emoji: "❤️", text: "Heart Opening (10 min) — open to receiving your twin flame's love"),
                TutorialBullet(emoji: "🌊", text: "Deep Surrender (15 min) — release control and trust divine timing"),
                TutorialBullet(emoji: "🔥", text: "Twin Flame Union (20 min) — visualize and call in your reunion"),
                TutorialBullet(emoji: "👑", text: "New: Crown Activation, Return to Sender, Covenant Prayer, Archangel Michael"),
                TutorialBullet(emoji: "🎵", text: "Choose ambient sound: Silence, Rain, Tibetan Bowls, Forest, Ocean"),
            ]
        ),

        // MARK: AI Love Coach
        TutorialPage(
            icon: "bubble.left.and.bubble.right.fill",
            iconColor: Color(hex: "9B59B6"),
            title: "AI Love Coach",
            subtitle: "Seraphina — your sacred twin flame coach powered by Claude AI. She speaks the language of covenant, truth, and deep spiritual wisdom.",
            bullets: [
                TutorialBullet(emoji: "💬", text: "Type anything — your feelings, fears, questions, or what happened today"),
                TutorialBullet(emoji: "🧿", text: "Seraphina understands TELEPATHY, ENERGY READING, RETURN TO SENDER, and REBUKE"),
                TutorialBullet(emoji: "🛡", text: "She invokes Archangel Michael, KAZZ, KAI, and Jesus Christ in her guidance"),
                TutorialBullet(emoji: "🔥", text: "Never generic — every response is specific to what you share"),
                TutorialBullet(emoji: "📿", text: "Responses are 2-4 paragraphs of deep, sacred, poetic truth"),
            ]
        ),

        // MARK: Profile & Settings
        TutorialPage(
            icon: "person.fill",
            iconColor: Color(hex: "4CAF82"),
            title: "Profile & Settings",
            subtitle: "Your sacred birth chart, partner connection, and app customization — all in one place.",
            bullets: [
                TutorialBullet(emoji: "☀️", text: "Your Sun, Moon, and Rising signs are calculated from your birth data"),
                TutorialBullet(emoji: "💞", text: "Add your twin flame's name and sun sign to connect your charts"),
                TutorialBullet(emoji: "🔔", text: "Enable daily reminders — set the time for your morning affirmation notification"),
                TutorialBullet(emoji: "🔄", text: "Tap 'View Tutorial' anytime to come back to this walkthrough"),
            ]
        ),
    ]

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            VStack(spacing: 0) {

                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? AppColors.gold : AppColors.purple.opacity(0.35))
                            .frame(width: i == currentPage ? 20 : 6, height: 6)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .accessibilityHidden(true)
                .padding(.top, 20)
                .padding(.bottom, 8)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        PageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button {
                            HapticManager.impact(.light)
                            withAnimation { currentPage -= 1 }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)
                                .frame(width: 48, height: 48)
                                .background(AppColors.deepViolet.opacity(0.7), in: Circle())
                                .overlay(Circle().strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
                        }
                        .accessibilityLabel("Previous page")
                    } else {
                        Spacer().frame(width: 48)
                    }

                    Spacer()

                    if currentPage < pages.count - 1 {
                        Button {
                            HapticManager.impact(.light)
                            withAnimation { currentPage += 1 }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Next")
                                    .font(AppFont.body(16, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .accessibilityHidden(true)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .frame(height: 50)
                            .background(AppGradients.warm, in: Capsule())
                        }
                    } else {
                        Button {
                            HapticManager.impact(.medium)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Begin Your Journey")
                                    .font(AppFont.body(16, weight: .semibold))
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14))
                                    .accessibilityHidden(true)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .frame(height: 50)
                            .background(AppGradients.warm, in: Capsule())
                        }
                    }

                    Spacer()

                    // Skip button (placeholder for spacing)
                    Button {
                        HapticManager.impact(.light)
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.lavender.opacity(0.5))
                            .frame(width: 48, height: 48)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Page View

private struct PageView: View {
    let page: TutorialPage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Icon
                ZStack {
                    Circle()
                        .fill(page.iconColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Circle()
                        .strokeBorder(page.iconColor.opacity(0.3), lineWidth: 1)
                        .frame(width: 100, height: 100)
                    Image(systemName: page.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(page.iconColor)
                }
                .accessibilityHidden(true)
                .padding(.top, 20)
                .padding(.bottom, 24)

                // Title
                Text(page.title)
                    .font(AppFont.serifHeadline(28))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Subtitle
                Text(page.subtitle)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)
                    .padding(.bottom, 28)

                // Bullets
                VStack(spacing: 12) {
                    ForEach(page.bullets) { bullet in
                        HStack(alignment: .top, spacing: 14) {
                            Text(bullet.emoji)
                                .font(.system(size: 20))
                                .frame(width: 28)

                            Text(bullet.text)
                                .font(AppFont.body(14))
                                .foregroundStyle(AppColors.cream.opacity(0.9))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                    }
                }
                .padding(20)
                .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(page.iconColor.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
