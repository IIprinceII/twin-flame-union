# Phase 2 — App Store Compliance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clear the App Store 1.4.1 health-claim rejection and the secondary compliance gaps — add a wellness disclaimer (first-run sheet + footer + Settings), lightly soften physical-claim language, move to the Lifestyle category, flatten the app-icon alpha channel, declare privacy accurately, and remove paywall copy that implies a non-existent tier.

**Architecture:** One reusable `WellnessDisclaimer` unit (text + first-run sheet + read-only detail + footer) consumed by the two feature screens and Settings. Everything else is targeted text/config/asset edits — no new services or runtime behavior change.

**Tech Stack:** Swift / SwiftUI, Swift Testing (`import Testing`/`@Test`/`#expect`), `@AppStorage`, a CoreGraphics `swift` script for the icon, shell for claim-lint.

**Spec:** `docs/superpowers/specs/2026-06-16-phase-2-app-store-compliance-design.md`

**Conventions (same repo as Phase 1):**
- Xcode project uses `PBXFileSystemSynchronizedRootGroup` — new `.swift` files under `Twin Flame Union/` or `Twin Flame UnionTests/` auto-join the build. No `project.pbxproj` editing for new files.
- Test module is **`The_Twin_Flame_Union_App`**; Swift Testing, not XCTest.
- Build/test headless: `-scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`.
- Style tokens already in the app: `AppColors.{cream,lavender,gold,purple,coral,sage}`, `AppFont.{body,caption,serifHeadline}`, `Color(hex:)`, `warmButtonStyle()`.
- SourceKit "cannot find X" diagnostics are stale-index noise — trust `** BUILD/TEST SUCCEEDED **`.
- Final functional verification is the user in Xcode + App Store submission (Task 10).

---

## Task 0: Working branch

- [ ] **Step 1: Branch from main**

```bash
cd ~/Developer/twin-flame-union
git checkout main
git checkout -b phase-2-app-store-compliance
git status
```
Expected: on `phase-2-app-store-compliance`, clean tree.

---

## Task 1: Wellness disclaimer component

**Files:**
- Create: `Twin Flame Union/Views/Compliance/WellnessDisclaimer.swift`
- Test: `Twin Flame UnionTests/WellnessDisclaimerTests.swift`

- [ ] **Step 1: Write the failing test**

Create `Twin Flame UnionTests/WellnessDisclaimerTests.swift`:
```swift
import Testing
@testable import The_Twin_Flame_Union_App

struct WellnessDisclaimerTests {

    @Test func disclaimerTextIsHonestAndComplete() {
        let t = WellnessDisclaimer.text
        #expect(t.isEmpty == false)
        #expect(t.contains("not medical"))
        #expect(t.contains("not a substitute"))
        #expect(t.contains("consult a qualified professional"))
    }

    @Test func ackKeyIsStable() {
        #expect(WellnessDisclaimer.ackKey == "hasAcknowledgedWellnessDisclaimer")
    }

    @Test func footerIsNonMedical() {
        #expect(WellnessDisclaimer.footerShort.lowercased().contains("not medical"))
    }
}
```

- [ ] **Step 2: Run to verify it FAILS**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/WellnessDisclaimerTests"`
Expected: FAIL — `cannot find 'WellnessDisclaimer' in scope`.

- [ ] **Step 3: Create the component**

Create `Twin Flame Union/Views/Compliance/WellnessDisclaimer.swift`:
```swift
//
//  WellnessDisclaimer.swift
//  Twin Flame Union
//
//  Single source of truth for the wellness/medical disclaimer (App Store 1.4.1).
//  Consumed by SolfeggioView, EnergyEnhancementView, and Settings → About.
//

import SwiftUI

enum WellnessDisclaimer {
    /// UserDefaults flag: has the user acknowledged the first-run disclaimer?
    static let ackKey = "hasAcknowledgedWellnessDisclaimer"

    /// Full disclaimer shown in the first-run sheet and Settings.
    static let text = "Twin Flame Union is a spiritual and self-reflection app for entertainment and personal-growth purposes. It is not medical, psychological, or health advice and is not a substitute for professional care. Sound frequencies and energy practices are offered as meditative experiences, not treatments. If you have a health concern, please consult a qualified professional."

    /// One-line footer for feature screens.
    static let footerShort = "For spiritual & entertainment purposes only — not medical advice."
}

/// First-run acknowledgment sheet. The button records acknowledgment.
struct WellnessDisclaimerSheet: View {
    @AppStorage(WellnessDisclaimer.ackKey) private var acknowledged = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0418").ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.lavender)
                Text("A Gentle Note")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)
                ScrollView {
                    Text(WellnessDisclaimer.text)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                Button("I understand") {
                    acknowledged = true
                    dismiss()
                }
                .warmButtonStyle()
            }
            .padding(32)
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(true)
    }
}

/// Read-only presentation for Settings → About.
struct WellnessDisclaimerDetail: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0418").ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Wellness Disclaimer")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)
                ScrollView {
                    Text(WellnessDisclaimer.text)
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                }
                Button("Done") { dismiss() }
                    .warmButtonStyle()
            }
            .padding(32)
        }
        .preferredColorScheme(.dark)
    }
}

/// Small persistent footer for feature screens.
struct DisclaimerFooter: View {
    var body: some View {
        Text(WellnessDisclaimer.footerShort)
            .font(AppFont.caption(11))
            .italic()
            .foregroundStyle(AppColors.lavender.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
    }
}
```

- [ ] **Step 4: Run to verify it PASSES**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests/WellnessDisclaimerTests"`
Expected: PASS (3 tests). If `warmButtonStyle`/`AppFont.serifHeadline`/`Color(hex:)` don't resolve, confirm the exact names in `Theme.swift` / `Views/Onboarding/PaywallView.swift` (which use all of them) and match.

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Compliance/WellnessDisclaimer.swift" "Twin Flame UnionTests/WellnessDisclaimerTests.swift"
git commit -m "Phase 2: reusable WellnessDisclaimer (text, first-run sheet, detail, footer)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: SolfeggioView — disclaimer + rename 285 Hz

**Files:**
- Modify: `Twin Flame Union/Views/Journey/SolfeggioView.swift`

- [ ] **Step 1: Rename the 285 Hz subtitle**

In `Twin Flame Union/Views/Journey/SolfeggioView.swift`, change the 285 Hz entry's subtitle:
```swift
    .init(hz: 285, name: "285 Hz", subtitle: "Cellular Restoration",
```
to:
```swift
    .init(hz: 285, name: "285 Hz", subtitle: "Energetic Renewal",
```
(The `twinFlameBenefit`/`affirmation` for 285 Hz are already soft — leave them.)

- [ ] **Step 2: Add disclaimer state to the `SolfeggioView` struct**

Read the file. Just below `struct SolfeggioView: View {` and its existing `@Environment`/`@State` lines, add:
```swift
    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false
```

- [ ] **Step 3: Present the first-run sheet + add the footer**

On the OUTERMOST view returned by `var body` (the root container), append these modifiers:
```swift
        .onAppear {
            if !disclaimerAcked { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) {
            WellnessDisclaimerSheet()
        }
```
And add `DisclaimerFooter()` as the LAST element inside the screen's primary scrollable content (after the frequency list / selected-frequency detail, before the scroll content closes), so it's always visible at the bottom.

- [ ] **Step 4: Build to verify**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Journey/SolfeggioView.swift"
git commit -m "Phase 2: Solfeggio disclaimer (first-run + footer); rename 285Hz to Energetic Renewal

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: EnergyEnhancementView — disclaimer + reframe physical-claim lines

**Files:**
- Modify: `Twin Flame Union/Views/Journey/EnergyEnhancementView.swift`

- [ ] **Step 1: Reframe the "Elimination System" physical-mechanism sentence**

In the `EnergySection(heading: "The Elimination System", ...)` content string, replace exactly:
```
The blood facilitates grabbing denser vibrations and carrying them to elimination organs. When all systems are working in high order, you can shift your vibration in minutes.
```
with:
```
Picture your breath, movement, and warmth helping to carry denser energy away. With steady, consistent practice, many people describe feeling lighter and more energetically clear.
```

- [ ] **Step 2: Reframe the "Mind-Directed Energy Work" claims**

In the `EnergySection(heading: "Mind-Directed Energy Work", ...)` content string, make two exact replacements.

Replace:
```
With visualization you can directly influence the energy state of any structure in your body.
```
with:
```
With visualization you can work with the energy you sense in and around your body.
```

Replace:
```
The blood/energy system will excrete the lower vibrations.
```
with:
```
Imagine that denser energy being released and gently carried away.
```

- [ ] **Step 3: Add disclaimer state to the `EnergyEnhancementView` struct**

Read the file. Just below the `EnergyEnhancementView` view struct declaration and its existing state, add:
```swift
    @AppStorage(WellnessDisclaimer.ackKey) private var disclaimerAcked = false
    @State private var showDisclaimer = false
```
(If the file has multiple view structs, add to the top-level screen view that `var body` renders as the screen — the one shown when the user opens "Energy Enhancement".)

- [ ] **Step 4: Present the first-run sheet + add the footer**

On the outermost view of that screen's `var body`, append:
```swift
        .onAppear {
            if !disclaimerAcked { showDisclaimer = true }
        }
        .sheet(isPresented: $showDisclaimer) {
            WellnessDisclaimerSheet()
        }
```
And add `DisclaimerFooter()` as the last element of the primary scrollable content (after the energy sections).

- [ ] **Step 5: Build to verify**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 6: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Journey/EnergyEnhancementView.swift"
git commit -m "Phase 2: Energy disclaimer (first-run + footer); reframe physical-claim lines

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Settings → About — Wellness Disclaimer row

**Files:**
- Modify: `Twin Flame Union/Views/Settings/SettingsView.swift`

- [ ] **Step 1: Add presentation state**

After the existing `@State private var showExporter` / `exportDocument` lines (added in Phase 1) in `SettingsView`, add:
```swift
    @State private var showWellnessDisclaimer = false
```

- [ ] **Step 2: Add the disclaimer row to `aboutSection`**

In `aboutSection`, AFTER the "Privacy Policy" button block (the one opening `iiprinceii.github.io`), insert a divider + a Wellness Disclaimer row:
```swift
            Divider().background(AppColors.purple.opacity(0.3)).padding(.horizontal, 16)

            Button {
                showWellnessDisclaimer = true
            } label: {
                SettingsRowButton(icon: "heart.text.square.fill", iconColor: AppColors.sage, label: "Wellness Disclaimer", showChevron: true)
            }
```

- [ ] **Step 3: Present the detail sheet**

On the `body`'s outer `ZStack` (where the Phase 1 `.fileExporter` was attached, after `.preferredColorScheme(.dark)`), add:
```swift
        .sheet(isPresented: $showWellnessDisclaimer) {
            WellnessDisclaimerDetail()
        }
```

- [ ] **Step 4: Build to verify**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `** BUILD SUCCEEDED **`. (`AppColors.sage` exists in `Theme.swift`.)

- [ ] **Step 5: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Settings/SettingsView.swift"
git commit -m "Phase 2: Settings -> About Wellness Disclaimer row

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Remove paywall copy implying a non-existent tier

**Files:**
- Modify: `Twin Flame Union/Views/Onboarding/TutorialView.swift`
- Modify: `Twin Flame Union/Views/Journey/ChakraCheckinView.swift`

- [ ] **Step 1: Remove the "Upgrade to Premium" tutorial bullet**

In `Twin Flame Union/Views/Onboarding/TutorialView.swift`, delete this entire line:
```swift
                TutorialBullet(emoji: "💎", text: "Upgrade to Premium for unlimited access to all features"),
```

- [ ] **Step 2: Remove the dormant "Premium feature" label**

In `Twin Flame Union/Views/Journey/ChakraCheckinView.swift`, delete this block (it sits in an `if !StoreService.shared.isPremium` branch that never executes, but must not appear in source/screenshots):
```swift
                    if !StoreService.shared.isPremium {
                        Text("Premium feature")
                            .font(AppFont.caption(11))
                            .foregroundStyle(AppColors.lavender.opacity(0.5))
                    }
```

- [ ] **Step 3: Build to verify**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `** BUILD SUCCEEDED **`. (The "Get Personalized Healing Plan" button stays and works — `isPremium` is always true, so it opens the plan directly.)

- [ ] **Step 4: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/Views/Onboarding/TutorialView.swift" "Twin Flame Union/Views/Journey/ChakraCheckinView.swift"
git commit -m "Phase 2: remove residual Premium/Upgrade copy (no purchasable tier until Phase 6)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: App category → Lifestyle

**Files:**
- Modify: `Twin Flame Union.xcodeproj/project.pbxproj` (lines 412 and 458)

- [ ] **Step 1: Change both config occurrences**

Replace BOTH occurrences (Debug + Release) of:
```
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.healthcare-fitness";
```
with:
```
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.lifestyle";
```

- [ ] **Step 2: Verify**

Run:
```bash
cd ~/Developer/twin-flame-union
grep -c "public.app-category.lifestyle" "Twin Flame Union.xcodeproj/project.pbxproj"
grep -c "public.app-category.healthcare-fitness" "Twin Flame Union.xcodeproj/project.pbxproj" || true
```
Expected: `2` lifestyle, `0` healthcare-fitness.

- [ ] **Step 3: Build to verify the project still parses**

Run: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'`
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union.xcodeproj/project.pbxproj"
git commit -m "Phase 2: move primary category to Lifestyle (lower health-claim scrutiny)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Flatten the app-icon alpha channel

**Files:**
- Create: `scripts/flatten-icon-alpha.swift`
- Modify: `Twin Flame Union/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`

- [ ] **Step 1: Create the flatten script**

Create `scripts/flatten-icon-alpha.swift`:
```swift
// Flattens a PNG's alpha channel by compositing onto opaque black and re-encoding
// with no alpha. Dependency-free (CoreGraphics/ImageIO). Usage: swift flatten-icon-alpha.swift <in> <out>
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 3 else { fputs("usage: flatten <in> <out>\n", stderr); exit(2) }
let inURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outURL = URL(fileURLWithPath: CommandLine.arguments[2])

guard let src = CGImageSourceCreateWithURL(inURL as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fputs("cannot read\n", stderr); exit(1) }
let w = img.width, h = img.height
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8,
                          bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fputs("ctx fail\n", stderr); exit(1) }
ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
guard let flat = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.png.identifier as CFString, 1, nil) else { fputs("write fail\n", stderr); exit(1) }
CGImageDestinationAddImage(dest, flat, nil)
CGImageDestinationFinalize(dest)
```

- [ ] **Step 2: Flatten the icon in place**

```bash
cd ~/Developer/twin-flame-union
ICON="Twin Flame Union/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
swift scripts/flatten-icon-alpha.swift "$ICON" /tmp/icon_flat.png
mv /tmp/icon_flat.png "$ICON"
```

- [ ] **Step 3: Verify no alpha remains**

```bash
cd ~/Developer/twin-flame-union
sips -g hasAlpha -g pixelWidth -g pixelHeight "Twin Flame Union/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" | grep -E "hasAlpha|pixel"
```
Expected: `hasAlpha: no`, `pixelWidth: 1024`, `pixelHeight: 1024`.

- [ ] **Step 4: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "scripts/flatten-icon-alpha.swift" "Twin Flame Union/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
git commit -m "Phase 2: flatten app-icon alpha channel (App Store marketing-icon requirement)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Privacy manifest + App Store Connect doc

**Files:**
- Modify: `Twin Flame Union/PrivacyInfo.xcprivacy`
- Create: `docs/superpowers/app-store-connect-compliance.md`

- [ ] **Step 1: Declare User Content collection in the manifest**

In `Twin Flame Union/PrivacyInfo.xcprivacy`, replace the empty collected-data array:
```xml
	<key>NSPrivacyCollectedDataTypes</key>
	<array/>
```
with:
```xml
	<key>NSPrivacyCollectedDataTypes</key>
	<array>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeOtherUserContent</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
			</array>
		</dict>
	</array>
```

- [ ] **Step 2: Verify the manifest parses as valid plist**

```bash
cd ~/Developer/twin-flame-union
plutil -lint "Twin Flame Union/PrivacyInfo.xcprivacy"
```
Expected: `... OK`.

- [ ] **Step 3: Create the App Store Connect compliance doc**

Create `docs/superpowers/app-store-connect-compliance.md`:
```markdown
# App Store Connect — Compliance Checklist (Phase 2)

Apply these in App Store Connect (cannot be set from code) before resubmitting.

## Primary category
- Set **Lifestyle** (the binary now declares `public.app-category.lifestyle`).

## App Privacy — Data Types
- **User Content -> Other User Content**
  - Collected: **Yes**
  - Linked to the user: **No** (the app has no account system; the AI proxy uses an anonymous key)
  - Used for tracking: **No**
  - Purpose: **App Functionality**
  - Why: journal / dream / coaching text is sent to a server-side proxy (Supabase Edge Function) and on to Anthropic to generate readings.
- **Health & Fitness**
  - Collected: **No** -- meditation/mindful sessions are written to Apple Health on-device and are not transmitted to us.
- Everything else: **Not Collected**.

## Review notes (paste into "Notes for Reviewer")
> Twin Flame Union is a spiritual / self-reflection app (astrology, journaling, meditation
> tones) for entertainment and personal-growth purposes. It does not provide medical,
> psychological, or health advice. A wellness disclaimer appears on first use of the sound-
> frequency and energy screens, persistently as a footer on those screens, and in
> Settings -> About. AI-generated readings are produced via a server-side proxy; no API keys
> ship in the binary. HealthKit is used only to optionally log mindful-minute sessions to
> Apple Health.

## Age rating
- Confirm the content rating reflects spiritual/entertainment content (no medical claims).
```

- [ ] **Step 4: Commit**

```bash
cd ~/Developer/twin-flame-union
git add "Twin Flame Union/PrivacyInfo.xcprivacy" "docs/superpowers/app-store-connect-compliance.md"
git commit -m "Phase 2: declare User Content in privacy manifest + ASC compliance checklist

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 9: Claim-lint guard + full sweep + merge

**Files:**
- Create: `scripts/claim-lint.sh`

- [ ] **Step 1: Create the claim-lint script**

Create `scripts/claim-lint.sh`:
```bash
#!/bin/bash
# Fails if any forbidden health-claim / phantom-tier phrase reappears in the app source.
set -uo pipefail
ROOT="${1:-Twin Flame Union}"
DENY=(
  "Cellular Restoration"
  "Upgrade to Premium"
  "Premium feature"
  "carrying them to elimination organs"
  "shift your vibration in minutes"
  "directly influence the energy state of any structure in your body"
  "The blood/energy system will excrete"
)
fail=0
for phrase in "${DENY[@]}"; do
  if grep -rn --include="*.swift" -F "$phrase" "$ROOT" >/dev/null 2>&1; then
    echo "FORBIDDEN PHRASE FOUND: \"$phrase\""
    grep -rn --include="*.swift" -F "$phrase" "$ROOT"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "claim-lint: clean"
exit $fail
```

- [ ] **Step 2: Make it executable and run it**

```bash
cd ~/Developer/twin-flame-union
chmod +x scripts/claim-lint.sh
./scripts/claim-lint.sh "Twin Flame Union"
```
Expected: `claim-lint: clean` (exit 0). If it flags anything, fix the offending file (the phrase should have been edited in Tasks 2/3/5) and re-run.

- [ ] **Step 3: Run the full unit-test suite**

Run: `xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:"Twin Flame UnionTests"`
Expected: `** TEST SUCCEEDED **` — Phase 1 suites (AppSchema, PersistenceRecovery, ModelDefaults, DataExport) + WellnessDisclaimerTests (3) all pass.

- [ ] **Step 4: Commit the script**

```bash
cd ~/Developer/twin-flame-union
git add "scripts/claim-lint.sh"
git commit -m "Phase 2: claim-lint guard script (denylist of health-claim / phantom-tier phrases)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

- [ ] **Step 5: Merge to main**

```bash
cd ~/Developer/twin-flame-union
git checkout main
git merge --no-ff phase-2-app-store-compliance -m "Merge Phase 2: App Store compliance (disclaimer, claim softening, category, icon, privacy)"
```

- [ ] **Step 6: 🧑 Push** (needs the user's git credentials / branch-protection approval)

```bash
git push origin main
```
🤖 attempts this; if it fails, the user runs `! cd ~/Developer/twin-flame-union && git push origin main`.

---

## Task 10: 🧑 User verification gate

**Do not mark Phase 2 complete until the user confirms.**

- [ ] **Step 1:** Open in Xcode, build + run on a simulator. First time opening **Solfeggio** or **Energy** work → the "A Gentle Note" sheet appears and dismisses on "I understand"; a small disclaimer footer is visible at the bottom of those screens; Settings → About → **Wellness Disclaimer** opens the full text.
- [ ] **Step 2:** Confirm 285 Hz now reads **"Energetic Renewal"**, and the Energy screen no longer asserts physical mechanisms. Confirm no "Upgrade to Premium" / "Premium feature" copy appears anywhere.
- [ ] **Step 3:** In **App Store Connect**, apply `docs/superpowers/app-store-connect-compliance.md`: set category **Lifestyle**, the privacy nutrition labels, and paste the reviewer notes. Then archive + submit.

---

## Self-Review notes

- **Spec coverage:** Disclaimer component → Task 1; feature-screen integration → Tasks 2,3; Settings entry → Task 4; light claim softening (285 rename + Energy reframes) → Tasks 2,3; category → Task 6; icon alpha → Task 7; privacy manifest + ASC labels → Task 8; paywall cleanup → Task 5; claim-lint test → Task 9; user gate → Task 10. ✅
- **Testing deviation (intentional):** the spec floated a "claim-lint unit test" and "privacy manifest test." A simulator-hosted Swift test cannot read the Mac repo source, so claim-lint is a **shell script** (Task 9) and the privacy manifest is verified via `plutil` + the script — both more reliable than a sandboxed unit test. The disclaimer constants ARE covered by a hermetic Swift test (Task 1).
- **Type consistency:** `WellnessDisclaimer.{text,ackKey,footerShort}`, `WellnessDisclaimerSheet`, `WellnessDisclaimerDetail`, `DisclaimerFooter` used consistently across Tasks 1–4. The `@AppStorage(WellnessDisclaimer.ackKey)` flag name matches in the component and both feature screens.
- **No placeholders:** every edit shows exact old→new text or full file content; verifications use real commands with expected output.
