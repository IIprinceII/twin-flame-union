# Phase 5 — Polish Design

**Date:** 2026-06-17
**Status:** Approved (design locked by user 2026-06-17)
**Roadmap:** `2026-06-14-twin-flame-union-program-roadmap.md` → Phase 5
**Repo:** `~/Developer/twin-flame-union` (GitHub `IIprinceII/twin-flame-union`)

## Goal

Visual + interaction polish: make the serif headlines actually render as serif, deduplicate
hardcoded colors into the existing semantic tokens (no visual change), make the launch
animation fast and skippable, lock the app to dark mode and kill the launch white-flash, add
press feedback to buttons, and give users an in-app support contact.

## Locked decisions (from brainstorm)

| Decision | Choice |
|----------|--------|
| **Color cleanup** | **Conservative dedup** — migrate only hardcoded hexes that EXACTLY match an existing `AppColors` token to that token (zero visual change). Leave one-off colors alone. |
| **Launch animation** | **Full on first launch; ~1.2s brief after; always tap-to-skip; Reduce Motion = instant static logo.** |

## Current state (verified 2026-06-17)

- **Serif font:** `AppFont.serifHeadline`/`serifTitle` use `Font.custom("NewYork-Bold"/"NewYork-Regular", …)`.
  "NewYork-…" is **not a valid custom font name**, so these silently fall back to SF — ~121
  headlines are not serif. (`headline`/`title` use Georgia, which IS available on iOS and works.)
  No fonts are bundled (`UIAppFonts` absent from Info.plist).
- **Colors:** **598** `Color(hex: "…")` usages, **160** distinct hex values. `AppColors` already
  defines semantic tokens (deepViolet `#0E0620`, purple `#7B35B8`, gold `#F0C060`, rose
  `#E8739A`, sage `#7EC8A0`, coral `#CC88FF`, cream `#F5EFE6`, lavender `#B8A8D0`, ember `#FF9A6C`).
- **Launch animation:** `LaunchAnimationView` is a fixed ~3.8s `DispatchQueue.main.asyncAfter`
  chain on EVERY launch — no tap-to-skip, no first-launch gating, no Reduce-Motion handling.
- **Dark mode:** **62** scattered `.preferredColorScheme(.dark)`; no global lock; no launch-screen
  config → white flash on cold launch.
- **Buttons:** `warmButtonStyle()` exists; many controls use `.buttonStyle(.plain)` with no press
  feedback.
- **Support:** effectively no contact path in Settings. Remaining "placeholder" markers are
  intentional Phase-6 stubs (`PaywallView`, `StoreService`) — out of scope.

## Architecture

Focused infra changes (Theme, launch view, Info.plist, a button style, a Settings row), plus a
mechanical per-token color-dedup sweep across the view files.

### A. Serif headline font (`Theme.swift`)
Rewrite `serifHeadline`/`serifTitle` to use the system serif at the requested size, scaled with
Dynamic Type:
```swift
private static func scaledSerif(_ size: CGFloat, weight: UIFont.Weight, textStyle: UIFont.TextStyle) -> Font {
    let sys = UIFont.systemFont(ofSize: size, weight: weight)
    let serif = sys.fontDescriptor.withDesign(.serif).map { UIFont(descriptor: $0, size: size) } ?? sys
    return Font(UIFontMetrics(forTextStyle: textStyle).scaledFont(for: serif))
}
```
`serifHeadline(size)` → `scaledSerif(size, .bold, .largeTitle)`; `serifTitle(size)` →
`scaledSerif(size, .regular, .title)`. Keeps the existing call sites and point sizes; New York
serif now actually renders. Georgia-based `headline`/`title` unchanged. No bundled assets.

### B. Color dedup (conservative, per-token sweep)
For each `AppColors` token, find `Color(hex: "<token-hex>")` (case-insensitive on the hex) across
all `*.swift` and replace with the token (e.g. `Color(hex: "7B35B8")` → `AppColors.purple`). This
is exact-match only — the rendered color is identical, so **no visual change**. Done per-token,
fanned out by folder/token. One-off colors (no token match) are left untouched. A grep verifies
the migrated hexes no longer appear as raw `Color(hex:)`.

### C. Launch animation (`LaunchAnimationView`)
- Pure decision helper: `enum LaunchMode { case full, brief, staticLogo }` and
  `LaunchPlan.mode(hasSeen: Bool, reduceMotion: Bool) -> LaunchMode` —
  reduceMotion → `.staticLogo`; else !hasSeen → `.full`; else `.brief`. (Unit-tested.)
- The view reads `@AppStorage("hasSeenLaunchAnimation")` + `@Environment(\.accessibilityReduceMotion)`,
  picks the mode, and: `.full` runs the existing sequence then sets `hasSeen = true`; `.brief`
  runs a ~1.2s fade; `.staticLogo` shows the logo and calls `onComplete` after a brief beat.
- Add `.onTapGesture` (and an accessibility action) that immediately finishes (`onComplete()`),
  cancelling pending work. Reduce Motion shows no looping/particle motion.

### D. Global dark-mode lock + launch screen
- Add `UIUserInterfaceStyle = Dark` to `Twin Flame Union/Info.plist` — the true global lock
  (covers system chrome too). The 62 per-view `.preferredColorScheme(.dark)` become redundant
  but are left in place (harmless; removing them is a noisy no-op and out of scope).
- Configure the launch screen so its background is the dark void `#0E0620` (via the `UILaunchScreen`
  Info.plist dict referencing a dark color, or a minimal launch storyboard) → no white flash.

### E. Pressable button style (`Theme.swift` or `Support/`)
- `struct PressableButtonStyle: ButtonStyle` — on press: `scaleEffect(0.96)`, slight opacity dim,
  and `HapticManager.impact(.light)` once on press-down (via `onChange(of: configuration.isPressed)`).
- Apply `.buttonStyle(PressableButtonStyle())` to the primary CTAs that currently use `.plain`
  and lack press feedback (a focused pass over the main action buttons, not all 62 controls).

### F. Support / feedback path (`SettingsView`)
- Add a Settings → About (or a "Support" section) row **"Contact / Feedback"** that opens a
  `mailto:` to the support address (default `justin04rodriguez04@gmail.com`, the user can change
  it), with a subject like "Twin Flame Union Feedback". Satisfies App Review's support-contact
  expectation.

## Data flow

No new persistence beyond `@AppStorage("hasSeenLaunchAnimation")` (Bool). Colors/fonts/dark-mode/
launch-screen are static config; press feedback and mailto are stateless.

## Testing

- `LaunchPlanTests`: `mode(hasSeen:reduceMotion:)` returns `.staticLogo` under reduce-motion,
  `.full` when unseen, `.brief` when seen.
- `SerifFontTests`: the serif `UIFont` built by the helper carries the serif design trait
  (`fontDescriptor.withDesign(.serif)` resolves non-nil), confirming it is not the SF fallback.
- Color dedup verified by a grep/script: after the sweep, `Color(hex: "<token-hex>")` for each
  token appears 0 times (all migrated to the token), and the full unit suite + build stay green.
- Dark-mode lock, launch-screen (no white flash), press feel, and the mailto are verified by the
  user on device (user gate).

## Out of scope

- Aggressive color collapse / any visual redesign (decision: conservative dedup only).
- Removing the 62 redundant `.preferredColorScheme(.dark)` calls (harmless; noisy no-op).
- Phase-6 stubs (PaywallView/StoreService) and real IAP.
- Bundling a custom OTF font (system serif chosen instead).

## File summary

**New:**
- `Twin Flame Union/Support/LaunchPlan.swift` (`LaunchMode` + `LaunchPlan.mode`)
- `Twin Flame Union/Support/PressableButtonStyle.swift`
- `Twin Flame UnionTests/LaunchPlanTests.swift`
- `Twin Flame UnionTests/SerifFontTests.swift`

**Modified:**
- `Twin Flame Union/Theme.swift` (serif fonts; possibly the button style if co-located)
- `Twin Flame Union/LaunchAnimationView.swift` (mode gating + tap-to-skip + reduce-motion)
- `Twin Flame Union/Info.plist` (`UIUserInterfaceStyle = Dark`; launch-screen background)
- `Twin Flame Union/Views/Settings/SettingsView.swift` (Contact / Feedback row)
- The view files across `Views/**` + `Components/**` (per-token color dedup; pressable style on primary CTAs)
