//
//  PersistenceController.swift
//  Twin Flame Union
//
//  Owns ModelContainer creation with a preserve-and-fresh-start recovery path:
//  if the store can't be opened (corruption / failed migration), the unreadable
//  store files are MOVED ASIDE (never deleted) and a fresh container is created so
//  the app always launches. In-memory is the absolute last resort.
//

import Foundation
import SwiftData
import OSLog

enum Persistence {

    /// Set when a recovery happened, so the UI can show a one-time notice.
    static let didRecoverKey = "didRecoverStore"

    private static let log = Logger(subsystem: "com.twinflameunion.app", category: "Persistence")

    struct Result {
        let container: ModelContainer
        let didRecover: Bool
    }

    /// Production entry point — default store location (where existing data lives).
    static func makeContainer() -> ModelContainer {
        let schema = Schema(AppSchemaV1.models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let result = makeContainer(config: config)
        if result.didRecover {
            UserDefaults.standard.set(true, forKey: didRecoverKey)
        }
        return result.container
    }

    /// Testable core. Takes an explicit configuration so tests can target a temp store.
    static func makeContainer(config: ModelConfiguration) -> Result {
        let schema = Schema(AppSchemaV1.models)

        // 1. Happy path.
        do {
            let container = try ModelContainer(
                for: schema, migrationPlan: TFUMigrationPlan.self, configurations: [config]
            )
            return Result(container: container, didRecover: false)
        } catch {
            log.error("Store open failed, attempting recovery: \(error.localizedDescription)")
        }

        // 2. Preserve the unreadable store, then retry fresh.
        preserveStore(at: config.url)
        do {
            let container = try ModelContainer(
                for: schema, migrationPlan: TFUMigrationPlan.self, configurations: [config]
            )
            return Result(container: container, didRecover: true)
        } catch {
            log.error("Fresh store creation failed: \(error.localizedDescription)")
        }

        // 3. Absolute last resort — in-memory, so the app still opens.
        do {
            let memory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [memory])
            return Result(container: container, didRecover: true)
        } catch {
            // If even in-memory fails, the runtime is unusable; surface it loudly.
            fatalError("Unrecoverable: could not create in-memory container: \(error)")
        }
    }

    /// Move the store trio (.store, -shm, -wal) into a sibling `Recovered/` dir,
    /// timestamped. Rename, never delete.
    private static func preserveStore(at storeURL: URL) {
        let fm = FileManager.default
        let recoveredDir = storeURL.deletingLastPathComponent()
            .appendingPathComponent("Recovered", isDirectory: true)
        try? fm.createDirectory(at: recoveredDir, withIntermediateDirectories: true)

        let stamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let base = storeURL.deletingPathExtension().lastPathComponent  // "test" or "default"
        let ext = storeURL.pathExtension                               // "store"

        // Move the trio together. If a sidecar (-shm/-wal) can't be moved, continue
        // anyway — the .store file is the forensic payload; sidecars regenerate on open.
        for suffix in ["", "-shm", "-wal"] {
            let src = URL(fileURLWithPath: storeURL.path + suffix)
            guard fm.fileExists(atPath: src.path) else { continue }
            let dst = recoveredDir.appendingPathComponent("\(base)-\(stamp).\(ext)\(suffix)")
            do {
                try fm.moveItem(at: src, to: dst)
            } catch {
                log.error("Could not preserve \(src.lastPathComponent): \(error.localizedDescription)")
            }
        }
    }
}
