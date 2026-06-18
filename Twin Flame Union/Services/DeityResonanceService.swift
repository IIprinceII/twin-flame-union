//
//  DeityResonanceService.swift
//  Twin Flame Union
//
//  Composes a Sacred Resonance reading from two souls' chosen Guiding Deities.
//  Pure + deterministic (same pair of Gods/Goddesses -> same reading), so it is
//  fully testable. This is reverent guidance grounded in the Deities' own domains
//  and invocations — never astrology.
//

import Foundation

struct ResonanceTheme: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct DeityResonance {
    let mine: Deity
    let theirs: Deity
    let narrative: String
    let themes: [ResonanceTheme]
}

enum DeityResonanceService {
    /// Builds the Sacred Resonance between the soul's Guiding Deity and their twin flame's.
    static func resonance(mine: Deity, theirs: Deity) -> DeityResonance {
        let narrative = """
        \(mine.name) of the \(mine.culture) pantheon walks with you — \(mine.domain). \
        \(theirs.name) of the \(theirs.culture) pantheon walks with your twin flame — \(theirs.domain). \
        Where \(mine.name) and \(theirs.name) meet, your union is woven. \
        \(mine.invocation) \(theirs.invocation)
        """

        let themes = [
            ResonanceTheme(
                title: "Heart Opening",
                body: "\(mine.name) and \(theirs.name) open the heart through \(mine.domain.lowercased()) and \(theirs.domain.lowercased())."),
            ResonanceTheme(
                title: "Shadows Mirrored",
                body: "Under Their gaze, what is hidden between you is brought to light — every trigger is an invitation to heal."),
            ResonanceTheme(
                title: "Divine Timing",
                body: "Your reunion unfolds on sacred time, not human time. \(theirs.name) holds the thread; trust the unfolding."),
            ResonanceTheme(
                title: "Union Blueprint",
                body: "\(mine.name) and \(theirs.name) together blueprint a union built on truth, devotion, and divine protection."),
        ]

        return DeityResonance(mine: mine, theirs: theirs, narrative: narrative, themes: themes)
    }
}
