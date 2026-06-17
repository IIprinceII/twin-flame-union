# Phase 4 — UX & Accessibility Design

**Date:** 2026-06-16
**Status:** Approved (design locked by user 2026-06-16)
**Roadmap:** `2026-06-14-twin-flame-union-program-roadmap.md` → Phase 4
**Repo:** `~/Developer/twin-flame-union` (GitHub `IIprinceII/twin-flame-union`)

## Goal

Make the app calmer and usable by everyone: replace the hard daily-ritual gate with an
optional Home card, make the app fully accessible (VoiceOver labels, Dynamic Type, Reduce
Motion), let Seraphina's chat recover from a failed reply without retyping, and apply
haptics consistently.

## Locked decisions (from brainstorm)

| Decision | Choice |
|----------|--------|
| **Accessibility + haptics scope** | **Comprehensive, app-wide** — label every icon-only button, hide every decorative element, add haptics to every interactive control. Fanned out across subagents by screen folder. |
| **Dynamic Type range** | **Scale body/caption, clamped to ≤ XXL** (`DynamicTypeSize.xxLarge`) — meaningful scaling, far less layout-break risk than the giant AX sizes. |

## Current state (verified 2026-06-16)

- **Ritual gate:** `Twin_Flame_UnionApp.swift` shows `DailyRitualLockView` as a full-screen
  blocker (`showRitual` branch) before `MainTabView`, gated on `ritualCompletedToday()`.
- **Dynamic Type:** serif fonts already scale (`Font.custom(..., relativeTo:)`), but
  `AppFont.body`/`caption` use fixed `.system(size:)` — no scaling.
- **Reduce Motion:** **33** `repeatForever` animation sites; `accessibilityReduceMotion` used
  in **0** files.
- **Accessibility labels:** **0** `.accessibilityLabel`, **0** `.accessibilityHidden`
  app-wide; ~**91** `Button {` sites, many icon-only.
- **Seraphina chat:** `LoveCoachViewModel.send` catches stream errors → sets `errorMessage`
  + `showError` (an alert), but there is **no retry** — the failed exchange just sits there.
- **Haptics:** `Services/HapticManager.swift` exists (`impact`, `notification`, `selection`)
  but only ~6 view files use it.

## Architecture

Build reusable infra first (each a small testable unit), then a comprehensive per-folder
sweep applies the cross-cutting concerns (labels + haptics + reduce-motion) to every screen.

### Workstream A — Daily Ritual Lock → optional Home card
- **`Twin_Flame_UnionApp.swift`:** remove the `showRitual` state and the `else if showRitual`
  branch. After onboarding the app goes straight to `MainTabView` (no hard gate). Keep the
  `dailyRitualCompletedDate` UserDefaults concept.
- **`RitualPromptCard` (new, in Home):** a dismissible "Begin Today's Ritual ✨" card at the
  top of the Home screen. Tapping it presents `DailyRitualLockView` as a `.sheet` (reachable
  on demand). An "✕" sets `ritualCardDismissedDate` (hidden for the rest of the day);
  completing the ritual sets `dailyRitualCompletedDate` (hidden until tomorrow).
- **Pure logic:** `RitualPrompt.shouldShow(completedAt:dismissedAt:now:Calendar) -> Bool`
  (true unless completed-today or dismissed-today). Unit-tested.

### Workstream B — Accessibility
- **Dynamic Type (`Theme.swift`):** rewrite `AppFont.body`/`caption` to scale via
  `UIFontMetrics(forTextStyle:).scaledFont(for:)` wrapping a `UIFont.systemFont(ofSize:weight:)`
  (so they track the user's text size). A small `Font.Weight → UIFont.Weight` mapping helper
  (`uiWeight`) supports it (unit-tested). Clamp the app to ≤ XXL with
  `.dynamicTypeSize(...DynamicTypeSize.xxLarge)` on the root scene content.
- **Reduce Motion:** a reusable helper
  `Animation.calm(_ reduceMotion: Bool, _ base: Animation) -> Animation?` returning `nil`
  when reduce-motion is on (unit-tested). Each of the 33 `repeatForever` sites reads
  `@Environment(\.accessibilityReduceMotion)` and uses the helper so motion stops (static
  state) when the user prefers reduced motion.
- **Labels (sweep):** `.accessibilityLabel("…")` on every icon-only button (SF-symbol-only,
  no visible text); `.accessibilityHidden(true)` on purely decorative elements (animated
  orbs, particles, background gradients/art, decorative symbols). Applied folder-by-folder.

### Workstream C — Seraphina chat retry
- **`LoveCoachViewModel`:** retain the last user message text; on stream failure expose
  `canRetry` + `retry()`. `retry()` re-sends the preserved message through the existing
  `send` path (no retyping). The user's message stays in the transcript.
- **`CoachView`:** when `canRetry`, show an inline "Tap to retry" affordance (button) under
  the failed exchange that calls `viewModel.retry()`.

### Workstream D — Haptics consistency
- **Convention** (documented in `HapticManager`): `.impact(.light)` for selection/navigation,
  `.impact(.medium)` for primary actions (begin/submit/save), `.notification(.success)` for
  completions (ritual/meditation/XP/achievement), `.notification(.error)` for failures.
- Applied to interactive controls across all screens **in the same folder-sweep** as the
  labels (they touch the same buttons), per the convention.

## Data flow

No new persistence beyond two UserDefaults dates for the ritual card
(`dailyRitualCompletedDate` existing, `ritualCardDismissedDate` new). Dynamic Type / Reduce
Motion are read from the environment; haptics are fire-and-forget.

## Testing

Pure/logic units are unit-tested (Swift Testing):
- `RitualPrompt.shouldShow(...)` — hidden when completed-today or dismissed-today; shown
  otherwise.
- `Font.Weight.uiWeight` mapping (regular/semibold/bold/etc. → correct `UIFont.Weight`).
- `Animation.calm(_:_:)` — returns `nil` when reduce-motion true, the base animation when false.
- `LoveCoachViewModel.retry()` — re-invokes the service with the preserved last user message
  (verified with a fake `streamMessage` service; no UI).

Verified by the user in Xcode (cannot unit-test): VoiceOver reads every control sensibly
(Accessibility Inspector audit shows no unlabeled controls on core screens); largest text
size (XXL) doesn't clip core screens; Reduce Motion stops the looping animations; the chat
"Tap to retry" recovers a failed reply; haptics fire on the documented interactions.

## Out of scope

- Full AX1–AX5 Dynamic Type sizes (clamped at XXL by decision).
- New visual redesigns — this is polish/accessibility over the existing UI.
- Localization / RTL.
- Phase 5 polish items (fonts/colors/launch screen) and Phase 6 features.

## File summary

**New:**
- `Twin Flame Union/Views/Home/RitualPromptCard.swift` (card + `RitualPrompt.shouldShow`)
- `Twin Flame Union/Support/Accessibility.swift` (`Animation.calm`, `Font.Weight.uiWeight`, any shared a11y helpers)
- `Twin Flame UnionTests/RitualPromptTests.swift`
- `Twin Flame UnionTests/AccessibilityHelpersTests.swift`
- `Twin Flame UnionTests/CoachRetryTests.swift`

**Modified:**
- `Twin Flame Union/Twin_Flame_UnionApp.swift` (remove gate; root Dynamic-Type clamp)
- `Twin Flame Union/Theme.swift` (`AppFont.body`/`caption` scale; `uiWeight`)
- `Twin Flame Union/Views/Home/*` (ritual card on Home)
- `Twin Flame Union/ViewModels/LoveCoachViewModel.swift` + `Views/Home/CoachView.swift` (retry)
- `Twin Flame Union/Services/HapticManager.swift` (convention doc)
- The view files across `Views/**` (labels + decorative-hidden + reduce-motion + haptics sweep)
