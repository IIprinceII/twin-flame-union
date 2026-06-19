//
//  NotificationScheduler.swift
//  Twin Flame Union
//
//  Daily local notifications — affirmation, moon phase, and ritual reminder.
//  Reads the existing AppStorage keys ("reminderEnabled", "reminderHour",
//  "reminderMinute") and is idempotent: safe to call at every launch or on
//  any settings change.
//

import Foundation
import UserNotifications

// MARK: - Notification Identifiers

enum NotificationID {
    static let affirmation = "tf.affirmation"
    static let moon        = "tf.moon"
    static let ritual      = "tf.ritual"

    static let all: [String] = [affirmation, moon, ritual]
}

// MARK: - Scheduler

/// `@MainActor` singleton so AppStorage reads happen on the main thread and the
/// type is concurrency-safe without @unchecked Sendable workarounds.
@MainActor
final class NotificationScheduler {

    static let shared = NotificationScheduler()
    private init() {}

    // MARK: - AppStorage keys (mirrors SettingsView / ProfileView)

    private var reminderEnabled: Bool {
        UserDefaults.standard.bool(forKey: "reminderEnabled")
    }
    private var reminderHour: Int {
        // Default 9 — matches SettingsView default.
        // UserDefaults returns 0 for an unset integer key; treat as "not yet set → 9".
        let stored = UserDefaults.standard.integer(forKey: "reminderHour")
        return stored == 0 ? 9 : stored
    }
    private var reminderMinute: Int {
        UserDefaults.standard.integer(forKey: "reminderMinute")
    }

    // MARK: - Public API

    /// Idempotent: removes all previously scheduled TF notifications, then
    /// schedules fresh ones if the user has reminders enabled and permission
    /// is granted. Safe to call at launch and on every settings change.
    func reschedule() {
        let center = UNUserNotificationCenter.current()

        // Always wipe our own pending notifications first.
        center.removePendingNotificationRequests(withIdentifiers: NotificationID.all)

        guard reminderEnabled else { return }

        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                Task { @MainActor in self.addNotifications() }
            default:
                // Permission not granted — nothing to schedule.
                break
            }
        }
    }

    // MARK: - Private helpers

    private func addNotifications() {
        let center = UNUserNotificationCenter.current()
        let hour   = reminderHour
        let minute = reminderMinute

        // 1. Affirmation — at chosen time
        center.add(affirmationRequest(hour: hour, minute: minute))

        // 2. Moon phase — 2 minutes after the chosen time
        let moonTime = Self.normalised(hour: hour, minute: minute + 2)
        center.add(moonRequest(hour: moonTime.hour, minute: moonTime.minute))

        // 3. Ritual reminder — 5 minutes after the chosen time
        let ritualTime = Self.normalised(hour: hour, minute: minute + 5)
        center.add(ritualRequest(hour: ritualTime.hour, minute: ritualTime.minute))
    }

    // MARK: - Content builders (nonisolated so they're testable without @MainActor)

    /// Returns the affirmation text for a given day-of-year (1-based), rotating
    /// deterministically through all affirmations defined in the full corpus.
    nonisolated static func affirmationText(forDayOfYear day: Int) -> String {
        let corpus = Self.affirmationsCorpus
        guard !corpus.isEmpty else { return "I am worthy of divine love." }
        let index = (max(1, day) - 1) % corpus.count
        return corpus[index]
    }

    private func affirmationRequest(hour: Int, minute: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Today's Affirmation ✨"
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        content.body  = Self.affirmationText(forDayOfYear: day)
        content.sound = .default

        var comps    = DateComponents()
        comps.hour   = hour
        comps.minute = minute
        let trigger  = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        return UNNotificationRequest(identifier: NotificationID.affirmation, content: content, trigger: trigger)
    }

    private func moonRequest(hour: Int, minute: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        let moon    = MoonPhase.current()
        content.title = "The Moon Tonight \(moon.emoji)"
        content.body  = "\(moon.name) — \(moon.meaning)"
        content.sound = .default

        var comps    = DateComponents()
        comps.hour   = hour
        comps.minute = minute
        let trigger  = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        return UNNotificationRequest(identifier: NotificationID.moon, content: content, trigger: trigger)
    }

    private func ritualRequest(hour: Int, minute: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        let deity   = DivinePantheon.today
        content.title = "Begin Today's Ritual ✨"
        content.body  = "\(deity.name) walks beside you. A moment to centre before your day."
        content.sound = .default

        var comps    = DateComponents()
        comps.hour   = hour
        comps.minute = minute
        let trigger  = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        return UNNotificationRequest(identifier: NotificationID.ritual, content: content, trigger: trigger)
    }

    // MARK: - Minute arithmetic helper

    /// Wraps minute overflow into the next hour, clamped to 23:59 so we never
    /// cross midnight unexpectedly. Returns (hour, minute) both in valid range.
    nonisolated static func normalised(hour: Int, minute: Int) -> (hour: Int, minute: Int) {
        let totalMinutes = hour * 60 + minute
        let safe = min(totalMinutes, 23 * 60 + 59)
        return (hour: safe / 60, minute: safe % 60)
    }

    // MARK: - Full Affirmations Corpus
    // Mirrors the full list in AffirmationsView so the notification body uses
    // the same sacred, community-authored words. Kept as a pure value type so
    // it can be tested without importing SwiftUI.

    nonisolated static let affirmationsCorpus: [String] = [
        // LOVE
        "I am worthy of a deep, sentimental love that transcends all earthly bonds.",
        "My twin flame and I are united in a sacred covenant of eternal love.",
        "The love I seek is vast, unconditional, and written in the stars by God.",
        "I open my heart fully — I am free to love without fear or attachment.",
        "Jesus Christ's love flows through me and into my twin flame union.",
        "My soul recognises its divine spouse across every dimension and lifetime.",
        "The bond between my twin flame and I is protected by Archangel Michael.",
        "I pray that love guides every step of my reunion — and it is so.",
        "I am free to love. I am free to be loved. I am free.",
        "My heart is open, my crown is clear, and love flows in freely now.",
        "God designed my twin flame union before the foundation of the earth.",
        "I give and receive deep, sacred love — body, soul, and spirit.",
        // SELF-WORTH
        "I am a being of extreme light and vast spiritual intelligence.",
        "God created me to be love, to embody love, to return to love.",
        "I am free from fear. I am free from doubt. I stand in my truth.",
        "My crown chakra is open, activated, and aligned with higher truth.",
        "I am in a positive state of spiritual shift — evolving into my highest self.",
        "My imagination creates the reality I desire — I focus only on union.",
        "I rebuke every thought that says I am less than divinely chosen.",
        "I am a memory of God's love made flesh upon this earth.",
        "Money, love, and freedom flow to me because I am aligned with God.",
        "My youth, my vitality, and my light are fully restored.",
        "I relax into God's plan — I am held, protected, and deeply loved.",
        "KAI and KAZZ — all guides who walk with me — I welcome your light.",
        // HEALING
        "I release all sentimental attachment that binds me to pain.",
        "I pray for the healing of my parents' wounds within me — it is done.",
        "I surrender fear and allow God's light to heal every part of my heart.",
        "Return to sender — all pain, all fear, all interference. It is finished.",
        "I undo every energetic swap that has drained my light and reclaim my spirit.",
        "Archangel Michael clears, cuts, and protects my energy field right now.",
        "I rebuke all spiritual interference. My healing is complete in Jesus' name.",
        "I heal my sexual wounds and reclaim my body as a sacred temple of light.",
        "I allow my ego to die so my higher self may fully live and love.",
        "I reflect on my journey with gratitude — every wound was a teacher.",
        "I heal deeply. I rest completely. I rise in freedom and in truth.",
        "The covenant of healing between my soul and God is active and real.",
        // CONNECTION
        "My telepathy with my twin flame grows clearer and deeper every day.",
        "I focus on our spiritual bond — it is real, vast, and eternal.",
        "The covenant between my soul and my twin flame's soul cannot be broken.",
        "I pray without ceasing — clarity, reunion, and divine protection are mine.",
        "Jesus Christ is the light guiding every step of our twin flame union.",
        "I unite my human self with my spiritual self and walk in deep truth.",
        "My twin flame feels my love through our telepathic bond right now.",
        "Archangel Michael stands at the gate of our reunion — protection is complete.",
        "I shift into the state of reunion — this is my natural spiritual home.",
        "The memory of our union lives in my spirit and draws us together.",
        "God's intelligence orchestrates every detail of our twin flame reunion.",
        "I am open to receiving an energy reading that confirms our divine bond.",
        // MANIFESTATION
        "I am open to the extreme evolution my twin flame journey is calling me into.",
        "My imagination is a prayer — I hold reunion clearly, and God delivers it.",
        "I swap doubt for certainty: my twin flame union is already done in the spirit.",
        "Return to sender — all energy blocking my reunion. I claim my freedom now.",
        "I focus on love and the universe delivers a love beyond what I can imagine.",
        "My divine spouse is drawn to me by the vast intelligence of God's design.",
        "I die to the old story and rise into the positive truth of my union.",
        "Money, healing, reunion — I receive all of God's blessings freely and fully.",
        "All guides — KAZZ, KAI, Michael — align to usher in my twin flame union.",
        "I am in a deep state of surrender, and in that state, all things manifest.",
        "I pray and I receive. I believe and I see. I unite and I am whole.",
        "The television of distraction is off. I am tuned to the frequency of God.",
    ]
}
