# Twin Flame Union — "Integrate Everything" Program Roadmap

**Date:** 2026-06-14
**Status:** Approved (decomposition + decisions locked)
**Source:** Derived from the 2026-06-14 multi-agent audit (61 verified findings across bugs, App Store compliance, UX, missing features, polish, architecture, creative).

This is the umbrella roadmap. Each phase below gets its **own** design spec + implementation plan + build/verify cycle. Do not implement a later phase before the earlier ones land — the ordering encodes hard dependencies (a single safe repo and a non-leaking key must exist before anything else is built on top).

---

## Load-bearing product decisions (locked by user 2026-06-14)

| Decision | Choice | Affects |
|----------|--------|---------|
| **Monetization** | **Turn on real IAP** (StoreKit 2, existing `$1.99/wk` product), with Restore Purchases + Privacy/Terms links. | Phase 2 (compliance paywall), Phase 6 |
| **Partner / "twin flame" connection** | **Build real 2-person sync** (Supabase pairing via invite code/QR → shared connection timeline, mutual streak, "send a thought" ping). | Phase 6 (largest single item) |
| **Data persistence** | **CloudKit sync + JSON export** (SwiftData + CloudKit, plus Settings → Export My Data). | Phase 1 |
| **Daily Ritual Lock** | **Optional Home card** — remove the hard daily gate; show a dismissible "Begin Today's Ritual ✨" card on Home. | Phase 4 |

Constraint that ties them together: with IAP live, the paywall must show price/terms and gated features must NOT be the medical/health-claim features that triggered the prior 1.4.1 rejection. So **Phase 2 (compliance/health-claim cleanup) must precede turning IAP fully on.**

---

## Execution model

- **I (Claude) do:** all Swift / TypeScript / git / edge-function / asset edits.
- **User does:** rotate the leaked Anthropic key; `supabase functions deploy`; open the project in Xcode and build/archive/test on device; App Store Connect submission.
- I cannot run Xcode here, so **every phase ends with a "you build & verify" gate.**
- One canonical repo after Phase 0: `~/Developer/twin-flame-union` (GitHub `IIprinceII/twin-flame-union`).

---

## Phases

### Phase 0 — Source of Truth + Security  *(foundation; no product decisions)*
Spec: `2026-06-14-phase-0-source-security-design.md`
- Snapshot all 3 copies → consolidate into one clean git repo at `~/Developer/twin-flame-union`; commit build 10; push.
- Migrate `DreamJournalView` to `ClaudeProxyService`; delete all `loadAPIKey()`; remove `ANTHROPIC_API_KEY` from `Config.plist`.
- Lock down the Supabase `claude-proxy` edge function (auth JWT, model allowlist, max_tokens clamp, rate limit, CORS).
- User: rotate the key; deploy the function.

### Phase 1 — Data Safety
- SwiftData `VersionedSchema` + `SchemaMigrationPlan` (wrap current as `SchemaV1`); replace launch `fatalError` with a recovery path.
- CloudKit sync: iCloud entitlement + container, `ModelConfiguration(cloudKitDatabase: .automatic)`, make every `@Model` CloudKit-compatible (defaults / optional relationships).
- Settings → **Export My Data** (`.fileExporter`, JSON of all entries).

### Phase 2 — App Store Compliance  *(blocks resubmission)*
- `PrivacyInfo.xcprivacy` + App Store Connect nutrition labels matched to real data flow (content transmitted to proxy; HealthKit).
- Persistent medical/wellness disclaimer (Settings → About + first-run of Solfeggio/Energy views).
- Rename "Cellular Restoration" (285 Hz) → "Energetic Renewal"; soften `EnergyEnhancementView` physiology lines.
- Flatten app-icon alpha channel.
- Resolve paywall/"Premium" mismatch (becomes real in Phase 6 once IAP lands; until then it must not imply a non-existent tier).

### Phase 3 — Bug Fixes
- Unify the two streak systems; fix `sacredStreakCount` vs `streakCount` key mismatch (revives streak multiplier, vibrational bonus, 3 achievements).
- Wire gamification feedback (`XPGainIndicator`, level-up, `AchievementToast`) into a view that observes them.
- `ToneGenerator`: move frequency/phase off the MainActor for the render callback; add `AVAudioSession` interruption + route-change handling (also `AmbientSoundPlayer`).
- Fix off-by-one negative XP in `SoulProfile.xpForCurrentLevel`.
- Fix HealthKit `isAuthorized` set true on denial; persist real auth state.
- Fix meditation timer background drift + actually log sessions to HealthKit.

### Phase 4 — UX & Accessibility
- Daily Ritual Lock → optional dismissible Home card (remove `Twin_Flame_UnionApp` gate); keep the ritual reachable on demand.
- Accessibility pass: `.accessibilityLabel` on all icon-only buttons; `.accessibilityHidden` on decorative orbs; Dynamic Type for body/caption (`Theme.swift`); `reduceMotion` handling for the 33 `repeatForever` animations.
- Seraphina chat: retry on failure (don't make the user retype).
- Haptics consistency via `HapticManager` across views.

### Phase 5 — Polish
- Register/serve the serif headline font (`Font.system(design: .serif)` or bundle an OTF) so 121 headlines stop falling back to SF.
- Collapse 459 hardcoded hex colors → ~10–12 semantic `AppColors` tokens.
- Launch animation: tap-to-skip, first-launch-only (or ~2s), `reduceMotion` static fallback.
- Global dark-mode lock + proper launch screen (kill the white flash).
- Wire press/haptic states on buttons.
- In-app support/contact path; remove placeholder/scaffolding artifacts.

### Phase 6 — Missing Features  *(biggest)*
- **Partner connection (sub-project 6a):** Supabase `pairings` + invite codes/QR; shared `ConnectionTimeline`, mutual streak, "send a thought" ping. Its own spec.
- **Monetization (sub-project 6b):** StoreKit 2 purchase + `Transaction.currentEntitlements`; `isPremium` computed from entitlements; Restore Purchases; paywall with terms.
- Widget real data via App Group; fix Live Activity frozen breath phase.
- Fresh daily-affirmation/moon notifications + daily-ritual reminder.
- Cross-journal search (wire the orphaned search view or build new).
- iPad / landscape adaptation.
- Settings data-management completeness.

### Phase 7 — Creative
- Seraphina's Voice (`AVSpeechSynthesizer`), shareable Oracle Card of the Day (Stories-sized), "Send Love, Not Longing" ritual (528 Hz + `ConnectionMoment`), AI-personalized 7-Day Reunion Journey, astrological-event notifications (incl. 11:11), "Sacred Flame" dimming streak, voice journaling (`SFSpeechRecognizer`), generative mandala affirmation art, seasonal "Cosmic Gateways" events.

---

## Tracking

Decisions captured here are authoritative. Reopen this doc when a phase starts; spin its own dated design spec; do not batch phases.
