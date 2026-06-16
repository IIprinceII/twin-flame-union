# Phase 3 — Bug Fixes Design

**Date:** 2026-06-16
**Status:** Approved (design locked by user 2026-06-16)
**Roadmap:** `2026-06-14-twin-flame-union-program-roadmap.md` → Phase 3
**Repo:** `~/Developer/twin-flame-union` (GitHub `IIprinceII/twin-flame-union`)

## Goal

Finish the two remaining Phase 3 bugs — HealthKit authorization that lies on denial, and
the meditation timer that drifts in the background and never logs to Apple Health. The
other four Phase 3 items were already fixed in a prior session (see audit below).

## Audit — Phase 3 items already done (verified on `main`, 2026-06-16)

| Roadmap item | Status |
|--------------|--------|
| Unify the two streak systems (`sacredStreakCount` vs `streakCount`) | **Done** — unified `streakCount` key everywhere (`MoonPhase.swift`, `GamificationService.swift`) |
| Wire gamification feedback (`XPGainIndicator`, level-up, `AchievementToast`) | **Done** — `MainTabView.swift:92` `.overlay { GamificationOverlay() }` |
| `ToneGenerator` off-MainActor render + `AVAudioSession` interruption/route-change | **Done** — render block captures frequency off-actor; interruption + routeChange observers present |
| Off-by-one negative XP in `SoulProfile.xpForCurrentLevel` | **Done** — corrected consumed-XP loop |

Only the two below remain.

## Locked decision (from brainstorm)

| Decision | Choice |
|----------|--------|
| **HealthKit logging UX** | **Request permission on the user's first meditation; log to Apple Health only on full completion.** A denial just no-ops (no nagging). Early manual "End Session" does not log. |

## Current state of the two open bugs (verified)

**Bug 5 — `Services/HealthService.swift`:**
- `var isAuthorized: Bool = false` is an in-memory bool, reset to `false` every launch.
- `requestAuthorization()` calls `store.requestAuthorization(toShare:read:)` then sets
  `isAuthorized = true` **unconditionally**. HealthKit's request succeeds whether the user
  grants OR denies (it only means the prompt was shown), so the app claims authorization it
  may not have. `logMindfulSession`/`fetchRecentSessions` then gate on this false-positive.

**Bug 6 — `Views/Home/MeditationView.swift`:**
- `startCountdown()` runs `Task { while !cancelled { try? await Task.sleep(for: .seconds(1)); timeRemaining -= 1 } }`.
  This **suspends when the app is backgrounded** and `Task.sleep` is not wall-clock exact, so
  elapsed meditation time drifts (a 10-min session backgrounded for 5 min takes ~15 real min).
- On completion it awards XP (`GamificationService.awardXP`) but **never calls
  `HealthService.logMindfulSession`** — meditations are not logged to Apple Health at all.

## Architecture

Two focused, independent fixes. The timer fix introduces one small pure value type so the
wall-clock logic is unit-testable without HealthKit or the UI.

### Component 1 — HealthKit authorization (`Services/HealthService.swift`)
Replace the stored `isAuthorized` with a **computed** property reflecting the real status:
```swift
var isAuthorized: Bool {
    #if canImport(HealthKit)
    guard isAvailable,
          let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)
    else { return false }
    return HKHealthStore().authorizationStatus(for: mindfulType) == .sharingAuthorized
    #else
    return false
    #endif
}
```
- Remove the `isAuthorized = true` assignment in `requestAuthorization()`. The prompt still
  shows; the computed property now returns the truth (`.sharingDenied`/`.notDetermined` →
  false). Since `mindfulSession` is a **share/write** type, `authorizationStatus(for:)` is
  reliable (unlike read types, which HealthKit obscures for privacy).
- No other change to `logMindfulSession` / `fetchRecentSessions` — they already gate on
  `isAuthorized`, which is now correct and launch-stable.

### Component 2 — Meditation timer wall-clock + Health logging (`Views/Home/MeditationView.swift`)
- **New pure value type** (same file or `Models/`), the wall-clock source of truth:
  ```swift
  struct MeditationClock {
      let endDate: Date
      func remaining(at now: Date) -> TimeInterval { max(0, endDate.timeIntervalSince(now)) }
      func isComplete(at now: Date) -> Bool { now >= endDate }
  }
  ```
- **ViewModel `start()`:** set `clock = MeditationClock(endDate: Date().addingTimeInterval(selectedSession.duration))`.
  On the **first-ever** meditation start (gated by an `@AppStorage("hasRequestedMeditationHealth")`
  flag), fire `Task { try? await HealthService.shared.requestAuthorization() }` once.
- **Countdown `Task`:** each tick set `timeRemaining = clock.remaining(at: Date())` (compute,
  do not decrement). When `clock.isComplete(at: Date())`, run the completion path.
- **Foreground re-sync:** the View observes `@Environment(\.scenePhase)`; on return to
  `.active`, re-evaluate `timeRemaining` from `clock`. If the end already passed while
  backgrounded, run the completion path then.
- **Completion path (full completion only):** mark `isComplete`, `stop()`, award XP (existing),
  and `Task { try? await HealthService.shared.logMindfulSession(duration: selectedSession.duration) }`.
  `logMindfulSession` internally no-ops if `!isAuthorized`, so a denial is silent. Manual
  "End Session" before completion does **not** log.

## Data flow

Start → set wall-clock `endDate` + (first time) request Health auth → countdown computes
`timeRemaining` from `endDate` each tick and on foreground → at `endDate`: complete → award
XP + log mindful session to Apple Health (if authorized).

## Error handling

- HealthKit unavailable / denied → `isAuthorized` false → logging silently skipped; app
  behaves normally.
- `requestAuthorization`/`logMindfulSession` are `try?` from the meditation flow — a Health
  failure never disrupts the meditation or crashes.

## Testing

- **`MeditationClockTests`** (pure, hermetic): `remaining(at:)` equals `endDate − now` and
  floors at 0; a simulated background gap (jump `now` forward) does not "lose" time vs. a
  decrement loop; `isComplete(at:)` is false before `endDate` and true at/after it.
- **`HealthServiceTests`**: on the simulator (default `.notDetermined`), `isAuthorized == false`
  — proving the app no longer claims authorization it doesn't have. `isAvailable` reflects
  `HKHealthStore.isHealthDataAvailable()`.
- **User-verified in Xcode** (can't unit-test Health writes / scene backgrounding): start a
  short meditation, background the app mid-session, return — time is correct; on completion a
  mindful session appears in Apple Health (after granting permission on first run); denying
  permission logs nothing and doesn't break anything.

## Out of scope

- The four already-fixed Phase 3 bugs (streaks, gamification feedback, ToneGenerator, XP math).
- Logging partial/early-ended meditations (only full completions log, per decision).
- Reading/among other HealthKit types beyond `mindfulSession`.
- Any new gamification, audio, or feature work.

## File summary

**New:**
- `Twin Flame UnionTests/MeditationClockTests.swift`
- `Twin Flame UnionTests/HealthServiceTests.swift`

**Modified:**
- `Twin Flame Union/Services/HealthService.swift` (computed `isAuthorized`; drop `= true`)
- `Twin Flame Union/Views/Home/MeditationView.swift` (`MeditationClock`, wall-clock countdown,
  scenePhase re-sync, first-run Health request, log on completion)
