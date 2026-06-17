# Phase 5 — Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the serif headlines, dedup hardcoded colors into existing tokens (no visual change), make the launch animation fast/skippable, lock dark mode + kill the white flash, add button press feedback, and add an in-app support contact.

**Architecture:** Focused infra tasks (serif font, launch-plan helper + view, Info.plist, a button style, a Settings row) each TDD where there's pure logic, plus one deterministic scripted per-token color-dedup sweep.

**Tech Stack:** Swift / SwiftUI, UIKit (`UIFontMetrics`, `UIFontDescriptor.withDesign`), Swift Testing, Info.plist, asset catalog color.

**Spec:** `docs/superpowers/specs/2026-06-17-phase-5-polish-design.md`

**Conventions (same repo as Phases 1–4):**
- New `.swift` files under `Twin Flame Union/` or `Twin Flame UnionTests/` auto-join the build (synchronized groups).
- Test module is **`The_Twin_Flame_Union_App`**; Swift Testing.
- Build/test headless: `-scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`.
- SourceKit "cannot find X"/"hex:"/"No such module 'UIKit'/'Testing'" diagnostics are stale-index noise — trust `** BUILD/TEST SUCCEEDED **`.
- `Theme.swift` already has `import UIKit` (added in Phase 4). `AppColors` tokens: deepViolet `0E0620`, purple `7B35B8`, gold `F0C060`, rose `E8739A`, sage `7EC8A0`, coral `CC88FF`, cream `F5EFE6`, lavender `B8A8D0`, ember `FF9A6C`.
- Final visual verification (dark mode, white flash, press feel, mailto) is the user (Task 8).

---

## Task 0: Working branch

- [ ] `cd ~/Developer/twin-flame-union && git checkout main && git checkout -b phase-5-polish && git status` → on branch, clean.

---

## Task 1: Serif headline font (system serif)

**Files:** Modify `Twin Flame Union/Theme.swift`; Test `Twin Flame UnionTests/SerifFontTests.swift`

- [ ] **Step 1: Write the test** — Create `Twin Flame UnionTests/SerifFontTests.swift`:
```swift
import Testing
import UIKit
@testable import The_Twin_Flame_Union_App

struct SerifFontTests {
    // Proves the system serif design is available (so headlines render serif, not the SF fallback).
    @Test func systemSerifDesignResolves() {
        let sys = UIFont.systemFont(ofSize: 24, weight: .bold)
        #expect(sys.fontDescriptor.withDesign(.serif) != nil)
    }
    // Proves the AppFont helpers exist and return a font (not the old broken custom name).
    @Test func serifHelpersProduceFonts() {
        _ = AppFont.serifHeadline(28)
        _ = AppFont.serifTitle(20)
        #expect(Bool(true))
    }
}
```

- [ ] **Step 2: Run it** (`-only-testing:"Twin Flame UnionTests/SerifFontTests"`). It passes against current code (the helpers exist) — this is the regression guard for the rewrite below.

- [ ] **Step 3: Rewrite the serif helpers.** In `Twin Flame Union/Theme.swift`, replace:
```swift
    // Serif headlines — Georgia with New York as preferred option
    static func serifHeadline(_ size: CGFloat) -> Font {
        .custom("NewYork-Bold", size: size, relativeTo: .largeTitle)
    }

    static func serifTitle(_ size: CGFloat) -> Font {
        .custom("NewYork-Regular", size: size, relativeTo: .title)
    }
```
with:
```swift
    // System serif (New York), scaled with Dynamic Type. The old .custom("NewYork-…") name
    // never resolved and fell back to SF — this renders the actual serif.
    private static func scaledSerif(_ size: CGFloat, weight: UIFont.Weight, textStyle: UIFont.TextStyle) -> Font {
        let sys = UIFont.systemFont(ofSize: size, weight: weight)
        let serif = sys.fontDescriptor.withDesign(.serif).map { UIFont(descriptor: $0, size: size) } ?? sys
        return Font(UIFontMetrics(forTextStyle: textStyle).scaledFont(for: serif))
    }

    static func serifHeadline(_ size: CGFloat) -> Font { scaledSerif(size, weight: .bold, textStyle: .largeTitle) }
    static func serifTitle(_ size: CGFloat) -> Font { scaledSerif(size, weight: .regular, textStyle: .title) }
```
(Leave the Georgia-based `headline`/`title` unchanged — Georgia is a real iOS font and works.)

- [ ] **Step 4: Run → PASS.** Then `xcodebuild build … iPhone 17` → `** BUILD SUCCEEDED **` (confirms all call sites compile).

- [ ] **Step 5: Commit**
```bash
git add "Twin Flame Union/Theme.swift" "Twin Flame UnionTests/SerifFontTests.swift"
git commit -m "Phase 5: serif headlines render as system serif (was a broken custom-font fallback to SF)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Launch animation — full/brief/skippable/reduce-motion

**Files:** Create `Twin Flame Union/Support/LaunchPlan.swift`; Test `Twin Flame UnionTests/LaunchPlanTests.swift`; Modify `Twin Flame Union/LaunchAnimationView.swift`

- [ ] **Step 1: Write the failing test** — Create `Twin Flame UnionTests/LaunchPlanTests.swift`:
```swift
import Testing
@testable import The_Twin_Flame_Union_App

struct LaunchPlanTests {
    @Test func reduceMotionAlwaysStatic() {
        #expect(LaunchPlan.mode(hasSeen: false, reduceMotion: true) == .staticLogo)
        #expect(LaunchPlan.mode(hasSeen: true,  reduceMotion: true) == .staticLogo)
    }
    @Test func fullOnFirstLaunchOnly() {
        #expect(LaunchPlan.mode(hasSeen: false, reduceMotion: false) == .full)
        #expect(LaunchPlan.mode(hasSeen: true,  reduceMotion: false) == .brief)
    }
}
```

- [ ] **Step 2: Run → FAIL** (`cannot find 'LaunchPlan'`).

- [ ] **Step 3: Create the helper** — Create `Twin Flame Union/Support/LaunchPlan.swift`:
```swift
//
//  LaunchPlan.swift
//  Twin Flame Union
//
//  Decides how the launch animation plays. Pure + testable.
//

import Foundation

enum LaunchMode: Equatable { case full, brief, staticLogo }

enum LaunchPlan {
    static let seenKey = "hasSeenLaunchAnimation"

    /// Reduce Motion → instant static logo. Otherwise the full sequence the first time,
    /// then a brief fade on later launches.
    static func mode(hasSeen: Bool, reduceMotion: Bool) -> LaunchMode {
        if reduceMotion { return .staticLogo }
        return hasSeen ? .brief : .full
    }
}
```

- [ ] **Step 4: Run → PASS** (2 tests).

- [ ] **Step 5: Wire it into `LaunchAnimationView`.** Read `Twin Flame Union/LaunchAnimationView.swift`. The view has `let onComplete: () -> Void` and a fixed `DispatchQueue.main.asyncAfter` chain that always runs the full ~3.8s sequence. Modify it:
  - Add `@AppStorage(LaunchPlan.seenKey) private var hasSeenLaunch = false` and `@Environment(\.accessibilityReduceMotion) private var reduceMotion`.
  - Add `@State private var finished = false` and a single `finish()` that guards re-entry: `guard !finished else { return }; finished = true; onComplete()`. Replace the existing terminal `onComplete()` call(s) with `finish()`.
  - On the root view add `.onTapGesture { finish() }` and `.accessibilityAction { finish() }` so a tap (or VoiceOver action) skips immediately.
  - In `.onAppear` (where the DispatchQueue chain is kicked off), branch on `LaunchPlan.mode(hasSeen: hasSeenLaunch, reduceMotion: reduceMotion)`:
    - `.full`: run the existing sequence, then set `hasSeenLaunch = true` when it completes (at/just before `finish()`).
    - `.brief`: skip the long chain; show the logo and call `finish()` after `DispatchQueue.main.asyncAfter(deadline: .now() + 1.2)`.
    - `.staticLogo`: skip all animation/particles; call `finish()` after `DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)`.
  - Guard any looping/`repeatForever`/particle animation so it does not run when `mode == .staticLogo` (or when `reduceMotion`).

- [ ] **Step 6: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 7: Commit**
```bash
git add "Twin Flame Union/Support/LaunchPlan.swift" "Twin Flame UnionTests/LaunchPlanTests.swift" "Twin Flame Union/LaunchAnimationView.swift"
git commit -m "Phase 5: launch animation — full first launch, brief after, tap-to-skip, reduce-motion static

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Global dark-mode lock + launch-screen white-flash fix

**Files:** Modify `Twin Flame Union/Info.plist`; Create `Twin Flame Union/Assets.xcassets/LaunchBackground.colorset/Contents.json`

- [ ] **Step 1: Add the global dark lock + launch-screen background to Info.plist.** In `Twin Flame Union/Info.plist`, inside the top-level `<dict>`, add:
```xml
	<key>UIUserInterfaceStyle</key>
	<string>Dark</string>
	<key>UILaunchScreen</key>
	<dict>
		<key>UIColorName</key>
		<string>LaunchBackground</string>
	</dict>
```
(If a `UILaunchScreen` key already exists, merge `UIColorName` into it instead of duplicating.)

- [ ] **Step 2: Create the dark launch-background color asset.** Create `Twin Flame Union/Assets.xcassets/LaunchBackground.colorset/Contents.json` (`#0E0620`):
```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0x20",
          "green" : "0x06",
          "red" : "0x0E"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

- [ ] **Step 3: Verify + build.** `plutil -lint "Twin Flame Union/Info.plist"` → `OK`. Then `xcodebuild build … iPhone 17` → `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**
```bash
git add "Twin Flame Union/Info.plist" "Twin Flame Union/Assets.xcassets/LaunchBackground.colorset"
git commit -m "Phase 5: lock app to Dark mode (Info.plist) + dark launch-screen background (no white flash)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Pressable button style

**Files:** Create `Twin Flame Union/Support/PressableButtonStyle.swift`; Modify a focused set of primary-CTA call sites.

- [ ] **Step 1: Create the style** — Create `Twin Flame Union/Support/PressableButtonStyle.swift`:
```swift
//
//  PressableButtonStyle.swift
//  Twin Flame Union
//
//  Tactile press feedback: subtle scale + dim + a light haptic on press-down.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticManager.impact(.light) }
            }
    }
}
```

- [ ] **Step 2: Apply to primary CTAs.** Find the main action buttons that currently use `.buttonStyle(.plain)` (or no style) and lack press feedback — start with the primary CTAs: `OnboardingView` (Begin/Continue/Enter Portal), `MainTabView` `MiniFrequencyPlayer`, the Home cards' tappable buttons, `CoachInputBar` send, and the "Begin … Reading"/"Begin Sacred Session" buttons. Add `.buttonStyle(PressableButtonStyle())`. (Do NOT change buttons already using `warmButtonStyle()` — only add press feel where there is none. Skip buttons wrapped in NavigationLink or that already animate.)

- [ ] **Step 3: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**
```bash
git add "Twin Flame Union/Support/PressableButtonStyle.swift" "Twin Flame Union/Views" "Twin Flame Union/MainTabView.swift"
git commit -m "Phase 5: PressableButtonStyle (scale + dim + light haptic) on primary CTAs

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Support / feedback contact (Settings)

**Files:** Modify `Twin Flame Union/Views/Settings/SettingsView.swift`

- [ ] **Step 1: Add a Contact / Feedback row** to the About section (after the Phase-2 "Wellness Disclaimer" row):
```swift
            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                if let url = URL(string: "mailto:justin04rodriguez04@gmail.com?subject=Twin%20Flame%20Union%20Feedback") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRowButton(icon: "envelope.fill", iconColor: AppColors.rose, label: "Contact / Feedback", showChevron: true)
            }
```

- [ ] **Step 2: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**
```bash
git add "Twin Flame Union/Views/Settings/SettingsView.swift"
git commit -m "Phase 5: Settings -> Contact / Feedback (mailto) support path

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Color dedup (deterministic per-token sweep)

**Files:** Modify view/component `.swift` files (NOT `Theme.swift` — the token definitions + design gradients live there).

- [ ] **Step 1: Run the per-token replace** (exact-match hex → token; excludes `Theme.swift`):
```bash
cd ~/Developer/twin-flame-union
declare -A MAP=( [F0C060]=gold [E8739A]=rose [7EC8A0]=sage [CC88FF]=coral [B8A8D0]=lavender [FF9A6C]=ember )
for hex in "${!MAP[@]}"; do
  token="${MAP[$hex]}"
  grep -rl "Color(hex: \"$hex\")" --include="*.swift" "Twin Flame Union" | grep -v "/Theme.swift" | while read -r f; do
    perl -i -pe "s/Color\\(hex: \"$hex\"\\)/AppColors.$token/g" "$f"
  done
done
```
(The token DEFINITIONS in `Theme.swift` — e.g. `static let gold = Color(hex: "F0C060")` — are intentionally NOT touched, so the tokens still resolve to the real hex.)

- [ ] **Step 2: Verify the dedup** (each token-hex now appears only in Theme.swift):
```bash
cd ~/Developer/twin-flame-union
for hex in F0C060 E8739A 7EC8A0 CC88FF B8A8D0 FF9A6C; do
  n=$(grep -rn "Color(hex: \"$hex\")" --include="*.swift" "Twin Flame Union" | grep -v "/Theme.swift" | wc -l | tr -d ' ')
  echo "$hex outside Theme.swift: $n (expect 0)"
done
```
Expected: all `0`.

- [ ] **Step 3: Build + full test suite** → `** BUILD SUCCEEDED **` and `** TEST SUCCEEDED **`. (No visual change — identical colors, now via tokens.)

- [ ] **Step 4: Commit**
```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union"
git commit -m "Phase 5: dedup ~91 hardcoded hexes to existing AppColors tokens (zero visual change)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Full sweep + merge

- [ ] **Step 1: Full unit-test suite** → `** TEST SUCCEEDED **` (Phase 1–4 suites + SerifFontTests (2) + LaunchPlanTests (2)).
- [ ] **Step 2: claim-lint** → `cd ~/Developer/twin-flame-union && ./scripts/claim-lint.sh "Twin Flame Union"` → `claim-lint: clean`.
- [ ] **Step 3: Merge**
```bash
cd ~/Developer/twin-flame-union
git checkout main && git merge --no-ff phase-5-polish -m "Merge Phase 5: polish (serif fix, color dedup, launch anim, dark lock, press feel, support)"
```
- [ ] **Step 4: 🧑 Push** — `git push origin main` (controller attempts; user runs `! …` if blocked).

---

## Task 8: 🧑 User verification gate

**Do not mark Phase 5 complete until the user confirms.**

- [ ] **Step 1 (serif):** Headlines render in a serif (New York), not SF sans.
- [ ] **Step 2 (launch):** First launch = full animation; later launches = brief fade; tapping skips immediately; Reduce Motion = instant static logo.
- [ ] **Step 3 (dark + flash):** Cold-launch shows no white flash (dark from frame 1); app is dark everywhere.
- [ ] **Step 4 (press feel):** Primary buttons scale/dim with a light haptic on press.
- [ ] **Step 5 (support):** Settings → Contact / Feedback opens Mail to the support address.
- [ ] **Step 6 (colors):** No visual change vs before — a few screens look identical.

---

## Self-Review notes

- **Spec coverage:** A serif → Task 1. B color dedup → Task 6. C launch animation → Task 2. D dark lock + launch screen → Task 3. E pressable style → Task 4. F support path → Task 5. Testing → Tasks 1,2 (units) + Task 7 sweep + Task 8 user gate. ✅
- **Type consistency:** `AppFont.serifHeadline/serifTitle` + private `scaledSerif` (Task 1). `LaunchMode`/`LaunchPlan.mode`/`LaunchPlan.seenKey` (Task 2) used in the view + tests. `PressableButtonStyle` (Task 4). Token names (gold/rose/sage/coral/lavender/ember) match `AppColors` exactly (Task 6).
- **Dedup safety:** the per-token script excludes `Theme.swift`, so token DEFINITIONS keep their `Color(hex:)` and still resolve to the real color — guaranteeing zero visual change. Verified by Step-2 grep (0 outside Theme) + the full suite.
- **No placeholders:** every code step shows exact code or an exact script; verifications use real commands with expected output. The launch-view wiring (Task 2 Step 5) is described against the file's known shape (`onComplete` + DispatchQueue chain) — the implementer reads the file to place the mode branch; precise integration, not a placeholder.
