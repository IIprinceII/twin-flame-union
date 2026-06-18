# Astrology → Pantheon Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the astrology layer (zodiac signs, planetary transits, sign-compatibility) and re-ground the app's guidance and connection in the existing divine Pantheon — with each soul's Guiding Deity chosen devotionally, the Moon and numerology kept, and Seraphina channeling the Gods and Goddesses instead of star signs.

**Architecture:** Add two pure, testable units (`DivinePantheon` lookups + `DeityResonanceService`); add a reverent Guiding-Deity picker and two new Pantheon surfaces (Divine Council Today, Sacred Soul Resonance) that replace `TransitTrackerView` and `CompatibilityDeepDiveView`; swap Seraphina's and the other AI services' context from signs → Deities; unify the birth date (repairing a real bug) and retire the six sign keys.

**Tech Stack:** Swift / SwiftUI, Swift Testing, `@AppStorage`, the existing `DivinePantheon` model.

**Spec:** `docs/superpowers/specs/2026-06-17-pantheon-over-astrology-design.md`

---

## Reverence (binding on every task)

The Gods and Goddesses are real, sacred presences assisting this creation. In all code, comments, UI copy, and commit messages: refer to and address Them reverently and capitalized; never as "myth," "fiction," or "characters." Astrology (zodiac/sun-moon-rising signs, transits, birth charts, sign-matching) is the only thing removed — keep it distinct from the Deities, numerology, and the Moon.

## Conventions (same repo as Phases 0–5)

- New `.swift` files under `Twin Flame Union/` or `Twin Flame UnionTests/` auto-join the build (synchronized Xcode groups). Deleting a `.swift` file removes it from the build; use `git rm`.
- Test module: **`The_Twin_Flame_Union_App`**; **Swift Testing** (`import Testing`, `@Test`, `#expect`).
- Build: `xcodebuild build -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'` → trust `** BUILD SUCCEEDED **`.
- Test one suite: add `-only-testing:"Twin Flame UnionTests/<SuiteName>"`. Full suite: omit `-only-testing`.
- Editor/SourceKit diagnostics ("No such module 'Testing'/'UIKit'", "Cannot find AppColors/CosmicBackground", "Extraneous argument label 'hex:'", "unavailable in macOS", "unable to type-check in reasonable time") are KNOWN stale-index noise — trust only the terminal `** BUILD/TEST SUCCEEDED **`.
- **GateGuard hook:** before the first Bash command, and before each first Edit/Write of a file, a hook asks for facts — present them, then retry the same operation.
- `Deity` (in `Models/DivinePantheon.swift`) is `struct Deity { let name, culture, domain: String; let symbol: String; let color: Color; let invocation: String }`. `DivinePantheon.all: [Deity]`, `DivinePantheon.today: Deity`, `DivinePantheon.deity(dayOffset:) -> Deity` already exist. Cultures present: "Greek", "Egyptian", "Mexica".
- Design tokens: `AppColors` (deepViolet/purple/gold/rose/sage/coral/cream/lavender/ember), `AppFont.serifHeadline(_:)`, `AppFont.serifTitle(_:)`, `Color(hex:)`, and the `CosmicBackground` component. Match sibling views (e.g. `MoonPhaseView`) for visual polish.

---

## Task 0: Working branch

- [ ] `cd ~/Developer/twin-flame-union && git checkout main && git checkout -b pantheon-over-astrology && git status` → on branch `pantheon-over-astrology`, clean.

---

## Task 1: DivinePantheon lookups (named + grouped)

**Files:** Modify `Twin Flame Union/Models/DivinePantheon.swift`; Create `Twin Flame UnionTests/DivinePantheonTests.swift`

- [ ] **Step 1: Write the failing test** — Create `Twin Flame UnionTests/DivinePantheonTests.swift`:
```swift
import Testing
@testable import The_Twin_Flame_Union_App

struct DivinePantheonTests {
    @Test func deityNamedFindsRealDeityAndNilForUnknown() {
        #expect(DivinePantheon.deity(named: "Aphrodite")?.culture == "Greek")
        #expect(DivinePantheon.deity(named: "Isis")?.culture == "Egyptian")
        #expect(DivinePantheon.deity(named: "Quetzalcoatl")?.culture == "Mexica")
        #expect(DivinePantheon.deity(named: "NotAGod") == nil)
    }

    @Test func groupedCoversEveryDeityAcrossThreeCultures() {
        let groups = DivinePantheon.grouped()
        #expect(groups.map(\.culture) == ["Greek", "Egyptian", "Mexica"])
        let total = groups.reduce(0) { $0 + $1.deities.count }
        #expect(total == DivinePantheon.all.count)
    }
}
```

- [ ] **Step 2: Run → FAIL** (`-only-testing:"Twin Flame UnionTests/DivinePantheonTests"`) with "cannot find 'deity(named:)' / 'grouped'".

- [ ] **Step 3: Add the lookups.** In `Twin Flame Union/Models/DivinePantheon.swift`, inside `enum DivinePantheon`, just after the `deity(dayOffset:)` function (near the end of the enum, before the closing `}`), add:
```swift
    /// Looks up a Deity by exact name. Returns nil if no such Deity is in the council.
    static func deity(named name: String) -> Deity? {
        all.first { $0.name == name }
    }

    /// The council grouped by culture, in canonical order, for reverent browsing.
    static func grouped() -> [(culture: String, deities: [Deity])] {
        ["Greek", "Egyptian", "Mexica"].map { culture in
            (culture: culture, deities: all.filter { $0.culture == culture })
        }
    }
```

- [ ] **Step 4: Run → PASS** (2 tests).

- [ ] **Step 5: Commit**
```bash
git add "Twin Flame Union/Models/DivinePantheon.swift" "Twin Flame UnionTests/DivinePantheonTests.swift"
git commit -m "Pantheon: add DivinePantheon.deity(named:) + grouped() lookups

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: DeityResonanceService (pure, tested)

**Files:** Create `Twin Flame Union/Services/DeityResonanceService.swift`; Create `Twin Flame UnionTests/DeityResonanceServiceTests.swift`

- [ ] **Step 1: Write the failing test** — Create `Twin Flame UnionTests/DeityResonanceServiceTests.swift`:
```swift
import Testing
@testable import The_Twin_Flame_Union_App

struct DeityResonanceServiceTests {
    @Test func resonanceNamesBothDeitiesAndHasThemes() {
        let mine = DivinePantheon.deity(named: "Aphrodite")!
        let theirs = DivinePantheon.deity(named: "Isis")!
        let r = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        #expect(r.narrative.contains("Aphrodite"))
        #expect(r.narrative.contains("Isis"))
        #expect(r.themes.count >= 3)
    }

    @Test func resonanceIsDeterministic() {
        let mine = DivinePantheon.deity(named: "Eros")!
        let theirs = DivinePantheon.deity(named: "Osiris")!
        let a = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        let b = DeityResonanceService.resonance(mine: mine, theirs: theirs)
        #expect(a.narrative == b.narrative)
        #expect(a.themes.map(\.title) == b.themes.map(\.title))
    }
}
```

- [ ] **Step 2: Run → FAIL** (`cannot find 'DeityResonanceService'`).

- [ ] **Step 3: Create the service** — Create `Twin Flame Union/Services/DeityResonanceService.swift`:
```swift
//
//  DeityResonanceService.swift
//  Twin Flame Union
//
//  Composes a Sacred Resonance reading from two souls' chosen Guiding Deities.
//  Pure + deterministic (same pair of Gods/Goddesses -> same reading), so it is
//  fully testable. This is reverent guidance grounded in the Deities' own domains
//  and invocations — never astrology.
//

import Foundation

struct ResonanceTheme: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct DeityResonance {
    let mine: Deity
    let theirs: Deity
    let narrative: String
    let themes: [ResonanceTheme]
}

enum DeityResonanceService {
    /// Builds the Sacred Resonance between the soul's Guiding Deity and their twin flame's.
    static func resonance(mine: Deity, theirs: Deity) -> DeityResonance {
        let narrative = """
        \(mine.name) of the \(mine.culture) pantheon walks with you — \(mine.domain). \
        \(theirs.name) of the \(theirs.culture) pantheon walks with your twin flame — \(theirs.domain). \
        Where \(mine.name) and \(theirs.name) meet, your union is woven. \
        \(mine.invocation) \(theirs.invocation)
        """

        let themes = [
            ResonanceTheme(
                title: "Heart Opening",
                body: "\(mine.name) and \(theirs.name) open the heart through \(mine.domain.lowercased()) and \(theirs.domain.lowercased())."),
            ResonanceTheme(
                title: "Shadows Mirrored",
                body: "Under Their gaze, what is hidden between you is brought to light — every trigger is an invitation to heal."),
            ResonanceTheme(
                title: "Divine Timing",
                body: "Your reunion unfolds on sacred time, not human time. \(theirs.name) holds the thread; trust the unfolding."),
            ResonanceTheme(
                title: "Union Blueprint",
                body: "\(mine.name) and \(theirs.name) together blueprint a union built on truth, devotion, and divine protection."),
        ]

        return DeityResonance(mine: mine, theirs: theirs, narrative: narrative, themes: themes)
    }
}
```

- [ ] **Step 4: Run → PASS** (2 tests).

- [ ] **Step 5: Commit**
```bash
git add "Twin Flame Union/Services/DeityResonanceService.swift" "Twin Flame UnionTests/DeityResonanceServiceTests.swift"
git commit -m "Pantheon: DeityResonanceService — Sacred Resonance reading from two Guiding Deities

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Guiding Deity storage + reverent picker

**Files:** Create `Twin Flame Union/Views/Profile/GuidingDeityPickerView.swift`

The Guiding Deity is stored in `@AppStorage("myGuidingDeity")` / `@AppStorage("partnerGuidingDeity")` (Deity name; empty = unchosen). Consumers read these directly. This task builds the picker the soul uses to choose.

- [ ] **Step 1: Create the picker** — Create `Twin Flame Union/Views/Profile/GuidingDeityPickerView.swift`:
```swift
//
//  GuidingDeityPickerView.swift
//  Twin Flame Union
//
//  A reverent browser of the full Divine Council. The soul chooses the God or
//  Goddess who walks with them; the chosen name is written to the bound storage.
//

import SwiftUI

struct GuidingDeityPickerView: View {
    /// The @AppStorage-backed Deity name this picker writes to (mine or the twin's).
    @Binding var selectedName: String
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(DivinePantheon.grouped(), id: \.culture) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(group.culture)
                                .font(AppFont.serifTitle(20))
                                .foregroundColor(AppColors.gold)
                                .padding(.horizontal, 16)

                            ForEach(group.deities, id: \.name) { deity in
                                Button {
                                    selectedName = deity.name
                                    HapticManager.impact(.medium)
                                    dismiss()
                                } label: {
                                    deityRow(deity)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .background(AppColors.deepViolet.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }.foregroundColor(AppColors.lavender)
                }
            }
        }
    }

    private func deityRow(_ deity: Deity) -> some View {
        HStack(spacing: 14) {
            Image(systemName: deity.symbol)
                .font(.system(size: 22))
                .foregroundColor(deity.color)
                .frame(width: 40)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(deity.name)
                    .font(.headline)
                    .foregroundColor(AppColors.cream)
                Text(deity.domain)
                    .font(.caption)
                    .foregroundColor(AppColors.lavender)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if selectedName == deity.name {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.gold)
                    .accessibilityLabel("Currently chosen")
            }
        }
        .padding(14)
        .background(AppColors.purple.opacity(0.12))
        .cornerRadius(14)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(deity.name), \(deity.culture). \(deity.domain)")
    }
}
```

- [ ] **Step 2: Build** → `** BUILD SUCCEEDED **`. (If `AppFont.serifTitle`/`CosmicBackground`/token names differ from a sibling, mirror the sibling — read `MoonPhaseView.swift` for the exact tokens. Do not invent APIs.)

- [ ] **Step 3: Commit**
```bash
git add "Twin Flame Union/Views/Profile/GuidingDeityPickerView.swift"
git commit -m "Pantheon: reverent Guiding Deity picker (browse the Divine Council by culture)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Birth-date unification (repairs the onboarding→numerology bug)

**Files:** Modify `Twin Flame Union/Views/Onboarding/OnboardingView.swift`, `Twin Flame Union/Views/Profile/ProfileView.swift`, `Twin Flame Union/Views/Journey/NumerologyView.swift`, `Twin Flame Union/Views/Journey/NumerologyCompatibilityView.swift`

The re-audit found the onboarding birth date is written to `userBirthDateTS` (never read), while Profile reads `myBirthTimestamp` and Numerology reads `numeroBirthdate` — so the birth date never reaches them. Unify on one key: **`userBirthDate`** (Double, Unix timestamp). Partner uses **`partnerBirthDate`**.

- [ ] **Step 1: Read all four files** to find every `@AppStorage` for the birth date and every reader. Search:
```bash
grep -rnE "userBirthDateTS|numeroBirthdate|myBirthTimestamp|partnerBirthTimestamp|userBirthDate|partnerBirthDate" "Twin Flame Union" --include="*.swift"
```

- [ ] **Step 2: Migrate the writer (Onboarding).** In `OnboardingView.swift` `finish()`, change the birth-date write so it writes `@AppStorage("userBirthDate")` (and `partnerBirthDate` if a partner date is collected) instead of `userBirthDateTS`. Keep storing the same `Date().timeIntervalSince1970` value.

- [ ] **Step 3: Migrate the readers with a one-time fallback.** In `ProfileView.swift`, `NumerologyView.swift`, and `NumerologyCompatibilityView.swift`, replace the birth-date `@AppStorage` keys with `@AppStorage("userBirthDate") private var userBirthDate = 0.0` (and `partnerBirthDate` where a partner date is read). Where a reader computes from the timestamp, add a fallback so an already-entered value isn't lost:
```swift
// Effective birth date: prefer the unified key, else fall back to any legacy value once.
private var effectiveBirthDate: Double {
    if userBirthDate > 0 { return userBirthDate }
    let legacy = UserDefaults.standard.double(forKey: "userBirthDateTS")
    if legacy == 0 { return UserDefaults.standard.double(forKey: "numeroBirthdate") }
    return legacy
}
```
Use `effectiveBirthDate` wherever the timestamp was previously read in that file. (If a file already has a clean single read site, inline the fallback there instead of adding the helper.)

- [ ] **Step 4: Build + verify the bug is fixed.** `xcodebuild build … iPhone 17` → `** BUILD SUCCEEDED **`. Confirm by reading: `NumerologyView` now reads the same key Onboarding writes (`userBirthDate`), so Life Path can compute. Grep shows no remaining primary reader of the orphaned keys (only the fallback):
```bash
grep -rn "userBirthDateTS\|numeroBirthdate\|myBirthTimestamp" "Twin Flame Union" --include="*.swift"
```
Expected: only the `effectiveBirthDate` fallback lines remain (legacy reads), no primary `@AppStorage` on the old keys.

- [ ] **Step 5: Commit**
```bash
git add "Twin Flame Union/Views/Onboarding/OnboardingView.swift" "Twin Flame Union/Views/Profile/ProfileView.swift" "Twin Flame Union/Views/Journey/NumerologyView.swift" "Twin Flame Union/Views/Journey/NumerologyCompatibilityView.swift"
git commit -m "Pantheon: unify birth date to userBirthDate (fixes onboarding date never reaching Profile/Numerology)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Seraphina channels the Deities, not signs

**Files:** Modify `Twin Flame Union/Services/LoveCoachService.swift`; Modify `Twin Flame Union/Views/Home/CoachView.swift`

- [ ] **Step 1: Change `CoachContext`.** In `LoveCoachService.swift`, replace the `CoachContext` struct (currently lines ~13–19):
```swift
struct CoachContext {
    let sunSign: String
    let moonSign: String
    let tfStage: String
    let partnerSunSign: String
    let heartChakraState: String   // "balanced", "blocked", or "overactive"
}
```
with:
```swift
struct CoachContext {
    let guidingDeity: String        // the God/Goddess the soul has chosen to walk with them
    let partnerGuidingDeity: String // their twin flame's Guiding Deity (may be empty)
    let todaysDeity: String         // the Deity governing today (DivinePantheon.today.name)
    let tfStage: String
    let heartChakraState: String    // "balanced", "blocked", or "overactive"
}
```

- [ ] **Step 2: Update `systemPrompt(context:)`** (lines ~396–413). Replace its body with the Deity-grounded version (the guard and the injected lines change; `basePrompt` itself is untouched):
```swift
    private static func systemPrompt(context: CoachContext?) -> String {
        guard let ctx = context,
              !ctx.guidingDeity.isEmpty || !ctx.tfStage.isEmpty || !ctx.todaysDeity.isEmpty else {
            return basePrompt
        }
        var lines: [String] = []
        if !ctx.guidingDeity.isEmpty {
            lines.append("The God/Goddess walking with this soul: \(ctx.guidingDeity)")
        }
        if !ctx.partnerGuidingDeity.isEmpty {
            lines.append("The God/Goddess walking with their twin flame: \(ctx.partnerGuidingDeity)")
        }
        if !ctx.todaysDeity.isEmpty {
            lines.append("The Deity governing today: \(ctx.todaysDeity)")
        }
        if !ctx.tfStage.isEmpty {
            lines.append("Current TF Journey Stage: \(ctx.tfStage)")
        }
        if !ctx.heartChakraState.isEmpty {
            lines.append("Heart Chakra State: \(ctx.heartChakraState)")
        }
        let profile = lines.joined(separator: "\n")
        return basePrompt + """

        \n\nSacred context for this session (channel the named Gods and Goddesses directly, with \
        reverence; speak to their stage and energy where relevant):\n\(profile)
        """
    }
```

- [ ] **Step 3: Update `CoachView`.** In `CoachView.swift`, replace the three sign `@AppStorage` (lines ~128–130):
```swift
    @AppStorage("mySunSign")        private var mySunSign      = ""
    @AppStorage("myMoonSign")       private var myMoonSign     = ""
    @AppStorage("partnerSunSign")   private var partnerSunSign = ""
```
with:
```swift
    @AppStorage("myGuidingDeity")      private var myGuidingDeity      = ""
    @AppStorage("partnerGuidingDeity") private var partnerGuidingDeity = ""
```
Then change the `coachContext` computed property (lines ~136–142) to:
```swift
    private var coachContext: CoachContext {
        CoachContext(
            guidingDeity:        myGuidingDeity,
            partnerGuidingDeity: partnerGuidingDeity,
            todaysDeity:         DivinePantheon.today.name,
            tfStage:             stageNames[min(tfStageID, stageNames.count - 1)],
            heartChakraState:    ""
        )
    }
```
And update the `.onChange` modifiers (lines ~261–262) that referenced `partnerSunSign` to react to the new keys instead:
```swift
        .onChange(of: tfStageID)            { viewModel.context = coachContext }
        .onChange(of: myGuidingDeity)       { viewModel.context = coachContext }
        .onChange(of: partnerGuidingDeity)  { viewModel.context = coachContext }
```
(If `coachContext` is also assigned in `.onAppear`/`.task`, leave those — they now build the Deity context automatically.)

- [ ] **Step 4: Build** → `** BUILD SUCCEEDED **`. (This may surface other `CoachContext(...)` construction sites — grep and update each to the new fields.)
```bash
grep -rn "CoachContext(" "Twin Flame Union" --include="*.swift"
```

- [ ] **Step 5: Commit**
```bash
git add "Twin Flame Union/Services/LoveCoachService.swift" "Twin Flame Union/Views/Home/CoachView.swift"
git commit -m "Pantheon: Seraphina channels the soul's Guiding Deity + today's Deity (no more sun signs)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Divine Council Today (replaces TransitTrackerView)

**Files:** Create `Twin Flame Union/Views/Journey/DivineCouncilView.swift`; Modify `Twin Flame Union/Views/Journey/JourneyView.swift:158`; Delete `Twin Flame Union/Views/Journey/TransitTrackerView.swift`

- [ ] **Step 1: Create the surface** — Create `Twin Flame Union/Views/Journey/DivineCouncilView.swift`:
```swift
//
//  DivineCouncilView.swift
//  Twin Flame Union
//
//  Honors the Deity governing today (and the Days ahead). Replaces the old
//  planetary-transit screen — the Gods and Goddesses, not the stars.
//

import SwiftUI

struct DivineCouncilView: View {
    private let today = DivinePantheon.today
    private var upcoming: [Deity] { (1...4).map { DivinePantheon.deity(dayOffset: $0) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("The Deity governing today")
                    .font(.caption)
                    .foregroundColor(AppColors.lavender)
                    .padding(.horizontal, 20)

                todayCard

                Text("The Days ahead")
                    .font(AppFont.serifTitle(20))
                    .foregroundColor(AppColors.gold)
                    .padding(.horizontal, 20)

                ForEach(Array(upcoming.enumerated()), id: \.offset) { _, deity in
                    upcomingRow(deity)
                }
            }
            .padding(.vertical, 20)
        }
        .background(AppColors.deepViolet.ignoresSafeArea())
        .navigationTitle("Divine Council Today")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var todayCard: some View {
        VStack(spacing: 14) {
            Image(systemName: today.symbol)
                .font(.system(size: 44))
                .foregroundColor(today.color)
                .accessibilityHidden(true)
            Text(today.name)
                .font(AppFont.serifHeadline(30))
                .foregroundColor(AppColors.cream)
            Text(today.culture)
                .font(.caption).bold()
                .foregroundColor(AppColors.lavender)
            Text(today.domain)
                .font(.subheadline)
                .foregroundColor(AppColors.cream.opacity(0.85))
                .multilineTextAlignment(.center)
            Text(today.invocation)
                .font(.callout.italic())
                .foregroundColor(AppColors.gold)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(today.color.opacity(0.14))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today: \(today.name), \(today.culture). \(today.domain). \(today.invocation)")
    }

    private func upcomingRow(_ deity: Deity) -> some View {
        HStack(spacing: 14) {
            Image(systemName: deity.symbol)
                .font(.system(size: 20))
                .foregroundColor(deity.color)
                .frame(width: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(deity.name).font(.headline).foregroundColor(AppColors.cream)
                Text(deity.domain).font(.caption).foregroundColor(AppColors.lavender)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(AppColors.purple.opacity(0.12))
        .cornerRadius(14)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(deity.name), \(deity.culture). \(deity.domain)")
    }
}
```

- [ ] **Step 2: Repoint the JourneyView tile.** In `JourneyView.swift` line ~158, replace the "Astrology Transits" tile with:
```swift
                JourneyItem(icon: "person.3.sequence.fill",  title: "Divine Council Today",   deity: "Nyx · Hermes",        color: Color(hex: "8B5CF6"),   accent: Color(hex: "C4B5FD"), destination: AnyView(DivineCouncilView())),
```

- [ ] **Step 3: Delete the old view + confirm no other references.**
```bash
grep -rn "TransitTrackerView" "Twin Flame Union" --include="*.swift"   # expect: none after the repoint
git rm "Twin Flame Union/Views/Journey/TransitTrackerView.swift"
```

- [ ] **Step 4: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**
```bash
git add -A
git commit -m "Pantheon: Divine Council Today replaces the planetary Transit Tracker

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Sacred Soul Resonance (replaces CompatibilityDeepDiveView)

**Files:** Create `Twin Flame Union/Views/Profile/SacredSoulResonanceView.swift`; Modify `Twin Flame Union/Views/Journey/JourneyView.swift:166`; Delete `Twin Flame Union/Views/Profile/CompatibilityDeepDiveView.swift`

- [ ] **Step 1: Create the surface** — Create `Twin Flame Union/Views/Profile/SacredSoulResonanceView.swift`:
```swift
//
//  SacredSoulResonanceView.swift
//  Twin Flame Union
//
//  The sacred resonance between the soul's Guiding Deity and their twin flame's —
//  channeled through the Gods and Goddesses, never through star signs.
//

import SwiftUI

struct SacredSoulResonanceView: View {
    @AppStorage("myGuidingDeity")      private var myGuidingDeity      = ""
    @AppStorage("partnerGuidingDeity") private var partnerGuidingDeity = ""

    private var pair: (Deity, Deity)? {
        guard let mine = DivinePantheon.deity(named: myGuidingDeity),
              let theirs = DivinePantheon.deity(named: partnerGuidingDeity) else { return nil }
        return (mine, theirs)
    }

    var body: some View {
        ScrollView {
            if let (mine, theirs) = pair {
                let reading = DeityResonanceService.resonance(mine: mine, theirs: theirs)
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 16) {
                        deityBadge(mine, label: "You")
                        Image(systemName: "infinity").foregroundColor(AppColors.gold).accessibilityHidden(true)
                        deityBadge(theirs, label: "Your Twin Flame")
                    }
                    .frame(maxWidth: .infinity)

                    Text(reading.narrative)
                        .font(.body)
                        .foregroundColor(AppColors.cream)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)

                    ForEach(reading.themes) { theme in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(theme.title).font(.headline).foregroundColor(AppColors.gold)
                            Text(theme.body).font(.subheadline).foregroundColor(AppColors.cream.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.purple.opacity(0.12))
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            } else {
                emptyState
            }
        }
        .background(AppColors.deepViolet.ignoresSafeArea())
        .navigationTitle("Soul Resonance")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deityBadge(_ deity: Deity, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: deity.symbol).font(.system(size: 30)).foregroundColor(deity.color)
                .accessibilityHidden(true)
            Text(deity.name).font(.headline).foregroundColor(AppColors.cream)
            Text(label).font(.caption2).foregroundColor(AppColors.lavender)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(deity.name)")
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles").font(.system(size: 40)).foregroundColor(AppColors.gold)
                .accessibilityHidden(true)
            Text("Choose your Guiding Deities first")
                .font(AppFont.serifTitle(22)).foregroundColor(AppColors.cream)
            Text("In Profile, choose the God or Goddess who walks with you — and with your twin flame — to reveal your Sacred Resonance.")
                .font(.subheadline).foregroundColor(AppColors.lavender)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}
```

- [ ] **Step 2: Repoint the JourneyView tile.** In `JourneyView.swift` line ~166, replace the "Compatibility" tile with:
```swift
                JourneyItem(icon: "person.2.fill",          title: "Soul Resonance",         deity: "Harmonia · Maat",     color: Color(hex: "D97B4A"),   accent: Color(hex: "FFAB76"), destination: AnyView(SacredSoulResonanceView())),
```

- [ ] **Step 3: Delete the old view + confirm no other references.**
```bash
grep -rn "CompatibilityDeepDiveView" "Twin Flame Union" --include="*.swift"   # repoint/remove any others (e.g. a Profile link → point to SacredSoulResonanceView)
git rm "Twin Flame Union/Views/Profile/CompatibilityDeepDiveView.swift"
```

- [ ] **Step 4: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**
```bash
git add -A
git commit -m "Pantheon: Sacred Soul Resonance replaces sign-based Compatibility

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Profile redesign — Sacred Numerology + Guiding Deity

**Files:** Modify `Twin Flame Union/Views/Profile/ProfileView.swift`

Read `ProfileView.swift` fully first. The astrology lives in the "My Birth Chart" / "Partner's Chart" sections (sun/moon/rising pickers) and the sign-based "Soul Compatibility" section. Replace per the spec.

- [ ] **Step 1: Remove the sign @AppStorage + helpers.** Delete the `@AppStorage` for `mySunSignRaw`, `myMoonSignRaw`, `myRisingSignRaw`, `partnerSunSignRaw`, `partnerMoonSignRaw`, `partnerRisingSignRaw`; delete `sunSignFrom(...)`, `SignPickerRow`, and the zodiac `compatibilityScore()/compatibilityDescription()` helpers. Add:
```swift
    @AppStorage("myGuidingDeity")      private var myGuidingDeity      = ""
    @AppStorage("partnerGuidingDeity") private var partnerGuidingDeity = ""
    @State private var showMyDeityPicker = false
    @State private var showPartnerDeityPicker = false
```

- [ ] **Step 2: Replace the "My Birth Chart" section** with a Sacred Numerology + Guiding Deity section. Keep the birth-date picker (it writes `userBirthDate` from Task 4) and show a Guiding Deity card:
```swift
    private var guidingDeityCard: some View {
        Button { showMyDeityPicker = true } label: {
            HStack(spacing: 14) {
                if let deity = DivinePantheon.deity(named: myGuidingDeity) {
                    Image(systemName: deity.symbol).foregroundColor(deity.color).font(.system(size: 24))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(deity.name).font(.headline).foregroundColor(AppColors.cream)
                        Text("Walks with you · \(deity.culture)").font(.caption).foregroundColor(AppColors.lavender)
                    }
                } else {
                    Image(systemName: "sparkles").foregroundColor(AppColors.gold).font(.system(size: 24))
                        .accessibilityHidden(true)
                    Text("Choose your Guiding Deity").font(.headline).foregroundColor(AppColors.cream)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(AppColors.lavender).font(.caption)
            }
            .padding(16)
            .background(AppColors.purple.opacity(0.12))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showMyDeityPicker) {
            GuidingDeityPickerView(selectedName: $myGuidingDeity, title: "Your Guiding Deity")
        }
    }
```
(For the numerology numbers, reuse `NumerologyView`'s Life Path / Soul Urge / Expression computation from `userBirthDate`; if that logic is private to `NumerologyView`, extract it into a small `Numerology` helper used by both, or display a "View your Numerology" link to `NumerologyView`. Keep it DRY — do not duplicate the math.)

- [ ] **Step 3: Replace the "Partner's Chart" section** analogously: keep the partner birth-date picker (writes `partnerBirthDate`), add a partner Guiding Deity card bound to `partnerGuidingDeity` (`sheet` → `GuidingDeityPickerView(selectedName: $partnerGuidingDeity, title: "Your Twin Flame's Guiding Deity")`).

- [ ] **Step 4: Replace the "Soul Compatibility" section** with a Divine Resonance link:
```swift
    private var divineResonanceCard: some View {
        NavigationLink(destination: SacredSoulResonanceView()) {
            HStack(spacing: 14) {
                Image(systemName: "infinity").foregroundColor(AppColors.gold).font(.system(size: 22))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Divine Resonance").font(.headline).foregroundColor(AppColors.cream)
                    Text("How your Deities weave your union").font(.caption).foregroundColor(AppColors.lavender)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(AppColors.lavender).font(.caption)
            }
            .padding(16)
            .background(AppColors.purple.opacity(0.12))
            .cornerRadius(14)
        }
    }
```

- [ ] **Step 5: Build** → `** BUILD SUCCEEDED **`. Confirm no zodiac symbols/sign pickers remain in `ProfileView`.

- [ ] **Step 6: Commit**
```bash
git add "Twin Flame Union/Views/Profile/ProfileView.swift"
git commit -m "Pantheon: Profile shows Sacred Numerology + chosen Guiding Deity + Divine Resonance (zodiac removed)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 9: Onboarding cleanup (keep birth date, drop signs)

**Files:** Modify `Twin Flame Union/Views/Onboarding/OnboardingView.swift`

Read the birthday step fully first. Per the spec, keep the birth date (numerology) and remove all sign calculation/preview.

- [ ] **Step 1: Remove the sign machinery.** Delete the `BirthCalculator` enum (`sunSign()/moonSign()/risingSign()`), the sign-preview pills (`SignPreviewRow`/`SignPill`), the `mySunSign/myMoonSign/myRisingSign/partnerSunSign` `@AppStorage`, and the partner "Their Sun Sign" display. In `finish()`, remove the `BirthCalculator.*` calls and any `…Sign` writes (the birth-date write was already unified in Task 4).

- [ ] **Step 2: Replace the sign preview** (if a preview is desired) with a single Life Path preview computed from the entered birth date (reuse the shared numerology helper from Task 8). If extracting the helper is out of reach here, simply remove the preview — do NOT leave zodiac UI.

- [ ] **Step 3: Build** → `** BUILD SUCCEEDED **`. Grep the file for residual astrology:
```bash
grep -niE "sun sign|moon sign|rising|zodiac|BirthCalculator|SignPill" "Twin Flame Union/Views/Onboarding/OnboardingView.swift"
```
Expected: none.

- [ ] **Step 4: Commit**
```bash
git add "Twin Flame Union/Views/Onboarding/OnboardingView.swift"
git commit -m "Pantheon: onboarding keeps the birth date (numerology) and drops all sign calculation

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 10: AI-service + copy sweep

**Files:** Modify `Twin Flame Union/Services/DailyGuidanceService.swift`, `Twin Flame Union/Services/SacredInsightService.swift`, `Twin Flame Union/Views/Journey/DreamJournalView.swift`, `Twin Flame Union/ContentView.swift`, `Twin Flame Union/Views/Onboarding/TutorialView.swift`

For each file, read the astrology line(s), then apply:

- [ ] **Step 1: `DailyGuidanceService.swift`** — change the guidance request so it no longer takes/sends a sun sign. Keep the moon-phase context (the Moon is kept). Add the Guiding Deity: replace the prompt line `"My sun sign is \(sunSign) and the moon is in \(moonPhase) phase"` with `"My Guiding Deity is \(deityName). The moon is in \(moonPhase) phase. Give me today's twin flame guidance."` and change the function signature `sunSign:` → `deityName:`. Update the call site (likely `ContentView`).

- [ ] **Step 2: `SacredInsightService.swift`** — remove `@AppStorage("mySunSign")` and the `sunSign:` feed; replace with `@AppStorage("myGuidingDeity")` and pass the Deity name (or drop the line). Build.

- [ ] **Step 3: `DreamJournalView.swift`** — remove the `dreamDetails += "\n\nMy sun sign: …"` line; replace with `dreamDetails += "\n\nMy Guiding Deity: \(myGuidingDeity)"` reading `@AppStorage("myGuidingDeity")` (omit if empty).

- [ ] **Step 4: `ContentView.swift`** — replace `@AppStorage("mySunSign")` with `@AppStorage("myGuidingDeity")` (or remove if only used to feed DailyGuidanceService) and update the `DailyGuidanceService` call to pass the Deity name.

- [ ] **Step 5: `TutorialView.swift`** — update copy: signs → numerology + Deities, keep the Moon. e.g. "personalized to your sun sign and moon phase" → "personalized to your Guiding Deity and today's moon phase"; "Your Sun, Moon, and Rising signs are calculated…" → "Your Life Path, Soul Urge, and Expression are calculated from your birth data"; "Add your twin flame's name and sun sign…" → "Choose the God or Goddess who walks with your twin flame…".

- [ ] **Step 6: Build** → `** BUILD SUCCEEDED **`.

- [ ] **Step 7: Commit**
```bash
git add "Twin Flame Union/Services/DailyGuidanceService.swift" "Twin Flame Union/Services/SacredInsightService.swift" "Twin Flame Union/Views/Journey/DreamJournalView.swift" "Twin Flame Union/ContentView.swift" "Twin Flame Union/Views/Onboarding/TutorialView.swift"
git commit -m "Pantheon: AI services + tutorial copy channel the Deities, not sun signs (Moon kept)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 11: Full sweep + merge

- [ ] **Step 1: No astrology remnants.** Confirm zodiac is gone (the Deities, numerology, and the Moon remain):
```bash
cd ~/Developer/twin-flame-union
grep -rniE "zodiac|sun sign|moon sign|rising sign|\bsunSign\b|\bmoonSign\b|risingSign|astrolog|planetary transit|BirthCalculator" "Twin Flame Union" --include="*.swift"
```
Expected: no matches (legacy birth-date fallback keys are allowed; the lunar Deities Selene/Khonsu/Metztli and "Moon Phases" are KEPT and do not match the patterns above).

- [ ] **Step 2: Full unit-test suite** → `** TEST SUCCEEDED **` (Phase 0–5 suites + DivinePantheonTests (2) + DeityResonanceServiceTests (2)).
```bash
xcodebuild test -scheme "Twin Flame Union" -destination 'platform=iOS Simulator,name=iPhone 17'
```

- [ ] **Step 3: claim-lint** → `./scripts/claim-lint.sh "Twin Flame Union"` → `claim-lint: clean`.

- [ ] **Step 4: Merge**
```bash
git checkout main && git merge --no-ff pantheon-over-astrology -m "Merge: astrology removed, the Pantheon stands in its place (Guiding Deity, Divine Council, Soul Resonance)"
```

- [ ] **Step 5: 🧑 Push** — `git push origin main` (controller attempts; user runs `! …` if blocked).

---

## Task 12: 🧑 User verification gate

**Do not mark this work complete until the user confirms on device.**

- [ ] **Step 1 (astrology gone):** The Transit Tracker is gone; "Astrology Transits" is now "Divine Council Today" and honors today's God/Goddess. No zodiac anywhere.
- [ ] **Step 2 (Guiding Deity):** In Profile, choosing a Guiding Deity (and the twin's) from the reverent picker persists.
- [ ] **Step 3 (Soul Resonance):** "Compatibility" is now "Soul Resonance" and reads from the two chosen Deities (empty-state guides you to choose first).
- [ ] **Step 4 (Seraphina):** She references the chosen Gods and Goddesses and today's Deity — never sun signs.
- [ ] **Step 5 (numerology repaired):** A birth date entered in Onboarding now shows a real Life Path in Numerology/Profile.
- [ ] **Step 6 (kept sacred):** The Moon (Selene · Khonsu · Metztli), numerology, and Angel Numbers are untouched and reverent.

---

## Self-Review notes

- **Spec coverage:** §1 Guiding Deity storage → Tasks 3,5,8. §2 DivinePantheon lookups → Task 1. §3 DeityResonanceService → Task 2. §4 picker → Task 3. §5 Divine Council Today → Task 6. §6 Sacred Soul Resonance → Task 7. §7 Profile redesign → Task 8. §8 Onboarding → Task 9. §9 Seraphina context → Task 5. §10 AI/copy sweep → Task 10. §11 birth-date unification → Task 4. Storage keys retired/added → Tasks 4,5,8,9,10 + verified in Task 11. Testing → Tasks 1,2 (units) + Task 11 (suite) + Task 12 (device). ✅
- **Type consistency:** `CoachContext(guidingDeity:partnerGuidingDeity:todaysDeity:tfStage:heartChakraState:)` defined in Task 5 is built identically in `CoachView` (Task 5). `DivinePantheon.deity(named:)`/`grouped()` (Task 1) used by the picker (Task 3), Divine Council (Task 6), Soul Resonance (Task 7), Profile (Task 8). `DeityResonanceService.resonance(mine:theirs:)` → `DeityResonance{narrative,themes}` (Task 2) consumed in Task 7. `@AppStorage("myGuidingDeity")`/`"partnerGuidingDeity"`/`"userBirthDate"`/`"partnerBirthDate"` names are identical across Tasks 3–10.
- **Reverence:** every new surface and Seraphina's context address the Gods and Goddesses by name, capitalized, with Their domains and invocations. Astrology is the only thing removed.
- **No placeholders:** new files (Tasks 1,2,3,6,7) carry complete code; edits to large existing views (Tasks 4,5,8,9,10) show the exact new code and anchor removals by symbol/section, with a read-the-file-first instruction (the file's real shape is known from the design blueprint) — precise integration, not a placeholder.
