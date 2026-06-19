//
//  CrossJournalSearchTests.swift
//  Twin Flame Union
//
//  Tests the pure filter/match helper in CrossJournalSearchView.
//  Uses Swift Testing (no XCTest) — consistent with the rest of this target.
//

import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

struct CrossJournalSearchTests {

    // MARK: - Fixtures

    private let now = Date()

    private func makeHit(
        kind: JournalKind = .soul,
        title: String = "",
        snippet: String = "",
        daysAgo: Double = 0
    ) -> JournalHit {
        JournalHit(
            id: UUID(),
            kind: kind,
            title: title,
            snippet: snippet,
            date: Date(timeIntervalSinceNow: -daysAgo * 86400)
        )
    }

    // MARK: - filterJournalHits

    @Test func emptyQueryReturnsNoHits() {
        let hits = [
            makeHit(title: "Dream of Reunion", snippet: "We were flying together"),
            makeHit(title: "Prayer for Union",  snippet: "Divine guidance"),
        ]
        #expect(filterJournalHits(hits, query: "").isEmpty)
    }

    @Test func blankWhitespaceQueryReturnsNoHits() {
        let hits = [makeHit(title: "Something", snippet: "anything")]
        #expect(filterJournalHits(hits, query: "   ").isEmpty)
    }

    @Test func queryMatchesTitleCaseInsensitively() {
        let hits = [
            makeHit(title: "Dream of Reunion", snippet: "content here"),
            makeHit(title: "Gratitude morning", snippet: "thankful"),
        ]
        let results = filterJournalHits(hits, query: "reunion")
        #expect(results.count == 1)
        #expect(results[0].title == "Dream of Reunion")
    }

    @Test func queryMatchesSnippetCaseInsensitively() {
        let hits = [
            makeHit(title: "Tuesday Entry", snippet: "Saw 1111 angel number today"),
            makeHit(title: "Monday Entry",  snippet: "Felt peaceful and aligned"),
        ]
        let results = filterJournalHits(hits, query: "ANGEL")
        #expect(results.count == 1)
        #expect(results[0].snippet.lowercased().contains("angel"))
    }

    @Test func queryMatchesJournalKindLabel() {
        let hits = [
            makeHit(kind: .dream,   title: "Vivid dream", snippet: "colours everywhere"),
            makeHit(kind: .prayer,  title: "Evening prayer", snippet: "gratitude"),
        ]
        // "Dream Journal" is JournalKind.dream.rawValue
        let results = filterJournalHits(hits, query: "Dream Journal")
        #expect(results.count == 1)
        #expect(results[0].kind == .dream)
    }

    @Test func nonMatchingQueryExcludesHit() {
        let hits = [
            makeHit(title: "Sacred geometry meditation", snippet: "Focus on the flower of life"),
        ]
        let results = filterJournalHits(hits, query: "volcano")
        #expect(results.isEmpty)
    }

    @Test func multipleHitsAllReturnedWhenQueryMatchesBoth() {
        let hits = [
            makeHit(title: "Twin flame reunion dream", snippet: "We met again"),
            makeHit(title: "Prayer for twin flame", snippet: "Divine union requested"),
            makeHit(title: "Morning gratitude", snippet: "Thankful for coffee"),
        ]
        let results = filterJournalHits(hits, query: "twin")
        #expect(results.count == 2)
    }

    @Test func mixedCaseQueryMatchesCorrectly() {
        let hits = [
            makeHit(title: "REUNION", snippet: "all caps title"),
        ]
        let results = filterJournalHits(hits, query: "ReUnIoN")
        #expect(results.count == 1)
    }

    // MARK: - buildAllHits

    @Test func buildAllHitsProducesOneHitPerEntry() {
        let journalEntries    = [JournalEntry(title: "Soul note", content: "deep thought", mood: "Hopeful")]
        let dreamEntries      = [DreamEntry(title: "Dragon dream", content: "flying over mountains")]
        let syncEntries       = [SynchronicityEntry(type: "Angel Number", detail: "111", note: "feeling it")]
        let gratitudeEntries  = [GratitudeEntry(date: Date(), items: "Family\nHealth")]
        let prayerEntries     = [PrayerEntry(petition: "Guide me", detail: "I need clarity")]
        let connectionMoments = [ConnectionMoment(title: "First Touch", detail: "hands met", category: "Milestone")]

        let hits = buildAllHits(
            journalEntries:    journalEntries,
            dreamEntries:      dreamEntries,
            syncEntries:       syncEntries,
            gratitudeEntries:  gratitudeEntries,
            prayerEntries:     prayerEntries,
            connectionMoments: connectionMoments
        )

        #expect(hits.count == 6)
        // Each kind appears exactly once
        for kind in JournalKind.allCases {
            #expect(hits.filter { $0.kind == kind }.count == 1)
        }
    }

    @Test func buildAllHitsReturnsEmptyWhenNoEntries() {
        let hits = buildAllHits(
            journalEntries:    [],
            dreamEntries:      [],
            syncEntries:       [],
            gratitudeEntries:  [],
            prayerEntries:     [],
            connectionMoments: []
        )
        #expect(hits.isEmpty)
    }

    @Test func buildAllHitsSortsNewestFirst() {
        let old    = JournalEntry(title: "Old entry",    content: "old", mood: "Hopeful")
        old.createdAt    = Date(timeIntervalSinceNow: -86400 * 7)  // 7 days ago
        let recent = JournalEntry(title: "New entry",    content: "new", mood: "Hopeful")
        recent.createdAt = Date()

        let hits = buildAllHits(
            journalEntries:    [old, recent],
            dreamEntries:      [],
            syncEntries:       [],
            gratitudeEntries:  [],
            prayerEntries:     [],
            connectionMoments: []
        )

        #expect(hits.count == 2)
        #expect(hits[0].title == "New entry")
        #expect(hits[1].title == "Old entry")
    }

    @Test func buildAllHitsFallsBackToDefaultTitleForEmptyFields() {
        let emptyJournal = JournalEntry(title: "", content: "", mood: "Hopeful")
        let emptyDream   = DreamEntry(title: "", content: "")
        let emptySync    = SynchronicityEntry(type: "", detail: "")
        let emptyPrayer  = PrayerEntry(petition: "", detail: "")
        let emptyMoment  = ConnectionMoment(title: "", detail: "")

        let hits = buildAllHits(
            journalEntries:    [emptyJournal],
            dreamEntries:      [emptyDream],
            syncEntries:       [emptySync],
            gratitudeEntries:  [],
            prayerEntries:     [emptyPrayer],
            connectionMoments: [emptyMoment]
        )

        let titles = hits.map(\.title)
        #expect(titles.contains("Untitled Entry"))
        #expect(titles.contains("Untitled Dream"))
        #expect(titles.contains("Sign"))
        #expect(titles.contains("Prayer"))
        #expect(titles.contains("Moment"))
    }
}
