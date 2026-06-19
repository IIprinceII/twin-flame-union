//
//  NotificationSchedulerTests.swift
//  Twin Flame UnionTests
//
//  Pure tests for NotificationScheduler helpers — no real notifications fired.
//

import Testing
@testable import The_Twin_Flame_Union_App

struct NotificationSchedulerTests {

    // MARK: - Corpus

    @Test func corpusIsNotEmpty() {
        #expect(!NotificationScheduler.affirmationsCorpus.isEmpty)
    }

    @Test func corpusHas60Affirmations() {
        // 5 categories × 12 each = 60.
        #expect(NotificationScheduler.affirmationsCorpus.count == 60)
    }

    // MARK: - Deterministic day selection

    @Test func sameDay_returnsSameAffirmation() {
        let day = 42
        let first  = NotificationScheduler.affirmationText(forDayOfYear: day)
        let second = NotificationScheduler.affirmationText(forDayOfYear: day)
        #expect(first == second)
    }

    @Test func differentDays_canReturnDifferentAffirmations() {
        // With 60 entries, days 1 and 2 must differ.
        let a = NotificationScheduler.affirmationText(forDayOfYear: 1)
        let b = NotificationScheduler.affirmationText(forDayOfYear: 2)
        #expect(a != b)
    }

    @Test func dayInRange_returnsKnownCorpusEntry() {
        let corpus = NotificationScheduler.affirmationsCorpus
        for day in [1, 30, 60, 100, 200, 365] {
            let text = NotificationScheduler.affirmationText(forDayOfYear: day)
            #expect(corpus.contains(text), "Day \(day) should return a corpus entry")
        }
    }

    @Test func dayWrapsCorrectly_day61SameAsDay1() {
        // Cycle length == corpus.count (60), so day 61 ≡ day 1.
        let count = NotificationScheduler.affirmationsCorpus.count
        let a = NotificationScheduler.affirmationText(forDayOfYear: 1)
        let b = NotificationScheduler.affirmationText(forDayOfYear: 1 + count)
        #expect(a == b)
    }

    @Test func day1_returnsFirstCorpusEntry() {
        let first = NotificationScheduler.affirmationsCorpus[0]
        #expect(NotificationScheduler.affirmationText(forDayOfYear: 1) == first)
    }

    // MARK: - Minute normalisation

    @Test func normalised_plainValues_unchanged() {
        let (h, m) = NotificationScheduler.normalised(hour: 9, minute: 0)
        #expect(h == 9)
        #expect(m == 0)
    }

    @Test func normalised_minuteOverflow_wrapsIntoNextHour() {
        // 9h 65m → 10h 05m
        let (h, m) = NotificationScheduler.normalised(hour: 9, minute: 65)
        #expect(h == 10)
        #expect(m == 5)
    }

    @Test func normalised_clampedAtMaxTime() {
        // 23h 59m is the ceiling — going beyond stays at 23:59
        let (h, m) = NotificationScheduler.normalised(hour: 23, minute: 70)
        #expect(h == 23)
        #expect(m == 59)
    }

    @Test func normalised_moonOffset_staysInRange() {
        // Ritual fires at hour:minute + 5. Verify always valid.
        let (h, m) = NotificationScheduler.normalised(hour: 9, minute: 5)
        #expect(h >= 0 && h <= 23)
        #expect(m >= 0 && m <= 59)
    }
}
