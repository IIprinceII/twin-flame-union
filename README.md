# Twin Flame Union

iOS (SwiftUI) twin-flame journey app — AI coaching (Seraphina), dream journal,
oracle pulls, solfeggio tones, gamified daily practice. Claude calls route through
a Supabase Edge Function (`claude-proxy`) so the Anthropic key never lives on-device.

## Canonical location

This repo at **`~/Developer/twin-flame-union`** (GitHub `IIprinceII/twin-flame-union`)
is the single source of truth. The old iCloud / Downloads copies were archived
`*.ARCHIVED-2026-06-15` on 2026-06-15 — **do not edit them.**

## Backend (Supabase)

- Project ref: `smflagmbcxrfqzbhywku`
- Edge function: `supabase/functions/claude-proxy` — model allowlist, max-token cap,
  CORS, per-IP rate limiting. Deploy with `supabase functions deploy claude-proxy`.
- The Anthropic key lives only as the `ANTHROPIC_API_KEY` Supabase secret (never in the repo or app bundle).
- Migrations in `supabase/migrations/` — apply with `supabase db push`.

## Program roadmap

See `docs/superpowers/specs/2026-06-14-twin-flame-union-program-roadmap.md`
(Phase 0 → Phase 7). Each phase gets its own dated design spec + implementation plan.
