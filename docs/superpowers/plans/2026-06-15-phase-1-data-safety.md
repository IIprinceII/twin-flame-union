# Phase 1 — Data Safety Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make local SwiftData safe — versioned schema + migration scaffold, a non-crashing "preserve-and-fresh-start" recovery path replacing the launch `fatalError`, CloudKit-ready model defaults, and a Settings "Export My Data" JSON export.

**Architecture:** A dedicated `Persistence` layer owns `ModelContainer` creation and recovery; an `AppSchema` type holds the `VersionedSchema` + `SchemaMigrationPlan`. Models gain property-level defaults (CloudKit prep). Export uses a `Codable` snapshot of plain DTOs written through a `FileDocument` + `.fileExporter`.

**Tech Stack:** Swift / SwiftUI, SwiftData (`VersionedSchema`, `SchemaMigrationPlan`, `ModelContainer`, `ModelConfiguration`), Swift Testing (`import Testing`, `@Test`, `#expect`), `UniformTypeIdentifiers`.

**Spec:** `docs/superpowers/specs/2026-06-15-phase-1-data-safety-design.md`

**Conventions for this repo:**
- The Xcode project uses **`PBXFileSystemSynchronizedRootGroup`** — any new `.swift` file placed under `Twin Flame Union/` (app target) or `Twin Flame UnionTests/` (test target) is **auto-included** in the build. No `project.pbxproj` editing needed.
- Tests use **Swift Testing**, not XCTest.
- Run tests from Xcode with **Cmd+U** (primary), or headless:
  `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests"`
  (adjust the simulator name to one shown by `xcrun simctl list devices available`).
- Final functional verification is the **user building/running in Xcode** (Task 8).

---

## Task 0: Working branch

- [ ] **Step 1: Create the feature branch**

```bash
cd ~/Developer/twin-flame-union
git checkout main
git checkout -b phase-1-data-safety
git status
```
Expected: on branch `phase-1-data-safety`, clean tree.

---

## Task 1: Versioned schema + migration plan

**Files:**
- Create: `Twin Flame Union/Persistence/AppSchema.swift`
- Test: `Twin Flame UnionTests/AppSchemaTests.swift`

- [ ] **Step 1: Write the failing test**

Create `Twin Flame UnionTests/AppSchemaTests.swift`:
```swift
import Testing
import SwiftData
@testable import Twin_Flame_Union

struct AppSchemaTests {

    @Test func versionedSchemaListsAllTwelveModels() {
        #expect(AppSchemaV1.models.count == 12)
        #expect(AppSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    }

    @Test func containerBuildsFromMigrationPlanAndRoundTrips() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Schema(AppSchemaV1.models),
            migrationPlan: TFUMigrationPlan.self,
            configurations: [config]
        )
        let context = ModelContext(container)
        context.insert(DreamEntry(title: "Test Dream"))
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<DreamEntry>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.title == "Test Dream")
    }
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/AppSchemaTests"`
Expected: FAIL — `cannot find 'AppSchemaV1' in scope`.

- [ ] **Step 3: Create the schema file**

Create `Twin Flame Union/Persistence/AppSchema.swift`:
```swift
//
//  AppSchema.swift
//  Twin Flame Union
//
//  Versioned SwiftData schema + migration plan. AppSchemaV1 freezes the current
//  model shape as the documented baseline. A future AppSchemaV2 is a small diff:
//  add the new versioned schema to `schemas` and one stage to `stages`.
//

import Foundation
import SwiftData

enum AppSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            JournalEntry.self,
            DreamEntry.self,
            SynchronicityEntry.self,
            ChakraEntry.self,
            ManifestationItem.self,
            ConnectionMoment.self,
            PrayerEntry.self,
            GratitudeEntry.self,
            SoulProfile.self,
            XPEvent.self,
            Achievement.self,
            DailyChallenge.self,
        ]
    }
}

enum TFUMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [AppSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []   // No migrations yet. Add a stage here when AppSchemaV2 lands.
    }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/AppSchemaTests"`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Persistence/AppSchema.swift" "Twin Flame UnionTests/AppSchemaTests.swift"
git commit -m "Phase 1: add versioned schema (AppSchemaV1) + migration plan scaffold

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Persistence controller with preserve-and-fresh-start recovery

**Files:**
- Create: `Twin Flame Union/Persistence/PersistenceController.swift`
- Test: `Twin Flame UnionTests/PersistenceRecoveryTests.swift`

Design note: `makeContainer()` is the production entry point (default store location).
`makeContainer(config:)` takes an explicit configuration so tests can point at a temp
store file and corrupt it. Recovered files go to a `Recovered/` directory that is a
sibling of the store file, so test artifacts stay in the temp dir.

- [ ] **Step 1: Write the failing test**

Create `Twin Flame UnionTests/PersistenceRecoveryTests.swift`:
```swift
import Testing
import SwiftData
import Foundation
@testable import Twin_Flame_Union

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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/PersistenceRecoveryTests"`
Expected: FAIL — `cannot find 'Persistence' in scope`.

- [ ] **Step 3: Create the persistence controller**

Create `Twin Flame Union/Persistence/PersistenceController.swift`:
```swift
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
        if let storeURL = config.url as URL? {
            preserveStore(at: storeURL)
        }
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
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/PersistenceRecoveryTests"`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Persistence/PersistenceController.swift" "Twin Flame UnionTests/PersistenceRecoveryTests.swift"
git commit -m "Phase 1: preserve-and-fresh-start ModelContainer recovery

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: CloudKit-ready model defaults (all 12 models)

**Files (modify — add property-level defaults; leave `init`s unchanged):**
- `Twin Flame Union/Item.swift` (JournalEntry)
- `Twin Flame Union/Models/DreamEntry.swift`
- `Twin Flame Union/Models/SynchronicityEntry.swift`
- `Twin Flame Union/Models/ChakraEntry.swift`
- `Twin Flame Union/Models/ManifestationItem.swift`
- `Twin Flame Union/Models/ConnectionMoment.swift`
- `Twin Flame Union/Models/PrayerEntry.swift`
- `Twin Flame Union/Models/GratitudeEntry.swift`
- `Twin Flame Union/Models/Gamification/SoulProfile.swift`
- `Twin Flame Union/Models/Gamification/XPEvent.swift`
- `Twin Flame Union/Models/Gamification/Achievement.swift`
- `Twin Flame Union/Models/Gamification/DailyChallenge.swift`
- Test: `Twin Flame UnionTests/ModelDefaultsTests.swift`

- [ ] **Step 1: Write the failing test**

Create `Twin Flame UnionTests/ModelDefaultsTests.swift`:
```swift
import Testing
import SwiftData
import Foundation
@testable import Twin_Flame_Union

struct ModelDefaultsTests {

    // Building the full production schema in-memory and round-tripping one of each
    // model proves the property-level defaults don't break persistence.
    @Test func fullSchemaPersistsEveryModel() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Schema(AppSchemaV1.models), configurations: [config])
        let ctx = ModelContext(container)

        ctx.insert(JournalEntry(title: "j"))
        ctx.insert(DreamEntry(title: "d"))
        ctx.insert(SynchronicityEntry(type: "Angel Number"))
        ctx.insert(ChakraEntry())
        ctx.insert(ManifestationItem(intention: "m"))
        ctx.insert(ConnectionMoment(title: "c"))
        ctx.insert(PrayerEntry(petition: "p"))
        ctx.insert(GratitudeEntry())
        ctx.insert(SoulProfile())
        ctx.insert(XPEvent(amount: 10))
        ctx.insert(Achievement(key: "a"))
        ctx.insert(DailyChallenge())
        try ctx.save()

        #expect(try ctx.fetch(FetchDescriptor<JournalEntry>()).count == 1)
        #expect(try ctx.fetch(FetchDescriptor<SoulProfile>()).count == 1)
        #expect(try ctx.fetch(FetchDescriptor<DailyChallenge>()).count == 1)
    }

    @Test func defaultInitsProduceExpectedValues() {
        #expect(JournalEntry().mood == "Hopeful")
        #expect(DreamEntry().isLucid == false)
        #expect(ChakraEntry().heart == 3)
        #expect(ManifestationItem().emoji == "✨")
        #expect(SoulProfile().constitutionRating == "A")
        #expect(DailyChallenge().xpReward == 50)
    }
}
```

- [ ] **Step 2: Run the test to verify it builds/passes against current code**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/ModelDefaultsTests"`
Expected: PASS already (defaults currently come from `init`). This test is the **regression guard** — it must still pass after Step 3 moves the defaults to the property declarations.

- [ ] **Step 3: Add property-level defaults to each model**

Edit each file so every stored property declares its default. Apply exactly these declaration blocks (the `init`s stay as-is):

`Twin Flame Union/Item.swift` (JournalEntry):
```swift
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var mood: String = "Hopeful"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
```

`Twin Flame Union/Models/DreamEntry.swift`:
```swift
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var people: String = ""
    var symbols: String = ""
    var wakeFeeling: String = ""
    var isLucid: Bool = false
    var isTwinFlameDream: Bool = false
    var createdAt: Date = Date()
```

`Twin Flame Union/Models/SynchronicityEntry.swift`:
```swift
    var id: UUID = UUID()
    var type: String = ""
    var detail: String = ""
    var note: String = ""
    var createdAt: Date = Date()
```

`Twin Flame Union/Models/ChakraEntry.swift`:
```swift
    var id: UUID = UUID()
    var date: Date = Date()
    var root: Int = 3
    var sacral: Int = 3
    var solarPlexus: Int = 3
    var heart: Int = 3
    var throat: Int = 3
    var thirdEye: Int = 3
    var crown: Int = 3
    var note: String = ""
```

`Twin Flame Union/Models/ManifestationItem.swift`:
```swift
    var id: UUID = UUID()
    var intention: String = ""
    var emoji: String = "✨"
    var isManifested: Bool = false
    var createdAt: Date = Date()
```

`Twin Flame Union/Models/ConnectionMoment.swift`:
```swift
    var id: UUID = UUID()
    var title: String = ""
    var detail: String = ""
    var category: String = "Milestone"
    var date: Date = Date()
    var createdAt: Date = Date()
```

`Twin Flame Union/Models/PrayerEntry.swift`:
```swift
    var id: UUID = UUID()
    var petition: String = ""
    var detail: String = ""
    var isAnswered: Bool = false
    var answeredNote: String = ""
    var createdAt: Date = Date()
    var answeredAt: Date? = nil
```

`Twin Flame Union/Models/GratitudeEntry.swift`:
```swift
    var id: UUID = UUID()
    var date: Date = Date()
    var items: String = ""
```

`Twin Flame Union/Models/Gamification/SoulProfile.swift`:
```swift
    var id: UUID = UUID()
    var totalXP: Int = 0
    var vibrationalScore: Double = 0.0
    var vibrationalGameXP: Int = 0
    var energyEnhancementXP: Int = 0
    var apolluxXP: Int = 0
    var skillLevelsData: Data = Data()
    var constitutionRating: String = "A"
    var createdAt: Date = Date()
    var lastActivityAt: Date = Date()
```

`Twin Flame Union/Models/Gamification/XPEvent.swift`:
```swift
    var id: UUID = UUID()
    var amount: Int = 0
    var source: String = ""
    var framework: String = ""
    var skillKey: String = ""
    var detail: String = ""
    var createdAt: Date = Date()
```

`Twin Flame Union/Models/Gamification/Achievement.swift`:
```swift
    var id: UUID = UUID()
    var key: String = ""
    var title: String = ""
    var detail: String = ""
    var icon: String = ""
    var rarity: String = "common"
    var framework: String = ""
    var unlockedAt: Date = Date()
    var xpReward: Int = 0
```

`Twin Flame Union/Models/Gamification/DailyChallenge.swift`:
```swift
    var id: UUID = UUID()
    var date: Date = Date()
    var challengeKey: String = ""
    var title: String = ""
    var detail: String = ""
    var xpReward: Int = 50
    var isCompleted: Bool = false
    var completedAt: Date? = nil
```

- [ ] **Step 4: Run the tests to verify they still pass**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/ModelDefaultsTests"`
Expected: PASS (2 tests) — behavior unchanged, defaults now at property level.

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Item.swift" "Twin Flame Union/Models" "Twin Flame UnionTests/ModelDefaultsTests.swift"
git commit -m "Phase 1: CloudKit-ready property-level defaults on all 12 models

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Export snapshot + service + document

**Files:**
- Create: `Twin Flame Union/Services/DataExportService.swift`
- Create: `Twin Flame Union/Services/JSONDocument.swift`
- Test: `Twin Flame UnionTests/DataExportTests.swift`

- [ ] **Step 1: Write the failing test**

Create `Twin Flame UnionTests/DataExportTests.swift`:
```swift
import Testing
import SwiftData
import Foundation
@testable import Twin_Flame_Union

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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/DataExportTests"`
Expected: FAIL — `cannot find 'DataExportService' in scope`.

- [ ] **Step 3: Create the export service**

Create `Twin Flame Union/Services/DataExportService.swift`:
```swift
//
//  DataExportService.swift
//  Twin Flame Union
//
//  Builds a Codable snapshot of all user data for "Export My Data".
//  Export-only. The `schemaVersion` field future-proofs a later import path.
//

import Foundation
import SwiftData

// MARK: - Snapshot DTOs (plain Codable mirrors of the @Model types)

struct DataExportSnapshot: Codable {
    var schemaVersion: String = "1.0.0"
    var exportedAt: Date = Date()
    var journalEntries: [JournalDTO] = []
    var dreamEntries: [DreamDTO] = []
    var synchronicities: [SynchronicityDTO] = []
    var chakraEntries: [ChakraDTO] = []
    var manifestations: [ManifestationDTO] = []
    var connectionMoments: [ConnectionMomentDTO] = []
    var prayers: [PrayerDTO] = []
    var gratitudeEntries: [GratitudeDTO] = []
    var soulProfiles: [SoulProfileDTO] = []
    var xpEvents: [XPEventDTO] = []
    var achievements: [AchievementDTO] = []
    var dailyChallenges: [DailyChallengeDTO] = []
}

struct JournalDTO: Codable { var id: UUID; var title: String; var content: String; var mood: String; var createdAt: Date; var updatedAt: Date }
struct DreamDTO: Codable { var id: UUID; var title: String; var content: String; var people: String; var symbols: String; var wakeFeeling: String; var isLucid: Bool; var isTwinFlameDream: Bool; var createdAt: Date }
struct SynchronicityDTO: Codable { var id: UUID; var type: String; var detail: String; var note: String; var createdAt: Date }
struct ChakraDTO: Codable { var id: UUID; var date: Date; var root: Int; var sacral: Int; var solarPlexus: Int; var heart: Int; var throat: Int; var thirdEye: Int; var crown: Int; var note: String }
struct ManifestationDTO: Codable { var id: UUID; var intention: String; var emoji: String; var isManifested: Bool; var createdAt: Date }
struct ConnectionMomentDTO: Codable { var id: UUID; var title: String; var detail: String; var category: String; var date: Date; var createdAt: Date }
struct PrayerDTO: Codable { var id: UUID; var petition: String; var detail: String; var isAnswered: Bool; var answeredNote: String; var createdAt: Date; var answeredAt: Date? }
struct GratitudeDTO: Codable { var id: UUID; var date: Date; var items: String }
struct SoulProfileDTO: Codable { var id: UUID; var totalXP: Int; var vibrationalScore: Double; var vibrationalGameXP: Int; var energyEnhancementXP: Int; var apolluxXP: Int; var constitutionRating: String; var createdAt: Date; var lastActivityAt: Date }
struct XPEventDTO: Codable { var id: UUID; var amount: Int; var source: String; var framework: String; var skillKey: String; var detail: String; var createdAt: Date }
struct AchievementDTO: Codable { var id: UUID; var key: String; var title: String; var detail: String; var icon: String; var rarity: String; var framework: String; var unlockedAt: Date; var xpReward: Int }
struct DailyChallengeDTO: Codable { var id: UUID; var date: Date; var challengeKey: String; var title: String; var detail: String; var xpReward: Int; var isCompleted: Bool; var completedAt: Date? }

// MARK: - Service

enum DataExportService {

    static func snapshot(from context: ModelContext) throws -> DataExportSnapshot {
        var snap = DataExportSnapshot()
        snap.exportedAt = Date()

        snap.journalEntries = try context.fetch(FetchDescriptor<JournalEntry>()).map {
            JournalDTO(id: $0.id, title: $0.title, content: $0.content, mood: $0.mood, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        snap.dreamEntries = try context.fetch(FetchDescriptor<DreamEntry>()).map {
            DreamDTO(id: $0.id, title: $0.title, content: $0.content, people: $0.people, symbols: $0.symbols, wakeFeeling: $0.wakeFeeling, isLucid: $0.isLucid, isTwinFlameDream: $0.isTwinFlameDream, createdAt: $0.createdAt)
        }
        snap.synchronicities = try context.fetch(FetchDescriptor<SynchronicityEntry>()).map {
            SynchronicityDTO(id: $0.id, type: $0.type, detail: $0.detail, note: $0.note, createdAt: $0.createdAt)
        }
        snap.chakraEntries = try context.fetch(FetchDescriptor<ChakraEntry>()).map {
            ChakraDTO(id: $0.id, date: $0.date, root: $0.root, sacral: $0.sacral, solarPlexus: $0.solarPlexus, heart: $0.heart, throat: $0.throat, thirdEye: $0.thirdEye, crown: $0.crown, note: $0.note)
        }
        snap.manifestations = try context.fetch(FetchDescriptor<ManifestationItem>()).map {
            ManifestationDTO(id: $0.id, intention: $0.intention, emoji: $0.emoji, isManifested: $0.isManifested, createdAt: $0.createdAt)
        }
        snap.connectionMoments = try context.fetch(FetchDescriptor<ConnectionMoment>()).map {
            ConnectionMomentDTO(id: $0.id, title: $0.title, detail: $0.detail, category: $0.category, date: $0.date, createdAt: $0.createdAt)
        }
        snap.prayers = try context.fetch(FetchDescriptor<PrayerEntry>()).map {
            PrayerDTO(id: $0.id, petition: $0.petition, detail: $0.detail, isAnswered: $0.isAnswered, answeredNote: $0.answeredNote, createdAt: $0.createdAt, answeredAt: $0.answeredAt)
        }
        snap.gratitudeEntries = try context.fetch(FetchDescriptor<GratitudeEntry>()).map {
            GratitudeDTO(id: $0.id, date: $0.date, items: $0.items)
        }
        snap.soulProfiles = try context.fetch(FetchDescriptor<SoulProfile>()).map {
            SoulProfileDTO(id: $0.id, totalXP: $0.totalXP, vibrationalScore: $0.vibrationalScore, vibrationalGameXP: $0.vibrationalGameXP, energyEnhancementXP: $0.energyEnhancementXP, apolluxXP: $0.apolluxXP, constitutionRating: $0.constitutionRating, createdAt: $0.createdAt, lastActivityAt: $0.lastActivityAt)
        }
        snap.xpEvents = try context.fetch(FetchDescriptor<XPEvent>()).map {
            XPEventDTO(id: $0.id, amount: $0.amount, source: $0.source, framework: $0.framework, skillKey: $0.skillKey, detail: $0.detail, createdAt: $0.createdAt)
        }
        snap.achievements = try context.fetch(FetchDescriptor<Achievement>()).map {
            AchievementDTO(id: $0.id, key: $0.key, title: $0.title, detail: $0.detail, icon: $0.icon, rarity: $0.rarity, framework: $0.framework, unlockedAt: $0.unlockedAt, xpReward: $0.xpReward)
        }
        snap.dailyChallenges = try context.fetch(FetchDescriptor<DailyChallenge>()).map {
            DailyChallengeDTO(id: $0.id, date: $0.date, challengeKey: $0.challengeKey, title: $0.title, detail: $0.detail, xpReward: $0.xpReward, isCompleted: $0.isCompleted, completedAt: $0.completedAt)
        }
        return snap
    }

    static func encode(_ snapshot: DataExportSnapshot) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(snapshot)
    }
}
```

- [ ] **Step 4: Create the FileDocument wrapper**

Create `Twin Flame Union/Services/JSONDocument.swift`:
```swift
//
//  JSONDocument.swift
//  Twin Flame Union
//
//  Minimal FileDocument wrapping raw JSON bytes, for use with `.fileExporter`.
//

import SwiftUI
import UniformTypeIdentifiers

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        guard let contents = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = contents
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/DataExportTests"`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Services/DataExportService.swift" "Twin Flame Union/Services/JSONDocument.swift" "Twin Flame UnionTests/DataExportTests.swift"
git commit -m "Phase 1: data export snapshot + service + JSON FileDocument

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Wire the App to Persistence + recovery notice

**Files:**
- Modify: `Twin Flame Union/Twin_Flame_UnionApp.swift`

- [ ] **Step 1: Replace the container closure with `Persistence.makeContainer()`**

In `Twin Flame Union/Twin_Flame_UnionApp.swift`, replace the entire
`var sharedModelContainer: ModelContainer = { … }()` block (lines 20–41) with:
```swift
    let sharedModelContainer: ModelContainer = Persistence.makeContainer()

    @AppStorage(Persistence.didRecoverKey) private var didRecoverStore = false
    @State private var showRecoveryNotice = false
```

- [ ] **Step 2: Present the one-time recovery notice**

In the same file, add an `.alert` to the `WindowGroup` content. Change the
`.modelContainer(sharedModelContainer)` modifier chain so it reads:
```swift
        .modelContainer(sharedModelContainer)
        .environment(toneGenerator)
        .environment(gamification)
        .alert("Your data was recovered", isPresented: $showRecoveryNotice) {
            Button("OK") { didRecoverStore = false }
        } message: {
            Text("We had trouble opening your saved data, so we started fresh to keep the app working. Your previous data was safely backed up.")
        }
        .onAppear {
            if didRecoverStore { showRecoveryNotice = true }
        }
```
(Keep the existing `.onChange(of: hasCompletedOnboarding)` modifier that follows.)

- [ ] **Step 3: Build to verify it compiles**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `BUILD SUCCEEDED`.

- [ ] **Step 4: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Twin_Flame_UnionApp.swift"
git commit -m "Phase 1: use Persistence.makeContainer() + one-time recovery notice

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Settings → Export My Data UI

**Files:**
- Modify: `Twin Flame Union/Views/Settings/SettingsView.swift`

- [ ] **Step 1: Add export state to `SettingsView`**

After line 31 (`@State private var showDeleteAccount = false`), add:
```swift
    @State private var showExporter   = false
    @State private var exportDocument: JSONDocument?
```

- [ ] **Step 2: Add the Export row + build the document**

In `dataSection` (currently starting at line 185), insert an Export button **above**
the existing "Clear Journal Entries" button, so the `SettingsCard` body becomes:
```swift
    private var dataSection: some View {
        SettingsCard(title: "Data") {
            Button {
                exportMyData()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.purple)
                        .frame(width: 28)
                    Text("Export My Data")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            Button(role: .destructive) {
                showClearConfirm = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.coral)
                        .frame(width: 28)
                    Text("Clear Journal Entries")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.coral)
                    Spacer()
                    if !journalEntries.isEmpty {
                        Text("\(journalEntries.count) entries")
                            .font(AppFont.caption(12))
                            .foregroundStyle(AppColors.coral.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }

    private func exportMyData() {
        do {
            let snapshot = try DataExportService.snapshot(from: modelContext)
            exportDocument = JSONDocument(data: try DataExportService.encode(snapshot))
            showExporter = true
        } catch {
            // Export is best-effort; if the fetch/encode fails there is nothing to write.
            exportDocument = nil
        }
    }
```

Note: if `AppColors.textPrimary` does not exist in this codebase, use the color the
other non-destructive rows use (check `aboutSection` around line 168 for the label
color in use) and match it.

- [ ] **Step 3: Attach `.fileExporter` to the body**

In `body`, on the outer `ZStack` (after `.preferredColorScheme(.dark)` at line 61),
add:
```swift
        .fileExporter(
            isPresented: $showExporter,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "TwinFlameUnion-Backup-\(Self.exportDateString())"
        ) { _ in }
```
And add this helper to `SettingsView` (near the other `private func`s):
```swift
    private static func exportDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
```

- [ ] **Step 4: Build to verify it compiles**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `BUILD SUCCEEDED`. If it fails on `AppColors.textPrimary`, swap to the
matching token per the note in Step 2 and rebuild.

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Settings/SettingsView.swift"
git commit -m "Phase 1: Settings -> Export My Data (.fileExporter JSON backup)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Full test sweep + merge

- [ ] **Step 1: Run the entire unit-test suite**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests"`
Expected: PASS — AppSchemaTests (2), PersistenceRecoveryTests (2), ModelDefaultsTests (2), DataExportTests (2).

- [ ] **Step 2: Merge to main**

```bash
cd ~/Developer/twin-flame-union
git checkout main
git merge --no-ff phase-1-data-safety -m "Merge Phase 1: data safety (versioned schema, recovery, export)"
```

- [ ] **Step 3: 🧑 Push** (needs the user's git credentials / branch-protection approval)

```bash
git push origin main
```
🤖 attempts this; if it fails on auth or the branch-protection classifier, the user
runs `! cd ~/Developer/twin-flame-union && git push origin main`.

---

## Task 8: 🧑 User verification gate

**Do not mark Phase 1 complete until the user confirms.**

- [ ] **Step 1:** Open `~/Developer/twin-flame-union/Twin Flame Union.xcodeproj` in Xcode; build + run on a simulator. Confirm the app launches normally and existing entries are intact.
- [ ] **Step 2:** Settings → **Export My Data** → confirm a `TwinFlameUnion-Backup-<date>.json` file is produced and opens as readable JSON with your entries.
- [ ] **Step 3 (recovery smoke test, optional):** With the app installed in the simulator, corrupt the store to prove recovery: find the container path
  (`xcrun simctl get_app_container booted <bundle-id> data` → `Library/Application Support/default.store`), overwrite it with junk, relaunch. Expect the **recovery notice** (not a crash), and a `Recovered/` folder beside the store holding the preserved file.

---

## Self-Review notes

- **Spec coverage:** VersionedSchema + migration plan → Task 1. Recovery path replacing `fatalError` → Tasks 2 + 5. CloudKit-ready defaults (all 12 models) → Task 3. Export My Data → Tasks 4 + 6. Recovery notice → Task 5. Testing → tests in Tasks 1–4, sweep in Task 7, user gate in Task 8. CloudKit turn-on, JSON import, relationships → explicitly out of scope (unchanged). ✅
- **Type consistency:** `Persistence.makeContainer()` (prod) and `Persistence.makeContainer(config:) -> Persistence.Result` (testable) used consistently; `Persistence.didRecoverKey` used in controller + App `@AppStorage`; `DataExportSnapshot` / `DataExportService.snapshot(from:)` / `.encode(_:)` and `JSONDocument(data:)` consistent across service, tests, and Settings. `AppSchemaV1.models` used everywhere a schema is built.
- **Placeholder scan:** No TBD/TODO. The one conditional ("if `AppColors.textPrimary` doesn't exist, match the sibling row's token") is a guarded, explicit fallback with a concrete check location, not a placeholder.
- **Known environmental caveat:** the `xcodebuild` simulator name (`iPhone 16`) may need swapping for a locally-available device; noted at the top.
