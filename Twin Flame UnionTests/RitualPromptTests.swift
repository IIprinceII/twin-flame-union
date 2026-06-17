import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

struct RitualPromptTests {
    let cal = Calendar.current

    @Test func shownWhenNeverCompletedOrDismissed() {
        #expect(RitualPrompt.shouldShow(completedAt: nil, dismissedAt: nil, now: Date(), calendar: cal) == true)
    }

    @Test func hiddenWhenCompletedToday() {
        let now = Date()
        #expect(RitualPrompt.shouldShow(completedAt: now, dismissedAt: nil, now: now, calendar: cal) == false)
    }

    @Test func hiddenWhenDismissedToday() {
        let now = Date()
        #expect(RitualPrompt.shouldShow(completedAt: nil, dismissedAt: now, now: now, calendar: cal) == false)
    }

    @Test func shownAgainNextDay() {
        let now = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: now)!
        #expect(RitualPrompt.shouldShow(completedAt: yesterday, dismissedAt: yesterday, now: now, calendar: cal) == true)
    }
}
