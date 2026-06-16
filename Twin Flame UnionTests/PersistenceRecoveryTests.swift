import Testing
import SwiftData
import Foundation
@testable import The_Twin_Flame_Union_App

struct PersistenceRecoveryTests {

    @Test func cleanStoreOpensWithoutRecovery() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let storeURL = dir.appendingPathComponent("test.store")
        let config = ModelConfiguration(schema: Schema(AppSchemaV1.models), url: storeURL)

        let result = Persistence.makeContainer(config: config)
        #expect(result.didRecover == false)

        let context = ModelContext(result.container)
        context.insert(JournalEntry(title: "Hello"))
        try context.save()
        #expect(try context.fetch(FetchDescriptor<JournalEntry>()).count == 1)
    }

    @Test func corruptStoreIsPreservedAndFreshContainerOpens() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let storeURL = dir.appendingPathComponent("test.store")
        // Write garbage so SwiftData fails to open it.
        try Data("not a real sqlite store".utf8).write(to: storeURL)

        let config = ModelConfiguration(schema: Schema(AppSchemaV1.models), url: storeURL)
        let result = Persistence.makeContainer(config: config)

        #expect(result.didRecover == true)
        #expect(result.mode == .recoveredFromCorruption)
        #expect(result.backupSucceeded == true)
        // The fresh container works:
        let context = ModelContext(result.container)
        context.insert(JournalEntry(title: "Fresh"))
        try context.save()
        #expect(try context.fetch(FetchDescriptor<JournalEntry>()).count == 1)
        // The corrupt file was moved aside, not deleted:
        let recoveredDir = dir.appendingPathComponent("Recovered", isDirectory: true)
        let preserved = try FileManager.default
            .contentsOfDirectory(atPath: recoveredDir.path)
            .filter { $0.hasPrefix("test-") && $0.hasSuffix(".store") }
        #expect(preserved.count == 1)
    }

    /// CRITICAL safety property: a store with a VALID SQLite header that still won't open
    /// (transient/permissions/environmental, NOT corruption) must NOT be moved aside. The
    /// on-disk data is left untouched and the app runs in temporary in-memory mode.
    @Test func validHeaderStoreThatWontOpenIsLeftUntouched() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let storeURL = dir.appendingPathComponent("test.store")
        // Valid 16-byte SQLite magic header + garbage body: passes the corruption probe
        // (looks like a real DB) but cannot actually be opened as a SwiftData store.
        var bytes = Data("SQLite format 3\u{0}".utf8)
        bytes.append(Data(repeating: 0xAB, count: 512))
        try bytes.write(to: storeURL)

        let config = ModelConfiguration(schema: Schema(AppSchemaV1.models), url: storeURL)
        let result = Persistence.makeContainer(config: config)

        #expect(result.mode == .temporaryInMemory)
        #expect(result.backupSucceeded == false)
        // The on-disk file is UNTOUCHED — never moved aside:
        #expect(FileManager.default.fileExists(atPath: storeURL.path) == true)
        #expect(try Data(contentsOf: storeURL) == bytes)
        // No Recovered/ directory was created:
        let recoveredDir = dir.appendingPathComponent("Recovered", isDirectory: true)
        #expect(FileManager.default.fileExists(atPath: recoveredDir.path) == false)
    }

    /// CRITICAL safety property: the .store/-shm/-wal trio is preserved together (atomic),
    /// so uncheckpointed WAL data is never separated from its store.
    @Test func corruptStoreTrioIsPreservedTogether() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let storeURL = dir.appendingPathComponent("test.store")
        // Invalid header => corruption path. Seed all three trio members.
        try Data("garbage-store".utf8).write(to: storeURL)
        try Data("garbage-wal".utf8).write(to: URL(fileURLWithPath: storeURL.path + "-wal"))
        try Data("garbage-shm".utf8).write(to: URL(fileURLWithPath: storeURL.path + "-shm"))

        let config = ModelConfiguration(schema: Schema(AppSchemaV1.models), url: storeURL)
        let result = Persistence.makeContainer(config: config)

        #expect(result.mode == .recoveredFromCorruption)
        let recoveredDir = dir.appendingPathComponent("Recovered", isDirectory: true)
        let preserved = try FileManager.default.contentsOfDirectory(atPath: recoveredDir.path)
        // All three trio members were moved together:
        #expect(preserved.contains { $0.hasSuffix(".store") })
        #expect(preserved.contains { $0.hasSuffix(".store-wal") })
        #expect(preserved.contains { $0.hasSuffix(".store-shm") })
        // The preserved .store is the ORIGINAL (moved, not a copy of the fresh one):
        let preservedStoreName = preserved.first { $0.hasSuffix(".store") }!
        let preservedStore = try Data(contentsOf: recoveredDir.appendingPathComponent(preservedStoreName))
        #expect(preservedStore == Data("garbage-store".utf8))
    }
}
