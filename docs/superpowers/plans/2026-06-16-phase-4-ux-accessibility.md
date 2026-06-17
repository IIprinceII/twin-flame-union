# Phase 4 — UX & Accessibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the hard daily-ritual gate with an optional Home card; make the app accessible (VoiceOver labels, Dynamic Type ≤ XXL, Reduce Motion); add chat retry; apply haptics consistently app-wide.

**Architecture:** Build reusable infra (Tasks 1–5: pure testable helpers + the ritual card + chat-retry seam) first, then a comprehensive per-folder sweep (Tasks 6–9) applies four cross-cutting concerns — accessibility labels, decorative-hidden, reduce-motion, haptics — to every view, fanned out by folder.

**Tech Stack:** Swift / SwiftUI, UIKit (`UIFontMetrics`), Swift Testing, `@Environment(\.accessibilityReduceMotion)`, `@Environment(\.dynamicTypeSize)`.

**Spec:** `docs/superpowers/specs/2026-06-16-phase-4-ux-accessibility-design.md`

**Conventions (same repo as Phases 1–3):**
- New `.swift` files under `Twin Flame Union/` or `Twin Flame UnionTests/` auto-join the build (synchronized groups).
- Test module is **`The_Twin_Flame_Union_App`**; Swift Testing.
- Build/test headless: `-scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`.
- SourceKit "cannot find X / hex:" diagnostics are stale-index noise — trust `** BUILD/TEST SUCCEEDED **`.
- Final functional verification (VoiceOver, Dynamic Type, Reduce Motion on device) is the user (Task 11).

---

## Task 0: Working branch

- [ ] **Step 1:** `cd ~/Developer/twin-flame-union && git checkout main && git checkout -b phase-4-ux-accessibility && git status` → on the branch, clean.

---

## Task 1: Accessibility helpers (reduce-motion + font-weight mapping)

**Files:**
- Create: `Twin Flame Union/Support/Accessibility.swift`
- Test: `Twin Flame UnionTests/AccessibilityHelpersTests.swift`

- [ ] **Step 1: Write the failing test** — Create `Twin Flame UnionTests/AccessibilityHelpersTests.swift`:
```swift
import Testing
import SwiftUI
import UIKit
@testable import The_Twin_Flame_Union_App

struct AccessibilityHelpersTests {

    @Test func calmReturnsNilWhenReduceMotionOn() {
        #expect(Animation.calm(true, .easeInOut(duration: 1)) == nil)
        #expect(Animation.calm(false, .easeInOut(duration: 1)) != nil)
    }

    @Test func fontWeightMapsToUIFontWeight() {
        #expect(Font.Weight.regular.uiWeight == .regular)
        #expect(Font.Weight.semibold.uiWeight == .semibold)
        #expect(Font.Weight.bold.uiWeight == .bold)
        #expect(Font.Weight.light.uiWeight == .light)
    }
}
```

- [ ] **Step 2: Run → FAIL** (`-only-testing:"Twin Flame UnionTests/AccessibilityHelpersTests"`): `cannot find 'calm'` / `value of type 'Font.Weight' has no member 'uiWeight'`.

- [ ] **Step 3: Create the helpers** — Create `Twin Flame Union/Support/Accessibility.swift`:
```swift
//
//  Accessibility.swift
//  Twin Flame Union
//
//  Shared accessibility helpers: Reduce Motion gating + Dynamic Type weight mapping.
//

import SwiftUI
import UIKit

extension Animation {
    /// The base animation, or `nil` when Reduce Motion is on — so callers can drop
    /// looping/decorative motion. Usage:
    ///   `.animation(.calm(reduceMotion, .easeInOut(duration: 2).repeatForever()), value: x)`
    static func calm(_ reduceMotion: Bool, _ base: Animation) -> Animation? {
        reduceMotion ? nil : base
    }
}

extension Font.Weight {
    /// The matching `UIFont.Weight`, for building Dynamic-Type-scaled system fonts via UIFontMetrics.
    var uiWeight: UIFont.Weight {
        if self == .ultraLight { return .ultraLight }
        if self == .thin       { return .thin }
        if self == .light      { return .light }
        if self == .medium     { return .medium }
        if self == .semibold   { return .semibold }
        if self == .bold       { return .bold }
        if self == .heavy      { return .heavy }
        if self == .black      { return .black }
        return .regular
    }
}
```

- [ ] **Step 4: Run → PASS** (2 tests).

- [ ] **Step 5: Commit**
```bash
git add "Twin Flame Union/Support/Accessibility.swift" "Twin Flame UnionTests/AccessibilityHelpersTests.swift"
git commit -m "Phase 4: accessibility helpers (Animation.calm reduce-motion + Font.Weight.uiWeight)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Dynamic Type for body/caption + root clamp

**Files:**
- Modify: `Twin Flame Union/Theme.swift`
- Modify: `Twin Flame Union/Twin_Flame_UnionApp.swift`

- [ ] **Step 1: Make `AppFont.body`/`caption` scale.** In `Theme.swift`, ensure `import UIKit` is present at the top (add it next to `import SwiftUI` if missing). Replace:
```swift
    static func body(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func caption(_ size: CGFloat = 13, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
```
with:
```swift
    static func body(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight.uiWeight)
        return Font(UIFontMetrics(forTextStyle: .body).scaledFont(for: base))
    }

    static func caption(_ size: CGFloat = 13, weight: Font.Weight = .regular) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight.uiWeight)
        return Font(UIFontMetrics(forTextStyle: .caption1).scaledFont(for: base))
    }
```

- [ ] **Step 2: Clamp the app to ≤ XXL.** In `Twin_Flame_UnionApp.swift`, on the `WindowGroup`'s root content view (the `Group { … }` wrapping the launch/onboarding/main branches — the same view the `.alert`/`.onChange` modifiers attach to), add:
```swift
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
```

- [ ] **Step 3: Build** → `** BUILD SUCCEEDED **`. (Existing `AppFont.body(...)`/`caption(...)` callers are unchanged — they now scale automatically.)

- [ ] **Step 4: Commit**
```bash
git add "Twin Flame Union/Theme.swift" "Twin Flame Union/Twin_Flame_UnionApp.swift"
git commit -m "Phase 4: Dynamic Type — body/caption scale via UIFontMetrics, clamped to XXL

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Ritual lock → optional Home card

**Files:**
- Create: `Twin Flame Union/Views/Home/RitualPromptCard.swift`
- Test: `Twin Flame UnionTests/RitualPromptTests.swift`
- Modify: `Twin Flame Union/Twin_Flame_UnionApp.swift` (remove the gate)
- Modify: the Home screen view (the tab-0 root — find it via `MainTabView.swift` `.tag(0)`)

- [ ] **Step 1: Write the failing test** — Create `Twin Flame UnionTests/RitualPromptTests.swift`:
```swift
import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

struct RitualPromptTests {
    let cal = Calendar.current

    @Test func shownWhenNeverCompletedOrDismissed() {
        #expect(RitualPrompt.shouldShow(completedAt: nil, dismissedAt: nil, now: Date(), calendar: cal) == true)
    }

    @Test func hiddenWhenCompletedToday() {
        let now = Date()
        #expect(RitualPrompt.shouldShow(completedAt: now, dismissedAt: nil, now: now, calendar: cal) == false)
    }

    @Test func hiddenWhenDismissedToday() {
        let now = Date()
        #expect(RitualPrompt.shouldShow(completedAt: nil, dismissedAt: now, now: now, calendar: cal) == false)
    }

    @Test func shownAgainNextDay() {
        let now = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: now)!
        #expect(RitualPrompt.shouldShow(completedAt: yesterday, dismissedAt: yesterday, now: now, calendar: cal) == true)
    }
}
```

- [ ] **Step 2: Run → FAIL**: `cannot find 'RitualPrompt' in scope`.

- [ ] **Step 3: Create the card + pure logic** — Create `Twin Flame Union/Views/Home/RitualPromptCard.swift`:
```swift
//
//  RitualPromptCard.swift
//  Twin Flame Union
//
//  Optional, dismissible "Begin Today's Ritual" card on Home (replaces the old hard gate).
//

import SwiftUI

enum RitualPrompt {
    static let completedKey = "dailyRitualCompletedDate"
    static let dismissedKey = "ritualCardDismissedDate"

    /// The card shows unless the ritual was already completed today or dismissed today.
    static func shouldShow(completedAt: Date?, dismissedAt: Date?, now: Date, calendar: Calendar) -> Bool {
        if let c = completedAt, calendar.isDate(c, inSameDayAs: now) { return false }
        if let d = dismissedAt, calendar.isDate(d, inSameDayAs: now) { return false }
        return true
    }
}

struct RitualPromptCard: View {
    let onBegin: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 18))
                .foregroundStyle(AppColors.gold)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Begin Today's Ritual ✨")
                    .font(AppFont.body(15, weight: .semibold))
                    .foregroundStyle(AppColors.cream)
                Text("A moment to center before your day")
                    .font(AppFont.caption(12))
                    .foregroundStyle(AppColors.lavender)
            }
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.lavender.opacity(0.7))
                    .padding(8)
            }
            .accessibilityLabel("Dismiss today's ritual reminder")
        }
        .padding(16)
        .background(AppColors.purple.opacity(0.18), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(AppColors.purple.opacity(0.35), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { onBegin() }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Opens today's ritual")
    }
}
```

- [ ] **Step 4: Run → PASS** (4 tests).

- [ ] **Step 5: Remove the hard gate from the App.** In `Twin_Flame_UnionApp.swift`:
  - Delete the `@State private var showRitual = false` line.
  - In the launch-animation completion closure, delete the `if hasCompletedOnboarding { showRitual = !ritualCompletedToday() }` assignment (keep the rest of the closure).
  - In the onboarding completion closure, delete `showRitual = !ritualCompletedToday()`.
  - Delete the entire `} else if showRitual { DailyRitualLockView { … } .transition(.opacity)` branch so the chain is launch → onboarding → `MainTabView`.
  - In the `.onChange(of: hasCompletedOnboarding)` modifier, delete the `showRitual = false` line.
  - Delete the now-unused `private func ritualCompletedToday()` helper.

- [ ] **Step 6: Add the card to the Home screen.** Open `MainTabView.swift`, find the view at `.tag(0)` (Home). In that view's main scroll content, near the top, add state + the card gated by `RitualPrompt.shouldShow`:
```swift
    @AppStorage(RitualPrompt.completedKey) private var ritualCompletedRaw: Double = 0
    @AppStorage(RitualPrompt.dismissedKey) private var ritualDismissedRaw: Double = 0
    @State private var showRitualSheet = false
```
Render the card at the top of the content when it should show:
```swift
                if RitualPrompt.shouldShow(
                    completedAt: ritualCompletedRaw > 0 ? Date(timeIntervalSinceReferenceDate: ritualCompletedRaw) : nil,
                    dismissedAt: ritualDismissedRaw > 0 ? Date(timeIntervalSinceReferenceDate: ritualDismissedRaw) : nil,
                    now: Date(), calendar: .current
                ) {
                    RitualPromptCard(
                        onBegin: { showRitualSheet = true },
                        onDismiss: { ritualDismissedRaw = Date().timeIntervalSinceReferenceDate }
                    )
                    .padding(.horizontal)
                }
```
And present the ritual on demand:
```swift
        .sheet(isPresented: $showRitualSheet) {
            DailyRitualLockView { showRitualSheet = false }
        }
```
NOTE: `DailyRitualLockView` already writes `dailyRitualCompletedDate` on completion. READ it to confirm the stored type — if it stores a `Date` object (`UserDefaults.standard.set(Date(), forKey:)`) rather than a `timeIntervalSinceReferenceDate` Double, change the card's completion read to use `UserDefaults.standard.object(forKey: RitualPrompt.completedKey) as? Date` (with a `@State` refresh on `.onAppear`/sheet-dismiss) instead of `@AppStorage(Double)`. Match whatever `DailyRitualLockView` actually writes. Also make `DailyRitualLockView` write `dailyRitualCompletedDate` on completion if it does not already.

- [ ] **Step 7: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 8: Commit**
```bash
git add "Twin Flame Union/Views/Home/RitualPromptCard.swift" "Twin Flame UnionTests/RitualPromptTests.swift" "Twin Flame Union/Twin_Flame_UnionApp.swift" "Twin Flame Union/MainTabView.swift"
git commit -m "Phase 4: replace hard ritual gate with an optional dismissible Home card

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Seraphina chat retry (no retype)

**Files:**
- Modify: `Twin Flame Union/ViewModels/LoveCoachViewModel.swift`
- Modify: `Twin Flame Union/Services/LoveCoachService.swift` (add a tiny protocol conformance)
- Modify: `Twin Flame Union/Views/Home/CoachView.swift` (retry affordance)
- Test: `Twin Flame UnionTests/CoachRetryTests.swift`

- [ ] **Step 1: Write the failing test** — Create `Twin Flame UnionTests/CoachRetryTests.swift`:
```swift
import Testing
import Foundation
@testable import The_Twin_Flame_Union_App

@MainActor
struct CoachRetryTests {

    /// A fake stream: first call throws, second call yields text. Records histories seen.
    final class FakeStream: ChatStreaming {
        var calls: [[ChatMessage]] = []
        var failFirst = true
        func streamMessage(history: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
            calls.append(history)
            let shouldFail = failFirst && calls.count == 1
            return AsyncThrowingStream { cont in
                if shouldFail { cont.finish(throwing: URLError(.timedOut)) }
                else { cont.yield("Hello, soul."); cont.finish() }
            }
        }
    }

    @Test func retryResendsPreservedMessageWithoutRetyping() async {
        let fake = FakeStream()
        let vm = LoveCoachViewModel(service: fake)
        vm.inputText = "Will we reunite?"
        await vm.sendMessage()

        #expect(vm.canRetry == true)                       // first send failed
        #expect(vm.messages.contains { $0.role == .user && $0.content == "Will we reunite?" })

        await vm.retry()                                   // no retype
        #expect(vm.canRetry == false)
        // The retried call still carried the user's preserved message:
        #expect(fake.calls.last?.contains { $0.content == "Will we reunite?" } == true)
        #expect(vm.messages.last?.role == .assistant)
        #expect(vm.messages.last?.content == "Hello, soul.")
    }
}
```

- [ ] **Step 2: Run → FAIL**: `cannot find type 'ChatStreaming'` / `LoveCoachViewModel` has no `canRetry`/`retry`/`init(service:)`.

- [ ] **Step 3: Add the `ChatStreaming` seam.** In `Twin Flame Union/Services/LoveCoachService.swift`, add at file scope (outside the class):
```swift
/// Minimal streaming interface so the chat view model can be tested with a fake.
protocol ChatStreaming {
    func streamMessage(history: [ChatMessage]) -> AsyncThrowingStream<String, Error>
}

extension LoveCoachService: ChatStreaming {
    func streamMessage(history: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        streamMessage(history: history, context: nil)
    }
}
```
(`LoveCoachService.streamMessage(history:context:)` already exists with `context` defaulting to nil; this adds the no-context overload the protocol needs.)

- [ ] **Step 4: Rewrite `LoveCoachViewModel` for injection + retry.** Replace the whole body of `Twin Flame Union/ViewModels/LoveCoachViewModel.swift` with:
```swift
//
//  LoveCoachViewModel.swift
//  Twin Flame Union
//

import SwiftUI

@Observable
@MainActor
final class LoveCoachViewModel {

    var messages: [ChatMessage] = []
    var inputText = ""
    var isStreaming = false
    var errorMessage: String?
    var showError = false
    var canRetry = false

    private let service: ChatStreaming

    init(service: ChatStreaming = LoveCoachService()) {
        self.service = service
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }
        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))
        await streamReply()
    }

    /// Re-send after a failure WITHOUT making the user retype. Drops the failed
    /// assistant bubble and streams again against the preserved history.
    func retry() async {
        guard canRetry, !isStreaming else { return }
        if messages.last?.role == .assistant { messages.removeLast() }
        await streamReply()
    }

    private func streamReply() async {
        canRetry = false
        let placeholder = ChatMessage(role: .assistant, content: "")
        messages.append(placeholder)
        let idx = messages.count - 1
        isStreaming = true
        errorMessage = nil

        let history = Array(messages.dropLast())   // history excludes the empty placeholder
        do {
            for try await chunk in service.streamMessage(history: history) {
                messages[idx].content += chunk
            }
        } catch {
            messages[idx].content = "Something interrupted our connection. Tap to retry, dear soul."
            errorMessage = error.localizedDescription
            showError = true
            canRetry = true
        }
        isStreaming = false
    }
}
```

- [ ] **Step 5: Run → PASS** (1 test).

- [ ] **Step 6: Add the retry affordance to `CoachView`.** Read `Views/Home/CoachView.swift`. Where messages/error render, when `viewModel.canRetry && !viewModel.isStreaming`, show a tappable retry button just above the input bar:
```swift
                if viewModel.canRetry && !viewModel.isStreaming {
                    Button {
                        Task { await viewModel.retry() }
                    } label: {
                        Label("Tap to retry", systemImage: "arrow.clockwise")
                            .font(AppFont.body(14, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    .accessibilityLabel("Retry sending your message")
                    .padding(.vertical, 8)
                }
```
Keep any existing error alert — the inline retry is additive. Confirm `CoachView` drives `LoveCoachViewModel`; if it instantiates it with no args, that still works (the `init(service:)` default is `LoveCoachService()`).

- [ ] **Step 7: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 8: Commit**
```bash
git add "Twin Flame Union/ViewModels/LoveCoachViewModel.swift" "Twin Flame Union/Services/LoveCoachService.swift" "Twin Flame Union/Views/Home/CoachView.swift" "Twin Flame UnionTests/CoachRetryTests.swift"
git commit -m "Phase 4: Seraphina chat retry — re-send the preserved message without retyping

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Haptic conventions (doc)

**Files:**
- Modify: `Twin Flame Union/Services/HapticManager.swift`

- [ ] **Step 1: Document the convention** at the top of `HapticManager` (a doc comment block), so the sweep tasks apply it consistently:
```swift
//  Haptic conventions (apply consistently across the app):
//   • impact(.light)         — selection / navigation (tab, row, segment, picker)
//   • impact(.medium)        — primary actions (Begin, Submit, Save, Send)
//   • notification(.success) — completions (ritual / meditation done, XP, achievement, save success)
//   • notification(.error)   — failures (request/save failed)
```

- [ ] **Step 2: Build** → `** BUILD SUCCEEDED **` (comment-only change). **Commit**
```bash
git add "Twin Flame Union/Services/HapticManager.swift"
git commit -m "Phase 4: document haptic conventions for the app-wide sweep

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## SWEEP PROCEDURE (Tasks 6–9 each apply this to their file list)

For every `.swift` view file in the task's folder, READ the file, then apply all four concerns:

1. **Accessibility labels.** For every `Button`/tappable control whose label is an **icon only**
   (`Image(systemName:)` / shape with no adjacent visible `Text`), add `.accessibilityLabel("<the action in plain words>")` to the Button. Example:
   ```swift
   Button { dismiss() } label: { Image(systemName: "xmark") /*…*/ }
       .accessibilityLabel("Close")
   ```
2. **Decorative-hidden.** Add `.accessibilityHidden(true)` to purely decorative views — animated
   orbs/glows, particle/sparkle effects, background gradients/`CosmicBackground`, and standalone
   decorative `Image(systemName:)` beside text that already conveys the meaning. Example:
   ```swift
   Circle().fill(/*…*/).blur(/*…*/)        // a glow orb
       .accessibilityHidden(true)
   ```
3. **Reduce Motion.** In any view containing a `repeatForever` animation, add
   `@Environment(\.accessibilityReduceMotion) private var reduceMotion` to the view struct, and
   wrap the looping animation so it stops when reduce-motion is on. Two patterns:
   ```swift
   // .animation(...) modifier form:
   .animation(.calm(reduceMotion, .easeInOut(duration: 2).repeatForever(autoreverses: true)), value: pulse)
   // withAnimation(...) form — guard it:
   if !reduceMotion { withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { pulse = true } }
   ```
   `Animation.calm` + the env value come from Task 1. (Decorative animations that are also
   `.accessibilityHidden` STILL must respect reduce-motion — motion sensitivity is separate from VoiceOver.)
4. **Haptics.** Add a `HapticManager` call inside each interactive `Button`/control action per the
   Task-5 convention (light = selection/nav, medium = primary action, success = completion, error = failure). Example:
   ```swift
   Button { HapticManager.impact(.medium); save() } label: { Text("Save") }
   ```

After applying to all files in the folder: **build** (`xcodebuild build … iPhone 17`) → `** BUILD SUCCEEDED **`, then **commit** (`Phase 4 sweep: accessibility + haptics + reduce-motion (<folder>)`).

Do NOT change any logic, copy, or layout beyond adding these modifiers/calls. If a control's purpose is ambiguous, label it by what tapping it does.

---

## Task 6: Sweep — Home + Components

**Files (apply the SWEEP PROCEDURE):** every `.swift` in `Twin Flame Union/Views/Home/` (AffirmationsView, AngelNumberView, CoachView, JournalView, LoveCoachView, MeditationView, QuizView, SoulJournalView, TFReadingView, RitualPromptCard) and `Twin Flame Union/Components/` (8 files).

- [ ] **Step 1:** Apply the SWEEP PROCEDURE to all Home view files.
- [ ] **Step 2:** Apply the SWEEP PROCEDURE to all Components files.
- [ ] **Step 3:** Build → `** BUILD SUCCEEDED **`.
- [ ] **Step 4:** Commit `git add "Twin Flame Union/Views/Home" "Twin Flame Union/Components"` — message `Phase 4 sweep: accessibility + haptics + reduce-motion (Home + Components)`.

---

## Task 7: Sweep — Journey (part 1)

**Files (apply the SWEEP PROCEDURE):** the first ~12 `.swift` files in `Twin Flame Union/Views/Journey/` alphabetically (`ls "Twin Flame Union/Views/Journey/"` and take the first half). Includes the Solfeggio/Energy/Chakra/Mind/Dream views touched in Phase 2 — only ADD labels/haptics/reduce-motion; do NOT alter the disclaimer wiring or any copy.

- [ ] **Step 1:** Apply the SWEEP PROCEDURE to each file in part 1.
- [ ] **Step 2:** Build → `** BUILD SUCCEEDED **`.
- [ ] **Step 3:** Commit `Phase 4 sweep: accessibility + haptics + reduce-motion (Journey part 1)`.

---

## Task 8: Sweep — Journey (part 2)

**Files (apply the SWEEP PROCEDURE):** the remaining `.swift` files in `Twin Flame Union/Views/Journey/` (the second half).

- [ ] **Step 1:** Apply the SWEEP PROCEDURE to each file in part 2.
- [ ] **Step 2:** Build → `** BUILD SUCCEEDED **`.
- [ ] **Step 3:** Commit `Phase 4 sweep: accessibility + haptics + reduce-motion (Journey part 2)`.

---

## Task 9: Sweep — Onboarding + Profile + Settings + top-level

**Files (apply the SWEEP PROCEDURE):** `Twin Flame Union/Views/Onboarding/` (3), `Twin Flame Union/Views/Profile/` (5), `Twin Flame Union/Views/Settings/` (1), and the top-level views `Twin Flame Union/MainTabView.swift` + any other top-level `Views/*.swift` not already swept. For the `MainTabView` tab bar, `Label("Home", systemImage:)` etc. already provide text — no extra label needed; add `HapticManager.impact(.light)` on tab change if there's a selection handler, else skip.

- [ ] **Step 1:** Apply the SWEEP PROCEDURE to Onboarding, Profile, Settings, and top-level views.
- [ ] **Step 2:** Build → `** BUILD SUCCEEDED **`.
- [ ] **Step 3:** Commit `Phase 4 sweep: accessibility + haptics + reduce-motion (Onboarding/Profile/Settings/top-level)`.

---

## Task 10: Full sweep + merge

- [ ] **Step 1: Full unit-test suite** → `** TEST SUCCEEDED **` (Phase 1–3 suites + AccessibilityHelpersTests (2) + RitualPromptTests (4) + CoachRetryTests (1)).
- [ ] **Step 2: claim-lint** → `cd ~/Developer/twin-flame-union && ./scripts/claim-lint.sh "Twin Flame Union"` → `claim-lint: clean`.
- [ ] **Step 3: Coverage heuristic** (informational): `grep -rn "accessibilityLabel" "Twin Flame Union/Views" --include="*.swift" | wc -l` is now well above 0. Log the count.
- [ ] **Step 4: Merge**
```bash
git checkout main && git merge --no-ff phase-4-ux-accessibility -m "Merge Phase 4: UX & accessibility (ritual card, a11y sweep, chat retry, haptics)"
```
- [ ] **Step 5: 🧑 Push** — `git push origin main` (controller attempts; user runs `! …` if blocked).

---

## Task 11: 🧑 User verification gate

**Do not mark Phase 4 complete until the user confirms.**

- [ ] **Step 1 (VoiceOver):** Turn on VoiceOver; swipe through Home, a Journey hub, the AI chat, Settings — every control announced sensibly; decorative orbs skipped.
- [ ] **Step 2 (Accessibility Inspector):** Run Xcode's Accessibility Inspector audit on core screens — no "unlabeled control" warnings.
- [ ] **Step 3 (Dynamic Type):** Set text size to the largest non-AX size (XXL) — core screens stay legible without clipping.
- [ ] **Step 4 (Reduce Motion):** Enable Reduce Motion — the looping orbs/breath animations stop (static); the app still works.
- [ ] **Step 5 (Ritual + chat):** App no longer hard-gates on the ritual; the Home card appears, opens the ritual, dismisses for the day. Force a chat failure (airplane mode) → "Tap to retry" recovers the reply without retyping. Haptics fire on taps.

---

## Self-Review notes

- **Spec coverage:** Workstream A (ritual card) → Task 3. B: Dynamic Type → Task 2; Reduce-Motion helper → Task 1, applied in Tasks 6–9; labels/decorative → Tasks 6–9. C (chat retry) → Task 4. D (haptics) → Task 5 (convention) + applied in Tasks 6–9. Testing → Tasks 1,3,4 (units) + Task 10 sweep + Task 11 user gate. ✅
- **Type consistency:** `Animation.calm(_:_:)` + `Font.Weight.uiWeight` (Task 1) used in Tasks 2 + 6–9. `RitualPrompt.shouldShow(...)` (Task 3) used by the Home card. `ChatStreaming` + `LoveCoachViewModel(service:)` + `canRetry`/`retry()` (Task 4) consistent across VM, service, view, and test.
- **Sweep tasks are pattern-application, not placeholders:** each gives the exact 4-point checklist + concrete before/after examples; per-button code can't be pre-enumerated without reading ~30 files (the implementer's job). Verified by build + the Task 11 VoiceOver/Inspector audit.
- **Flagged uncertainty (Task 3 Step 6):** the Home card's read of the completion date must match the type `DailyRitualLockView` actually writes (Double vs Date) — the implementer reads that file and aligns.
