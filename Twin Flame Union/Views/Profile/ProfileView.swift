//
//  ProfileView.swift
//  Twin Flame Union
//
//  Profile tab with birth chart, partner compatibility, streak, and reminders.
//

import SwiftUI
import UserNotifications

// MARK: - Zodiac Element

enum Element: String, CaseIterable {
    case fire  = "Fire"
    case earth = "Earth"
    case air   = "Air"
    case water = "Water"

    var icon: String {
        switch self {
        case .fire:  return "flame.fill"
        case .earth: return "leaf.fill"
        case .air:   return "wind"
        case .water: return "drop.fill"
        }
    }

    var color: Color {
        switch self {
        case .fire:  return Color(hex: "FF6B47")
        case .earth: return Color(hex: "4CAF82")
        case .air:   return Color(hex: "4A90D9")
        case .water: return Color(hex: "2E86AB")
        }
    }
}

// MARK: - Zodiac Sign

enum ZodiacSign: String, CaseIterable {
    case aries       = "Aries"
    case taurus      = "Taurus"
    case gemini      = "Gemini"
    case cancer      = "Cancer"
    case leo         = "Leo"
    case virgo       = "Virgo"
    case libra       = "Libra"
    case scorpio     = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn   = "Capricorn"
    case aquarius    = "Aquarius"
    case pisces      = "Pisces"

    var symbol: String {
        switch self {
        case .aries:       return "♈"
        case .taurus:      return "♉"
        case .gemini:      return "♊"
        case .cancer:      return "♋"
        case .leo:         return "♌"
        case .virgo:       return "♍"
        case .libra:       return "♎"
        case .scorpio:     return "♏"
        case .sagittarius: return "♐"
        case .capricorn:   return "♑"
        case .aquarius:    return "♒"
        case .pisces:      return "♓"
        }
    }

    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius:       return .fire
        case .taurus, .virgo, .capricorn:      return .earth
        case .gemini, .libra, .aquarius:       return .air
        case .cancer, .scorpio, .pisces:       return .water
        }
    }

    var color: Color { element.color }
}

// MARK: - Compatibility Calculator

private func compatibilityScore(
    mySun: ZodiacSign?, partnerSun: ZodiacSign?,
    myMoon: ZodiacSign?, partnerMoon: ZodiacSign?
) -> Int {
    guard let sun1 = mySun, let sun2 = partnerSun else { return 0 }

    var score: Int

    // Base element compatibility
    let e1 = sun1.element
    let e2 = sun2.element

    if e1 == e2 {
        score = 95
    } else {
        switch (e1, e2) {
        case (.fire, .air), (.air, .fire):       score = 85
        case (.earth, .water), (.water, .earth): score = 85
        case (.air, .earth), (.earth, .air):     score = 70
        case (.air, .water), (.water, .air):     score = 60
        case (.fire, .water), (.water, .fire):   score = 50
        case (.fire, .earth), (.earth, .fire):   score = 55
        default:                                 score = 65
        }
    }

    // Moon compatibility bonus
    if let moon1 = myMoon, let moon2 = partnerMoon {
        if moon1.element == moon2.element {
            score = min(100, score + 8)
        } else {
            let me = moon1.element
            let pe = moon2.element
            let compatible: Bool
            switch (me, pe) {
            case (.fire, .air), (.air, .fire),
                 (.earth, .water), (.water, .earth):
                compatible = true
            default:
                compatible = false
            }
            if compatible {
                score = min(100, score + 4)
            }
        }
    }

    return score
}

private func compatibilityDescription(_ score: Int) -> String {
    switch score {
    case 90...100: return "An extraordinary soul resonance. Your energies merge like stars in perfect alignment — rare and transcendent."
    case 80..<90:  return "A powerful and harmonious connection. Your elemental energies flow together with natural ease and deep understanding."
    case 70..<80:  return "A dynamic bond with great potential. Your differences create a beautiful tension that can lead to profound growth."
    case 60..<70:  return "A relationship that invites deep learning. Through each other, you discover hidden aspects of yourselves."
    default:       return "A transformative connection. The contrast between your energies is your greatest teacher and catalyst for change."
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @AppStorage("userName")             private var userName             = ""
    @AppStorage("reminderEnabled")      private var reminderEnabled      = false
    @AppStorage("reminderHour")         private var reminderHour         = 9
    @AppStorage("reminderMinute")       private var reminderMinute       = 0
    @AppStorage("mySunSign")            private var mySunSignRaw         = ""
    @AppStorage("myMoonSign")           private var myMoonSignRaw        = ""
    @AppStorage("myRisingSign")         private var myRisingSignRaw      = ""
    @AppStorage("myBirthTimestamp")     private var myBirthTimestamp     = 0.0
    @AppStorage("partnerName")          private var partnerName          = ""
    @AppStorage("partnerSunSign")       private var partnerSunSignRaw    = ""
    @AppStorage("partnerMoonSign")      private var partnerMoonSignRaw   = ""
    @AppStorage("partnerRisingSign")    private var partnerRisingSignRaw = ""
    @AppStorage("partnerBirthTimestamp") private var partnerBirthTimestamp = 0.0
    @AppStorage("showPartnerChart")     private var showPartnerChart     = false

    @State private var streak              = StreakTracker.current
    @State private var editingName         = false
    @State private var nameInput           = ""
    @State private var reminderTime        = Date()
    @State private var showPermissionAlert = false
    @State private var showTutorial        = false
    @State private var appeared            = false

    private var displayName: String { userName.isEmpty ? "Soul" : userName }

    private var mySunSign:      ZodiacSign? { ZodiacSign(rawValue: mySunSignRaw) }
    private var myMoonSign:     ZodiacSign? { ZodiacSign(rawValue: myMoonSignRaw) }
    private var myRisingSign:   ZodiacSign? { ZodiacSign(rawValue: myRisingSignRaw) }
    private var partnerSunSign:    ZodiacSign? { ZodiacSign(rawValue: partnerSunSignRaw) }
    private var partnerMoonSign:   ZodiacSign? { ZodiacSign(rawValue: partnerMoonSignRaw) }
    private var partnerRisingSign: ZodiacSign? { ZodiacSign(rawValue: partnerRisingSignRaw) }

    private var showCompatibility: Bool { mySunSign != nil && partnerSunSign != nil }

    private var score: Int {
        compatibilityScore(
            mySun: mySunSign, partnerSun: partnerSunSign,
            myMoon: myMoonSign, partnerMoon: partnerMoonSign
        )
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            // Seshat golden-blue atmospheric glow
            RadialGradient(
                colors: [Color(hex: "A0A0D0").opacity(0.06), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // ── Seshat Deity Banner ──
                    seshatBanner
                        .padding(.top, 8)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)

                    // MARK: Avatar + Name
                    avatarSection
                        .opacity(appeared ? 1 : 0)

                    // MARK: Sacred Progress
                    if let profile = GamificationService.shared.profile {
                        NavigationLink {
                            ProgressionView()
                                .environment(GamificationService.shared)
                        } label: {
                            VibrationalScoreCard(profile: profile)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                    }

                    // MARK: Streak
                    streakSection

                    // MARK: Birth Chart
                    birthChartSection

                    // MARK: Partner's Chart
                    partnerChartSection

                    // MARK: Compatibility
                    if showCompatibility {
                        compatibilitySection
                    }

                    // MARK: Daily Reminder
                    reminderSection

                    // MARK: About
                    aboutSection

                    Spacer().frame(height: 20)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.lavender)
                }
                .accessibilityLabel("Settings")
            }
        }
        .onAppear {
            streak = StreakTracker.current
            var comps = DateComponents()
            comps.hour   = reminderHour
            comps.minute = reminderMinute
            reminderTime = Calendar.current.date(from: comps) ?? Date()
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        }
        .alert("Notifications Needed", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { reminderEnabled = false }
        } message: {
            Text("Please enable notifications in Settings to receive your daily affirmation.")
        }
    }

    // MARK: - Seshat Banner

    private var seshatBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: "A0A0D0").opacity(0.45), Color(hex: "A0A0D0").opacity(0.08)],
                        center: .center, startRadius: 0, endRadius: 26
                    ))
                    .frame(width: 52, height: 52)
                Circle()
                    .strokeBorder(Color(hex: "A0A0D0").opacity(0.35), lineWidth: 1)
                    .frame(width: 52, height: 52)
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: "A0A0D0"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("SACRED RECORD · SESHAT")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(2.0)
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
                Text(displayName + "'s Soul Record")
                    .font(AppFont.serifTitle(17))
                    .foregroundStyle(Color(hex: "A0A0D0"))
                Text("Seshat recorded your soul contract in the stars.")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
                    .italic()
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: 14) {
            ZStack {
                // Outer halo rings
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .stroke(AppColors.gold.opacity(0.08 - Double(i) * 0.03), lineWidth: 1)
                        .frame(width: CGFloat(104 + i * 18), height: CGFloat(104 + i * 18))
                        .accessibilityHidden(true)
                }
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.purple.opacity(0.8), AppColors.deepViolet],
                            center: .center,
                            startRadius: 0,
                            endRadius: 44
                        )
                    )
                    .frame(width: 88, height: 88)
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [AppColors.gold.opacity(0.6), AppColors.gold.opacity(0.2), AppColors.gold.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 88, height: 88)
                Text(displayName.prefix(1).uppercased())
                    .font(AppFont.serifHeadline(36))
                    .foregroundStyle(AppColors.cream)
            }

            if editingName {
                HStack(spacing: 10) {
                    TextField("Your name", text: $nameInput)
                        .font(AppFont.body(16))
                        .foregroundStyle(AppColors.cream)
                        .tint(AppColors.gold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1)
                        )

                    Button {
                        HapticManager.notification(.success)
                        userName = nameInput.trimmingCharacters(in: .whitespaces)
                        editingName = false
                    } label: {
                        Text("Save")
                            .font(AppFont.body(14, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                }
                .padding(.horizontal, 40)
            } else {
                Button {
                    HapticManager.impact(.light)
                    nameInput = userName
                    editingName = true
                } label: {
                    VStack(spacing: 3) {
                        Text(displayName)
                            .font(AppFont.serifHeadline(24))
                            .foregroundStyle(AppColors.cream)
                        Text("Tap to edit name")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "Your Streak")

            HStack(spacing: 0) {
                StreakStat(value: "\(streak)", label: "Day Streak")
                Divider()
                    .frame(height: 40)
                    .background(AppColors.purple.opacity(0.3))
                StreakStat(value: streak > 0 ? "🔥" : "—", label: "On Fire")
                Divider()
                    .frame(height: 40)
                    .background(AppColors.purple.opacity(0.3))
                StreakStat(
                    value: streak >= 7 ? "⭐️" : "\(7 - min(streak, 7))d",
                    label: streak >= 7 ? "Milestone" : "To 7-day"
                )
            }
            .padding(.vertical, 18)
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Birth Chart Section

    private var birthChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "My Birth Chart")

            VStack(spacing: 0) {
                // Birth date picker
                BirthDateRow(
                    label: "🎂 Birth Date",
                    timestamp: $myBirthTimestamp,
                    onDateChange: { ts in
                        if let sign = sunSignFrom(timestamp: ts) {
                            mySunSignRaw = sign.rawValue
                        }
                    }
                )
                Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                SignPickerRow(
                    label: myBirthTimestamp > 0 ? "☀️ Sun Sign (auto)" : "☀️ Sun Sign",
                    selectedRaw: $mySunSignRaw
                )
                Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                SignPickerRow(
                    label: "🌙 Moon Sign",
                    selectedRaw: $myMoonSignRaw
                )
                Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                SignPickerRow(
                    label: "↑ Rising Sign",
                    selectedRaw: $myRisingSignRaw
                )
            }
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Partner Chart Section

    private var partnerChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ProfileSectionHeader(title: "Partner's Chart")
                Spacer()
                Button {
                    HapticManager.impact(.light)
                    withAnimation { showPartnerChart.toggle() }
                } label: {
                    Image(systemName: showPartnerChart ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                }
                .accessibilityLabel(showPartnerChart ? "Collapse partner chart" : "Expand partner chart")
                .padding(.trailing, 4)
            }

            if showPartnerChart {
                VStack(spacing: 0) {
                    // Partner name
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 28)
                        TextField("Partner's name (optional)", text: $partnerName)
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.cream)
                            .tint(AppColors.gold)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)

                    Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)

                    BirthDateRow(
                        label: "🎂 Birth Date",
                        timestamp: $partnerBirthTimestamp,
                        onDateChange: { ts in
                            if let sign = sunSignFrom(timestamp: ts) {
                                partnerSunSignRaw = sign.rawValue
                            }
                        }
                    )
                    Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                    SignPickerRow(label: partnerBirthTimestamp > 0 ? "☀️ Sun Sign (auto)" : "☀️ Sun Sign", selectedRaw: $partnerSunSignRaw)
                    Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                    SignPickerRow(label: "🌙 Moon Sign", selectedRaw: $partnerMoonSignRaw)
                    Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                    SignPickerRow(label: "↑ Rising Sign", selectedRaw: $partnerRisingSignRaw)
                }
                .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Compatibility Section

    private var compatibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                ProfileSectionHeader(title: "Soul Compatibility")
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: "88D8B0").opacity(0.7))
                    Text("Harmonia · Maat")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "88D8B0").opacity(0.7))
                }
                .padding(.trailing, 4)
            }

            VStack(spacing: 20) {
                // Score ring
                ZStack {
                    Circle()
                        .stroke(AppColors.purple.opacity(0.2), lineWidth: 12)
                        .frame(width: 140, height: 140)

                    Circle()
                        .trim(from: 0, to: CGFloat(score) / 100)
                        .stroke(
                            AngularGradient(
                                colors: [AppColors.gold, AppColors.coral, AppColors.gold],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1, dampingFraction: 0.7), value: score)

                    VStack(spacing: 2) {
                        Text("\(score)")
                            .font(AppFont.serifHeadline(36))
                            .foregroundStyle(AppColors.gold)
                        Text("/ 100")
                            .font(AppFont.caption(13))
                            .foregroundStyle(AppColors.lavender)
                    }
                }

                VStack(spacing: 6) {
                    Text("Soul Resonance")
                        .font(AppFont.body(13, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                        .textCase(.uppercase)
                        .kerning(1.5)

                    Text(compatibilityDescription(score))
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.cream)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                }

                // Sign badges
                if let sun1 = mySunSign, let sun2 = partnerSunSign {
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text(sun1.symbol)
                                .font(.system(size: 28))
                            Text(sun1.rawValue)
                                .font(AppFont.caption(12))
                                .foregroundStyle(sun1.color)
                        }

                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.coral.opacity(0.7))

                        VStack(spacing: 4) {
                            Text(sun2.symbol)
                                .font(.system(size: 28))
                            Text(sun2.rawValue)
                                .font(AppFont.caption(12))
                                .foregroundStyle(sun2.color)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Reminder Section

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "Daily Reminder")

            VStack(spacing: 0) {
                Toggle(isOn: $reminderEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 28)
                        Text("Daily affirmation reminder")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.cream)
                    }
                }
                .tint(AppColors.gold)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .onChange(of: reminderEnabled) {
                    reminderEnabled ? scheduleReminder() : cancelReminder()
                }

                if reminderEnabled {
                    Divider()
                        .background(AppColors.purple.opacity(0.3))
                        .padding(.horizontal, 18)

                    DatePicker(
                        "Reminder time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(AppColors.gold)
                    .colorScheme(.dark)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 8)
                    .onChange(of: reminderTime) {
                        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                        reminderHour   = comps.hour   ?? 9
                        reminderMinute = comps.minute ?? 0
                        scheduleReminder()
                    }
                }
            }
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "About")

            VStack(spacing: 0) {
                ProfileInfoRow(icon: "flame.fill", text: "Twin Flame Union", detail: "Version 1.0")
                Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                ProfileInfoRow(
                    icon: "moon.stars.fill",
                    text: "Moon phase",
                    detail: MoonPhase.current().name + " " + MoonPhase.current().emoji
                )
                Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 18)
                Button {
                    HapticManager.impact(.light)
                    showTutorial = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 28)
                            .accessibilityHidden(true)
                        Text("View Tutorial")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.cream)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.lavender.opacity(0.4))
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showTutorial) {
            TutorialView()
        }
    }

    // MARK: - Notifications

    private func scheduleReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                guard granted else {
                    showPermissionAlert = true
                    reminderEnabled = false
                    return
                }
                let content = UNMutableNotificationContent()
                content.title = "Daily Affirmation ✨"
                let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
                let affirmations = [
                    "I am worthy of deep, unconditional love.",
                    "My heart is open to divine connection.",
                    "I trust the journey my soul has chosen.",
                    "Love flows to me easily and effortlessly.",
                    "I am aligned with my highest self.",
                ]
                content.body = affirmations[day % affirmations.count]
                content.sound = .default

                var trigger = DateComponents()
                trigger.hour   = reminderHour
                trigger.minute = reminderMinute

                let request = UNNotificationRequest(
                    identifier: "dailyAffirmation",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
                )
                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyAffirmation"])
    }
}

// MARK: - Sun Sign Calculator

private func sunSignFrom(timestamp: Double) -> ZodiacSign? {
    guard timestamp > 0 else { return nil }
    let date = Date(timeIntervalSince1970: timestamp)
    let cal = Calendar.current
    let month = cal.component(.month, from: date)
    let day   = cal.component(.day,   from: date)
    switch month {
    case 1:  return day >= 20 ? .aquarius    : .capricorn
    case 2:  return day >= 19 ? .pisces      : .aquarius
    case 3:  return day >= 21 ? .aries       : .pisces
    case 4:  return day >= 20 ? .taurus      : .aries
    case 5:  return day >= 21 ? .gemini      : .taurus
    case 6:  return day >= 21 ? .cancer      : .gemini
    case 7:  return day >= 23 ? .leo         : .cancer
    case 8:  return day >= 23 ? .virgo       : .leo
    case 9:  return day >= 23 ? .libra       : .virgo
    case 10: return day >= 24 ? .scorpio     : .libra
    case 11: return day >= 23 ? .sagittarius : .scorpio
    case 12: return day >= 22 ? .capricorn   : .sagittarius
    default: return nil
    }
}

// MARK: - Birth Date Row

private struct BirthDateRow: View {
    let label: String
    @Binding var timestamp: Double
    let onDateChange: (Double) -> Void

    @State private var isExpanded = false

    private var date: Date {
        timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : Date(timeIntervalSinceReferenceDate: -946771200) // ~1970
    }

    private var displayText: String {
        guard timestamp > 0 else { return "Set date" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    Text(label)
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundStyle(AppColors.cream)
                    Spacer()
                    Text(displayText)
                        .font(AppFont.caption(13))
                        .foregroundStyle(timestamp > 0 ? AppColors.gold : AppColors.lavender.opacity(0.5))
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { date },
                        set: { newDate in
                            timestamp = newDate.timeIntervalSince1970
                            onDateChange(newDate.timeIntervalSince1970)
                        }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(AppColors.gold)
                .colorScheme(.dark)
                .padding(.horizontal, 18)
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Sign Picker Row

private struct SignPickerRow: View {
    let label: String
    @Binding var selectedRaw: String

    var selected: ZodiacSign? { ZodiacSign(rawValue: selectedRaw) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppFont.body(14, weight: .semibold))
                .foregroundStyle(AppColors.cream)
                .padding(.horizontal, 18)
                .padding(.top, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // None / clear option
                    Button {
                        selectedRaw = ""
                    } label: {
                        Text("—")
                            .font(AppFont.caption(13))
                            .foregroundStyle(selectedRaw.isEmpty ? .white : AppColors.lavender)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedRaw.isEmpty
                                    ? AppColors.purple.opacity(0.6)
                                    : AppColors.deepViolet.opacity(0.5),
                                in: Capsule()
                            )
                            .overlay(Capsule().strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1))
                    }

                    ForEach(ZodiacSign.allCases, id: \.self) { sign in
                        Button {
                            selectedRaw = sign.rawValue
                        } label: {
                            HStack(spacing: 5) {
                                Text(sign.symbol)
                                    .font(.system(size: 14))
                                Text(sign.rawValue)
                                    .font(AppFont.caption(12, weight: selected == sign ? .semibold : .regular))
                                    .foregroundStyle(selected == sign ? .white : AppColors.lavender)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                selected == sign
                                    ? sign.color.opacity(0.6)
                                    : AppColors.deepViolet.opacity(0.5),
                                in: Capsule()
                            )
                            .overlay(Capsule().strokeBorder(selected == sign ? sign.color : AppColors.purple.opacity(0.3), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - Sub-components

private struct ProfileSectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(AppColors.lavender.opacity(0.7))
            .padding(.horizontal, 4)
    }
}

private struct StreakStat: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.serifHeadline(24))
                .foregroundStyle(AppColors.gold)
            Text(label)
                .font(AppFont.caption(11))
                .foregroundStyle(AppColors.lavender)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileInfoRow: View {
    let icon: String
    let text: String
    let detail: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.gold)
                .frame(width: 28)
                .accessibilityHidden(true)
            Text(text)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
            Spacer()
            Text(detail)
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}
