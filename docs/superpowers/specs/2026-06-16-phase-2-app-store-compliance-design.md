# Phase 2 — App Store Compliance Design

**Date:** 2026-06-16
**Status:** Approved (design locked by user 2026-06-16)
**Roadmap:** `2026-06-14-twin-flame-union-program-roadmap.md` → Phase 2
**Repo:** `~/Developer/twin-flame-union` (GitHub `IIprinceII/twin-flame-union`)

## Goal

Get Twin Flame Union past the prior **App Store 1.4.1** (health-claim) rejection and
clean up the secondary compliance gaps (privacy disclosure, app-icon alpha, a paywall
that implies a non-existent tier) so the app can be resubmitted. Preserve the app's
spiritual voice — reframe only the language that asserts physical/medical effects.

## Locked decisions (from brainstorm)

| Decision | Choice |
|----------|--------|
| **Claim softening depth** | **Light** — keep all spiritual/metaphysical teaching; reframe ONLY lines that assert physical/medical effects. The disclaimer carries the compliance weight. |
| **Disclaimer presentation** | **First-run acknowledgment sheet + persistent footer + Settings→About entry.** |
| **App category** | **Move Healthcare & Fitness → Lifestyle** (binary + App Store Connect) to lower health-claim scrutiny. |

## Current state (verified 2026-06-16)

- `INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.healthcare-fitness"` in
  `project.pbxproj` — the high-scrutiny category.
- **No disclaimer anywhere** in the app (grep found none).
- Health-claim surface:
  - `Views/Journey/SolfeggioView.swift` — frequency list with subtitles incl. **285 Hz
    "Cellular Restoration"** (physiological); others are emotional/spiritual ("Release
    Fear & Guilt", "The Love Frequency", etc.). Each entry has `subtitle`,
    description/`twinFlameBenefit`, `affirmation` fields.
  - `Views/Journey/EnergyEnhancementView.swift` — mostly spiritual (aura, "astral
    linkage", vibration), with ~3 physiological lines: "blood… carrying them to
    elimination organs", "shift your vibration in minutes", "directly influence the
    energy state of any structure in your body".
- `Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` — `hasAlpha: yes` (App Store
  auto-rejects a marketing icon with an alpha channel).
- `PrivacyInfo.xcprivacy` exists but `NSPrivacyCollectedDataTypes` is **empty**, despite
  journal/dream text being sent to the Claude proxy → Anthropic. Declares only
  UserDefaults API use (CA92.1).
- HealthKit: `Services/HealthService.swift` reads+writes only `.mindfulSession` to Apple
  Health. Info.plist has `NSHealthShareUsageDescription` + `NSHealthUpdateUsageDescription`.
- Paywall/Premium: already mostly neutralized — `Services/StoreService.swift` is a stub
  (`isPremium = true`, "All features are currently free"); `PaywallView`/`PremiumGateOverlay`
  are placeholder/`EmptyView`. Residual premium-implying copy: `TutorialView.swift`
  "Upgrade to Premium for unlimited access" bullet, and a dormant `Text("Premium feature")`
  in `ChakraCheckinView` (inside an `if !isPremium` branch that never executes).

## Architecture

One reusable disclaimer unit, consumed by the two feature screens and Settings; the rest
are targeted text/config/asset edits. No new services.

### Component 1 — `Views/Compliance/WellnessDisclaimer.swift` (new)
A single source of truth for the disclaimer:
- `enum WellnessDisclaimer` namespace with:
  - `static let text: String` — canonical wording:
    > "Twin Flame Union is a spiritual and self-reflection app for entertainment and
    > personal-growth purposes. It is not medical, psychological, or health advice and is
    > not a substitute for professional care. Sound frequencies and energy practices are
    > offered as meditative experiences, not treatments. If you have a health concern,
    > please consult a qualified professional."
  - `static let ackKey = "hasAcknowledgedWellnessDisclaimer"` — `@AppStorage` flag key.
- `WellnessDisclaimerSheet: View` — a first-run acknowledgment sheet showing `text` with a
  single "I understand" button that sets the ack flag and dismisses.
- `DisclaimerFooter: View` — a small italic caption (the `text`, or a one-line short form
  linking to the full text) for the bottom of feature screens.

### Component 2 — Feature-screen integration
- `SolfeggioView` and `EnergyEnhancementView` each:
  - Present `WellnessDisclaimerSheet` on first appearance when `!hasAcknowledgedWellnessDisclaimer`
    (shared flag — acknowledging on either screen satisfies both).
  - Render `DisclaimerFooter` pinned at the bottom of their scroll content.

### Component 3 — Settings → About entry
- `SettingsView` aboutSection: a "Wellness Disclaimer" `SettingsRowButton` that presents the
  full `WellnessDisclaimer.text` (sheet or detail view).

### Component 4 — Light claim softening (text edits only)
- `SolfeggioView`: 285 Hz `subtitle` "Cellular Restoration" → **"Energetic Renewal"**;
  reframe its description away from cellular/tissue/healing language into spiritual/energetic
  terms. Audit every frequency's description/`twinFlameBenefit`; reframe any physical-healing
  assertion (keep purely emotional/spiritual ones as-is).
- `EnergyEnhancementView`: reframe the three physiological lines into experiential/energetic
  language; the aura/astral/vibration teaching is unchanged.
- No structural/code changes — strings only.

### Component 5 — App category
- `project.pbxproj`: `INFOPLIST_KEY_LSApplicationCategoryType` →
  `"public.app-category.lifestyle"` (both Debug and Release configs).

### Component 6 — App-icon alpha flatten
- Composite every AppIcon PNG that reports `hasAlpha: yes` onto an opaque background and
  re-export without an alpha channel (`sips`/ImageMagick), beginning with `AppIcon-1024.png`.
  Verify `sips -g hasAlpha` reports `no` for all. Visual appearance unchanged (icon already
  has no transparent regions; we're just dropping the channel).

### Component 7 — Privacy
- `PrivacyInfo.xcprivacy`: add an `NSPrivacyCollectedDataTypes` entry — **Other User Content**
  (`NSPrivacyCollectedDataTypeOtherUserContent`), purpose **App Functionality**
  (`NSPrivacyCollectedDataTypePurposeAppFunctionality`), `Linked = false`, `Tracking = false`
  — reflecting journal/dream/coaching text transmitted to the Claude proxy → Anthropic. Keep
  the existing UserDefaults (CA92.1) entry. HealthKit `mindfulSession` is written to Apple
  Health on-device and not transmitted to us → not declared as collected.
- New `docs/superpowers/app-store-connect-compliance.md`: the exact **App Store Connect
  nutrition-label answers** (User Content → App Functionality → not linked → not tracking;
  Health → not collected) and **reviewer notes** (spiritual/entertainment positioning, where
  the disclaimer lives, that AI features route through a server-side proxy), since ASC cannot
  be edited from code.

### Component 8 — Paywall/Premium cleanup
- Remove the `TutorialView` "Upgrade to Premium for unlimited access to all features" bullet.
- Remove/neutralize the dormant `Text("Premium feature")` label (and any other visible
  "Premium"/"Upgrade" copy) so nothing implies a purchasable tier. Leave the dormant
  `StoreService`/`isPremium` plumbing for Phase 6 (do not rip out the gating scaffolding).

## Data flow

No runtime data-flow change. The disclaimer ack flag (`@AppStorage`) gates a one-time sheet;
the footer is static; claim edits are static strings; category/icon/privacy are
build-time/asset/config.

## Testing

Most of Phase 2 is content/asset/config, but key invariants are lockable:
- **Claim-lint test** (`ClaimComplianceTests`): scan the relevant source files for a denylist
  of forbidden phrases (e.g. "Cellular Restoration", "cure", "DNA repair", "treats",
  "diagnose", "heals the body") and fail if any are present. Permanently prevents regression.
- **Disclaimer gating test**: the ack flag flips correctly; the canonical `text` is non-empty
  and present.
- **Icon alpha check**: a script/test step asserting `sips -g hasAlpha` is `no` for the
  marketing icon.
- **Privacy manifest**: a test parsing `PrivacyInfo.xcprivacy` and asserting the User Content
  collected-data entry is present with the right purpose/linked/tracking values.
- Final verification: user builds in Xcode, visually confirms the first-run sheet + footers +
  Settings entry, and submits to App Store. App Store approval is the real acceptance test.

## Out of scope (explicitly deferred)

- Real IAP / a functional paywall (Phase 6).
- Any change to HealthKit behavior (Phase 3 fixes the `isAuthorized`-on-denial bug).
- Rewriting spiritual content beyond the specific physical-claim lines.
- Setting App Store Connect fields directly (documented for the user to apply).

## File summary

**New:**
- `Twin Flame Union/Views/Compliance/WellnessDisclaimer.swift`
- `Twin Flame UnionTests/ClaimComplianceTests.swift`
- `docs/superpowers/app-store-connect-compliance.md`

**Modified:**
- `Twin Flame Union/Views/Journey/SolfeggioView.swift` (footer + first-run sheet + claim edits)
- `Twin Flame Union/Views/Journey/EnergyEnhancementView.swift` (footer + first-run sheet + claim edits)
- `Twin Flame Union/Views/Settings/SettingsView.swift` (About → Wellness Disclaimer row)
- `Twin Flame Union/Views/Onboarding/TutorialView.swift` (remove premium upsell bullet)
- `Twin Flame Union/Views/Journey/ChakraCheckinView.swift` (neutralize dormant "Premium feature" label)
- `Twin Flame Union/PrivacyInfo.xcprivacy` (declare User Content collection)
- `Twin Flame Union.xcodeproj/project.pbxproj` (category → lifestyle)
- `Twin Flame Union/Assets.xcassets/AppIcon.appiconset/*.png` (flatten alpha)
