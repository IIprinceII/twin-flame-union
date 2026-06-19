//
//  CrossJournalSearchView.swift
//  Twin Flame Union
//
//  Cross-journal search — searches across all sacred journals in one place.
//  Journals covered: Soul Journal, Dream Journal, Synchronicity Log,
//  Gratitude Log, Prayer Journal, Connection Timeline.
//

import SwiftUI
import SwiftData

// MARK: - Journal Kind

/// Identifies which sacred journal a hit comes from.
enum JournalKind: String, CaseIterable {
    case soul          = "Soul Journal"
    case dream         = "Dream Journal"
    case synchronicity = "Synchronicity Log"
    case gratitude     = "Gratitude Log"
    case prayer        = "Prayer Journal"
    case connection    = "Connection Timeline"

    var icon: String {
        switch self {
        case .soul:          return "book.fill"
        case .dream:         return "moon.zzz.fill"
        case .synchronicity: return "sparkles"
        case .gratitude:     return "hand.thumbsup.fill"
        case .prayer:        return "hands.sparkles.fill"
        case .connection:    return "timeline.selection"
        }
    }

    var color: Color {
        switch self {
        case .soul:          return AppColors.purple
        case .dream:         return Color(hex: "4A90D9")
        case .synchronicity: return Color(hex: "9B59B6")
        case .gratitude:     return AppColors.gold
        case .prayer:        return AppColors.coral
        case .connection:    return Color(hex: "E74C8B")
        }
    }
}

// MARK: - Journal Hit (pure, testable)

/// A unified result row from any journal, with enough info to display it.
struct JournalHit: Identifiable {
    let id: UUID
    let kind: JournalKind
    let title: String     // primary display text
    let snippet: String   // secondary preview text (up to 120 chars)
    let date: Date
}

// MARK: - Pure Filter Helper (testable)

/// Filters `hits` whose combined text fields contain `query` (case-insensitive).
/// - Returns empty array when `query` is blank.
func filterJournalHits(_ hits: [JournalHit], query: String) -> [JournalHit] {
    let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !q.isEmpty else { return [] }
    let lower = q.localizedLowercase
    return hits.filter {
        $0.title.localizedLowercase.contains(lower) ||
        $0.snippet.localizedLowercase.contains(lower) ||
        $0.kind.rawValue.localizedLowercase.contains(lower)
    }
}

/// Builds JournalHit array from all journal models given a SwiftData context.
/// Exposed at module scope so tests can inject a real in-memory context.
func buildAllHits(
    journalEntries:   [JournalEntry],
    dreamEntries:     [DreamEntry],
    syncEntries:      [SynchronicityEntry],
    gratitudeEntries: [GratitudeEntry],
    prayerEntries:    [PrayerEntry],
    connectionMoments:[ConnectionMoment]
) -> [JournalHit] {
    var hits: [JournalHit] = []

    // Soul Journal — title + content
    for e in journalEntries {
        hits.append(JournalHit(
            id: e.id,
            kind: .soul,
            title: e.title.isEmpty ? "Untitled Entry" : e.title,
            snippet: String(e.content.prefix(120)),
            date: e.createdAt
        ))
    }

    // Dream Journal — title + content + symbols + people
    for e in dreamEntries {
        let extra = [e.people, e.symbols, e.wakeFeeling]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        let snip = [e.content, extra].filter { !$0.isEmpty }.joined(separator: " ")
        hits.append(JournalHit(
            id: e.id,
            kind: .dream,
            title: e.title.isEmpty ? "Untitled Dream" : e.title,
            snippet: String(snip.prefix(120)),
            date: e.createdAt
        ))
    }

    // Synchronicity Log — type + detail + note
    for e in syncEntries {
        let snip = [e.detail, e.note].filter { !$0.isEmpty }.joined(separator: " · ")
        hits.append(JournalHit(
            id: e.id,
            kind: .synchronicity,
            title: e.type.isEmpty ? "Sign" : e.type,
            snippet: String(snip.prefix(120)),
            date: e.createdAt
        ))
    }

    // Gratitude Log — items (newline-separated)
    for e in gratitudeEntries {
        let lines = e.items.components(separatedBy: "\n").filter { !$0.isEmpty }
        let preview = lines.prefix(3).joined(separator: " · ")
        hits.append(JournalHit(
            id: e.id,
            kind: .gratitude,
            title: "Gratitude · \(e.date.formatted(date: .abbreviated, time: .omitted))",
            snippet: String(preview.prefix(120)),
            date: e.date
        ))
    }

    // Prayer Journal — petition + detail + answeredNote
    for e in prayerEntries {
        let snip = [e.detail, e.isAnswered ? e.answeredNote : ""]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
        hits.append(JournalHit(
            id: e.id,
            kind: .prayer,
            title: e.petition.isEmpty ? "Prayer" : e.petition,
            snippet: String(snip.prefix(120)),
            date: e.createdAt
        ))
    }

    // Connection Timeline — title + detail + category
    for e in connectionMoments {
        let snip = [e.category, e.detail].filter { !$0.isEmpty }.joined(separator: " · ")
        hits.append(JournalHit(
            id: e.id,
            kind: .connection,
            title: e.title.isEmpty ? "Moment" : e.title,
            snippet: String(snip.prefix(120)),
            date: e.date
        ))
    }

    // Sort newest first
    return hits.sorted { $0.date > $1.date }
}

// MARK: - Cross Journal Search View

struct CrossJournalSearchView: View {
    @Environment(\.modelContext) private var modelContext

    // Query all journal model types
    @Query(sort: \JournalEntry.createdAt,       order: .reverse) private var journalEntries:    [JournalEntry]
    @Query(sort: \DreamEntry.createdAt,         order: .reverse) private var dreamEntries:      [DreamEntry]
    @Query(sort: \SynchronicityEntry.createdAt, order: .reverse) private var syncEntries:       [SynchronicityEntry]
    @Query(sort: \GratitudeEntry.date,          order: .reverse) private var gratitudeEntries:  [GratitudeEntry]
    @Query(sort: \PrayerEntry.createdAt,        order: .reverse) private var prayerEntries:     [PrayerEntry]
    @Query(sort: \ConnectionMoment.date,        order: .reverse) private var connectionMoments: [ConnectionMoment]

    @State private var searchText: String = ""

    private var allHits: [JournalHit] {
        buildAllHits(
            journalEntries:    journalEntries,
            dreamEntries:      dreamEntries,
            syncEntries:       syncEntries,
            gratitudeEntries:  gratitudeEntries,
            prayerEntries:     prayerEntries,
            connectionMoments: connectionMoments
        )
    }

    private var results: [JournalHit] {
        filterJournalHits(allHits, query: searchText)
    }

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                // Search bar
                CrossSearchBar(text: $searchText)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // Content
                Group {
                    if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        emptyPromptView
                    } else if results.isEmpty {
                        noResultsView
                    } else {
                        resultsList
                    }
                }
            }
        }
        .navigationTitle("Search Journals")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    // MARK: - Empty Prompt (no query entered yet)

    private var emptyPromptView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 52))
                .foregroundStyle(AppColors.lavender.opacity(0.35))

            VStack(spacing: 8) {
                Text("Search Your Sacred Writings")
                    .font(AppFont.serifTitle(20))
                    .foregroundStyle(AppColors.cream)
                    .multilineTextAlignment(.center)

                Text("Every prayer, dream, and synchronicity\nawaits your sacred search.")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Journal coverage chips
            journalKindChips

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var journalKindChips: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 10
        ) {
            ForEach(JournalKind.allCases, id: \.self) { kind in
                HStack(spacing: 5) {
                    Image(systemName: kind.icon)
                        .font(.system(size: 11))
                        .foregroundStyle(kind.color)
                    Text(kind.rawValue)
                        .font(AppFont.caption(11))
                        .foregroundStyle(AppColors.lavender)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(kind.color.opacity(0.10), in: Capsule())
                .overlay(Capsule().strokeBorder(kind.color.opacity(0.25), lineWidth: 1))
            }
        }
        .padding(.top, 4)
    }

    // MARK: - No Results

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.lavender.opacity(0.35))
            Text("No Sacred Writings Found")
                .font(AppFont.serifTitle(18))
                .foregroundStyle(AppColors.cream)
            Text("\"\(searchText)\" did not appear in\nany of your journals.")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Spacer()
        }
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(results) { hit in
                    JournalHitRow(hit: hit)
                }

                Text("\(results.count) \(results.count == 1 ? "result" : "results") across your sacred journals")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Cross Search Bar

private struct CrossSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.lavender)

            TextField("Search all journals…", text: $text)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
                .tint(AppColors.gold)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.lavender.opacity(0.6))
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Journal Hit Row

private struct JournalHitRow: View {
    let hit: JournalHit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // Kind badge
                HStack(spacing: 5) {
                    Image(systemName: hit.kind.icon)
                        .font(.system(size: 11))
                        .foregroundStyle(hit.kind.color)
                    Text(hit.kind.rawValue)
                        .font(AppFont.caption(11, weight: .semibold))
                        .foregroundStyle(hit.kind.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(hit.kind.color.opacity(0.12), in: Capsule())

                Spacer()

                Text(hit.date.formatted(date: .abbreviated, time: .omitted))
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
            }

            Text(hit.title)
                .font(AppFont.body(15, weight: .semibold))
                .foregroundStyle(AppColors.cream)
                .lineLimit(1)

            if !hit.snippet.isEmpty {
                Text(hit.snippet)
                    .font(AppFont.body(13))
                    .foregroundStyle(AppColors.lavender)
                    .lineLimit(2)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .background(AppColors.deepViolet.opacity(0.70), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(AppColors.purple.opacity(0.22), lineWidth: 1)
        )
    }
}
