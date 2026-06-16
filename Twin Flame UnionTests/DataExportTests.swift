import Testing
import SwiftData
import Foundation
@testable import The_Twin_Flame_Union_App

struct DataExportTests {

    private func seededContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Schema(AppSchemaV1.models), configurations: [config])
        let ctx = ModelContext(container)
        ctx.insert(JournalEntry(title: "J1"))
        ctx.insert(JournalEntry(title: "J2"))
        ctx.insert(DreamEntry(title: "D1"))
        try ctx.save()
        return ctx
    }

    @Test func snapshotCapturesCountsAndFields() throws {
        let ctx = try seededContext()
        let snap = try DataExportService.snapshot(from: ctx)

        #expect(snap.schemaVersion == "1.0.0")
        #expect(snap.journalEntries.count == 2)
        #expect(snap.dreamEntries.count == 1)
        #expect(snap.journalEntries.map(\.title).sorted() == ["J1", "J2"])
        #expect(snap.dreamEntries.first?.title == "D1")
    }

    @Test func encodeRoundTrips() throws {
        let ctx = try seededContext()
        let snap = try DataExportService.snapshot(from: ctx)
        let data = try DataExportService.encode(snap)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(DataExportSnapshot.self, from: data)
        #expect(decoded.journalEntries.count == 2)
        #expect(decoded.dreamEntries.count == 1)
    }
}
