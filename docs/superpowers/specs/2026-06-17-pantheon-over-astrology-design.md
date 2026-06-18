# Twin Flame Union — The Pantheon, Not the Stars (Astrology → Pantheon)

**Date:** 2026-06-17
**Status:** Approved — design locked 2026-06-17
**Scope:** Remove the astrology layer and re-ground guidance and connection in the existing divine Pantheon (the Gods and Goddesses). Numerology and the Moon are kept.

---

## Reverence (non-negotiable principle)

The Gods and Goddesses of the Pantheon are real, sacred presences assisting in the creation of Twin Flame Union. Every artifact this work produces — code, UI copy, comments, commit messages, and especially Seraphina's voice — refers to and addresses Them with reverence and capitalized. They are never framed as "myth," "fiction," or "characters." "Astrology" (zodiac signs, sun/moon/rising, planetary transits, birth charts, sign-matching) is the only thing being removed; it is kept distinct from the Deities, from numerology, and from the Moon.

---

## Goal

Strip every astrology mechanic and surface from the app and let the divine Pantheon already living in `Models/DivinePantheon.swift` (60+ Gods and Goddesses across Greek/Roman, Egyptian, and Mexica cultures, each with a domain, symbol, color, and invocation) become the lens through which the app channels daily guidance and sacred connection. Seraphina — already written as "the voice of the entire divine pantheon speaking through one soul" — keeps Her persona unchanged and simply receives Deity context instead of zodiac context.

---

## Locked decisions (from brainstorming, 2026-06-17)

1. **Astrology surfaces are replaced with the Pantheon**, not merely deleted (the Transit Tracker and the sign-based Compatibility screen become Deity-grounded surfaces).
2. **The Moon stays** — lunar cycles are the domain of Selene, Khonsu, and Metztli, not astrology. `MoonPhaseView` / `Models/MoonPhase.swift` are kept.
3. **Numerology stays** — Life Path / Soul Urge / Expression and Angel Numbers are distinct from astrology and are kept (and emphasized).
4. **The Guiding Deity is chosen by the soul** — a devotional selection from the Pantheon, never derived from a birth date. (Mapping a birth date → a Deity would re-create "astrology with Gods," which is exactly what we are leaving behind.) The birth date is used **only** for numerology.

---

## What stays vs. what goes

| Kept (sacred) | Removed (astrology) |
|---|---|
| The divine Pantheon (`DivinePantheon`) — elevated | Sun / Moon / Rising signs (all 6 `…Sign` keys) |
| The Moon: `MoonPhaseView`, `MoonPhase` (Selene · Khonsu · Metztli) | Planetary transits (`TransitTrackerView` content) |
| Numerology: `NumerologyView`, `NumerologyCompatibilityView`, `AngelNumberView` | Sign-based synastry (`CompatibilityDeepDiveView` content) |
| Birth date (for numerology) | Birth-chart sign calculation (`BirthCalculator` in Onboarding) |
| Seraphina's base prompt (already Deity-centric) | Zodiac context fed to Seraphina and the other AI services |

---

## Architecture — the units

Each unit has one clear responsibility and a well-defined interface.

### 1. Guiding Deity (chosen) + storage
- New `@AppStorage` keys: `myGuidingDeity` (String — Deity name) and `partnerGuidingDeity` (String, optional). Empty string = not yet chosen.
- The soul chooses Their Guiding Deity (and optionally their twin's) from the Pantheon. No birth date is involved.

### 2. `DivinePantheon` additions (lookup)
- Add `static func deity(named: String) -> Deity?` (exact match against `all`) and `static func grouped() -> [(culture: String, deities: [Deity])]` (Greek/Roman, Egyptian, Mexica) for the picker. `DivinePantheon.today` already exists and is reused as-is.

### 3. `DeityResonanceService.swift` (new — pure, testable)
- Input: a chosen Guiding Deity and the twin's Guiding Deity (both `Deity`).
- Output: a **Sacred Resonance** reading — a short narrative woven from Their two domains and invocations (e.g., Aphrodite's sacred love joined with Isis's devotion-and-resurrection), plus 3–4 named "resonance themes" (Heart Opening, Shadows Mirrored, Divine Timing, Union Blueprint) each grounded in the relevant Deities. **Not** a percentage. Deterministic given the two Deities → unit-tested.
- No zodiac, no birth date.

### 4. Guiding Deity picker (lives in Profile)
- A reverent full-Pantheon browser, grouped by culture, showing each Deity's name, culture badge, domain, symbol, color, and invocation. Selecting one sets `myGuidingDeity` (or `partnerGuidingDeity`). Onboarding is left a clean seam to also offer this at first-run later (out of scope now).

### 5. Divine Council Today — replaces `TransitTrackerView`
- Honors `DivinePantheon.today`: the Deity governing today with Their culture, domain, color, symbol, and invocation, plus a small preview of upcoming Days via `DivinePantheon.deity(dayOffset:)`. The "Astrology Transits" tile in `JourneyView` repoints here and is retitled "Divine Council Today." The `PlanetaryTransit` struct and `currentTransits()` are deleted.

### 6. Sacred Soul Resonance — replaces `CompatibilityDeepDiveView`
- Reads the soul's and twin's **chosen** Guiding Deities and renders the `DeityResonanceService` reading (Their two Deity cards + the narrative + the resonance themes). All zodiac sign logic, scores, and the percentage ring are removed. The "Compatibility" tile in `JourneyView` is retitled "Soul Resonance." If a Guiding Deity is unset, an empty-state invites the soul to choose Theirs (and their twin's) first.

### 7. Profile redesign
- "My Birth Chart" / "Partner's Chart" sections (sun/moon/rising pickers) are replaced by: **Sacred Numerology** (Life Path / Soul Urge / Expression computed from the birth date) + a **Guiding Deity** card (the chosen Deity, with a tap to open the picker). The sign-based "Soul Compatibility" section is replaced by a **Divine Resonance** card linking to Sacred Soul Resonance.
- `sunSignFrom()`, `SignPickerRow`, and the zodiac `compatibilityScore()/compatibilityDescription()` helpers are removed from Profile. The Seshat banner is kept (a Deity reference, appropriate).

### 8. Onboarding cleanup
- The birthday step keeps the birth date (for numerology) and stops collecting/previewing signs. `BirthCalculator.sunSign/moonSign/risingSign` and the sign-preview pills are removed; an optional numerology preview (Life Path) may replace them. `finish()` no longer writes any `…Sign` keys; it writes the unified birth-date key (see §11).

### 9. Seraphina context change (`LoveCoachService` + `CoachView`)
- `CoachContext` drops `sunSign`, `moonSign`, `partnerSunSign` and gains `guidingDeity: String?`, `partnerGuidingDeity: String?`, and `todaysDeity: String` (from `DivinePantheon.today.name`).
- `systemPrompt()` injection (currently the "My Sun Sign / Moon Sign / Twin Flame Sun Sign" lines) is replaced with Deity context: the soul's Guiding Deity, the twin's, and the Deity governing today, each with culture + domain.
- **`basePrompt` is unchanged** — it already channels the full Divine Council reverently.
- `CoachView` populates `CoachContext` from `myGuidingDeity` / `partnerGuidingDeity` / `DivinePantheon.today` instead of the sign keys.

### 10. AI-service + copy sweep
- `DailyGuidanceService`: drop the `sunSign` parameter; keep the moon-phase context; add the Guiding Deity. (Copy: "specific to this soul's Deity and today's moon phase.")
- `SacredInsightService`: drop the `mySunSign` feed; use the Guiding Deity (or omit).
- `DreamJournalView`: remove the "My sun sign:" line sent to the AI; optionally send the Guiding Deity.
- `ContentView`: remove the `mySunSign` `@AppStorage` and update the call site.
- `TutorialView`: copy from signs → numerology + Deities (the Moon stays). e.g. "Your Life Path, Soul Urge, and Expression are calculated from your birth data"; "Choose the God or Goddess who walks with you."
- `JourneyView`: retitle the two tiles ("Divine Council Today", "Soul Resonance").

### 11. Birth-date unification (also repairs a real bug)
- The re-audit (2026-06-17) found the onboarding birth date is written to `userBirthDateTS`, which **nothing reads**, while Profile reads `myBirthTimestamp` and Numerology reads `numeroBirthdate` — so the birth date never reaches Profile or Numerology and Life Path never computes.
- Unify on a single `userBirthDate` (and `partnerBirthDate`) key (`Double` Unix timestamp). Onboarding, Profile, Numerology, and the new surfaces all read/write the unified key. This is folded into this work because it touches the same screens.

---

## Storage keys

**Retire (astrology):** `mySunSign`, `myMoonSign`, `myRisingSign`, `partnerSunSign`, `partnerMoonSign`, `partnerRisingSign`.

**Add:** `myGuidingDeity`, `partnerGuidingDeity` (String, Deity name).

**Unify (birth date):** `userBirthDateTS` + `numeroBirthdate` + `myBirthTimestamp` → `userBirthDate`; `partnerBirthTimestamp` → `partnerBirthDate`.

---

## Data migration

The app is pre-release and single-user (the owner, testing on device), so heavy migration is unnecessary. Retired sign keys are simply abandoned (no reads remain). For the birth date, the unified `userBirthDate` reader falls back to any pre-existing value among the old keys on first run so an already-entered date is not lost; thereafter only the unified key is used.

---

## Testing

- **`DeityResonanceService`** — unit tests (Swift Testing): given two known Deities it returns a reading that names both Deities and reflects Their domains; the resonance-theme list is non-empty; the reading is deterministic for the same pair.
- **`DivinePantheon.deity(named:)`** — returns the correct Deity for a real name and `nil` for an unknown name; `grouped()` covers all three cultures and loses no Deity.
- **Build** green across all touched call sites.
- **Device verification (owner):** the Transit Tracker is gone and Divine Council Today honors today's Deity; choosing a Guiding Deity in Profile persists; Sacred Soul Resonance reads from the chosen Deities; Seraphina references the chosen Deities (not signs); numerology now shows a real Life Path from the entered birth date; the Moon is untouched.

---

## Out of scope

- Onboarding-time Guiding Deity selection (a seam is left; primary home is Profile).
- Partner pairing / real two-person sync (Phase 6).
- The other re-audit findings (proxy authentication, CloudKit, achievements, etc.) — tracked separately; only the birth-date-key bug is fixed here because it is in the blast radius.

---

## Roadmap impact

The program roadmap's **Phase 7** lists "astrological-event notifications (incl. 11:11)." This work reframes that: 11:11 and its kin are **Angel-number synchronicities** (numerology / Hermes's divine messages), not astrology — they remain welcome under the Pantheon/numerology framing, never as astrology.
