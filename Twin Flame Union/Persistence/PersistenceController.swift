//
//  PersistenceController.swift
//  Twin Flame Union
//
//  Owns ModelContainer creation with a CONSERVATIVE recovery path. The guiding
//  rule is "never destroy data we aren't certain is already lost":
//
//   1. Open the on-disk store. On a transient failure, retry before doing anything.
//   2. Only when the store file is PROVABLY corrupt (its SQLite header is invalid)
//      do we move it aside (atomically, never deleting) and start fresh.
//   3. For any other persistent failure (valid-looking store that still won't open,
//      permissions/disk problems), we leave the on-disk data UNTOUCHED and run in a
//      temporary in-memory store so the app still opens — the data is preserved for
//      a future launch, and the UI is told saving is unavailable.
//
//  This means a healthy store is never moved aside just because an open() threw.
//

import Foundation
import SwiftData
import OSLog

enum Persistence {

    /// How the container for the current launch was obtained. Persisted (raw value)
    /// under `recoveryModeKey` so the UI can show an honest, accurate notice.
    enum RecoveryMode: String {
        case normal                  // opened the on-disk store cleanly
        case recoveredFromCorruption // store was provably corrupt; moved aside, fresh store created
        case temporaryInMemory       // disk store unusable but NOT destroyed; running in RAM this launch
    }

    static let recoveryModeKey = "persistenceRecoveryMode"

    private static let log = Logger(subsystem: "com.twinflameunion.app", category: "Persistence")

    /// Number of immediate retries for a non-corruption open failure (transient lock, etc.).
    private static let transientRetries = 2

    struct Result {
        let container: ModelContainer
        let mode: RecoveryMode
        /// True only when a corrupt store was actually moved aside successfully.
        let backupSucceeded: Bool
        /// Back-compat convenience: did we deviate from a clean on-disk open?
        var didRecover: Bool { mode != .normal }
    }

    /// Production entry point — default store location (where existing data lives).
    static func makeContainer() -> ModelContainer {
        let schema = Schema(AppSchemaV1.models)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let result = makeContainer(config: config)
        // Always record the current launch's mode (overwrites any prior value) so the
        // UI reflects reality every launch — including recovering back to `.normal`.
        UserDefaults.standard.set(result.mode.rawValue, forKey: recoveryModeKey)
        return result.container
    }

    /// Testable core. Takes an explicit configuration so tests can target a temp store.
    static func makeContainer(config: ModelConfiguration) -> Result {
        let schema = Schema(AppSchemaV1.models)

        func openOnDisk() throws -> ModelContainer {
            try ModelContainer(for: schema, migrationPlan: TFUMigrationPlan.self, configurations: [config])
        }

        // 1. Happy path.
        do {
            return Result(container: try openOnDisk(), mode: .normal, backupSucceeded: false)
        } catch {
            log.error("Store open failed: \(error.localizedDescription)")
        }

        let storeURL = config.url

        // 2. Is the store file PROVABLY corrupt? Only then may we move it aside.
        //    A valid/healthy store has the SQLite magic header; garbage/corruption does not.
        if storeFileExists(at: storeURL) && !looksLikeValidSQLite(at: storeURL) {
            log.error("Store file is not a valid SQLite database — preserving and starting fresh")
            let preserved = preserveStore(at: storeURL)
            if preserved {
                if let container = try? openOnDisk() {
                    return Result(container: container, mode: .recoveredFromCorruption, backupSucceeded: true)
                }
                log.error("Fresh store creation failed after preserving the corrupt store")
            } else {
                log.error("Could not safely preserve the corrupt store — refusing to overwrite it")
            }
            // Preserve failed, or fresh open failed: fall through to in-memory WITHOUT
            // having overwritten anything we couldn't move.
            return inMemoryResult(schema: schema, backupSucceeded: preserved)
        }

        // 3. Store looks valid (or doesn't exist) but still won't open — treat as transient.
        //    Retry the SAME on-disk open a few times before giving up. NEVER move data aside here.
        for attempt in 1...transientRetries {
            if let container = try? openOnDisk() {
                log.info("On-disk store opened on retry \(attempt)")
                return Result(container: container, mode: .normal, backupSucceeded: false)
            }
        }

        // 4. Persistent non-corruption failure (permissions/disk/locked, or a valid-header
        //    store we can't open). Leave the on-disk data UNTOUCHED; run in-memory this launch
        //    so the app opens. Next launch will try the real store again.
        log.error("On-disk store unavailable; running in temporary in-memory mode (disk data left intact)")
        return inMemoryResult(schema: schema, backupSucceeded: false)
    }

    /// Build the in-memory last-resort container. `fatalError` only if even RAM fails.
    private static func inMemoryResult(schema: Schema, backupSucceeded: Bool) -> Result {
        do {
            let memory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [memory])
            return Result(container: container, mode: .temporaryInMemory, backupSucceeded: backupSucceeded)
        } catch {
            // If even in-memory fails, the runtime is unusable; surface it loudly.
            fatalError("Unrecoverable: could not create in-memory container: \(error)")
        }
    }

    // MARK: - Corruption detection

    private static func storeFileExists(at storeURL: URL) -> Bool {
        FileManager.default.fileExists(atPath: storeURL.path)
    }

    /// True if the file begins with the 16-byte SQLite magic header ("SQLite format 3\0").
    /// A healthy SwiftData/CoreData store always does; garbage/truncated/corrupt files do not.
    /// Conservative: any read problem returns `false`-for-corruption only when we can read a
    /// non-matching header; an unreadable file is treated as "not provably corrupt" (we do not
    /// move it aside) by the caller's `storeFileExists && !looksLikeValidSQLite` guard handling.
    static func looksLikeValidSQLite(at storeURL: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: storeURL) else {
            // Can't even read it (permissions, etc.) — not a corruption signal. Don't move aside.
            return true
        }
        defer { try? handle.close() }
        let magic = Data("SQLite format 3\u{0}".utf8)   // exactly 16 bytes
        let head = (try? handle.read(upToCount: magic.count)) ?? Data()
        return head == magic
    }

    // MARK: - Atomic preserve (move-aside, never delete)

    /// Atomically move the store trio (.store, -shm, -wal) into a sibling `Recovered/`
    /// directory, timestamped. All-or-nothing: if ANY member fails to move, everything
    /// already moved is rolled back and this returns `false` so the caller will NOT
    /// overwrite the original store. Never deletes.
    private static func preserveStore(at storeURL: URL) -> Bool {
        let fm = FileManager.default
        let recoveredDir = storeURL.deletingLastPathComponent()
            .appendingPathComponent("Recovered", isDirectory: true)
        do {
            try fm.createDirectory(at: recoveredDir, withIntermediateDirectories: true)
        } catch {
            log.error("Could not create Recovered/ dir: \(error.localizedDescription)")
            return false
        }

        let stamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let base = storeURL.deletingPathExtension().lastPathComponent  // "test" or "default"
        let ext = storeURL.pathExtension                               // "store"

        // The actual on-disk members of the trio, paired with their destinations.
        let members: [(src: URL, dst: URL)] = ["", "-shm", "-wal"].compactMap { suffix in
            let src = URL(fileURLWithPath: storeURL.path + suffix)
            guard fm.fileExists(atPath: src.path) else { return nil }
            let dst = recoveredDir.appendingPathComponent("\(base)-\(stamp).\(ext)\(suffix)")
            return (src, dst)
        }
        guard !members.isEmpty else { return false }  // nothing to preserve

        var moved: [(src: URL, dst: URL)] = []
        for member in members {
            do {
                try fm.moveItem(at: member.src, to: member.dst)
                moved.append(member)
            } catch {
                log.error("Preserve failed for \(member.src.lastPathComponent): \(error.localizedDescription); rolling back")
                // Roll everything back so the original store stays intact and untouched.
                for done in moved.reversed() {
                    try? fm.moveItem(at: done.dst, to: done.src)
                }
                return false
            }
        }
        return true
    }
}
