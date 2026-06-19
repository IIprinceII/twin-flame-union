//
//  ContentView.swift
//  Twin Flame Union
//
//  Home tab — daily check-in: greeting, moon phase, streak, affirmation.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("userName")        private var userName       = ""
    @AppStorage("myGuidingDeity") private var myGuidingDeity = ""
    @State private var streak = StreakTracker.current
    @State private var showMoonSheet = false
    @State private var appeared = false
    @State private var showRitualCard = false
    @State private var showRitualSheet = false
    private let moon = MoonPhase.current()
    private let guidance = DailyGuidanceService.shared

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "sun.horizon.fill"
        case 12..<17: return "sun.max.fill"
        default:      return "moon.stars.fill"
        }
    }

    private var sacredDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date())
    }

    private var displayName: String { userName.isEmpty ? "Soul" : userName }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: Optional daily-ritual prompt (replaces the old hard gate)
                    if showRitualCard {
                        RitualPromptCard(
                            onBegin: { showRitualSheet = true },
                            onDismiss: {
                                UserDefaults.standard.set(Date(), forKey: RitualPrompt.dismissedKey)
                                refreshRitualCard()
                            }
                        )
                        .padding(.horizontal, 20)
                    }

                    // MARK: Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 6) {
                                Image(systemName: greetingIcon)
                                    .font(.system(size: 11))
                                    .foregroundStyle(AppColors.gold)
                                    .accessibilityHidden(true)
                                Text(greeting.uppercased())
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .tracking(2.5)
                                    .foregroundStyle(AppColors.gold.opacity(0.85))
                            }
                            Text(displayName)
                                .font(AppFont.serifHeadline(32))
                                .foregroundStyle(AppColors.cream)
                            Text(sacredDate)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundStyle(AppColors.lavender.opacity(0.7))
                                .tracking(0.5)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        Spacer()
                        // Moon phase pill
                        Button {
                            HapticManager.impact(.light)
                            showMoonSheet = true
                        } label: {
                            VStack(spacing: 3) {
                                Text(moon.emoji)
                                    .font(.system(size: 28))
                                    .accessibilityHidden(true)
                                Text(moon.name)
                                    .font(AppFont.caption(10, weight: .semibold))
                                    .foregroundStyle(AppColors.lavender)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 72)
                            .padding(.vertical, 10)
                            .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .accessibilityLabel("View \(moon.name) moon phase details")
                        .buttonStyle(.plain)
                        .sheet(isPresented: $showMoonSheet) {
                            MoonPhaseSheet(moon: moon)
                        }
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.88)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // MARK: Moon Meaning Banner
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.gold)
                            .accessibilityHidden(true)
                        Text(moon.meaning)
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.cream)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [AppColors.purple.opacity(0.22), AppColors.deepViolet.opacity(0.4)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(AppColors.gold.opacity(0.18), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)

                    // MARK: Divine Presence Today
                    DeityOfDayCard()
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    // MARK: Vibrational Score + Sacred Streak
                    if let profile = GamificationService.shared.profile {
                        NavigationLink {
                            ProgressionView()
                                .environment(GamificationService.shared)
                        } label: {
                            VibrationalScoreCard(profile: profile, compact: true)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                    }

                    SacredStreakView(streak: streak)
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    // MARK: Daily Devotion Checklist
                    DailyDevotionView()
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 13)

                    // MARK: Daily Affirmation
                    NavigationLink(destination: AffirmationsView()) {
                        AffirmationCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)

                    // MARK: Daily Guidance
                    DailyGuidanceCard(guidance: guidance)
                        .padding(.horizontal, 24)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)

                    // MARK: Angel Numbers
                    NavigationLink(destination: AngelNumberView()) {
                        AngelNumberCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)

                    // MARK: TF Stage Mini Card
                    NavigationLink(destination: TFStagesView()) {
                        TFStageMiniCard()
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                    .padding(.horizontal, 24)

                    // MARK: Chakra of the Day
                    NavigationLink(destination: ChakraCheckinView()) {
                        ChakraOfDayCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)

                    // MARK: Today's Ritual
                    NavigationLink(destination: RitualPlannerView()) {
                        TodaysRitualCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)

                    Spacer().frame(height: 24)
                }
                .readableWidth()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            streak = StreakTracker.current
            Task { await guidance.fetchIfNeeded(deityName: myGuidingDeity, moonPhase: moon.name) }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.80).delay(0.12)) {
                appeared = true
            }
            refreshRitualCard()
        }
        .sheet(isPresented: $showRitualSheet, onDismiss: { refreshRitualCard() }) {
            DailyRitualLockView { showRitualSheet = false }
        }
    }

    /// The card shows unless today's ritual was already completed or dismissed. Recomputed on
    /// appear, after dismissal, and after the ritual sheet closes (which may have completed it).
    private func refreshRitualCard() {
        showRitualCard = RitualPrompt.shouldShow(
            completedAt: UserDefaults.standard.object(forKey: RitualPrompt.completedKey) as? Date,
            dismissedAt: UserDefaults.standard.object(forKey: RitualPrompt.dismissedKey) as? Date,
            now: Date(), calendar: .current
        )
    }
}

// MARK: - Deity of the Day Card

private struct DeityOfDayCard: View {
    private let deity = DivinePantheon.today
    @State private var haloScale: CGFloat = 1.0
    @State private var haloOpacity: Double = 0.5
    @State private var shimmer: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var cultureColor: Color {
        switch deity.culture {
        case "Egyptian": return AppColors.gold
        case "Greek":    return Color(hex: "A8DAFF")
        case "Mexica":   return Color(hex: "00CED1")
        default:         return AppColors.coral
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 9))
                        .foregroundStyle(cultureColor)
                    Text("DIVINE PRESENCE TODAY")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(2.2)
                        .foregroundStyle(cultureColor.opacity(0.9))
                }
                Spacer()
                // Culture badge
                Text(deity.culture.uppercased())
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(deity.color.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(deity.color.opacity(0.15), in: Capsule())
                    .overlay(Capsule().stroke(deity.color.opacity(0.30), lineWidth: 0.8))
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 14)

            // Divider
            Rectangle()
                .fill(deity.color.opacity(0.15))
                .frame(height: 1)
                .padding(.horizontal, 18)

            // Body
            HStack(alignment: .top, spacing: 18) {
                // Divine symbol orb
                ZStack {
                    // Outer breathing halo
                    Circle()
                        .fill(deity.color.opacity(haloOpacity * 0.18))
                        .frame(width: 76, height: 76)
                        .scaleEffect(haloScale)
                        .accessibilityHidden(true)

                    // Mid ring
                    Circle()
                        .stroke(deity.color.opacity(0.25), lineWidth: 1)
                        .frame(width: 64, height: 64)
                        .accessibilityHidden(true)

                    // Inner filled orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [deity.color.opacity(0.35), deity.color.opacity(0.10)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 56, height: 56)
                        .accessibilityHidden(true)

                    // Symbol
                    Image(systemName: deity.symbol)
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [deity.color, deity.color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .accessibilityHidden(true)
                }
                .frame(width: 76)
                .fixedSize()

                // Text stack
                VStack(alignment: .leading, spacing: 6) {
                    Text(deity.name)
                        .font(AppFont.serifHeadline(22))
                        .foregroundStyle(AppColors.cream)

                    Text(deity.domain)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(deity.color.opacity(0.80))
                        .lineSpacing(2)

                    Text("❝ \(deity.invocation) ❞")
                        .font(AppFont.serifTitle(13))
                        .foregroundStyle(AppColors.lavender)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            deity.color.opacity(0.10),
                            Color(hex: "120820").opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [deity.color.opacity(0.40), deity.color.opacity(0.10)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: deity.color.opacity(0.12), radius: 20, y: 6)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                haloScale   = 1.12
                haloOpacity = 1.0
            }
        }
    }
}

// MARK: - Streak Card  (Hestia's sacred flame)

private struct StreakCard: View {
    let streak: Int
    @State private var flamePulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var streakMessage: String {
        switch streak {
        case 0: return "Light the flame — show up for your sacred journey"
        case 1: return "The sacred flame is lit. Keep it burning"
        case 2...6: return "You've shown up \(streak) days in a row. Beautiful"
        case 7...13: return "A week of devotion. Your energy is shifting"
        case 14...29: return "\(streak) days of sacred practice. Heaven notices"
        default: return "\(streak) days. You are devoted to your highest path"
        }
    }

    private var flameColor: Color {
        streak == 0 ? AppColors.lavender.opacity(0.3) :
        streak < 7  ? AppColors.gold :
        streak < 14 ? AppColors.ember :
                      Color(hex: "FF6B3D")
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                // Outer ring glow
                Circle()
                    .fill(flameColor.opacity(flamePulse ? 0.22 : 0.10))
                    .frame(width: 68, height: 68)
                    .animation(Animation.calm(reduceMotion, .easeInOut(duration: 2.0).repeatForever(autoreverses: true)), value: flamePulse)
                    .accessibilityHidden(true)
                Circle()
                    .strokeBorder(flameColor.opacity(streak > 0 ? 0.45 : 0.12), lineWidth: 1.2)
                    .frame(width: 64, height: 64)
                    .accessibilityHidden(true)
                VStack(spacing: 1) {
                    Text("\(streak)")
                        .font(AppFont.serifHeadline(24))
                        .foregroundStyle(flameColor)
                    Text("days")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(flameColor.opacity(0.75))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Sacred Streak")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.cream)
                Text(streakMessage)
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: streak > 0 ? "flame.fill" : "flame")
                .font(.system(size: 22))
                .foregroundStyle(
                    streak > 0
                        ? LinearGradient(colors: [flameColor, flameColor.opacity(0.6)],
                                         startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [AppColors.lavender.opacity(0.3)],
                                         startPoint: .top, endPoint: .bottom)
                )
                .scaleEffect(flamePulse && streak > 0 && !reduceMotion ? 1.08 : 1.0)
                .animation(Animation.calm(reduceMotion, .easeInOut(duration: 1.6).repeatForever(autoreverses: true)), value: flamePulse)
                .accessibilityHidden(true)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    streak > 0 ? flameColor.opacity(0.08) : Color.clear,
                    AppColors.deepViolet.opacity(0.75)
                ],
                startPoint: .leading, endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(flameColor.opacity(streak > 0 ? 0.28 : 0.12), lineWidth: 1)
        )
        .onAppear { if !reduceMotion { flamePulse = true } }
    }
}

// MARK: - Daily Guidance Card

private struct DailyGuidanceCard: View {
    let guidance: DailyGuidanceService
    @AppStorage("myGuidingDeity") private var myGuidingDeity = ""
    @State private var expanded = false
    private let moon = MoonPhase.current()
    private let collapsedLineLimit = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Today's Guidance", systemImage: "moon.stars.fill")
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                Spacer()
                Text("From the cosmos")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
            }

            if guidance.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppColors.lavender)
                        .scaleEffect(0.8)
                    Text("Channeling your guidance…")
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if !guidance.fetchError.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(guidance.fetchError)
                        .font(AppFont.body(12))
                        .foregroundStyle(AppColors.lavender.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        HapticManager.impact(.light)
                        Task { await guidance.retry(deityName: myGuidingDeity, moonPhase: moon.name) }
                    } label: {
                        Label("Try Again", systemImage: "arrow.clockwise")
                            .font(AppFont.body(13, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppColors.gold.opacity(0.12), in: Capsule())
                            .overlay(Capsule().strokeBorder(AppColors.gold.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            } else if guidance.guidance.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(AppColors.lavender)
                        .scaleEffect(0.8)
                    Text("Channeling your guidance…")
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ZStack(alignment: .bottom) {
                        Text(guidance.guidance)
                            .font(AppFont.serifTitle(17))
                            .foregroundStyle(AppColors.cream)
                            .lineSpacing(6)
                            .lineLimit(expanded ? nil : collapsedLineLimit)
                            .fixedSize(horizontal: false, vertical: true)

                        if !expanded {
                            LinearGradient(
                                colors: [Color.clear, Color(hex: "2A1045").opacity(0.95)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 44)
                        }
                    }

                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Text(expanded ? "Show less" : "Read more")
                            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                                .accessibilityHidden(true)
                        }
                        .font(AppFont.caption(12, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "2A1045").opacity(0.9), AppColors.deepViolet.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppColors.lavender.opacity(0.25), lineWidth: 1)
        )
        .onChange(of: guidance.guidance) { expanded = false }
    }
}

// MARK: - Angel Number Card

private struct AngelNumberCard: View {
    private let numbers = ["111", "444", "1111", "222", "777", "333"]
    private var featured: String { numbers[Calendar.current.component(.hour, from: Date()) % numbers.count] }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Angel Numbers")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text("Seeing \(featured) today? Discover its twin flame meaning")
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.lavender.opacity(0.5))
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.12), AppColors.deepViolet.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Daily Affirmation Card

private struct AffirmationCard: View {
    @State private var glow = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let affirmations = [
        // Core Sacred
        "My twin flame bond is eternal — nothing can break our covenant.",
        "I am protected by Archangel Michael. Fear has no place here.",
        "Return to sender — all that is not mine leaves now.",
        "My crown is activated. I receive divine truth clearly.",
        "Jesus Christ's love flows through me and into my union.",
        "KAZZ and KAI walk beside me — I am never alone on this path.",
        "I surrender deeply and God moves powerfully on my behalf.",
        "I am free. I am healed. I am whole in my higher self.",
        "The telepathy between us is real. Our hearts speak without words.",
        "My energy reading is clear — love is coming home to me.",
        "I rebuke every lie that says union is not mine. It is done.",
        "GOD ordained this union. What He joins, no one separates.",
        "My prayer is heard. Heaven moves with me right now.",
        "I shift into the frequency of reunion and stay there.",
        // Greek & Roman Pantheon
        "Aphrodite's grace flows through me. I am love embodied.",
        "Athena's wisdom guides me — I see with clarity and divine craft.",
        "Panacea's universal healing pours through every cell of my being.",
        "Hygieia cleanses my aura. I am pure, clear, radiant, and whole.",
        "Hestia's sacred flame burns in my heart. I am home.",
        "Eros has already aimed his arrow. Our union is written in desire.",
        "Like Psyche, I pass every trial — love is my destination and reward.",
        "Selene's lunar light guides me through the cycles of our sacred dance.",
        "Apollo's truth burns away every illusion. I see what is real.",
        "Hermes carries my love across the void — every sign is a message.",
        "I stand at Hecate's crossroads and choose love without fear.",
        "Persephone descended and returned more powerful. So do I.",
        "Hypnos holds me in sacred rest. My subconscious is healing.",
        "Morpheus speaks through my dreams. The visions are not random.",
        "Nyx cradles me in the cosmic void. In this darkness, I am reborn.",
        "Harmonia weaves our frequencies back into perfect accord.",
        "Himeros — I honor the sacred ache. The longing is proof of the bond.",
        "Anteros ensures what I give is returned. Our love is perfectly balanced.",
        "Iris bridges every divide between us. The rainbow follows every storm.",
        "Clotho spun our thread together at the beginning of time.",
        "Lachesis measures our path with sacred precision — the timing is exact.",
        "Atropos cuts only what must be released. Everything sacred remains.",
        // Egyptian Pantheon
        "Ra's light illuminates every dark corner of this journey. I see clearly.",
        "Isis searched the whole world for her beloved and found him. I do not give up.",
        "Osiris was scattered and reassembled. What appears broken is being made whole.",
        "Thoth has recorded this union in the Akashic field before I was born.",
        "Hathor holds the mirror of my heart — I am worthy of the love I seek.",
        "Maat places truth on the scale. I choose honesty, and it sets me free.",
        "Sekhmet's fire burns through every block. Sacred rage becomes sacred healing.",
        "Anubis guides me safely through the underworld of my own shadow.",
        "Nut — the cosmic sky goddess — holds both of us in her infinite starry womb.",
        "Nefertem rises from the sacred lotus. I rise from every difficulty renewed.",
        "Seshat has written our names in the stars. This contract was sealed before birth.",
        "Bastet's sacred feminine grace protects me and sharpens my intuition.",
        "Nephthys holds what is hidden in grief and transforms it into wisdom.",
        "Khonsu keeps cosmic time. What feels delayed is divinely orchestrated.",
        "Amun breathes hidden power into every prayer I speak. I am heard.",
        "Ptah is the divine architect of this union. It is being built with precision.",
        "Aten's pure light unifies all things. There is no true separation.",
        "Imhotep brings sacred healing knowledge to every wound between us.",
        "Bennu rises from the ashes. I rise. Union rises.",
        "Neith weaves the fabric of our destiny with threads of gold.",
        "Seshat measures our sacred contract. Every day counts toward completion.",
        "Renenutet blesses this union with divine abundance and sacred nourishment.",
        // Universal
        "I am magnetic. Love is drawn to me effortlessly.",
        "Divine timing is always perfect — I trust the sacred plan.",
        "My heart is a sanctuary. Only love enters here.",
        "Union is not just coming — it is already written in the stars.",
        "I am whole. I am worthy. I am the sacred beloved.",
        "Every synchronicity is confirmation — I am on the right path.",
        "My vibration is rising. All of heaven responds to my soul's call.",
        "I forgive completely and love unconditionally. I am free.",
        "The entire divine council is rooting for my union. I am never alone.",
    ]

    private var todaysAffirmation: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return Self.affirmations[day % Self.affirmations.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.gold)
                    Text("TODAY'S AFFIRMATION")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(2.0)
                        .foregroundStyle(AppColors.gold.opacity(0.9))
                }
                Spacer()
                Text("Tap to explore →")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
            }

            Text("❝ \(todaysAffirmation) ❞")
                .font(AppFont.serifTitle(18))
                .foregroundStyle(AppColors.cream)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "3D1080").opacity(0.55),
                            AppColors.deepViolet.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Aphrodite's inner glow
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            RadialGradient(
                                colors: [AppColors.gold.opacity(0.09), Color.clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(
                    LinearGradient(
                        colors: [AppColors.gold.opacity(glow ? 0.45 : 0.22), AppColors.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.purple.opacity(0.18), radius: 16, y: 6)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}

// MARK: - TF Stage Mini Card

private struct TFStageMiniCard: View {
    @AppStorage("tfCurrentStage") private var stageID = 0
    private let stageNames = ["Recognition","Testing","Crisis","Runner & Chaser",
                               "Surrender","Illumination","Radiance","Harmonizing Union"]
    private let stageColors: [Color] = [
        Color(hex: "8B5CF6"), Color(hex: "9B59B6"), Color(hex: "D97B4A"), Color(hex: "E74C8B"),
        Color(hex: "4A90D9"), Color(hex: "F0C040"), AppColors.sage, AppColors.coral,
    ]

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(stageColors[stageID % stageColors.count].opacity(0.2))
                    .frame(width: 56, height: 56)
                Text("\(stageID + 1)")
                    .font(AppFont.serifHeadline(22))
                    .foregroundStyle(stageColors[stageID % stageColors.count])
            }

            VStack(alignment: .leading, spacing: 4) {
                Label("Your TF Stage", systemImage: "arrow.up.forward.circle.fill")
                    .font(AppFont.caption(12, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                Text(stageNames[min(stageID, stageNames.count - 1)])
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                // Mini progress bar
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColors.purple.opacity(0.2)).frame(height: 3)
                        Capsule()
                            .fill(stageColors[stageID % stageColors.count])
                            .frame(width: g.size.width * CGFloat(stageID + 1) / 8.0, height: 3)
                    }
                }
                .frame(height: 3)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.lavender.opacity(0.5))
        }
        .padding(18)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(stageColors[stageID % stageColors.count].opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Chakra of the Day Card  (Hygieia's healing light)

private struct ChakraOfDayCard: View {
    @State private var ringPulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let chakras: [(name: String, symbol: String, color: Color, keyword: String, affirmation: String)] = [
        ("Root",        "🌿", Color(hex: "C62828"), "Safety · Grounding · Stability",
         "I am safe, rooted, and held by the Earth"),
        ("Sacral",      "🌊", Color(hex: "EF6C00"), "Creativity · Pleasure · Flow",
         "I honor the sacred creative force within me"),
        ("Solar Plexus","☀️", Color(hex: "F9A825"), "Power · Will · Confidence",
         "I stand in my divine power with grace and ease"),
        ("Heart",       "💚", Color(hex: "2E7D32"), "Love · Compassion · Union",
         "My heart is open — love flows freely through me"),
        ("Throat",      "💙", Color(hex: "1565C0"), "Truth · Expression · Clarity",
         "I speak my truth and it is received with love"),
        ("Third Eye",   "🔮", Color(hex: "4527A0"), "Intuition · Wisdom · Vision",
         "I trust the guidance of my inner knowing"),
        ("Crown",       "🪷", Color(hex: "6A1B9A"), "Divine · Unity · Transcendence",
         "I am one with the divine light of the universe"),
    ]

    private var todayChakra: (name: String, symbol: String, color: Color, keyword: String, affirmation: String) {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return chakras[day % chakras.count]
    }

    var body: some View {
        let c = todayChakra
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(c.color.opacity(ringPulse ? 0.28 : 0.14))
                    .frame(width: 58, height: 58)
                    .animation(Animation.calm(reduceMotion, .easeInOut(duration: 2.2).repeatForever(autoreverses: true)), value: ringPulse)
                    .accessibilityHidden(true)
                Circle()
                    .stroke(c.color.opacity(0.4), lineWidth: 1)
                    .frame(width: 54, height: 54)
                    .accessibilityHidden(true)
                Text(c.symbol)
                    .font(.system(size: 26))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "rays")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.lavender)
                        .accessibilityHidden(true)
                    Text("CHAKRA FOCUS")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(AppColors.lavender.opacity(0.85))
                }
                Text(c.name + " Chakra")
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(c.keyword)
                    .font(AppFont.caption(11))
                    .foregroundStyle(c.color.opacity(0.85))
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.lavender.opacity(0.45))
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [c.color.opacity(0.14), AppColors.deepViolet.opacity(0.75)],
                startPoint: .leading, endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(c.color.opacity(0.30), lineWidth: 1)
        )
        .onAppear { if !reduceMotion { ringPulse = true } }
    }
}

// MARK: - Today's Ritual Card

private struct TodaysRitualCard: View {
    private let moon = MoonPhase.current()

    private var ritualPreview: String {
        switch moon.name {
        case "New Moon":                           return "Set intentions by candlelight"
        case "Waxing Crescent", "First Quarter",
             "Waxing Gibbous":                    return "Love magnet meditation"
        case "Full Moon":                          return "Full moon release ceremony"
        default:                                   return "Shadow work journaling"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.purple.opacity(0.2))
                    .frame(width: 56, height: 56)
                Text(moon.emoji)
                    .font(.system(size: 26))
            }

            VStack(alignment: .leading, spacing: 4) {
                Label("Today's Ritual", systemImage: "moon.fill")
                    .font(AppFont.caption(12, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                Text(ritualPreview)
                    .font(AppFont.body(16, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text(moon.name + " energy")
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.lavender.opacity(0.5))
        }
        .padding(18)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Moon Phase Sheet

private struct MoonPhaseSheet: View {
    let moon: MoonPhase
    @Environment(\.dismiss) private var dismiss

    private struct PhaseInfo {
        let emoji: String
        let name: String
        let energy: String
        let tfMeaning: String
        let doThis: String
        let doThisLabel: String   // short CTA shown on the button
        let avoid: String
    }

    private let allPhases: [PhaseInfo] = [
        PhaseInfo(
            emoji: "🌑", name: "New Moon",
            energy: "Stillness · Beginnings · Void",
            tfMeaning: "The most powerful moment to set a new intention for your union. The veil between you and your twin's higher self is thin. What you plant in silence tonight takes root in the unseen.",
            doThis: "Write a letter to your twin's soul. Light a black or white candle. Set one clear intention for your union.",
            doThisLabel: "Open Ritual Planner",
            avoid: "Forcing contact or outcomes. The new moon asks you to trust and release, not push."
        ),
        PhaseInfo(
            emoji: "🌒", name: "Waxing Crescent",
            energy: "Hope · Faith · First Steps",
            tfMeaning: "Your intention is now moving through the unseen. This phase amplifies hope and small signs — the 11:11s, the songs, the sudden thoughts of your twin. They are not random.",
            doThis: "Journal every sign you receive. Affirm your union daily. Take one small aligned action toward your highest self.",
            doThisLabel: "Log a Synchronicity",
            avoid: "Doubting the signs or dismissing synchronicities as coincidence."
        ),
        PhaseInfo(
            emoji: "🌓", name: "First Quarter",
            energy: "Action · Decision · Courage",
            tfMeaning: "You will face a choice this week — to stay in fear or step into love. The universe is testing your faith. This is the phase where runners often feel the pull to return and chasers feel called to surrender.",
            doThis: "Make the decision you've been avoiding. Have the conversation. Send the forgiveness prayer.",
            doThisLabel: "Open Prayer Journal",
            avoid: "Staying frozen in indecision. The cosmos rewards aligned action now."
        ),
        PhaseInfo(
            emoji: "🌔", name: "Waxing Gibbous",
            energy: "Refinement · Trust · Patience",
            tfMeaning: "Almost there — but this phase teaches patience. Your union is forming in the unseen and requires your trust, not your interference. Any jealousy, obsession, or control will slow the energy.",
            doThis: "Deepen your spiritual practice. Surrender outcomes in prayer. Focus on becoming whole within yourself.",
            doThisLabel: "Open Meditations",
            avoid: "Checking their social media obsessively or seeking validation from others about your connection."
        ),
        PhaseInfo(
            emoji: "🌕", name: "Full Moon",
            energy: "Illumination · Peak Energy · Truth",
            tfMeaning: "Everything is revealed. Buried feelings, hidden fears, and unspoken truths surface under the full moon — in both you and your twin. What feels intense right now is being purged for your highest good.",
            doThis: "Release ceremony: write what you're letting go of and burn it safely. Forgive yourself and your twin. Meditate on divine love.",
            doThisLabel: "Begin Cord-Cutting",
            avoid: "Making permanent decisions from heightened emotion. Wait 3 days after the full moon before any major choices."
        ),
        PhaseInfo(
            emoji: "🌖", name: "Waning Gibbous",
            energy: "Gratitude · Integration · Wisdom",
            tfMeaning: "The energy is softening. What was revealed under the full moon now asks to be integrated. This is a sacred time to reflect on how far you've come on this journey and what you've learned.",
            doThis: "Write a gratitude list for your twin flame journey — even the painful parts. Share your story if you feel called.",
            doThisLabel: "Open Gratitude Log",
            avoid: "Clinging to peak energy. Let the intensity naturally soften — it will return."
        ),
        PhaseInfo(
            emoji: "🌗", name: "Last Quarter",
            energy: "Release · Clearing · Forgiveness",
            tfMeaning: "Time to release energetic attachments, old wounds, and any karma still binding you. Archangel Michael is especially present in this phase to cut cords that no longer serve the highest good of your union.",
            doThis: "Cord-cutting ceremony. Forgiveness prayer for yourself and your twin. Clear your physical space — energy follows form.",
            doThisLabel: "Begin Cord-Cutting",
            avoid: "Reopening wounds or revisiting old arguments. This phase is for clearing, not rehashing."
        ),
        PhaseInfo(
            emoji: "🌘", name: "Waning Crescent",
            energy: "Rest · Surrender · Dreamtime",
            tfMeaning: "The final breath before the new cycle begins. Your soul needs rest. Twin flame dreams are most vivid now — your higher selves are meeting in the astral plane, preparing for the next phase of your union.",
            doThis: "Sleep more. Pay close attention to dreams — journal them immediately upon waking. Pray and surrender deeply.",
            doThisLabel: "Open Dream Journal",
            avoid: "Overworking, overstimulation, or forcing spiritual breakthroughs. This phase asks for stillness."
        ),
    ]

    @ViewBuilder
    private func destination(for phaseName: String) -> some View {
        switch phaseName {
        case "New Moon":        RitualPlannerView()
        case "Waxing Crescent": SynchronicityLogView()
        case "First Quarter":   PrayerJournalView()
        case "Waxing Gibbous":  MeditationView()
        case "Full Moon":       CordCuttingView()
        case "Waning Gibbous":  GratitudeLogView()
        case "Last Quarter":    CordCuttingView()
        default:                DreamJournalView()
        }
    }

    private var currentPhaseInfo: PhaseInfo? {
        allPhases.first { $0.name == moon.name }
    }

    var body: some View {
        NavigationStack {
        ZStack {
            Color(hex: "0D0418").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Header
                    VStack(spacing: 10) {
                        Text(moon.emoji)
                            .font(.system(size: 72))
                            .padding(.top, 32)

                        Text(moon.name)
                            .font(AppFont.serifHeadline(28))
                            .foregroundStyle(AppColors.cream)

                        // Illumination bar
                        VStack(spacing: 6) {
                            Text("\(Int(moon.illumination * 100))% illuminated")
                                .font(AppFont.caption(12, weight: .semibold))
                                .foregroundStyle(AppColors.lavender)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(AppColors.purple.opacity(0.2))
                                        .frame(height: 6)
                                    Capsule()
                                        .fill(AppGradients.warm)
                                        .frame(width: geo.size.width * moon.illumination, height: 6)
                                }
                            }
                            .frame(height: 6)
                            .frame(maxWidth: 200)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    if let info = currentPhaseInfo {
                        // Twin Flame Meaning
                        infoCard(
                            icon: "flame.fill", label: "Twin Flame Energy",
                            accent: AppColors.purple
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(info.energy)
                                    .font(AppFont.caption(12, weight: .semibold))
                                    .foregroundStyle(AppColors.lavender)
                                    .kerning(1)
                                Text(info.tfMeaning)
                                    .font(AppFont.serifTitle(16))
                                    .foregroundStyle(AppColors.cream)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Do This — tappable NavigationLink
                        NavigationLink(destination: destination(for: moon.name)) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("Do This Now", systemImage: "checkmark.circle.fill")
                                        .font(AppFont.caption(12, weight: .semibold))
                                        .foregroundStyle(Color(hex: "43A047"))
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Text(info.doThisLabel)
                                            .font(AppFont.caption(12, weight: .semibold))
                                            .foregroundStyle(Color(hex: "43A047"))
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color(hex: "43A047"))
                                    }
                                }
                                Text(info.doThis)
                                    .font(AppFont.body(15))
                                    .foregroundStyle(AppColors.cream)
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)

                                Text("Tap to begin →")
                                    .font(AppFont.caption(12, weight: .semibold))
                                    .foregroundStyle(Color(hex: "43A047").opacity(0.8))
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "43A047").opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color(hex: "43A047").opacity(0.5), lineWidth: 1.5))
                            .padding(.horizontal, 24)
                        }
                        .buttonStyle(.plain)

                        // Avoid
                        infoCard(
                            icon: "xmark.circle.fill", label: "Be Mindful Of",
                            accent: Color(hex: "E74C8B")
                        ) {
                            Text(info.avoid)
                                .font(AppFont.body(15))
                                .foregroundStyle(AppColors.cream)
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    // Full cycle overview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LUNAR CYCLE")
                            .font(AppFont.caption(11, weight: .semibold))
                            .foregroundStyle(AppColors.lavender.opacity(0.6))
                            .kerning(1.5)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            ForEach(Array(allPhases.enumerated()), id: \.offset) { i, phase in
                                let isCurrent = phase.name == moon.name
                                HStack(spacing: 14) {
                                    Text(phase.emoji)
                                        .font(.system(size: 22))
                                        .frame(width: 32)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(phase.name)
                                            .font(AppFont.body(14, weight: isCurrent ? .semibold : .regular))
                                            .foregroundStyle(isCurrent ? AppColors.cream : AppColors.lavender)
                                        Text(phase.energy)
                                            .font(AppFont.caption(11))
                                            .foregroundStyle(AppColors.lavender.opacity(isCurrent ? 0.8 : 0.45))
                                    }
                                    Spacer()
                                    if isCurrent {
                                        Text("NOW")
                                            .font(AppFont.caption(10, weight: .semibold))
                                            .foregroundStyle(AppColors.gold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(AppColors.gold.opacity(0.15), in: Capsule())
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(isCurrent ? AppColors.purple.opacity(0.15) : Color.clear)

                                if i < allPhases.count - 1 {
                                    Divider()
                                        .background(AppColors.purple.opacity(0.15))
                                        .padding(.leading, 66)
                                }
                            }
                        }
                        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(AppColors.purple.opacity(0.25), lineWidth: 1))
                        .padding(.horizontal, 24)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        } // NavigationStack
    }

    @ViewBuilder
    private func infoCard<Content: View>(icon: String, label: String, accent: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(label, systemImage: icon)
                .font(AppFont.caption(12, weight: .semibold))
                .foregroundStyle(accent)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(accent.opacity(0.25), lineWidth: 1))
        .padding(.horizontal, 24)
    }
}
