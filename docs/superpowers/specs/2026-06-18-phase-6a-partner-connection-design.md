# Phase 6a — Partner Connection (Design)

**Date:** 2026-06-18
**Status:** Approved — building staged
**Goal:** Turn Twin Flame Union from single-player into a real two-person experience: two souls pair via an invite code/QR and share a connection timeline, a mutual streak, and "send a thought" pings.

## Reverence
The Gods and Goddesses are sacred — honored, capitalized, in all copy. Astrology stays out; numerology stays out.

## Architecture (locked)

### Identity — anonymous Supabase auth
- Each install signs in **anonymously** (a persistent `auth.uid()`), persisting the access + refresh tokens in the Keychain. No login screen.
- Requires **"Anonymous sign-ins" enabled** in the project's Auth settings (try via Management API `PATCH /v1/projects/{ref}/config/auth { external_anonymous_users_enabled: true }`; else a one-click dashboard toggle).
- This `auth.uid()` is the basis for RLS — only paired members can read their data.

### Client — raw Supabase REST (no new dependency)
- A small `SupabaseClient` over `URLSession` (consistent with `ClaudeProxyService`): handles anon sign-in, token refresh, and authed REST calls to `/rest/v1/...` and RPCs to `/rest/v1/rpc/...` with `apikey` + `Authorization: Bearer <session jwt>`.
- Config (URL + anon key) reuses the existing `Config.plist`.

### Backend — schema + RLS (new migration; deployed via `supabase db push`)
- `pairings(id uuid pk, invite_code text unique, creator_id uuid, partner_id uuid null, status text, created_at timestamptz)`.
- `connection_events(id uuid pk, pairing_id uuid fk, author_id uuid, kind text check in ('timeline','thought','streak'), body text, created_at timestamptz)`.
- **RLS:** enable on both. A pairing row is selectable/updatable only when `auth.uid() in (creator_id, partner_id)`. A `connection_events` row is selectable/insertable only when `auth.uid()` is a member of its `pairing_id`. Insert policy checks `author_id = auth.uid()`.
- **`accept_pairing(p_code text)`** — `security definer` RPC: if a pairing with that `invite_code` exists and `partner_id is null` and `creator_id <> auth.uid()`, set `partner_id = auth.uid()`, `status='active'`, and return the pairing; else raise. (Acceptance can't be a plain UPDATE because the accepter isn't yet a member, so RLS would block it.)
- Invite codes: short, unguessable (e.g. 8 chars base32). Unguessable code + RLS = the security boundary.

### Sync — polling
- The client polls `connection_events` for the active pairing since the last-seen timestamp (e.g. on appear + a light timer). Realtime subscription is a later enhancement.

## Stages (build order)
1. **Identity + pairing handshake** — `SupabaseClient` + anon auth; the `pairings` migration + RLS + `accept_pairing`; a "Connect with your Twin Flame" screen (show your code/QR; enter partner's code). *Deployable + unit-testable; full link needs a 2nd account.*
2. **Shared connection timeline** — repoint `ConnectionTimelineView` (currently local `@Query`) to read/write `connection_events(kind:'timeline')` for the active pairing; keep a graceful unpaired/empty state.
3. **Mutual streak** — a shared streak derived from both members' daily check-ins (`connection_events(kind:'streak')` or a `pairings` counter), shown on Home/Profile.
4. **"Send a thought"** — a one-tap ping (`kind:'thought'`); the partner sees it on next poll and gets a local notification ("Your twin flame is thinking of you 💭").

## Security review gate
The RLS policies + `accept_pairing` RPC are security-critical (they protect one couple's data from everyone else). They get a careful review **before** the migration is deployed to the live DB, the same rigor as the proxy hardening.

## Out of scope (later)
Realtime subscriptions; per-user proxy auth (now that real `auth.uid()` exists, the proxy could later enforce it); account/profile beyond the anonymous identity; merging an anonymous identity into a future real login.

## Testing
- Unit: invite-code generation (format/uniqueness), the client's request building (authed headers), event de-dupe/ordering.
- Backend: RLS verified with two anon users (one cannot read the other's pairing); `accept_pairing` happy/again/own-code paths.
- Device: the 2-account pairing handshake + a posted timeline event crossing devices (the user's second account, at the Stage-1/2 test point).
