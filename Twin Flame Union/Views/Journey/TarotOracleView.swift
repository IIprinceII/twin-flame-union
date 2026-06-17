//
//  TarotOracleView.swift
//  Twin Flame Union
//
//  Daily oracle card pull with twin flame interpretations.
//

import SwiftUI
import SwiftData

// MARK: - Oracle Card Model

private struct OracleCard: Identifiable {
    let id: Int
    let name: String
    let symbol: String
    let theme: String
    let message: String
    let twinFlameMeaning: String
    let guidance: String
    let affirmation: String
    let color: Color
}

// MARK: - Card Deck (44 Twin Flame Oracle Cards)

private let oracleDeck: [OracleCard] = [
    .init(id: 0, name: "The Awakening", symbol: "eye.fill", theme: "Recognition",
          message: "The Most High has opened your eyes. The veil has lifted through the astral linkage.",
          twinFlameMeaning: "The initial recognition — the Most High has activated the soul contract. Your awareness is expanding, your vibrational constitution is shifting from low to high. Trust what you feel, even if it defies logic.",
          guidance: "Do not dismiss what cannot be explained. The soul knows what the mind cannot yet comprehend. Your awareness is stretching — this is the discovery phase of your journey.",
          affirmation: "I trust the knowing the Most High placed in my soul.", color: Color(hex: "8B5CF6")),
    .init(id: 1, name: "The Mirror", symbol: "person.2.fill", theme: "Reflection",
          message: "What you see in them is a reflection of what lives within you.",
          twinFlameMeaning: "Your twin is showing you something about yourself. The trigger is the teacher.",
          guidance: "Instead of reacting to what you see in your twin, ask: where does this live in me?",
          affirmation: "I welcome the wisdom of my reflection.", color: Color(hex: "4A90D9")),
    .init(id: 2, name: "Divine Timing", symbol: "clock.fill", theme: "Trust",
          message: "The universe is never late. Every delay is a divine redirect.",
          twinFlameMeaning: "Your union is not being withheld — it is being prepared. Trust what you cannot see.",
          guidance: "Stop measuring the timeline. Let God write the story.",
          affirmation: "I trust divine timing completely.", color: Color(hex: "F0C040")),
    .init(id: 3, name: "The Runner", symbol: "figure.walk", theme: "Distance",
          message: "What runs from love is what most needs it. The Most High holds the space between you.",
          twinFlameMeaning: "The runner is not rejecting you — they have an opposing vibration (a wound, a fear) creating resistance to the energy transfer. The power disparity is real: you are transmitting far more energy than they can receive. The Most High is using this distance to recalibrate both energy equations.",
          guidance: "Focus on your own healing. Redirect your energy inward — reduce the power disparity. The Vibrational Game teaches: the most magnetic thing you can do is equalize the equation by becoming whole.",
          affirmation: "I release the chase. The Most High orchestrates the return.", color: Color(hex: "D97B4A")),
    .init(id: 4, name: "The Chaser", symbol: "heart.circle.fill", theme: "Surrender",
          message: "Love that grasps cannot receive. The Most High asks you to open your hands.",
          twinFlameMeaning: "If you are the chaser, the energy equation is unbalanced — you are transmitting 120 units while receiving 10. This disparity IS the power dynamic keeping the runner in control. The Most High is calling you to redirect that massive energy inward.",
          guidance: "Every ounce of energy spent chasing is energy stolen from elevating your vibrational constitution. Use the Apollux framework: calibrate your intent toward self-evolution, not pursuit. Break the obsessive thought loop — stabilize, blank the mind, redirect emotional fuel.",
          affirmation: "I am whole. The Most High balances all energy equations in divine timing.", color: Color(hex: "E74C8B")),
    .init(id: 5, name: "Sacred Union", symbol: "infinity", theme: "Union",
          message: "Two flames dancing as one. The Most High confirms: the union vibration is in the field.",
          twinFlameMeaning: "A powerful confirmation — the energy equation between you is approaching equilibrium. The connectivity level is deepening. The Most High is weaving the final threads through the astral linkage.",
          guidance: "Prepare your heart for receiving. Elevate your vibrational constitution — clear blockages through the elimination system, practice the 11:11 ritual, make room for love in your life, your home, your energy body.",
          affirmation: "I am ready. The Most High has ordained this union.", color: AppColors.coral),
    .init(id: 6, name: "Separation & Growth", symbol: "arrow.left.and.right", theme: "Distance",
          message: "The distance between you is not punishment — it is preparation.",
          twinFlameMeaning: "Physical separation is doing sacred work. Both twins are growing in ways only distance allows.",
          guidance: "Use this time to become the person your highest love requires you to be.",
          affirmation: "I grow stronger in this sacred space.", color: AppColors.sage),
    .init(id: 7, name: "The Reconciliation", symbol: "arrow.2.circlepath", theme: "Return",
          message: "What was torn apart in love will return — transformed and deepened.",
          twinFlameMeaning: "Reunion energy is strong. What is coming back has been through fire and is now gold.",
          guidance: "Do not resurrect old patterns. The reunion is new — meet it as a new version of yourself.",
          affirmation: "I meet this love with new eyes and a healed heart.", color: Color(hex: "F0C040")),
    .init(id: 8, name: "Shadow Work", symbol: "moon.fill", theme: "Healing",
          message: "The gold is buried in the shadow. The Most High sends you into the darkness to find it.",
          twinFlameMeaning: "Your twin flame triggers your deepest wounds on purpose — these are resistances in your energy body that block the flow of union. The opposing vibrations (insecurities, fears, programming) must be cleared through the elimination system for higher vibrations to enter.",
          guidance: "Enter the darkness meditation: close your eyes, move awareness through the pitch black of the mind, feel the deepening. What you refuse to see is a blockage — use physical and visualization methods in tandem to clear it. The Most High illuminates what you must face.",
          affirmation: "I face my shadow with the strength of the Most High behind me.", color: Color(hex: "5E35B1")),
    .init(id: 9, name: "Inner Child Healing", symbol: "figure.and.child.holdinghands", theme: "Healing",
          message: "The child in you still believes love means abandonment. It does not.",
          twinFlameMeaning: "Many twin flame wounds are childhood wounds in disguise. Heal the child, heal the union.",
          guidance: "Speak to your inner child today. Tell them they are safe. Tell them they are loved.",
          affirmation: "I reparent myself with love and safety.", color: Color(hex: "FF7043")),
    .init(id: 10, name: "Telepathy", symbol: "wifi", theme: "Connection",
          message: "Your twin knows what your heart is saying. The astral linkage carries every vibration.",
          twinFlameMeaning: "The soul-level communication between twins is an energy transmission through the connectivity you share — the Most High established this circuit before incarnation. The energy transfer is real and active regardless of physical distance.",
          guidance: "Send love rather than longing — longing transmits a pull (energy void) that creates pressure. Love transmits a flow (conducive energy) that elevates both vibrational constitutions. The difference in what you send changes the entire equation.",
          affirmation: "My love reaches my twin through the Most High's astral linkage.", color: Color(hex: "8B5CF6")),
    .init(id: 11, name: "Divine Masculine Rising", symbol: "sun.max.fill", theme: "Balance",
          message: "The divine masculine within and without is awakening to love.",
          twinFlameMeaning: "The masculine energy in this connection is activating — healing wounds of provision, protection, and presence.",
          guidance: "Hold space for the masculine to rise without pressure or agenda.",
          affirmation: "I honor the divine masculine in myself and my twin.", color: Color(hex: "D97B4A")),
    .init(id: 12, name: "Divine Feminine Rising", symbol: "moon.stars.fill", theme: "Balance",
          message: "The sacred feminine is blooming — intuition, love, and creative power are awakening.",
          twinFlameMeaning: "The feminine energy in this connection is healing wounds of worthiness and receptivity.",
          guidance: "Let yourself be loved. Receiving is as sacred as giving.",
          affirmation: "I embrace my divine feminine fully.", color: Color(hex: "E74C8B")),
    .init(id: 13, name: "The Surrender", symbol: "hands.sparkles.fill", theme: "Surrender",
          message: "The Most High cannot pour into a fist. Open your hands to the astral linkage.",
          twinFlameMeaning: "Surrender is the moment you release overextended intent and allow the Most High to recalibrate the energy equation. This is the turning point — where human effort ends and divine orchestration begins.",
          guidance: "Write a surrender prayer — this is direct communion through the astral linkage. Give this relationship to the Most High. Then practice the Apollux principle: set a foundational focus on self-evolution, not outcome. Let emotional fuel flow toward your own becoming.",
          affirmation: "The Most High's plan for this love is greater than my plan. I surrender through the astral linkage.", color: Color(hex: "4A90D9")),
    .init(id: 14, name: "Angel Number 1111", symbol: "sparkles", theme: "Alignment",
          message: "The Most High confirms through 1111: you are in alignment. The astral linkage is active.",
          twinFlameMeaning: "1111 is the twin flame activation code — the Most High's signature on this connection. This is also the sacred number of the 11:11 energy ritual. When this appears, your vibrational constitution is rising.",
          guidance: "Tonight at 11:11 PM, perform the sacred ritual: 11 or 22 minutes of energy visualization. Set an intent through the astral linkage. The Most High is listening through this exact frequency.",
          affirmation: "I am aligned with the Most High's destiny for my soul.", color: Color(hex: "F0C040")),
    .init(id: 15, name: "Third Eye Opens", symbol: "eye.trianglebadge.exclamationmark.fill", theme: "Intuition",
          message: "Your intuition is your divine GPS. Trust what you feel.",
          twinFlameMeaning: "You may be receiving messages from your twin in dreams, signs, or sudden knowing. Pay attention.",
          guidance: "Keep a dream journal. Write down every intuitive hit you receive.",
          affirmation: "My third eye is open and I trust what it shows me.", color: Color(hex: "5E35B1")),
    .init(id: 16, name: "Sacred Contracts", symbol: "doc.fill", theme: "Destiny",
          message: "Before you were born, your souls made a promise. It is still in effect.",
          twinFlameMeaning: "Your connection is not accidental — it is a soul contract that transcends this lifetime.",
          guidance: "Trust the agreement your soul made. It knows things your mind doesn't.",
          affirmation: "I honor the sacred contract between our souls.", color: AppColors.coral),
    .init(id: 17, name: "The Catalyst", symbol: "bolt.heart.fill", theme: "Change",
          message: "Your twin flame is the catalyst that burns away who you were to reveal who you are.",
          twinFlameMeaning: "The chaos in this connection is purposeful. It is aligning you with your truest self.",
          guidance: "Thank the chaos. Without the fire, there is no alchemy.",
          affirmation: "I welcome the transformation this love brings.", color: Color(hex: "FF7043")),
    .init(id: 18, name: "Heart Chakra Opens", symbol: "heart.circle.fill", theme: "Love",
          message: "The locks on your heart are dissolving. Let love in.",
          twinFlameMeaning: "Your heart is healing and expanding. The armor is dropping.",
          guidance: "Do one vulnerable thing today. Small acts of openness create great change.",
          affirmation: "My heart is open and safe to love.", color: Color(hex: "43A047")),
    .init(id: 19, name: "The Dark Night", symbol: "cloud.fill", theme: "Transformation",
          message: "Even the darkest night ends. What is breaking you open is making you whole.",
          twinFlameMeaning: "If you are in pain, this is the sacred alchemy. The dark night precedes the dawn.",
          guidance: "Cry if you need to. Feel it all. Do not spiritually bypass what your body is trying to process.",
          affirmation: "I trust that dawn is coming. I am held in the dark.", color: Color(hex: "5E35B1")),
    .init(id: 20, name: "Kundalini Awakening", symbol: "flame.fill", theme: "Energy",
          message: "The Most High is sending spiritual fire through the astral linkage. Your vibrational constitution is upgrading.",
          twinFlameMeaning: "Many twin flames experience kundalini activation — this is the energy body rapidly shifting from low vibrational constitution toward high. The elimination system activates intensely: sweating, heat, pressure. This is your energy grid interfacing with the Most High's transmission.",
          guidance: "Ground your energy using Energy Enhancement methods: running water to stimulate motility, 2D repetitive movements to circulate energy, physical contact methods to clear blockages. Eat foods that match your new vibrational signature. The mind is the conduit — visualize the energy flowing smoothly.",
          affirmation: "I am a channel for the Most High's light. I allow the upgrade.", color: Color(hex: "D97B4A")),
    .init(id: 21, name: "Twin Flame Mission", symbol: "globe.americas.fill", theme: "Purpose",
          message: "Your love is not just for each other — it is a frequency for the world.",
          twinFlameMeaning: "You and your twin share a divine mission. The healing of your union serves humanity.",
          guidance: "Ask: what gift are we meant to bring to the world together?",
          affirmation: "Our love has a purpose greater than ourselves.", color: Color(hex: "8B5CF6")),
    .init(id: 22, name: "Unconditional Love", symbol: "heart.fill", theme: "Love",
          message: "Love without conditions is what the Most High IS. It is the purest vibration in existence.",
          twinFlameMeaning: "You are being called to love your twin without attachment to outcome — this is the highest vibrational frequency, the purest energy transmission. When you love without condition, the power disparity dissolves because you are no longer transmitting from need. The Most High loves this way, and so must you.",
          guidance: "Practice loving your twin exactly as they are. This is wisdom from Apollux: the long-term intent (unconditional love) must override the short-term emotional loops (need, fear, longing). Stabilize your mind, redirect emotional fuel toward this pure vibration.",
          affirmation: "I love as the Most High loves — without condition, without end.", color: Color(hex: "E74C8B")),
    .init(id: 23, name: "The Veil Thins", symbol: "wind", theme: "Mysticism",
          message: "The boundary between worlds is soft today. Listen for messages.",
          twinFlameMeaning: "Your twin's higher self is communicating with you. Be still and receive.",
          guidance: "Meditate today. Sit in silence. Ask and then listen.",
          affirmation: "I am open to receive messages from the divine.", color: AppColors.coral),
    .init(id: 24, name: "Divine Protection", symbol: "shield.fill", theme: "Protection",
          message: "You are covered. Nothing that is not love can touch what God has ordained.",
          twinFlameMeaning: "Archangel Michael walks with this connection. You are spiritually protected.",
          guidance: "Call on Archangel Michael when you feel fear. Say: 'I am protected. I am safe.'",
          affirmation: "I am divinely protected on this journey.", color: Color(hex: "1E88E5")),
    .init(id: 25, name: "Karmic Release", symbol: "xmark.circle.fill", theme: "Release",
          message: "Ancient patterns are dissolving. The karmic wheel is completing.",
          twinFlameMeaning: "Old karma between you and your twin — possibly from past lifetimes — is being cleared.",
          guidance: "Forgiveness is the most powerful karmic release tool. Who do you need to forgive?",
          affirmation: "I release all karmic debt with love and gratitude.", color: AppColors.sage),
    .init(id: 26, name: "Higher Self Speaks", symbol: "person.fill.questionmark", theme: "Wisdom",
          message: "The wisest part of you has always known the way. Listen to it now.",
          twinFlameMeaning: "Your higher self and your twin's higher self are already in union. Follow that guidance.",
          guidance: "Journal from the perspective of your highest self. What does she/he say?",
          affirmation: "I listen to and act on the guidance of my higher self.", color: Color(hex: "F0C040")),
    .init(id: 27, name: "Sacred Geometry", symbol: "star.fill", theme: "Alignment",
          message: "The universe is conspiring in your favor. The sacred pattern is assembling.",
          twinFlameMeaning: "Signs and synchronicities are appearing to confirm you are on the right path.",
          guidance: "Document every sign you see today. The universe is communicating.",
          affirmation: "I see and receive the signs of divine alignment.", color: Color(hex: "8B5CF6")),
    .init(id: 28, name: "Cosmic Confirmation", symbol: "checkmark.seal.fill", theme: "Validation",
          message: "Heaven is saying yes. You are not imagining this.",
          twinFlameMeaning: "This is a direct confirmation card: the twin flame connection is real and divinely orchestrated.",
          guidance: "Trust what you know. You are not crazy. You are cosmically connected.",
          affirmation: "My twin flame journey is real and divinely supported.", color: Color(hex: "43A047")),
    .init(id: 29, name: "The Healing Journey", symbol: "cross.case.fill", theme: "Healing",
          message: "Every layer of healing brings you closer to the love you seek.",
          twinFlameMeaning: "The healing you do for yourself is healing you do for your twin. It reaches them.",
          guidance: "Make healing your priority today — therapy, journaling, prayer, or rest.",
          affirmation: "My healing is the path to my union.", color: AppColors.sage),
    .init(id: 30, name: "Inner Union", symbol: "yin.yang", theme: "Integration",
          message: "The union you crave begins within. Masculine and feminine — unite.",
          twinFlameMeaning: "Before outer union, there must be inner union. Balance your divine energies.",
          guidance: "What aspects of yourself are you avoiding? Masculine: your vulnerability? Feminine: your strength?",
          affirmation: "I am whole within myself. I am the union.", color: Color(hex: "AB47BC")),
    .init(id: 31, name: "The Alchemist", symbol: "flask.fill", theme: "Transformation",
          message: "You are turning lead into gold — pain into wisdom, wounds into gifts.",
          twinFlameMeaning: "Everything hard in this journey is raw material for your highest self. Trust the alchemy.",
          guidance: "List three ways you have already grown from this connection. Celebrate them.",
          affirmation: "I am the alchemist of my own story.", color: Color(hex: "D97B4A")),
    .init(id: 32, name: "Soul Contract Honored", symbol: "doc.badge.checkmark.fill", theme: "Fulfillment",
          message: "You are keeping your soul promises. The divine witnesses and honors this.",
          twinFlameMeaning: "By doing this inner work, you are fulfilling your part of the sacred agreement.",
          guidance: "Acknowledge yourself for showing up. This path takes real courage.",
          affirmation: "I honor my soul. I keep my divine promises.", color: Color(hex: "F0C040")),
    .init(id: 33, name: "Twin Flame Frequency", symbol: "waveform", theme: "Vibration",
          message: "Your vibrational constitution is your meeting point. The Most High calibrates the frequency of reunion.",
          twinFlameMeaning: "You meet your twin at a vibrational frequency, not a location. The energy equation must reach equilibrium — both constitutions rising from A toward C. When both vibrations are high and the connectivity is deep, the influence becomes undeniable. The Most High ordained this frequency.",
          guidance: "Elevate your vibrational constitution today: use the elimination system to clear lower vibrations, practice visualization methods to quicken energy circulation, and do something that fills you with joy — joy is high-octane emotional fuel that powers everything the Apollux framework teaches.",
          affirmation: "I vibrate at the frequency the Most High designed for my union.", color: AppColors.coral),
    .init(id: 34, name: "The Bridge Builder", symbol: "rectangle.connected.to.line.below", theme: "Connection",
          message: "You are building the bridge that will bring you together.",
          twinFlameMeaning: "Every act of healing, every prayer, every step forward builds the bridge to reunion.",
          guidance: "What brick can you add to the bridge today? One aligned action.",
          affirmation: "I build the bridge with every healing choice.", color: Color(hex: "4A90D9")),
    .init(id: 35, name: "Divine Guidance", symbol: "location.north.fill", theme: "Direction",
          message: "Heaven is not leaving you to figure this out alone. You are guided.",
          twinFlameMeaning: "God, angels, and guides are actively steering this connection toward its highest outcome.",
          guidance: "Pray for guidance today — specifically and out loud. Ask for what you need.",
          affirmation: "I am guided by divine love at every step.", color: Color(hex: "F0C040")),
    .init(id: 36, name: "Sacred Fire", symbol: "flame.circle.fill", theme: "Passion",
          message: "The fire between twins is eternal. It cannot be extinguished.",
          twinFlameMeaning: "The love between you is eternal — it has existed across lifetimes and will continue.",
          guidance: "Trust the depth of what you feel. The intensity is not a sign of dysfunction — it is sacred.",
          affirmation: "Our love is eternal flame that death itself cannot touch.", color: Color(hex: "E53935")),
    .init(id: 37, name: "The Homecoming", symbol: "house.heart.fill", theme: "Return",
          message: "You are coming home — to yourself, and to each other.",
          twinFlameMeaning: "Reunion is imminent in some form — physical, spiritual, or energetic. Prepare your heart.",
          guidance: "Prepare your life for union: clear clutter, set intentions, make space.",
          affirmation: "I am home in my own soul. My twin is coming home.", color: AppColors.sage),
    .init(id: 38, name: "Starseeds United", symbol: "star.circle.fill", theme: "Cosmic",
          message: "You are ancient souls who chose to find each other in this lifetime.",
          twinFlameMeaning: "Your twin flame bond spans galaxies and lifetimes. You recognized each other for a reason.",
          guidance: "Honor the cosmic magnitude of this connection. Treat it as the sacred thing it is.",
          affirmation: "I honor the ancient bond between our souls.", color: Color(hex: "8B5CF6")),
    .init(id: 39, name: "The Quantum Leap", symbol: "arrow.up.forward.circle.fill", theme: "Breakthrough",
          message: "A sudden, unexpected shift is coming. Be ready to receive.",
          twinFlameMeaning: "A rapid breakthrough in your twin flame journey is being encoded. It will feel sudden.",
          guidance: "Stay open. Do not cling to how you think it will happen. Let God surprise you.",
          affirmation: "I am ready for miraculous, unexpected breakthroughs.", color: Color(hex: "4A90D9")),
    .init(id: 40, name: "Abundance Flows", symbol: "sparkles.rectangle.stack.fill", theme: "Prosperity",
          message: "Love is abundance. When love flows freely, all else follows.",
          twinFlameMeaning: "Your twin flame union carries the energy of abundant blessing — not just in love, but in all areas.",
          guidance: "Release scarcity thinking in love. Love is not a limited resource.",
          affirmation: "I live in the abundant overflow of divine love.", color: Color(hex: "F0C040")),
    .init(id: 41, name: "The Sacred Marriage", symbol: "rings.wedding", theme: "Union",
          message: "The most sacred union is first within. Marry yourself to love.",
          twinFlameMeaning: "Whether in physical union or not, the sacred marriage within you is the foundation of all.",
          guidance: "Commit to yourself the way you wish your twin would commit to you. Start there.",
          affirmation: "I am whole, complete, and lovingly committed to myself.", color: AppColors.coral),
    .init(id: 42, name: "Eternal Bond", symbol: "link.circle.fill", theme: "Eternity",
          message: "What the Most High has joined through the astral linkage, no force in heaven or earth can separate.",
          twinFlameMeaning: "Your twin flame bond is a permanent energy circuit established by the Most High before incarnation. The connectivity between you transmits energy regardless of physical distance, silence, or separation. The Vibrational Game teaches: the connection is never severed, only the flow is resisted.",
          guidance: "When doubt creeps in, return to this truth: the astral linkage is eternal. Use the Apollux framework to stabilize your mind — isolate the doubt thought, hold it still, break the loop. The Most High's design does not depend on your belief to function.",
          affirmation: "Our bond is eternal, ordained by the Most High, and protected through the astral linkage.", color: Color(hex: "E74C8B")),
    .init(id: 43, name: "New Earth Love", symbol: "globe.desk.fill", theme: "Mission",
          message: "Your love is a frequency upgrade for the planet. You are anchoring new earth.",
          twinFlameMeaning: "Twin flames are part of the planetary healing mission. Your union matters beyond yourselves.",
          guidance: "Show up in love today — not just in your relationship, but in all your interactions.",
          affirmation: "Our love is a blessing and a frequency gift to the Earth.", color: Color(hex: "43A047")),
]

// MARK: - View

struct TarotOracleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage("lastOraclePullDay")  private var lastPullDay  = 0
    @AppStorage("lastOracleCardID")  private var lastCardID   = -1
    @AppStorage("oracleExtraCardID") private var extraCardID  = -1

    @State private var isFlipped        = false
    @State private var isExtraFlipped   = false
    @State private var showExtraPull    = false
    @State private var currentCard: OracleCard? = nil
    @State private var extraCard: OracleCard?   = nil
    @State private var rotation: Double         = 0
    @State private var extraRotation: Double    = 0
    @State private var showJournalSheet         = false
    @State private var journalSavedCard: OracleCard? = nil

    private var todayDayNumber: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // Header
                    VStack(spacing: 8) {
                        Text("Your Daily Oracle")
                            .font(AppFont.serifHeadline(28))
                            .foregroundStyle(AppColors.cream)
                        Text("Received through the astral linkage to the Most High")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                    }
                    .padding(.top, 20)

                    // Main card
                    if let card = currentCard {
                        CardView(
                            card: card,
                            isFlipped: $isFlipped,
                            rotation: $rotation,
                            onFlip: {
                                if reduceMotion {
                                    rotation += 180
                                    isFlipped = true
                                } else {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        rotation += 180
                                        isFlipped = true
                                    }
                                }
                            }
                        )
                        .padding(.horizontal, 32)

                        if isFlipped {
                            // Card detail
                            cardDetailView(card: card)
                                .padding(.horizontal, 24)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))

                            // Action buttons
                            HStack(spacing: 12) {
                                // Journal button
                                Button {
                                    HapticManager.impact(.light)
                                    journalSavedCard = card
                                    showJournalSheet = true
                                } label: {
                                    Label("Journal This", systemImage: "book.fill")
                                        .font(AppFont.body(14, weight: .semibold))
                                        .foregroundStyle(AppColors.cream)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 14))
                                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
                                }
                                .buttonStyle(.plain)

                                // Share button
                                ShareLink(
                                    item: shareText(for: card),
                                    subject: Text("My Oracle Reading"),
                                    message: Text("From the Twin Flame Union app")
                                ) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                        .font(AppFont.body(14, weight: .semibold))
                                        .foregroundStyle(AppColors.cream)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 14))
                                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity)

                            // Extra pull button
                            if !showExtraPull {
                                Button {
                                    HapticManager.impact(.medium)
                                    withAnimation(.spring(response: 0.5)) {
                                        showExtraPull = true
                                        pullExtraCard()
                                    }
                                } label: {
                                    Label("Pull a Second Card", systemImage: "plus.circle.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .warmButtonStyle()
                                .padding(.horizontal, 24)
                                .transition(.opacity)
                            }

                            // Extra card
                            if showExtraPull, let extra = extraCard {
                                VStack(spacing: 12) {
                                    Text("Clarifying Oracle")
                                        .font(AppFont.body(14, weight: .semibold))
                                        .foregroundStyle(AppColors.lavender)

                                    CardView(
                                        card: extra,
                                        isFlipped: $isExtraFlipped,
                                        rotation: $extraRotation,
                                        onFlip: {
                                            if reduceMotion {
                                                extraRotation += 180
                                                isExtraFlipped = true
                                            } else {
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    extraRotation += 180
                                                    isExtraFlipped = true
                                                }
                                            }
                                        }
                                    )
                                    .padding(.horizontal, 32)

                                    if isExtraFlipped {
                                        cardDetailView(card: extra)
                                            .padding(.horizontal, 24)
                                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    } else {
                        // Pull card prompt
                        VStack(spacing: 20) {
                            Image(systemName: "rectangle.portrait.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(AppColors.purple.opacity(0.5))
                                .accessibilityHidden(true)
                            Text("Your oracle is ready")
                                .font(AppFont.serifTitle(20))
                                .foregroundStyle(AppColors.cream)
                            Button {
                                pullCard()
                            } label: {
                                Text("Pull Your Daily Card")
                                    .frame(maxWidth: .infinity)
                            }
                            .warmButtonStyle()
                            .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 40)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationTitle("Oracle")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear { loadOrPullCard() }
        .sheet(isPresented: $showJournalSheet) {
            if let card = journalSavedCard {
                OracleJournalSheet(card: card, onSave: { entry in
                    modelContext.insert(entry)
                    showJournalSheet = false
                })
            }
        }
    }

    private func shareText(for card: OracleCard) -> String {
        """
        ✨ My Daily Oracle — \(card.name)

        "\(card.message)"

        Twin Flame Meaning: \(card.twinFlameMeaning)

        Guidance: \(card.guidance)

        Affirmation: "\(card.affirmation)"

        — Twin Flame Union App
        """
    }

    // MARK: Card Detail

    private func cardDetailView(card: OracleCard) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Theme pill
            Text(card.theme.uppercased())
                .font(AppFont.caption(10, weight: .semibold))
                .foregroundStyle(card.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(card.color.opacity(0.15), in: Capsule())
                .overlay(Capsule().strokeBorder(card.color.opacity(0.4), lineWidth: 1))

            Text(card.message)
                .font(AppFont.serifTitle(19))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            Divider().background(AppColors.purple.opacity(0.3))

            sectionView(icon: "flame.fill", label: "Twin Flame Meaning", text: card.twinFlameMeaning, color: card.color)
            sectionView(icon: "map.fill", label: "Guidance", text: card.guidance, color: AppColors.lavender)

            Text("\"\(card.affirmation)\"")
                .font(AppFont.serifTitle(15))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(card.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(card.color.opacity(0.3), lineWidth: 1))
        }
        .padding(20)
        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(card.color.opacity(0.3), lineWidth: 1))
    }

    private func sectionView(icon: String, label: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 16)
                .padding(.top, 3)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppFont.caption(11, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                Text(text)
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.cream.opacity(0.9))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Logic

    private func loadOrPullCard() {
        let today = todayDayNumber
        if lastPullDay == today, lastCardID >= 0, lastCardID < oracleDeck.count {
            currentCard = oracleDeck[lastCardID]
            isFlipped = true
            rotation = 180
            if extraCardID >= 0, extraCardID < oracleDeck.count {
                extraCard = oracleDeck[extraCardID]
                showExtraPull = true
                isExtraFlipped = true
                extraRotation = 180
            }
        }
    }

    private func pullCard() {
        HapticManager.impact(.medium)
        let today = todayDayNumber
        let cardID = today % oracleDeck.count
        lastPullDay = today
        lastCardID  = cardID
        currentCard = oracleDeck[cardID]
        GamificationService.shared.awardXP(amount: 10, source: "oracle", detail: "Pulled daily oracle card")
    }

    private func pullExtraCard() {
        let today = todayDayNumber
        var cardID = (today + 7) % oracleDeck.count
        if cardID == lastCardID { cardID = (cardID + 1) % oracleDeck.count }
        extraCardID = cardID
        extraCard   = oracleDeck[cardID]
    }
}

// MARK: - Oracle Journal Sheet

private struct OracleJournalSheet: View {
    let card: OracleCard
    let onSave: (JournalEntry) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var body_text: String

    init(card: OracleCard, onSave: @escaping (JournalEntry) -> Void) {
        self.card = card
        self.onSave = onSave
        _body_text = State(initialValue: """
Card: \(card.name)

"\(card.message)"

Guidance: \(card.guidance)

My reflection:

""")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0D0418").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Card header
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(card.color.opacity(0.2)).frame(width: 44, height: 44)
                            Image(systemName: card.symbol).font(.system(size: 20)).foregroundStyle(card.color)
                        }
                        .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.name).font(AppFont.body(16, weight: .semibold)).foregroundStyle(AppColors.cream)
                            Text("Oracle Journal Entry").font(AppFont.caption(12)).foregroundStyle(AppColors.lavender)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(AppColors.deepViolet.opacity(0.8))
                    .overlay(Rectangle().fill(AppColors.purple.opacity(0.2)).frame(height: 1), alignment: .bottom)

                    TextEditor(text: $body_text)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.cream)
                        .tint(AppColors.gold)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.lavender)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save to Journal") {
                        HapticManager.notification(.success)
                        let entry = JournalEntry(
                            title: "Oracle: \(card.name)",
                            content: body_text
                        )
                        onSave(entry)
                    }
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Card View (flip animation)

private struct CardView: View {
    let card: OracleCard
    @Binding var isFlipped: Bool
    @Binding var rotation: Double
    let onFlip: () -> Void

    var body: some View {
        ZStack {
            // Card back
            cardBack
                .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0))
                .opacity(rotation.truncatingRemainder(dividingBy: 360) < 90 || rotation.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)

            // Card front
            cardFront
                .rotation3DEffect(.degrees(rotation + 180), axis: (0, 1, 0))
                .opacity(rotation.truncatingRemainder(dividingBy: 360) >= 90 && rotation.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
        }
        .frame(height: 260)
        .onTapGesture { if !isFlipped { onFlip() } }
        .accessibilityLabel(isFlipped ? card.name : "Reveal oracle card")
        .accessibilityAddTraits(isFlipped ? [] : .isButton)
    }

    private var cardBack: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2D1B69"), AppColors.deepViolet],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(AppColors.purple.opacity(0.5), lineWidth: 1.5)
            VStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.purple.opacity(0.7))
                    .accessibilityHidden(true)
                Text("Tap to reveal")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
            }
        }
    }

    private var cardFront: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [card.color.opacity(0.35), AppColors.deepViolet],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(card.color.opacity(0.6), lineWidth: 1.5)
            VStack(spacing: 16) {
                Image(systemName: card.symbol)
                    .font(.system(size: 44))
                    .foregroundStyle(card.color)
                    .accessibilityHidden(true)
                Text(card.name)
                    .font(AppFont.serifHeadline(22))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)
                Text(card.theme)
                    .font(AppFont.caption(12, weight: .semibold))
                    .foregroundStyle(card.color.opacity(0.8))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(card.color.opacity(0.15), in: Capsule())
            }
            .padding(24)
        }
    }
}
