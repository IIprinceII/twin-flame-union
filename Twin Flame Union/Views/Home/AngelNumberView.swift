//
//  AngelNumberView.swift
//  Twin Flame Union
//
//  Angel number lookup with twin flame–specific readings.
//

import SwiftUI

// MARK: - Data Model

struct AngelReading {
    let number: String
    let title: String
    let meaning: String
    let twinFlameMessage: String
    let action: String
    let color: Color
    let icon: String
}

// MARK: - Reading Library

private let angelReadings: [String: AngelReading] = [

    "000": AngelReading(
        number: "000",
        title: "The Divine Void",
        meaning: "You are standing at the threshold of infinite potential. The universe is resetting — clearing space for a new cycle to begin on your twin flame path.",
        twinFlameMessage: "This number appears when your connection is being cleansed of all karmic residue. The separation you feel is not an ending — it is the universe preparing a blank canvas on which your union will be painted anew.",
        action: "Sit in stillness today. Release any expectation of how reunion should look. The void is not empty — it is full of possibility.",
        color: Color(hex: "8B7EC8"),
        icon: "circle.dotted"
    ),

    "111": AngelReading(
        number: "111",
        title: "The Manifestation Portal",
        meaning: "Your thoughts are manifesting at extraordinary speed right now. Every belief, fear, and vision you hold is being amplified and drawn into physical reality.",
        twinFlameMessage: "111 is one of the most powerful twin flame signs. When you see this number, your twin is likely thinking of you at exactly that moment. Your energies are merging in the unseen realm, and the universe is broadcasting this alignment back to you.",
        action: "Write down exactly what you want your twin flame connection to feel like — not what you fear, but what you desire. You are co-creating with the universe right now.",
        color: Color.white,
        icon: "sparkles"
    ),

    "1111": AngelReading(
        number: "1111",
        title: "The Twin Flame Gateway",
        meaning: "This is the most recognised twin flame number in existence. Four ones forming a perfect mirror — just as twin flames are mirrors of each other's souls.",
        twinFlameMessage: "Seeing 1111 is a direct signal from the universe that your twin flame connection is divinely guided and cosmically protected. If you are in separation, this is confirmation that reunion is not just possible — it is written. Your higher selves are communicating right now.",
        action: "Make a wish, set an intention, or simply close your eyes and feel the love you hold for your twin flame without attachment to outcome. This is your activation moment.",
        color: Color.white,
        icon: "flame.fill"
    ),

    "222": AngelReading(
        number: "222",
        title: "Divine Timing & Trust",
        meaning: "Balance, harmony, and faith are the themes here. The universe is asking you to trust that everything is unfolding in perfect divine order, even when you cannot see the full picture.",
        twinFlameMessage: "222 appears when twin flames need to hear: be patient. The work being done in the unseen realm right now is profound. Both of you are being prepared — individually — for the love you will share together. Rushing this process would be like picking fruit before it is ripe.",
        action: "Surrender the urge to control timing or outcomes. Write a letter to your twin flame that you never send — pour out everything you feel. Then release it.",
        color: Color(hex: "4A90D9"),
        icon: "infinity"
    ),

    "333": AngelReading(
        number: "333",
        title: "Ascended Masters Surround You",
        meaning: "The Ascended Masters — those who have mastered love and transcended earthly limitations — are walking beside you. You are not alone in this journey.",
        twinFlameMessage: "333 carries the energy of divine support and creative expansion on your twin flame path. Your connection is being blessed and guided by higher forces. Any stagnation you have felt is about to shift — the masters are clearing your path.",
        action: "Pray, meditate, or speak out loud to your guides today. Ask specifically for clarity on your next step. The answer will come within 72 hours — watch for signs.",
        color: Color(hex: "4CAF82"),
        icon: "triangle.fill"
    ),

    "444": AngelReading(
        number: "444",
        title: "You Are Divinely Protected",
        meaning: "Your angels are surrounding you with an invisible fortress of love and protection. Whatever storm you are moving through, you are held.",
        twinFlameMessage: "444 in the twin flame journey signifies that your angels are actively working to remove obstacles between you and your twin. Agreements are being made in the spiritual realm. The foundation for your reunion is being laid, brick by brick, in the unseen world.",
        action: "Make a list of everything you are releasing: fear of abandonment, unworthiness, past heartbreak. Then burn it, delete it, or tear it up. The angels will transmute it.",
        color: Color(hex: "C0A060"),
        icon: "shield.fill"
    ),

    "555": AngelReading(
        number: "555",
        title: "Radical Transformation",
        meaning: "A massive change is coming — or is already underway. This transformation is divinely orchestrated, even if it feels chaotic or frightening from the surface.",
        twinFlameMessage: "555 on the twin flame path often signals an imminent shift in the dynamic between you and your twin. This might be a sudden contact after silence, a change in their circumstances that removes a barrier, or a breakthrough in your own healing that changes everything. Prepare for movement.",
        action: "Embrace the unknown rather than fearing it. Ask yourself: if everything changed tomorrow, what would I be most grateful for? Live from that gratitude today.",
        color: Color(hex: "FF6B9D"),
        icon: "wand.and.stars"
    ),

    "666": AngelReading(
        number: "666",
        title: "Rebalance Your Thoughts",
        meaning: "Your thoughts have drifted into fear, obsession, or a lack mindset. The universe is gently tapping your shoulder and asking you to refocus.",
        twinFlameMessage: "On the twin flame path, 666 appears when you have become too fixated on your twin — checking their social media, overanalysing every interaction, living in a future that hasn't arrived yet. Your power lies in the present. Return to yourself.",
        action: "Do one thing today that has nothing to do with your twin flame. Nourish a different part of your soul — a hobby, time in nature, or a meaningful conversation with a friend.",
        color: Color(hex: "9B59B6"),
        icon: "arrow.triangle.2.circlepath"
    ),

    "777": AngelReading(
        number: "777",
        title: "Spiritual Fortune",
        meaning: "You are in profound alignment with the universe. Every step of your spiritual journey has been leading to this moment of divine grace and expanded awareness.",
        twinFlameMessage: "777 is a sign that your twin flame journey is moving precisely as planned by your higher selves. The spiritual gifts you have developed through this journey — empathy, intuition, unconditional love — are exactly what your soul came here to cultivate. You are winning, even when it doesn't look like it.",
        action: "Acknowledge your spiritual growth today. Write down 7 ways this journey has made you more whole, more loving, or more yourself. This is the real victory.",
        color: Color(hex: "6B9DFF"),
        icon: "star.fill"
    ),

    "888": AngelReading(
        number: "888",
        title: "Infinite Abundance",
        meaning: "The symbol of infinity turned upright. Cycles are completing, karma is clearing, and abundance — in love, in energy, in opportunity — is flowing toward you.",
        twinFlameMessage: "888 in the twin flame journey indicates karmic completion. Patterns that have kept you and your twin in cycles of push and pull are finally resolving. What is ending now needed to end for years. What is beginning now is rooted in truth rather than karma.",
        action: "Review where you have been giving without receiving on this journey. Practice receiving today — let someone care for you, accept a compliment without deflecting, or simply rest without guilt.",
        color: Color(hex: "50C878"),
        icon: "seal.fill"
    ),

    "999": AngelReading(
        number: "999",
        title: "Sacred Completion",
        meaning: "A major chapter of your life is reaching its conclusion. This is not a loss — it is a graduation. You have completed what you came to complete.",
        twinFlameMessage: "999 is the most profound number you can receive in the twin flame journey. It signals the completion of a karmic cycle between you and your twin. The version of your connection built on wounds, patterns, and unhealed pain is ending. What replaces it will be built on wholeness.",
        action: "Write a farewell letter to the old version of your twin flame connection — the painful, the fearful, the desperate part. Thank it for the lessons. Then close that chapter.",
        color: Color(hex: "FF4757"),
        icon: "checkmark.seal.fill"
    ),

    "1010": AngelReading(
        number: "1010",
        title: "Awakening & New Cycles",
        meaning: "You are waking up to a higher version of reality. The zeros amplify the ones — infinite potential meeting new beginnings in a continuous spiral of growth.",
        twinFlameMessage: "1010 appears at pivot points in the twin flame journey — moments where you are being called to step into a higher version of yourself before reunion becomes possible. Your twin is also at a pivot point. You are both levelling up, separately but simultaneously.",
        action: "Start something new today that reflects who you are becoming, not who you have been. Even a small action — a new habit, a new intention — sends a powerful signal to the universe.",
        color: Color(hex: "FF8C42"),
        icon: "arrow.up.circle.fill"
    ),

    "1212": AngelReading(
        number: "1212",
        title: "Stay the Course",
        meaning: "You are exactly where you are meant to be. The universe is asking you to maintain your vision, your faith, and your positive outlook — especially now, when doubt may be creeping in.",
        twinFlameMessage: "1212 is a direct message from your guides: do not give up on this connection. What looks like stagnation from the outside is profound movement on the inside. Your twin is changing. You are changing. Keep holding the vision of love.",
        action: "Visualise your ideal twin flame reunion for 12 minutes today. Use all your senses. Feel the warmth, see their face, hear their voice. The subconscious mind does not distinguish this from reality.",
        color: Color(hex: "EC407A"),
        icon: "heart.circle.fill"
    ),

    "1234": AngelReading(
        number: "1234",
        title: "Step by Step Progress",
        meaning: "You are moving forward in perfect sequence. Every step you take right now — however small — is part of a divine staircase leading you exactly where you need to go.",
        twinFlameMessage: "1234 reassures you that your twin flame journey is progressing, even when the steps feel small or slow. You are not behind. You are not failing. Each numbered step has a purpose, and you are exactly on step where you need to be.",
        action: "Identify the one next step in your healing or self-love journey. Not the whole staircase — just the next step. Take it today.",
        color: Color(hex: "26C6DA"),
        icon: "arrow.right.circle.fill"
    ),

    "1414": AngelReading(
        number: "1414",
        title: "Build Your Foundation",
        meaning: "The angels are asking you to invest in the structures that will support your dreams. Stability, discipline, and focused effort are your magic tools right now.",
        twinFlameMessage: "1414 in the twin flame journey calls you to build yourself into the person capable of holding a sacred union. This is not criticism — it is an invitation. The love you seek requires a foundation within you that is strong enough to hold it.",
        action: "Identify one area of your life — health, finances, creativity, community — that needs more tending. Give it intentional energy this week.",
        color: Color(hex: "FFA726"),
        icon: "building.2.fill"
    ),

    "1515": AngelReading(
        number: "1515",
        title: "Positive Change Incoming",
        meaning: "The universe is rearranging circumstances in your favour. What looks like disruption is actually divine re-alignment. Your prayers are being answered in unexpected ways.",
        twinFlameMessage: "1515 signals that a significant change in your twin flame situation is imminent. This could be an unexpected message, a shift in their mindset, a change in their circumstances, or a breakthrough in your own healing. Stay open — it may not arrive in the form you expect.",
        action: "Let go of your attachment to how change should look. Make space in your life — clear your home, your phone, your schedule — for something new to arrive.",
        color: Color(hex: "AB47BC"),
        icon: "wind"
    ),

    "1717": AngelReading(
        number: "1717",
        title: "Inner Wisdom & Good Fortune",
        meaning: "Your intuition is your greatest asset right now. Trust the quiet knowing inside you over the noise of the outside world. You already know what you need to know.",
        twinFlameMessage: "1717 appears when twin flames are being called to trust their inner guidance above all else — above the advice of others, above logic, above fear. Something inside you knows the truth of this connection. That something is your soul, and it is never wrong.",
        action: "Spend 17 minutes in complete silence today. No phone, no music, no distraction. Just listen to what arises from within you.",
        color: Color(hex: "5C6BC0"),
        icon: "eye.fill"
    ),

    "2121": AngelReading(
        number: "2121",
        title: "Balance in Union",
        meaning: "The dance between giving and receiving, masculine and feminine, action and rest, is finding its natural rhythm. You are learning the art of sacred balance.",
        twinFlameMessage: "2121 speaks to the divine masculine and divine feminine energies within the twin flame connection. Both energies are learning to flow in harmony — both within each person and between the two of you. The friction you have experienced is two magnets learning how to align.",
        action: "Notice where you are out of balance today — are you giving too much or too little? Are you too active or too passive? Make one small adjustment toward centre.",
        color: Color(hex: "42A5F5"),
        icon: "scalemass.fill"
    ),

    "2222": AngelReading(
        number: "2222",
        title: "Deep Alignment",
        meaning: "Four twos in a row is an extremely powerful amplification of patience, trust, and divine partnership. The universe is fully behind this connection.",
        twinFlameMessage: "2222 is one of the strongest confirmation numbers a twin flame can receive. It appears when the universe wants you to know beyond any doubt: this connection is real, it is divinely guided, and it will reach its highest potential. Hold steady. Hold the faith.",
        action: "Write out your most honest vision for this twin flame relationship — not what you fear, and not a fantasy. What does a healed, whole, loving union actually look like in daily life?",
        color: Color(hex: "1E88E5"),
        icon: "heart.fill"
    ),

    "3333": AngelReading(
        number: "3333",
        title: "Creative Power Unleashed",
        meaning: "Your creative energy and your spiritual energy are one and the same right now. Express what lives inside you — through art, writing, music, movement, or words.",
        twinFlameMessage: "3333 often appears for twin flames who are holding back their authentic expression out of fear of being too much, too weird, or too intense. Your twin flame is specifically attracted to the full, unfiltered version of you — not the dimmed-down version. Let yourself be seen.",
        action: "Create something today with no agenda and no audience. Make it only for yourself. This act of self-expression is a form of self-love.",
        color: Color(hex: "26A69A"),
        icon: "paintbrush.fill"
    ),

    "4444": AngelReading(
        number: "4444",
        title: "Heaven's Army With You",
        meaning: "An extraordinary level of angelic support surrounds you. Whatever you are going through right now, you have an entire spiritual army fighting alongside you.",
        twinFlameMessage: "4444 appears in the darkest moments of the twin flame journey to remind you that you are never fighting this battle alone. The angels have not forgotten you. Your twin flame's angels and your angels are working together in the spiritual realm to facilitate healing, growth, and ultimately — union.",
        action: "Ask for help today. From your angels, from the universe, from a trusted friend. Receiving support is not weakness — it is wisdom.",
        color: Color(hex: "FF7043"),
        icon: "shield.lefthalf.filled"
    ),

    "5555": AngelReading(
        number: "5555",
        title: "The Great Shift",
        meaning: "This is one of the most powerful transformation sequences available. Everything in your life is being recalibrated to match your highest vibrational potential.",
        twinFlameMessage: "5555 is a wake-up call of the highest order on the twin flame journey. The universe is saying: the old version of this connection — and the old version of you — can no longer be sustained. The transformation happening now, however disorienting, is elevation. You are becoming who you were always meant to be.",
        action: "Identify the single biggest fear holding you back in this connection. Write it down. Then write: 'Even this fear is a portal to my freedom.' Feel what shifts.",
        color: Color(hex: "E91E63"),
        icon: "bolt.fill"
    ),

    "711": AngelReading(
        number: "711",
        title: "Spiritual Luck",
        meaning: "You are in a window of remarkable spiritual fortune. Your manifestations are accelerating, your intuition is sharp, and the universe is sending you green lights.",
        twinFlameMessage: "711 in the twin flame journey signals that luck and timing are working in your favour right now. An opportunity related to your connection — a chance meeting, a conversation, a moment of synchronicity — may be imminent. Stay present and alert.",
        action: "Act on one inspired impulse today — reach out to someone, visit a place, say yes to something you would normally hesitate on. This is your lucky window.",
        color: Color(hex: "FFD54F"),
        icon: "star.circle.fill"
    ),

    "818": AngelReading(
        number: "818",
        title: "Abundance After Release",
        meaning: "A cycle of lack — emotional, financial, or energetic — is ending. Abundance is flowing in behind it. But first, you must fully release what is leaving.",
        twinFlameMessage: "818 asks twin flames to examine where they have been operating from a scarcity mindset within their connection: fear that love is limited, fear that their twin will choose someone else, fear that they are not enough. These fears are the only true barrier. Release them, and watch the abundance of this love pour in.",
        action: "Identify one scarcity belief about love or your twin flame connection. Consciously replace it with its abundant counterpart. Repeat the replacement belief 8 times out loud.",
        color: Color(hex: "66BB6A"),
        icon: "leaf.circle.fill"
    ),

    "919": AngelReading(
        number: "919",
        title: "The Lightworker's Call",
        meaning: "You came to this planet with a sacred mission. Your twin flame journey is not separate from that mission — it is the centre of it. Your union serves a purpose beyond the two of you.",
        twinFlameMessage: "919 appears for twin flames who are lightworkers — souls who agreed before birth to hold love's frequency for others. Your connection with your twin, even in its most painful chapters, has been teaching you the depths of unconditional love. That love is meant to radiate outward. You are ready.",
        action: "Ask yourself: beyond my own happiness, what could my twin flame union contribute to the world? Let that vision expand your motivation from personal to cosmic.",
        color: Color(hex: "7E57C2"),
        icon: "rays"
    ),

    "1144": AngelReading(
        number: "1144",
        title: "Take Inspired Action",
        meaning: "Faith without action is just wishful thinking. The universe has been preparing you — now it is asking you to move. Take the step you have been hesitating on.",
        twinFlameMessage: "1144 appears when a twin flame has been waiting, praying, and hoping — but has not yet taken the action their soul is calling them toward. This might be reaching out, it might be walking away to heal, it might be finally beginning the inner work you have been postponing. The angels are saying: now. Move now.",
        action: "Name the action you have been avoiding. Set a time within the next 24 hours to take it. Tell someone you trust so you are held accountable.",
        color: Color(hex: "FF8F00"),
        icon: "figure.walk"
    ),

    "1155": AngelReading(
        number: "1155",
        title: "New Freedom",
        meaning: "Restrictions — self-imposed or circumstantial — are dissolving. A new sense of freedom, possibility, and expansiveness is becoming available to you.",
        twinFlameMessage: "1155 often signals the end of a particularly confining period in the twin flame journey — whether that was emotional restriction, distance, circumstance, or inner limitation. Something is about to open. Prepare to breathe more freely.",
        action: "Do one thing today that you have been telling yourself you cannot do. Start small — the point is to feel the sensation of your own freedom.",
        color: Color(hex: "26C6DA"),
        icon: "wind"
    ),

    "2244": AngelReading(
        number: "2244",
        title: "Angelic Foundation",
        meaning: "You are being supported at a foundational level by both your guides and the universe's natural order. What you are building right now will last.",
        twinFlameMessage: "2244 is a deeply reassuring number on the twin flame journey. It confirms that your connection has a solid spiritual foundation — that beneath the confusion, the silence, the push and pull, there is something unshakeable between you. This love is not going anywhere.",
        action: "List 5 things about your twin flame connection that feel genuinely, undeniably real to you — not the fears, but the truths. Read them aloud to yourself.",
        color: Color(hex: "78909C"),
        icon: "building.columns.fill"
    ),

    "3434": AngelReading(
        number: "3434",
        title: "Creative Discipline",
        meaning: "Your gifts are asking to be structured. Creativity without container scatters; creativity with container builds. The universe is asking you to commit to your gifts.",
        twinFlameMessage: "3434 for twin flames points to a need to channel the intense energy of this connection into something creative and purposeful. The longing, the love, the grief — all of it is fuel. What will you build with it?",
        action: "Begin a creative project today that is inspired by your twin flame journey — writing, art, music, or any form of expression. This is alchemy.",
        color: Color(hex: "8D6E63"),
        icon: "paintpalette.fill"
    ),

    "7777": AngelReading(
        number: "7777",
        title: "Miraculous Alignment",
        meaning: "You have reached a rare state of complete spiritual alignment. Every layer of your being — mental, emotional, physical, spiritual — is vibrating in harmony.",
        twinFlameMessage: "7777 is the most spiritually elevated number sequence you can receive on the twin flame journey. It signals that you have done extraordinary inner work and that the universe is preparing to reward that work with a breakthrough of equal magnitude. A miracle — however you personally define one — is near.",
        action: "Celebrate yourself today. Not for what you have achieved, but for who you have become. This journey has forged you into something beautiful.",
        color: Color(hex: "5C6BC0"),
        icon: "crown.fill"
    ),

    "9999": AngelReading(
        number: "9999",
        title: "The Grand Completion",
        meaning: "The most profound completion available. An entire era of your life is ending — not just a chapter, but a volume. And the next volume begins with you being unrecognisably, magnificently free.",
        twinFlameMessage: "9999 is the rarest and most powerful completion number. When it appears on your twin flame journey, it signals the end of the entire karmic contract that brought you and your twin together. What follows this completion is union built on absolute freedom, mutual wholeness, and conscious choice. The old story is over. A new one begins.",
        action: "Write the last entry of your old twin flame story — the fears, the pain, the patterns. Then begin a new page and write the first sentence of the story of who you are now.",
        color: Color(hex: "C62828"),
        icon: "checkmark.circle.fill"
    ),
]

// MARK: - View Model

@Observable
@MainActor
final class AngelNumberViewModel {

    var inputNumber    = ""
    var currentReading : AngelReading?
    var showNoResult   = false
    var recentSearches : [String] = []

    private let recentsKey = "angelNumberRecents"

    init() {
        recentSearches = (UserDefaults.standard.stringArray(forKey: recentsKey) ?? [])
    }

    func lookup() {
        let cleaned = inputNumber.trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty else { return }

        if let reading = angelReadings[cleaned] {
            currentReading = reading
            showNoResult   = false
            addRecent(cleaned)
            HapticManager.notification(.success)
        } else {
            currentReading = nil
            showNoResult   = true
            HapticManager.notification(.warning)
        }
    }

    func select(_ number: String) {
        inputNumber    = number
        currentReading = angelReadings[number]
        showNoResult   = false
        if currentReading != nil { addRecent(number) }
    }

    func clear() {
        inputNumber    = ""
        currentReading = nil
        showNoResult   = false
    }

    private func addRecent(_ number: String) {
        var updated = recentSearches.filter { $0 != number }
        updated.insert(number, at: 0)
        recentSearches = Array(updated.prefix(8))
        UserDefaults.standard.set(recentSearches, forKey: recentsKey)
    }
}

// MARK: - Angel Number View

struct AngelNumberView: View {
    @State private var viewModel = AngelNumberViewModel()
    @FocusState private var fieldFocused: Bool

    // Popular numbers shown when nothing is searched yet
    private let popular = ["111","222","333","444","555","777","888","999","1111","1212","1234"]

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: Search Bar
                    HStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 15))
                                .foregroundStyle(AppColors.gold)

                            TextField("Enter a number (e.g. 444)", text: $viewModel.inputNumber)
                                .font(AppFont.body(17))
                                .foregroundStyle(AppColors.cream)
                                .keyboardType(.numberPad)
                                .focused($fieldFocused)
                                .submitLabel(.search)
                                .onSubmit { withAnimation { viewModel.lookup() }; fieldFocused = false }

                            if !viewModel.inputNumber.isEmpty {
                                Button { viewModel.clear() } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(AppColors.lavender.opacity(0.6))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    fieldFocused ? AppColors.gold.opacity(0.5) : AppColors.purple.opacity(0.35),
                                    lineWidth: 1
                                )
                        )

                        Button {
                            withAnimation { viewModel.lookup() }
                            fieldFocused = false
                        } label: {
                            Text("Look Up")
                                .font(AppFont.body(15, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                                .background(AppGradients.warm, in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    // MARK: Result or Browse
                    if let reading = viewModel.currentReading {
                        ReadingCard(reading: reading)
                            .padding(.horizontal, 24)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if viewModel.showNoResult {
                        NoResultView(number: viewModel.inputNumber)
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                    } else {
                        browseSection
                    }

                    Spacer().frame(height: 32)
                }
            }
        }
        .navigationTitle("Angel Numbers")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onTapGesture { fieldFocused = false }
    }

    // MARK: Browse Section

    private var browseSection: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Recent searches
            if !viewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: "Recent")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.recentSearches, id: \.self) { number in
                                NumberChip(number: number, color: AppColors.purple) {
                                    withAnimation { viewModel.select(number) }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }

            // Popular numbers
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel(text: "Most Searched")
                    .padding(.horizontal, 24)
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    ForEach(popular, id: \.self) { number in
                        if let reading = angelReadings[number] {
                            PopularNumberCard(reading: reading) {
                                withAnimation { viewModel.select(number) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // How to use hint
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
                Text("Type any angel number you keep seeing to reveal its twin flame meaning")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                    .lineSpacing(3)
            }
            .padding(14)
            .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppColors.purple.opacity(0.2), lineWidth: 1))
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }
}

// MARK: - Reading Card

private struct ReadingCard: View {
    let reading: AngelReading
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {

            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(reading.color.opacity(0.18))
                        .frame(width: 100, height: 100)
                        .blur(radius: 16)
                    Image(systemName: reading.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(reading.color)
                }

                Text(reading.number)
                    .font(AppFont.serifHeadline(52))
                    .foregroundStyle(.white)
                    .tracking(6)

                Text(reading.title)
                    .font(AppFont.serifTitle(22))
                    .foregroundStyle(reading.color)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(28)
            .background(
                LinearGradient(
                    colors: [reading.color.opacity(0.25), AppColors.deepViolet.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Body sections
            VStack(spacing: 0) {
                ReadingSection(
                    icon: "doc.text.fill",
                    color: AppColors.lavender,
                    title: "Meaning",
                    text: reading.meaning
                )

                Divider().background(AppColors.purple.opacity(0.2)).padding(.horizontal, 20)

                ReadingSection(
                    icon: "flame.fill",
                    color: reading.color,
                    title: "Twin Flame Message",
                    text: reading.twinFlameMessage
                )

                Divider().background(AppColors.purple.opacity(0.2)).padding(.horizontal, 20)

                ReadingSection(
                    icon: "arrow.forward.circle.fill",
                    color: AppColors.gold,
                    title: "Your Invitation",
                    text: reading.action
                )
            }
            .background(AppColors.deepViolet.opacity(0.85))
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(reading.color.opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { appeared = true }
        }
        .onChange(of: reading.number) {
            appeared = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.05)) { appeared = true }
        }
    }
}

private struct ReadingSection: View {
    let icon: String
    let color: Color
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                Text(title.uppercased())
                    .font(AppFont.caption(11, weight: .semibold))
                    .foregroundStyle(color)
                    .kerning(1.5)
            }
            Text(text)
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Supporting Views

private struct NoResultView: View {
    let number: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.lavender.opacity(0.5))

            VStack(spacing: 6) {
                Text("No reading for \(number)")
                    .font(AppFont.body(17, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text("Try numbers like 111, 444, 1111, or 1212")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }
}

private struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(AppFont.caption(11, weight: .semibold))
            .foregroundStyle(AppColors.lavender.opacity(0.7))
            .kerning(1.5)
    }
}

private struct NumberChip: View {
    let number: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(number)
                .font(AppFont.body(14, weight: .semibold))
                .foregroundStyle(AppColors.cream)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(color.opacity(0.3), in: Capsule())
                .overlay(Capsule().strokeBorder(color.opacity(0.4), lineWidth: 1))
        }
    }
}

private struct PopularNumberCard: View {
    let reading: AngelReading
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: reading.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(reading.color)
                Text(reading.number)
                    .font(AppFont.serifHeadline(20))
                    .foregroundStyle(AppColors.cream)
                Text(reading.title)
                    .font(AppFont.caption(10))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                reading.color.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(reading.color.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
