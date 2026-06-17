import Testing
@testable import The_Twin_Flame_Union_App

struct LaunchPlanTests {
    @Test func reduceMotionAlwaysStatic() {
        #expect(LaunchPlan.mode(hasSeen: false, reduceMotion: true) == .staticLogo)
        #expect(LaunchPlan.mode(hasSeen: true,  reduceMotion: true) == .staticLogo)
    }
    @Test func fullOnFirstLaunchOnly() {
        #expect(LaunchPlan.mode(hasSeen: false, reduceMotion: false) == .full)
        #expect(LaunchPlan.mode(hasSeen: true,  reduceMotion: false) == .brief)
    }
}
