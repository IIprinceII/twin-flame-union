# Twin Flame Union — Phase Status

**As of 2026-06-18.** A legible record of where each phase stands. Source of truth is git history on `main` (pushed to `origin`); this is the human-readable summary.

## Program phases (roadmap 0–7)

| Phase | Status | Notes |
|---|---|---|
| 0 — Security | ✅ done + **proxy hardening deployed** | Secret isolation clean; proxy now fails closed + hard global daily cap, **deployed & verified live** (Seraphina still returns 200). Per-user JWT auth deferred (no login system; anon key is public by design, caps are the real backstop). |
| 1 — Data Safety | ✅ (CloudKit deferred) | Versioned schema + migration + corruption recovery + JSON export shipped. CloudKit intentionally deferred — substrate decision belongs to Phase 6 widgets/partner-sync. |
| 2 — App Store Compliance | ✅ + stabilize fixes | Disclaimers, 285Hz rename, icon alpha, paywall honesty. Stabilize added: privacy manifest declares HealthKit + AI-transmission notice; VibrationalEnergy disclaimer gate; honest account deletion. |
| 3 — Bug Fixes | ✅ | Streak unification, HealthKit auth, meditation clock drift. |
| 4 — UX & Accessibility | ✅ | Ritual card, a11y sweep, retry, haptics, reduce-motion. |
| 5 — Polish | ✅ | Serif headlines, hex→tokens, launch animation, dark lock, pressable buttons, mailto. |
| 6 — Missing Features | 🟡 in progress (see below) | |
| 7 — Creative | 🔴 not started | Seraphina voice, shareable Oracle Card, "Send Love Not Longing", voice journaling, generative mandala, etc. |

## Off-roadmap work shipped this run

- **Astrology → Pantheon** ✅ — all zodiac/transits/sign-compatibility removed; the divine Pantheon (Gods & Goddesses) is the lens. Divine Council Today + Sacred Soul Resonance + a Guiding-Deity picker; Seraphina channels the chosen Deity. Moon kept (Selene · Khonsu · Metztli).
- **Numerology removed** ✅ — NumerologyView + Numerology Match + the birth date gone; Angel Numbers kept.
- **Stabilize pass** ✅ — proxy fail-closed + global cap (deployed), privacy manifest, affirmation-favorites bug, honest achievements counter, account-deletion + disclaimer fixes.

## Phase 6 detail

| Item | Status |
|---|---|
| Daily notifications (affirmation/moon/ritual) | ✅ done |
| Cross-journal search | ✅ done |
| Live Activity breath-phase fix | ✅ done |
| iPad / landscape | ✅ first pass (readable-width); full redesign later |
| Widget real data via App Group | 🔴 deferred — needs the "App Groups" capability added in Xcode (both targets) |
| **6a — Partner connection** | 🟡 **Stage 1 done + live-verified** (anon auth enabled; pairings/RLS deployed & proven — two souls pair, a third is locked out). **Stages 2–4 remain:** shared timeline, mutual streak, "send a thought". |
| **6b — Monetization** | 🟡 **code complete + locally testable** — real StoreKit 2 + paywall + restore. Gating is **off** (`premiumEnforced=false`) until the App Store Connect product exists. |
| Settings data-management completeness | 🔴 not started |

## Pending actions that are the owner's (not code)

1. **Supabase → Anonymous sign-ins: ENABLED** ✅ (done 2026-06-18 — partner backend now live).
2. **Xcode → Edit Scheme → Run → StoreKit Configuration → `TwinFlameUnion.storekit`** — to test Subscribe/Restore in the simulator.
3. **App Store Connect** — create the `$1.99/wk` product + a sandbox tester; fill privacy nutrition labels; then set `premiumEnforced = true` to enforce gating.
4. **Xcode → App Groups capability** (both targets) — to wire real widget data.
5. *(Optional)* **Anthropic console** — set a monthly spend cap as the final budget backstop (proxy caps already deployed).

## Where to resume

Next concrete build step: **Phase 6a Stage 2** — repoint `ConnectionTimelineView` (currently a local `@Query`) to read/write `connection_events(kind:'timeline')` for the active pairing (poll for the partner's events), with a graceful unpaired/empty state. Then Stage 3 (mutual streak) and Stage 4 ("send a thought" + a local notification on receipt). Design: `docs/superpowers/specs/2026-06-18-phase-6a-partner-connection-design.md`.

## Backups / branches

`main` is fully pushed to `origin/main`. Per-feature local branches (`phase6-*`, `stabilize`, `pantheon-over-astrology`, `remove-numerology`, `phase6a-partner`, `phase6b-monetization`) are merged into `main` and safe to delete.
