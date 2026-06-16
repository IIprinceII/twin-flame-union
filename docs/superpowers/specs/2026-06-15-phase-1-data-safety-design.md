# Phase 1 — Data Safety Design

**Date:** 2026-06-15
**Status:** Approved (design locked by user 2026-06-15)
**Roadmap:** `2026-06-14-twin-flame-union-program-roadmap.md` → Phase 1
**Repo:** `~/Developer/twin-flame-union` (GitHub `IIprinceII/twin-flame-union`)

## Goal

Make Twin Flame Union's local data **safe**: a future schema change must never
brick an existing user's app, a corrupt store must never crash on launch, and the
user must be able to get their data out as a file. Lay the groundwork so CloudKit
sync becomes a config flip later, without doing CloudKit in this phase.

## Locked decisions (from brainstorm)

| Decision | Choice |
|----------|--------|
| **CloudKit timing** | **Deferred.** Make models CloudKit-*ready* now; turn-on (entitlement + container + `.automatic`) is a separate follow-on. User has a paid account but we don't want this phase blocked on device testing. |
| **Store-open failure behavior** | **Preserve + fresh start.** Move the unreadable store aside (never delete), start clean so the app opens, show a one-time calm notice. |
| **Export** | **Export-only** JSON via `.fileExporter`. No import/restore this phase (Phase 6). |
| **Persistence structure** | Dedicated `Persistence` + `AppSchema` types; App file shrinks to one call. |

## Current state (verified 2026-06-15)

- **12 `@Model` types**, all registered in one `Schema` in `Twin_Flame_UnionApp.swift`:
  `JournalEntry, DreamEntry, SynchronicityEntry, ChakraEntry, ManifestationItem,
  ConnectionMoment, PrayerEntry, GratitudeEntry, SoulProfile, XPEvent, Achievement,
  DailyChallenge`.
- **No `@Relationship`, no `@Attribute(.unique)`** anywhere — the two CloudKit
  blockers are absent.
- Properties are **non-optional with defaults only in `init()`**, not at the
  property declaration. CloudKit requires every attribute to be optional *or* have
  a property-level default.
- Container is created with `ModelConfiguration(schema:, isStoredInMemoryOnly: false)`
  at the **default store location**, and a `fatalError` on failure (line 39).
- Entitlements: HealthKit only. **No iCloud entitlement.**

## Architecture

A dedicated persistence layer isolates all SwiftData container concerns from the
App and the views.

### Component 1 — `Persistence/AppSchema.swift`
- `enum AppSchemaV1: VersionedSchema`
  - `static var versionIdentifier = Schema.Version(1, 0, 0)`
  - `static var models: [any PersistentModel.Type] = [ …all 12… ]`
  - Freezes today's shape as the documented baseline. Models stay where they live;
    the enum only *references* them.
- `enum TFUMigrationPlan: SchemaMigrationPlan`
  - `static var schemas: [any VersionedSchema.Type] = [AppSchemaV1.self]`
  - `static var stages: [MigrationStage] = []`
  - Empty today. The scaffold means a future `AppSchemaV2` is a tiny diff — add the
    new versioned schema + one migration stage — never a rewrite of container setup.

### Component 2 — `Persistence/PersistenceController.swift`
`enum Persistence` with:
- `static func makeContainer() -> ModelContainer`
- `static private(set) var didRecoverStore: Bool` (or surfaced via UserDefaults flag)

`makeContainer()` algorithm:
1. Build `let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)`
   — **default location**, so existing build-10 data is found, not orphaned.
2. Capture `let storeURL = config.url` (resolved path; no filename guessing).
3. `try ModelContainer(for: schema, migrationPlan: TFUMigrationPlan.self, configurations: [config])` → return on success.
4. **On throw (corruption / failed migration):**
   - Create `Application Support/Recovered/` if needed.
   - Move the store trio — `storeURL`, `storeURL-shm`, `storeURL-wal` — to
     `Recovered/TwinFlameUnion-<ISO8601-timestamp>.store(-shm/-wal)`. **Rename,
     never delete.**
   - Set the `didRecoverStore` flag (persisted in UserDefaults so the UI can read it).
   - Retry: `try ModelContainer(...)` with a now-empty store → return on success.
5. **If step 4 also throws:** return an in-memory container
   (`ModelConfiguration(isStoredInMemoryOnly: true)`) as an absolute last resort,
   so the app always opens. Log loudly.

### Component 3 — Recovery notice (UI)
- Driven by the `didRecoverStore` UserDefaults flag.
- A one-time, calm alert presented on first appearance of `MainTabView`:
  > "We had trouble opening your saved data, so we started fresh to keep the app
  > working. Your previous data was safely backed up."
- Dismissing clears the flag (so it shows once per recovery event).

### Component 4 — CloudKit-ready model defaults
- Edit all 12 `@Model` files: every stored property gets a **property-level default**
  matching what `init` already supplies — e.g. `var title: String = ""`,
  `var totalXP: Int = 0`, `var createdAt: Date = Date()`, `var isLucid: Bool = false`,
  `var skillLevelsData: Data = Data()`.
- `id` keeps `= UUID()`.
- **No behavior change**: the `init`s already pass these exact values; this only
  satisfies CloudKit's "optional-or-defaulted" requirement ahead of time.
- Leave `init`s intact (callers unchanged).

### Component 5 — Export My Data
- `Services/DataExportService.swift`:
  - A `Codable` snapshot struct, e.g. `DataExportSnapshot`, with:
    - `schemaVersion: String` (e.g. `"1.0.0"`, mirrors `AppSchemaV1`)
    - `exportedAt: Date`
    - one array per model type (plain `Codable` DTOs mirroring the model fields —
      not the `@Model` classes themselves).
  - `static func snapshot(from context: ModelContext) throws -> DataExportSnapshot`
    — fetches every model array and maps to DTOs.
  - `static func encode(_:) throws -> Data` — pretty-printed, ISO8601 dates.
- `JSONDocument: FileDocument` wrapper (`UTType.json`), read+write conformance.
- `SettingsView`: an **"Export My Data"** row that builds the document and presents
  `.fileExporter`, producing `TwinFlameUnion-Backup-<yyyy-MM-dd>.json`.
- Export-only; the `schemaVersion` field future-proofs a Phase 6 import path.

### Component 6 — App wiring
- `Twin_Flame_UnionApp.swift`: replace the `sharedModelContainer` closure body and
  its `fatalError` with `Persistence.makeContainer()`. Present the recovery notice
  off the `didRecoverStore` flag.

## Data flow

**Launch (happy path):** App → `Persistence.makeContainer()` → versioned container →
`.modelContainer(...)` → views query as today.

**Launch (corrupt store):** `makeContainer()` throws → store trio moved to
`Recovered/` → fresh container returned → app opens empty → one-time notice shown →
old data recoverable from `Recovered/` on disk.

**Export:** Settings "Export My Data" → `DataExportService.snapshot(from:)` →
`encode` → `JSONDocument` → `.fileExporter` → user picks a destination → file written.

## Testing

Logic is testable without the Xcode UI:
- **Migration:** a `ModelContainer` built from `TFUMigrationPlan` + `AppSchemaV1`
  loads cleanly and round-trips a sample insert/fetch.
- **Recovery:** given a deliberately-corrupt store file at the config URL,
  `makeContainer()` produces a working container AND the corrupt file now lives under
  `Recovered/` (original path empty), and `didRecoverStore == true`.
- **Export:** `snapshot(from:)` over a context seeded with known entries produces a
  snapshot whose arrays/counts/fields match; `encode` → decode round-trips equal.

Final functional verification is the **user building in Xcode** (per program execution
model): launch is clean, Settings → Export My Data writes a valid file, and an
intentionally-corrupted store triggers the notice instead of a crash.

## Out of scope (explicitly deferred)

- CloudKit entitlement, iCloud container, `ModelConfiguration(cloudKitDatabase: .automatic)`.
- JSON **import**/restore (Phase 6 — "Settings data-management completeness").
- Any `@Relationship` between models.
- HealthKit auth-state fixes (those are Phase 3 bug-fix items).

## File summary

**New:**
- `Twin Flame Union/Persistence/AppSchema.swift`
- `Twin Flame Union/Persistence/PersistenceController.swift`
- `Twin Flame Union/Services/DataExportService.swift`
- `Twin Flame Union/Services/JSONDocument.swift` (or co-located in the export service)

**Modified:**
- `Twin Flame Union/Twin_Flame_UnionApp.swift` (use `Persistence`, recovery notice)
- `Twin Flame Union/Views/Settings/SettingsView.swift` (Export My Data row + `.fileExporter`)
- All 12 `@Model` files (property-level defaults)
