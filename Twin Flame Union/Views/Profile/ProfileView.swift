//
//  ProfileView.swift
//  Twin Flame Union
//
//  Profile tab with guiding deities, divine resonance, streak, and reminders.
//

import SwiftUI
import UserNotifications

// MARK: - Profile View

struct ProfileView: View {
    @AppStorage("userName")             private var userName             = ""
    @AppStorage("reminderEnabled")      private var reminderEnabled      = false
    @AppStorage("reminderHour")         private var reminderHour         = 9
    @AppStorage("reminderMinute")       private var reminderMinute       = 0
    @AppStorage("partnerName")          private var partnerName          = ""
    @AppStorage("showPartnerChart")     private var showPartnerChart     = false
    @AppStorage("myGuidingDeity")       private var myGuidingDeity       = ""
    @AppStorage("partnerGuidingDeity")  private var partnerGuidingDeity  = ""

    @State private var streak              = StreakTracker.current
    @State private var editingName         = false
    @State private var nameInput           = ""
    @State private var reminderTime        = Date()
    @State private var showPermissionAlert = false
    @State private var showTutorial        = false
    @State private var appeared            = false
    @State private var showMyDeityPicker   = false
    @State private var showPartnerDeityPicker = false

    private var displayName: String { userName.isEmpty ? "Soul" : userName }

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

                    // MARK: My Guiding Deity
                    myChartSection

                    // MARK: Partner's Guiding Deity
                    partnerChartSection

                    // MARK: Divine Resonance
                    divineLinksSection

                    // MARK: Daily Reminder
                    reminderSection

                    // MARK: About
                    aboutSection

                    Spacer().frame(height: 20)
                }
                .padding(.top, 8)
                .readableWidth()
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

    // MARK: - My Chart Section (Guiding Deity)

    private var myChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "My Sacred Profile")

            VStack(spacing: 0) {
                guidingDeityCard
                    .padding(.horizontal, 18)
                    .padding(.vertical, 4)
            }
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Guiding Deity Card (My)

    private var guidingDeityCard: some View {
        Button { showMyDeityPicker = true } label: {
            HStack(spacing: 14) {
                if let deity = DivinePantheon.deity(named: myGuidingDeity) {
                    Image(systemName: deity.symbol).foregroundStyle(deity.color).font(.system(size: 24))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(deity.name).font(.headline).foregroundStyle(AppColors.cream)
                        Text("Walks with you · \(deity.culture)").font(.caption).foregroundStyle(AppColors.lavender)
                    }
                } else {
                    Image(systemName: "sparkles").foregroundStyle(AppColors.gold).font(.system(size: 24))
                        .accessibilityHidden(true)
                    Text("Choose your Guiding Deity").font(.headline).foregroundStyle(AppColors.cream)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(AppColors.lavender).font(.caption)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(AppColors.purple.opacity(0.12))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showMyDeityPicker) {
            GuidingDeityPickerView(selectedName: $myGuidingDeity, title: "Your Guiding Deity")
        }
        .accessibilityHint("Choose the God or Goddess who walks with you")
    }

    // MARK: - Partner Chart Section (Guiding Deity)

    private var partnerChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ProfileSectionHeader(title: "Twin Flame's Profile")
                Spacer()
                Button {
                    HapticManager.impact(.light)
                    withAnimation { showPartnerChart.toggle() }
                } label: {
                    Image(systemName: showPartnerChart ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.lavender)
                }
                .accessibilityLabel(showPartnerChart ? "Collapse twin flame profile" : "Expand twin flame profile")
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
                    partnerGuidingDeityCard
                        .padding(.horizontal, 18)
                        .padding(.vertical, 4)
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

    // MARK: - Guiding Deity Card (Partner)

    private var partnerGuidingDeityCard: some View {
        Button { showPartnerDeityPicker = true } label: {
            HStack(spacing: 14) {
                if let deity = DivinePantheon.deity(named: partnerGuidingDeity) {
                    Image(systemName: deity.symbol).foregroundStyle(deity.color).font(.system(size: 24))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(deity.name).font(.headline).foregroundStyle(AppColors.cream)
                        Text("Walks with your twin flame · \(deity.culture)").font(.caption).foregroundStyle(AppColors.lavender)
                    }
                } else {
                    Image(systemName: "sparkles").foregroundStyle(AppColors.gold).font(.system(size: 24))
                        .accessibilityHidden(true)
                    Text("Choose your twin flame's Guiding Deity").font(.headline).foregroundStyle(AppColors.cream)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(AppColors.lavender).font(.caption)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(AppColors.purple.opacity(0.12))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPartnerDeityPicker) {
            GuidingDeityPickerView(selectedName: $partnerGuidingDeity, title: "Your Twin Flame's Guiding Deity")
        }
        .accessibilityHint("Choose the God or Goddess who walks with your twin flame")
    }

    // MARK: - Divine Links Section (Resonance)

    private var divineLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "Sacred Union")

            VStack(spacing: 0) {
                divineResonanceCard
                    .padding(.horizontal, 18)
                    .padding(.vertical, 4)
            }
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.gold.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Divine Resonance Card

    private var divineResonanceCard: some View {
        NavigationLink(destination: SacredSoulResonanceView()) {
            HStack(spacing: 14) {
                Image(systemName: "infinity").foregroundStyle(AppColors.gold).font(.system(size: 22))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Divine Resonance").font(.headline).foregroundStyle(AppColors.cream)
                    Text("How your Deities weave your union").font(.caption).foregroundStyle(AppColors.lavender)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(AppColors.lavender).font(.caption)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(AppColors.purple.opacity(0.12))
            .cornerRadius(14)
        }
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
                    NotificationScheduler.shared.reschedule()
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
                        NotificationScheduler.shared.reschedule()
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
