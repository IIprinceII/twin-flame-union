//
//  WellnessDisclaimerTests.swift
//  Twin Flame UnionTests
//

import Testing
@testable import The_Twin_Flame_Union_App

struct WellnessDisclaimerTests {

    @Test func disclaimerTextIsHonestAndComplete() {
        let t = WellnessDisclaimer.text
        #expect(t.isEmpty == false)
        #expect(t.contains("not medical"))
        #expect(t.contains("not a substitute"))
        #expect(t.contains("consult a qualified professional"))
    }

    @Test func ackKeyIsStable() {
        #expect(WellnessDisclaimer.ackKey == "hasAcknowledgedWellnessDisclaimer")
    }

    @Test func footerIsNonMedical() {
        #expect(WellnessDisclaimer.footerShort.lowercased().contains("not medical"))
    }
}
