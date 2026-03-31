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
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour")    private var reminderHour    = 9
    @AppStorage("reminderMinute")  private var reminderMinute  = 0

    @State private var reminderTime        = Date()
    @State private var showPermissionAlert = false
    @State private var showClearConfirm    = false
    @State private var storeService        = StoreService.shared

    var body: some View {
        ZStack {
            CosmicBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Section 1: Notifications
                    notificationsSection

                    // Section 2: Premium
                    premiumSection

                    // Section 3: About
                    aboutSection

                    // Section 4: Data
                    dataSection

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
        }
    }

    // MARK: - Premium Section

    private var premiumSection: some View {
        Group {
            if storeService.isPremium {
                premiumMemberCard
            } else {
                upgradeCard
            }
        }
    }

    private var premiumMemberCard: some View {
        SettingsCard(title: "Premium") {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.gold.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text("✨")
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("✨ Premium Member")
                        .font(AppFont.body(16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                    Text("Thank you for supporting Twin Flame Union")
                        .font(AppFont.caption(13))
                        .foregroundStyle(AppColors.lavender)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                Task { await storeService.restore() }
            } label: {
                SettingsRowButton(icon: "arrow.clockwise", iconColor: AppColors.lavender, label: "Restore Purchases")
            }
        }
    }

    private var upgradeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Premium")
                    .font(AppFont.body(13, weight: .semibold))
                    .foregroundStyle(AppColors.lavender)
                Spacer()
            }

            VStack(spacing: 0) {
                // Gradient border card
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Unlock Premium ✨")
                            .font(AppFont.serifHeadline(22))
                            .foregroundStyle(AppColors.cream)

                        Text("Everything you need for your twin flame journey")
                            .font(AppFont.body(13))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 4)

                    // Features
                    VStack(spacing: 10) {
                        PremiumFeatureRow(text: "Unlimited AI coaching with Luna")
                        PremiumFeatureRow(text: "All meditation sessions unlocked")
                        PremiumFeatureRow(text: "Full oracle card readings")
                        PremiumFeatureRow(text: "Priority spiritual support")
                    }

                    // Product buttons
                    if storeService.isLoading {
                        ProgressView()
                            .tint(AppColors.gold)
                            .padding(.vertical, 8)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(storeService.products, id: \.id) { product in
                                SettingsProductButton(product: product) {
                                    Task {
                                        try? await storeService.purchase(product)
                                    }
                                }
                            }

                            if storeService.products.isEmpty {
                                Text("Tap to load products")
                                    .font(AppFont.caption(13))
                                    .foregroundStyle(AppColors.lavender)
                                    .onTapGesture {
                                        Task { await storeService.loadProducts() }
                                    }
                            }
                        }
                    }
                }
                .padding(20)
                .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [AppColors.gold.opacity(0.6), AppColors.coral.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

                // Restore button
                Button {
                    Task { await storeService.restore() }
                } label: {
                    Text("Restore Purchases")
                        .font(AppFont.body(13))
                        .foregroundStyle(AppColors.lavender)
                        .underline()
                        .padding(.vertical, 12)
                }
            }
        }
        .onAppear {
            if storeService.products.isEmpty {
                Task { await storeService.loadProducts() }
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
                if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRowButton(icon: "star.fill", iconColor: AppColors.gold, label: "Rate the App", showChevron: true)
            }

            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                if let url = URL(string: "https://twinflameunion.app/privacy") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRowButton(icon: "hand.raised.fill", iconColor: AppColors.purple, label: "Privacy Policy", showChevron: true)
            }

            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                if let url = URL(string: "https://twinflameunion.app/terms") {
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

    // MARK: - Helpers

    private func clearJournal() {
        for entry in journalEntries {
            modelContext.delete(entry)
        }
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

// MARK: - Premium Feature Row

private struct PremiumFeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.gold)
            Text(text)
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.cream)
            Spacer()
        }
    }
}

// MARK: - Settings Product Button

private struct SettingsProductButton: View {
    let product: Product
    let action: () -> Void

    private var isAnnual: Bool { product.id.contains("annual") }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(AppFont.body(15, weight: .semibold))
                            .foregroundStyle(AppColors.cream)
                        if isAnnual {
                            Text("Best Value")
                                .font(AppFont.caption(10, weight: .semibold))
                                .foregroundStyle(AppColors.deepViolet)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.gold, in: Capsule())
                        }
                    }
                    if product.subscription != nil {
                        Text(isAnnual ? "Billed annually" : "Billed monthly")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.lavender)
                    }
                }

                Spacer()

                Text(product.displayPrice)
                    .font(AppFont.body(16, weight: .bold))
                    .foregroundStyle(AppColors.gold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isAnnual ? AppColors.purple.opacity(0.25) : AppColors.deepViolet.opacity(0.5),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isAnnual ? AppColors.gold.opacity(0.4) : AppColors.purple.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
    }
}
