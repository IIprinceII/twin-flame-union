//
//  AffirmationFavoritesTests.swift
//  Twin Flame UnionTests
//
//  Regression test for the affirmation favorites data-loss bug:
//  UUIDs were previously assigned fresh on every cold launch, so persisted
//  favorites never matched the in-memory ids. The fix derives id from text.
//

import Testing
@testable import The_Twin_Flame_Union_App

struct AffirmationFavoritesTests {

    @Test func affirmationIdIsStableAcrossInstances() {
        // Two Affirmations with the same text must share an id, so a persisted
        // favorite still matches after a relaunch rebuilds the array.
        let a = Affirmation(text: "I am worthy of sacred love", category: .love)
        let b = Affirmation(text: "I am worthy of sacred love", category: .love)
        #expect(a.id == b.id)
    }

    @Test func affirmationIdEqualsText() {
        // The stable id should be the affirmation text itself.
        let text = "My twin flame and I are united in a sacred covenant of eternal love."
        let affirmation = Affirmation(text: text, category: .love)
        #expect(affirmation.id == text)
    }

    @Test func differentTextsHaveDifferentIds() {
        let a = Affirmation(text: "I am light.", category: .selfWorth)
        let b = Affirmation(text: "I am love.", category: .selfWorth)
        #expect(a.id != b.id)
    }
}
