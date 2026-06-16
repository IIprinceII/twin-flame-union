# Phase 3 — Bug Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the two remaining Phase 3 bugs — HealthKit `isAuthorized` that claims a grant on denial, and the meditation timer that drifts in the background and never logs to Apple Health.

**Architecture:** Make `HealthService.isAuthorized` a computed property reading the real `authorizationStatus` (with a pure, testable status→bool helper). Drive the meditation countdown from a wall-clock `MeditationClock` value type (pure, testable), re-synced on foreground, and log a mindful session to Apple Health on full completion.

**Tech Stack:** Swift / SwiftUI, HealthKit, Swift Testing (`import Testing`/`@Test`/`#expect`), `@Observable @MainActor` view model, `@Environment(\.scenePhase)`.

**Spec:** `docs/superpowers/specs/2026-06-16-phase-3-bug-fixes-design.md`

**Conventions (same repo as Phases 1–2):**
- New `.swift` files under `Twin Flame Union/` or `Twin Flame UnionTests/` auto-join the build (synchronized groups). No `project.pbxproj` editing.
- Test module is **`The_Twin_Flame_Union_App`**; Swift Testing, not XCTest.
- Build/test headless: `-scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`.
- SourceKit "cannot find X" diagnostics are stale-index noise — trust `** BUILD/TEST SUCCEEDED **`.
- Final functional verification (Health writes, real backgrounding) is the user in Xcode (Task 5).

---

## Task 0: Working branch

- [ ] **Step 1: Branch from main**

```bash
cd ~/Developer/twin-flame-union
git checkout main
git checkout -b phase-3-bug-fixes
git status
```
Expected: on `phase-3-bug-fixes`, clean tree.

---

## Task 1: HealthKit authorization reflects real status

**Files:**
- Modify: `Twin Flame Union/Services/HealthService.swift`
- Test: `Twin Flame UnionTests/HealthServiceTests.swift`

- [ ] **Step 1: Write the failing test**

Create `Twin Flame UnionTests/HealthServiceTests.swift`:
```swift
import Testing
import HealthKit
@testable import The_Twin_Flame_Union_App

struct HealthServiceTests {

    // The exact bug: the old code claimed authorization regardless of the real status.
    // Only `.sharingAuthorized` may count as authorized.
    @Test func onlySharingAuthorizedCountsAsAuthorized() {
        #expect(HealthService.isShareAuthorized(.sharingAuthorized) == true)
        #expect(HealthService.isShareAuthorized(.sharingDenied) == false)
        #expect(HealthService.isShareAuthorized(.notDetermined) == false)
    }

    // On the simulator with no prior grant, the live property must be false (not a stale true).
    @Test func isAuthorizedFalseWhenNotGranted() {
        #expect(HealthService.shared.isAuthorized == false)
    }
}
```

- [ ] **Step 2: Run to verify it FAILS**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/HealthServiceTests"`
Expected: FAIL — `type 'HealthService' has no member 'isShareAuthorized'`.

- [ ] **Step 3: Replace the stored `isAuthorized` with a computed property + pure helper**

In `Twin Flame Union/Services/HealthService.swift`, replace:
```swift
    var isAuthorized: Bool = false
```
with:
```swift
    /// True only when the user has actually granted write access to mindful sessions.
    /// Computed live from HealthKit, so it is correct after a denial and stable across launches.
    var isAuthorized: Bool {
        #if canImport(HealthKit)
        guard isAvailable,
              let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)
        else { return false }
        return Self.isShareAuthorized(HKHealthStore().authorizationStatus(for: mindfulType))
        #else
        return false
        #endif
    }

    #if canImport(HealthKit)
    /// Pure mapping of a HealthKit share-authorization status to a usable bool.
    /// `.sharingDenied` and `.notDetermined` are NOT authorized.
    static func isShareAuthorized(_ status: HKAuthorizationStatus) -> Bool {
        status == .sharingAuthorized
    }
    #endif
```

- [ ] **Step 4: Delete the unconditional `isAuthorized = true`**

In `requestAuthorization()`, delete this line (it set a false positive on denial; `isAuthorized` is now computed):
```swift
        isAuthorized = true
```
So the `#if canImport(HealthKit)` block in `requestAuthorization()` now ends right after `try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)`.

- [ ] **Step 5: Run to verify it PASSES**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/HealthServiceTests"`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Services/HealthService.swift" "Twin Flame UnionTests/HealthServiceTests.swift"
git commit -m "Phase 3: HealthService.isAuthorized reflects real authorizationStatus (no false-positive on denial)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: MeditationClock (wall-clock value type)

**Files:**
- Modify: `Twin Flame Union/Views/Home/MeditationView.swift` (add the `MeditationClock` struct near the top, alongside the other helper types like `MeditationSession`)
- Test: `Twin Flame UnionTests/MeditationClockTests.swift`

- [ ] **Step 1: Write the failing test**

Create `Twin Flame UnionTests/MeditationClockTests.swift`:
```swift
import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

struct MeditationClockTests {

    @Test func remainingIsWallClockAccurate() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let clock = MeditationClock(endDate: start.addingTimeInterval(600)) // 10 min
        #expect(clock.remaining(at: start) == 600)
        #expect(clock.remaining(at: start.addingTimeInterval(60)) == 540)
    }

    @Test func remainingFloorsAtZeroAndDoesNotLoseBackgroundTime() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let clock = MeditationClock(endDate: start.addingTimeInterval(600))
        // Simulate the app being backgrounded for 11 minutes (past the 10-min end):
        #expect(clock.remaining(at: start.addingTimeInterval(660)) == 0)   // floored, not negative
        // A decrement loop would still read ~ a few seconds left here; wall-clock reads 0.
    }

    @Test func isCompleteFlipsAtEndDate() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let clock = MeditationClock(endDate: start.addingTimeInterval(600))
        #expect(clock.isComplete(at: start) == false)
        #expect(clock.isComplete(at: start.addingTimeInterval(599)) == false)
        #expect(clock.isComplete(at: start.addingTimeInterval(600)) == true)
        #expect(clock.isComplete(at: start.addingTimeInterval(601)) == true)
    }
}
```

- [ ] **Step 2: Run to verify it FAILS**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/MeditationClockTests"`
Expected: FAIL — `cannot find 'MeditationClock' in scope`.

- [ ] **Step 3: Add the `MeditationClock` struct**

In `Twin Flame Union/Views/Home/MeditationView.swift`, add this near the top (e.g. just below the `import` lines, before or after the `MeditationSession` struct):
```swift
/// Wall-clock source of truth for a meditation countdown. Pure and testable —
/// computing remaining time from an absolute `endDate` means backgrounding never
/// drifts the timer (a suspended Task-sleep loop would).
struct MeditationClock {
    let endDate: Date
    func remaining(at now: Date) -> TimeInterval { max(0, endDate.timeIntervalSince(now)) }
    func isComplete(at now: Date) -> Bool { now >= endDate }
}
```

- [ ] **Step 4: Run to verify it PASSES**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/MeditationClockTests"`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Home/MeditationView.swift" "Twin Flame UnionTests/MeditationClockTests.swift"
git commit -m "Phase 3: add pure MeditationClock value type (wall-clock countdown)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Wire wall-clock countdown + Health logging into MeditationView

**Files:**
- Modify: `Twin Flame Union/Views/Home/MeditationView.swift`

The `MeditationViewModel` is `@Observable @MainActor final class` (around line 134) with properties
`selectedSession`, `timeRemaining: TimeInterval`, `isRunning`, `isComplete`, and
`@ObservationIgnored private var timerTask`. The `MeditationView` struct (around line 374) holds
`@State private var viewModel`. Read the file before editing.

- [ ] **Step 1: Add a `clock` to the view model**

In `MeditationViewModel`, alongside the `@ObservationIgnored private var timerTask` declarations, add:
```swift
    @ObservationIgnored
    private var clock: MeditationClock?
```

- [ ] **Step 2: Set the clock + request Health auth once in `start()`**

Replace the existing `start()` with (it adds the clock + first-run Health request; the rest is unchanged):
```swift
    func start() {
        isComplete = false
        timeRemaining = selectedSession.duration
        clock = MeditationClock(endDate: Date().addingTimeInterval(selectedSession.duration))
        currentPhase = .inhale
        isRunning = true
        // Ask for Apple Health permission once, on the user's first meditation.
        if !UserDefaults.standard.bool(forKey: "hasRequestedMeditationHealth") {
            UserDefaults.standard.set(true, forKey: "hasRequestedMeditationHealth")
            Task { try? await HealthService.shared.requestAuthorization() }
        }
        showInvocation = false
        startBreathCycle()
        startCountdown()
        startLiveActivity()
        soundPlayer.play(sound: selectedSound)
    }
```

- [ ] **Step 3: Drive the countdown from the clock + extract a completion path**

Replace the existing `startCountdown()` with a version that COMPUTES `timeRemaining` from the
clock (no decrement) and routes completion through a shared `complete()` method:
```swift
    private func startCountdown() {
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self, let clock = self.clock else { return }
                let now = Date()
                timeRemaining = clock.remaining(at: now)
                if clock.isComplete(at: now) {
                    complete()
                    return
                }
            }
        }
    }

    /// Full-completion path: stop, award XP, and log the mindful session to Apple Health.
    /// Guarded by `isComplete` so it runs once per session.
    private func complete() {
        guard !isComplete else { return }
        isComplete = true
        timeRemaining = 0
        let loggedDuration = selectedSession.duration
        stop()
        GamificationService.shared.awardXP(amount: 30, source: "meditation", framework: .apollux, skillKey: "ap_focus", detail: "Completed meditation: \(selectedSession.name)")
        Task { try? await HealthService.shared.logMindfulSession(duration: loggedDuration) }
    }
```
NOTE: if the existing `awardXP(...)` call in the old `startCountdown()` has different argument
labels than the snippet above, keep the EXISTING call verbatim — copy it into `complete()`
unchanged. Do not invent a new signature.

- [ ] **Step 4: Add a foreground re-sync method**

Add to `MeditationViewModel`:
```swift
    /// Re-evaluate the timer against the wall clock when the app returns to the foreground.
    /// If the session finished while backgrounded, complete it now.
    func syncToWallClock() {
        guard isRunning, let clock else { return }
        let now = Date()
        timeRemaining = clock.remaining(at: now)
        if clock.isComplete(at: now) { complete() }
    }
```
(If `complete()` is `private`, that's fine — `syncToWallClock()` is in the same type.)

- [ ] **Step 5: Observe scenePhase in the view**

In `MeditationView`, add the environment value alongside the other property wrappers (near
`@State private var viewModel`):
```swift
    @Environment(\.scenePhase) private var scenePhase
```
And on the `body`'s outermost view, add:
```swift
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.syncToWallClock() }
        }
```

- [ ] **Step 6: Build to verify**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 7: Run the full unit-test suite**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests"`
Expected: `** TEST SUCCEEDED **` (all suites, incl. MeditationClockTests + HealthServiceTests).

- [ ] **Step 8: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Home/MeditationView.swift"
git commit -m "Phase 3: wall-clock meditation countdown + Apple Health logging on completion

- Drive timeRemaining from MeditationClock (no background drift); re-sync on foreground
- Request Health permission once on first meditation; log mindful session on full completion

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Full sweep + merge

- [ ] **Step 1: Run the entire unit-test suite**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests"`
Expected: `** TEST SUCCEEDED **` — Phase 1/2 suites + HealthServiceTests (2) + MeditationClockTests (3).

- [ ] **Step 2: Claim-lint (ensure no Phase 2 compliance regression)**

Run: `cd ~/Developer/twin-flame-union && ./scripts/claim-lint.sh "Twin Flame Union"`
Expected: `claim-lint: clean`.

- [ ] **Step 3: Merge to main**

```bash
cd ~/Developer/twin-flame-union
git checkout main
git merge --no-ff phase-3-bug-fixes -m "Merge Phase 3: bug fixes (HealthKit auth + meditation timer/logging)"
```

- [ ] **Step 4: 🧑 Push** (needs the user's git credentials / branch-protection approval)

```bash
git push origin main
```
🤖 attempts this; if it fails, the user runs `! cd ~/Developer/twin-flame-union && git push origin main`.

---

## Task 5: 🧑 User verification gate

**Do not mark Phase 3 complete until the user confirms.**

- [ ] **Step 1:** Open in Xcode, build + run. Start a short meditation; first time, the Apple Health permission prompt appears.
- [ ] **Step 2 (drift):** Start a meditation, background the app for ~1 minute mid-session, return — the remaining time reflects real elapsed time (no extra minute added); if the session ended while backgrounded, it shows complete on return.
- [ ] **Step 3 (logging):** Complete a meditation in full → confirm a Mindful Minutes session appears in the Apple Health app. Then deny Health permission (Settings → Privacy → Health) and complete another → nothing is logged and the app behaves normally.

---

## Self-Review notes

- **Spec coverage:** Bug 5 (HealthKit auth) → Task 1 (computed `isAuthorized` + pure `isShareAuthorized` + drop the `= true`). Bug 6 (timer drift) → Tasks 2 (`MeditationClock`) + 3 (wall-clock countdown + foreground re-sync). Bug 6 (Health logging) → Task 3 (`complete()` logs on full completion; first-run auth request). Testing → Tasks 1–3 + sweep in Task 4 + user gate in Task 5. ✅
- **Type consistency:** `MeditationClock(endDate:)` / `remaining(at:)` / `isComplete(at:)` consistent across Task 2 (definition + tests) and Task 3 (`clock`, `startCountdown`, `syncToWallClock`, `complete`). `HealthService.isShareAuthorized(_:)` defined in Task 1, used by computed `isAuthorized`. `HealthService.shared.logMindfulSession(duration:)` / `requestAuthorization()` already exist with these signatures.
- **No placeholders:** every edit shows exact old→new code; verifications use real commands with expected output. The one conditional (keep the existing `awardXP` labels if they differ) is a guarded instruction with a concrete fallback, not a placeholder.
