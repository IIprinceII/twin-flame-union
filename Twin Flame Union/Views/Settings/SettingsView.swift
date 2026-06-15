//
//  SettingsView.swift
//  Twin Flame Union
//
//  Full settings screen with notifications, premium, about, and data sections.
//

import SwiftUI
import SwiftData
import UserNotifications
import StoreKit

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var journalEntries: [JournalEntry]

    // Notification settings
    @AppStorage("reminderEnabled")      private var reminderEnabled      = false
    @AppStorage("reminderHour")         private var reminderHour         = 9
    @AppStorage("reminderMinute")       private var reminderMinute       = 0
    @AppStorage("moonPhaseAlertEnabled") private var moonPhaseAlertEnabled = false

    // Onboarding flag — reset to false after account deletion to return to onboarding.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var reminderTime         = Date()
    @State private var showPermissionAlert  = false
    @State private var showClearConfirm     = false
    @State private var showDeleteAccount    = false

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Section 1: Notifications
                    notificationsSection

                    // Section 2: About
                    aboutSection

                    // Section 4: Data
                    dataSection

                    // Section 5: Account
                    accountSection

                    Spacer().frame(height: 32)
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            var comps = DateComponents()
            comps.hour   = reminderHour
            comps.minute = reminderMinute
            reminderTime = Calendar.current.date(from: comps) ?? Date()
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
        .confirmationDialog("Clear all journal entries?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear All Entries", role: .destructive) {
                clearJournal()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone. All \(journalEntries.count) entries will be permanently deleted.")
        }
        .confirmationDialog("Delete your account?", isPresented: $showDeleteAccount, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This permanently deletes your profile and all of your data on this device — journals, dreams, manifestations, progress, and settings. This cannot be undone.")
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        SettingsCard(title: "Notifications") {
            Toggle(isOn: $reminderEnabled) {
                SettingsRow(icon: "bell.fill", iconColor: AppColors.gold, label: "Daily affirmation reminder")
            }
            .tint(AppColors.gold)
            .onChange(of: reminderEnabled) {
                reminderEnabled ? scheduleReminder() : cancelReminder()
            }

            if reminderEnabled {
                Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

                DatePicker(
                    "Reminder time",
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(AppColors.gold)
                .colorScheme(.dark)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .onChange(of: reminderTime) {
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                    reminderHour   = comps.hour   ?? 9
                    reminderMinute = comps.minute ?? 0
                    scheduleReminder()
                }
            }

            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Toggle(isOn: $moonPhaseAlertEnabled) {
                SettingsRow(icon: "moon.stars.fill", iconColor: AppColors.lavender, label: "Moon phase alerts")
            }
            .tint(AppColors.lavender)
            .onChange(of: moonPhaseAlertEnabled) {
                moonPhaseAlertEnabled ? scheduleMoonAlert() : cancelMoonAlert()
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SettingsCard(title: "About") {
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

            SettingsRowButton(icon: "info.circle.fill", iconColor: AppColors.lavender, label: "App Version", detail: "\(appVersion) (\(buildNumber))")

            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } label: {
                SettingsRowButton(icon: "star.fill", iconColor: AppColors.gold, label: "Rate the App", showChevron: true)
            }

            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                if let url = URL(string: "https://iiprinceii.github.io/twin-flame-union-privacy/") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRowButton(icon: "hand.raised.fill", iconColor: AppColors.purple, label: "Privacy Policy", showChevron: true)
            }

            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRowButton(icon: "doc.text.fill", iconColor: AppColors.lavender, label: "Terms of Service", showChevron: true)
            }
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        SettingsCard(title: "Data") {
            Button(role: .destructive) {
                showClearConfirm = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.coral)
                        .frame(width: 28)
                    Text("Clear Journal Entries")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.coral)
                    Spacer()
                    if !journalEntries.isEmpty {
                        Text("\(journalEntries.count) entries")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.coral.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        SettingsCard(title: "Account") {
            VStack(alignment: .leading, spacing: 0) {
                Button(role: .destructive) {
                    showDeleteAccount = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.coral)
                            .frame(width: 28)
                        Text("Delete Account")
                            .font(AppFont.body(15))
                            .foregroundStyle(AppColors.coral)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }

                Text("Permanently deletes your profile and all data stored on this device, then returns you to the welcome screen. This cannot be undone.")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
            }
        }
    }

    // MARK: - Helpers

    private func clearJournal() {
        for entry in journalEntries {
            modelContext.delete(entry)
        }
    }

    /// Full account deletion (Apple Guideline 5.1.1(v)): erases every on-device
    /// record and the user's profile, then returns the app to first-launch onboarding.
    private func deleteAccount() {
        // 1. Delete every SwiftData record across all models.
        try? modelContext.delete(model: JournalEntry.self)
        try? modelContext.delete(model: DreamEntry.self)
        try? modelContext.delete(model: SynchronicityEntry.self)
        try? modelContext.delete(model: ChakraEntry.self)
        try? modelContext.delete(model: ManifestationItem.self)
        try? modelContext.delete(model: ConnectionMoment.self)
        try? modelContext.delete(model: PrayerEntry.self)
        try? modelContext.delete(model: GratitudeEntry.self)
        try? modelContext.delete(model: SoulProfile.self)
        try? modelContext.delete(model: XPEvent.self)
        try? modelContext.delete(model: Achievement.self)
        try? modelContext.delete(model: DailyChallenge.self)
        try? modelContext.save()

        // 2. Cancel any scheduled notifications.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()

        // 3. Wipe the profile and every stored preference (name, birth data,
        //    premium flags, gamification cache, onboarding state, etc.).
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }

        // 4. Return to first-launch onboarding so the user starts completely fresh.
        hasCompletedOnboarding = false
    }

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

    private func scheduleMoonAlert() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                guard granted else { moonPhaseAlertEnabled = false; return }
                let content = UNMutableNotificationContent()
                content.title = "Moon Phase Update 🌙"
                let moon = MoonPhase.current()
                content.body = "\(moon.emoji) \(moon.name) — \(moon.meaning)"
                content.sound = .default
                // Fire daily at 7 AM
                var comps = DateComponents()
                comps.hour = 7; comps.minute = 0
                let request = UNNotificationRequest(
                    identifier: "moonPhaseAlert",
                    content: content,
                    trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                )
                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    private func cancelMoonAlert() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["moonPhaseAlert"])
    }
}

// MARK: - Settings Card

private struct SettingsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.body(13, weight: .semibold))
                .foregroundStyle(AppColors.lavender)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            Text(label)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
        }
    }
}

// MARK: - Settings Row Button

private struct SettingsRowButton: View {
    let icon: String
    let iconColor: Color
    let label: String
    var detail: String? = nil
    var showChevron: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            Text(label)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
            Spacer()
            if let detail {
                Text(detail)
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

