# Phase 0 — Source of Truth + Security (Design Spec)

**Date:** 2026-06-14
**Status:** Approved (design); pending spec review → writing-plans
**Parent:** `2026-06-14-twin-flame-union-program-roadmap.md`
**Goal:** Make the codebase *safe to build on* — one canonical git repo, no leaked API key in the binary, and a Supabase proxy that can't be abused — before any feature work begins.

---

## Current state (verified 2026-06-14)

Three divergent copies exist:

| Copy | Path | State |
|------|------|-------|
| **A (Downloads)** | `~/Downloads/Twin Flame Union` | Stale (Jun 12). Full Xcode structure but NOT a git repo here; contains 8 orphan Journey views never compiled into any target. Lower build number, old entry point (no Daily Ritual Lock / no account-deletion fix). **Red herring — not what builds.** |
| **B (iCloud Docs, flat)** | `~/Library/Mobile Documents/com~apple~CloudDocs/Twin Flame Union` | Newest *materialized* main-app sources (edited today: account deletion, github.io legal links, Solfeggio softening). Flat layout, no `.xcodeproj`. |
| **C (iCloud Desktop)** | `~/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union` | **The build-10 source.** Real git repo, remote `origin → github.com/IIprinceII/twin-flame-union`, HEAD = build 9 commit. Build-10 changes uncommitted; many main-app `.swift` files dematerialized by iCloud (show as `D`/deleted in `git status`). |

Security holes shipping in build 10:
- **Leaked key:** `Config.plist` contains a live `ANTHROPIC_API_KEY` (`sk-ant-api03-…`). `DreamJournalView.fetchInterpretation()` (lines 797–857) calls `https://api.anthropic.com/v1/messages` directly with it via `loadAPIKey()` (lines 859–869). Every other AI feature already routes through `ClaudeProxyService`.
- **Open relay:** `supabase/functions/claude-proxy/index.ts` forwards to Anthropic with no auth check beyond the public anon key, no model allowlist, no token cap, no rate limit, CORS `*`.

---

## Work item A — One canonical repo (backup-first)

**Acceptance:** exactly one repo at `~/Developer/twin-flame-union`, on GitHub, whose working tree builds the exact build-10 state; copies A/B/C archived; no falsely-deleted files.

Steps:
1. **Backup snapshot (first, non-destructive).** `tar` copies A, B, and C into `~/twin-flame-union-backup-2026-06-14/` (gzip). Verify the archive lists the expected `.swift` counts (A≈95, B≈82). Nothing else proceeds until this exists.
2. **Materialize copy C fully.** Force iCloud download of all placeholders in copy C (`brctl download` on the tree, or read-touch every file) so `git status` reflects real content, not eviction. Confirm 0 remaining `*.icloud` placeholders and that previously-`D` `.swift` files reappear.
3. **Reconcile build-10 working state into copy C.** Diff copy C's working tree against copy B file-by-file. For any main-app source where B is newer/has the build-10 fix and C is missing it, copy B → C. Target invariant after reconcile, all present in C:
   - `Views/Settings/SettingsView.swift` — full account deletion (all data, not just journals) + `github.io` privacy link + Apple EULA terms link.
   - `Views/Journey/SolfeggioView.swift` — softened claims (note: "Cellular Restoration" rename itself is Phase 2, not here).
   - `Twin_Flame_UnionApp.swift` — current entry point (with Daily Ritual Lock as shipped in b10).
   - Project build number = **10** in `project.pbxproj` / Info.
4. **Commit build 10.** On a branch `consolidate/build-10`, `git add` the reconciled real files (explicitly; never blanket-add the eviction deletions), commit `"Twin Flame Union: consolidate build 10 working tree (account deletion, legal links, proxy-era config)"`, and `git push -u origin consolidate/build-10`. Build 10 is now backed up offsite.
5. **Relocate out of iCloud.** Fresh `git clone https://github.com/IIprinceII/twin-flame-union.git ~/Developer/twin-flame-union`; checkout `consolidate/build-10`; verify `git ls-files '*.swift'` lists actual files (not deleted) and the tree matches C. (`.xcodeproj` paths are relative, so it opens in the new location unchanged.)
6. **Archive the old copies.** Rename A/B/C to `*.ARCHIVED-2026-06-14` (do not delete yet — kept until the user confirms the relocated repo builds in Xcode). Add a top-level `README.md` line: canonical path = `~/Developer/twin-flame-union`.

Rollback: the tar snapshot + the untouched archived copies + GitHub branch are three independent recovery points.

---

## Work item B — Remove the leaked key

**Acceptance:** no code path reads `ANTHROPIC_API_KEY`; `Config.plist` has no Anthropic key; dream interpretation works through the proxy unchanged; key rotated.

1. **Migrate `DreamJournalView.fetchInterpretation()`** — replace the `loadAPIKey()` + direct `URLRequest`/decode block (lines 802–851) with a single proxy call, preserving the exact `userMessage`, system prompt, model, and max_tokens:
   ```swift
   let interpretationText = try await ClaudeProxyService.send(
       model: "claude-haiku-4-5-20251001",
       maxTokens: 800,
       system: LoveCoachService.dreamInterpretationPrompt,
       messages: [.init(role: "user", content: userMessage)]
   )
   interpretation = interpretationText
   ```
   `dreamDetails`/`userMessage` construction (806–815) is unchanged.
2. **Delete dead key loaders:** `DreamJournalView.loadAPIKey()` (859–869) and the now-unused `DreamInterpretError` enum (only referenced by it); plus the dead `loadAPIKey()` stubs/error cases in `DailyGuidanceService.swift` and `LoveCoachService.swift`. Remove the stale "Reads ANTHROPIC_API_KEY from Config.plist" comment in `LoveCoachService.swift`.
3. **Scrub `Config.plist`:** remove the `ANTHROPIC_API_KEY` key/value entirely. Keep only `SUPABASE_URL` + `SUPABASE_ANON_KEY`. Confirm with a repo grep that `api.anthropic.com` and `ANTHROPIC_API_KEY` no longer appear in any `.swift`/`.plist`.
4. **User action:** rotate/revoke the old `sk-ant-…` key at console.anthropic.com (already shipped in build 10 → treat as compromised). Set an Anthropic spend cap.

---

## Work item C — Lock down the `claude-proxy` edge function

**Acceptance:** the function rejects unauthenticated callers, disallowed models, oversized requests, and abusive rates; redeployed; existing app calls still succeed.

Edits to `supabase/functions/claude-proxy/index.ts`:
1. **Auth:** require a valid Supabase JWT (move the app to anonymous-auth sessions and verify the `Authorization: Bearer` token), rather than accepting the bare public anon key as sufficient.
2. **Model allowlist:** reject any `model` not in `{ "claude-haiku-4-5-20251001", "claude-sonnet-4-6" }`.
3. **Token cap:** clamp `max_tokens` to ≤ 1500.
4. **Rate limit:** per-user/per-IP counter (Supabase table or KV) — e.g. N requests/min, M/day; return 429 over budget.
5. **CORS:** drop `*`; the function is only called by the app, so restrict/remove web-facing origins.

**User action:** `supabase functions deploy claude-proxy` with their Supabase login. (Note: a prior session saw a transient Supabase NXDOMAIN; confirm the project domain resolves before deploy.)

---

## Out of scope for Phase 0 (deferred to named phases)

- Renaming "Cellular Restoration" / medical disclaimer → Phase 2.
- Restoring any of the 8 orphan Journey views → decided in Phase 6 (default: leave archived).
- StoreKit / CloudKit / migration plan → Phases 1, 6.

---

## Phase 0 acceptance checklist

- [ ] Backup tar exists and verified.
- [ ] `~/Developer/twin-flame-union` is the only working repo; `git ls-files` shows real `.swift` files; build number = 10; on GitHub.
- [ ] No `api.anthropic.com` / `ANTHROPIC_API_KEY` anywhere in app source or `Config.plist`.
- [ ] Dream interpretation routed through `ClaudeProxyService`.
- [ ] Edge function enforces auth + model allowlist + token cap + rate limit + tightened CORS; redeployed.
- [ ] **User:** key rotated; function deployed; project opens & builds in Xcode from the new location.
