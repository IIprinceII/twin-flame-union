import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

struct MeditationClockTests {

    @Test func remainingIsWallClockAccurate() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let clock = MeditationClock(endDate: start.addingTimeInterval(600)) // 10 min
        #expect(clock.remaining(at: start) == 600)
        #expect(clock.remaining(at: start.addingTimeInterval(60)) == 540)
    }

    @Test func remainingFloorsAtZeroAndDoesNotLoseBackgroundTime() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let clock = MeditationClock(endDate: start.addingTimeInterval(600))
        #expect(clock.remaining(at: start.addingTimeInterval(660)) == 0)   // floored, not negative
    }

    @Test func isCompleteFlipsAtEndDate() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let clock = MeditationClock(endDate: start.addingTimeInterval(600))
        #expect(clock.isComplete(at: start) == false)
        #expect(clock.isComplete(at: start.addingTimeInterval(599)) == false)
        #expect(clock.isComplete(at: start.addingTimeInterval(600)) == true)
        #expect(clock.isComplete(at: start.addingTimeInterval(601)) == true)
    }
}
