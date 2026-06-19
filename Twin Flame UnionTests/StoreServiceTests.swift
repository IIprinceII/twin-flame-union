//
//  StoreServiceTests.swift
//  Twin Flame UnionTests
//
//  Tests the pure entitlement decision logic in StoreService.resolvePremium(hasActive:enforced:).
//  These tests run without StoreKit, without network, and without App Store Connect.
//
//  Gating spec:
//  • premiumEnforced = false → isPremium is TRUE for everyone (no features lock)
//  • premiumEnforced = true  → isPremium == hasActivePremium (real entitlement check)
//

import Testing
@testable import The_Twin_Flame_Union_App

struct StoreServiceTests {

    // MARK: - Enforcement OFF (default state — owner's device, pre-ASC approval)

    @Test("When enforcement is OFF and user has NO active premium → isPremium is true")
    func enforcementOff_noActive_isTrue() {
        let result = StoreService.resolvePremium(hasActive: false, enforced: false)
        #expect(result == true)
    }

    @Test("When enforcement is OFF and user HAS active premium → isPremium is true")
    func enforcementOff_hasActive_isTrue() {
        let result = StoreService.resolvePremium(hasActive: true, enforced: false)
        #expect(result == true)
    }

    // MARK: - Enforcement ON (post-ASC-approval production state)

    @Test("When enforcement is ON and user has NO active premium → isPremium is false")
    func enforcementOn_noActive_isFalse() {
        let result = StoreService.resolvePremium(hasActive: false, enforced: true)
        #expect(result == false)
    }

    @Test("When enforcement is ON and user HAS active premium → isPremium is true")
    func enforcementOn_hasActive_isTrue() {
        let result = StoreService.resolvePremium(hasActive: true, enforced: true)
        #expect(result == true)
    }

    // MARK: - Symmetry assertion

    @Test("resolvePremium matches expected truth table for all combinations")
    func truthTable() {
        // (hasActive, enforced) → expected
        let cases: [(hasActive: Bool, enforced: Bool, expected: Bool)] = [
            (false, false, true),   // gate off, no sub  → open
            (true,  false, true),   // gate off, has sub → open
            (false, true,  false),  // gate on,  no sub  → locked
            (true,  true,  true),   // gate on,  has sub → open
        ]
        for c in cases {
            #expect(
                StoreService.resolvePremium(hasActive: c.hasActive, enforced: c.enforced) == c.expected,
                "resolvePremium(hasActive:\(c.hasActive), enforced:\(c.enforced)) should be \(c.expected)"
            )
        }
    }
}
