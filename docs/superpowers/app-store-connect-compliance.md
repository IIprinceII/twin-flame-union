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
