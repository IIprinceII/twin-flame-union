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
    var id: String { title }   // stable identity (titles are unique) — avoids SwiftUI ForEach churn
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
    /// Honors the case where both souls have chosen the same God or Goddess.
    static func resonance(mine: Deity, theirs: Deity) -> DeityResonance {
        let samePatron = mine.name == theirs.name
        let pair = samePatron ? mine.name : "\(mine.name) and \(theirs.name)"

        let opening = samePatron
            ? "\(mine.name) of the \(mine.culture) pantheon walks with both of you — \(mine.domain)."
            : "\(mine.name) of the \(mine.culture) pantheon walks with you — \(mine.domain). "
              + "\(theirs.name) of the \(theirs.culture) pantheon walks with your twin flame — \(theirs.domain)."

        let invocations = samePatron ? mine.invocation : "\(mine.invocation) \(theirs.invocation)"

        let narrative = """
        \(opening) Where \(pair) move through your union, the bond is woven. \(invocations)
        """

        let heartBody = samePatron
            ? "\(mine.name) opens the heart through \(primaryDomain(mine))."
            : "\(mine.name) and \(theirs.name) open the heart through \(primaryDomain(mine)) and \(primaryDomain(theirs))."

        let themes = [
            ResonanceTheme(title: "Heart Opening", body: heartBody),
            ResonanceTheme(
                title: "Shadows Mirrored",
                body: "Under Their gaze, what is hidden between you is brought to light — every trigger is an invitation to heal."),
            ResonanceTheme(
                title: "Divine Timing",
                body: "Your reunion unfolds on sacred time, not human time. \(theirs.name) holds the thread; trust the unfolding."),
            ResonanceTheme(
                title: "Union Blueprint",
                body: "\(pair) blueprint a union built on truth, devotion, and divine protection."),
        ]

        return DeityResonance(mine: mine, theirs: theirs, narrative: narrative, themes: themes)
    }

    /// The primary domain keyword (before the first "·"), lowercased, so multi-part
    /// domain strings like "Love · Beauty · Grace" read fluently inside prose.
    private static func primaryDomain(_ deity: Deity) -> String {
        deity.domain.split(separator: "·").first
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            ?? deity.domain.lowercased()
    }
}
