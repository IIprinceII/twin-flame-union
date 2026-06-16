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
}
