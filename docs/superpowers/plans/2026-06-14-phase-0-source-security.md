# Phase 0 — Source of Truth + Security Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This is an **operational** plan (git / filesystem / edge-function), not a unit-test TDD plan — "verify" steps use shell/grep/git commands instead of a test runner, and the final functional verification is the **user building in Xcode**.

**Goal:** Consolidate Twin Flame Union into one safe git repo, remove the leaked Anthropic key from the app binary, and harden the Supabase `claude-proxy` so it can't be abused.

**Architecture:** Materialize and commit the build-10 working tree in the existing git repo (copy C), bundle the security code fixes into the same branch, push to GitHub, then relocate the canonical checkout to `~/Developer/twin-flame-union` (out of iCloud). Old copies are archived (not deleted) until the user confirms a clean Xcode build.

**Tech Stack:** Swift / SwiftUI (Xcode), Supabase Edge Functions (Deno/TypeScript), Postgres (rate-limit table), git + GitHub.

**Legend:** 🤖 = Claude executes here · 🧑 = user must execute (auth / Xcode / Supabase login).

**Paths:**
- Copy A (stale): `~/Downloads/Twin Flame Union`
- Copy B (newest materialized, flat): `~/Library/Mobile Documents/com~apple~CloudDocs/Twin Flame Union`
- Copy C (git repo, build source): `~/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union`
- Canonical (to create): `~/Developer/twin-flame-union`

---

## Task 1: Backup snapshot (non-destructive) 🤖

**Files:** Create `~/twin-flame-union-backup-2026-06-14/{A,B,C}.tgz`

- [ ] **Step 1: Create backup dir and tar all three copies**

```bash
mkdir -p ~/twin-flame-union-backup-2026-06-14
tar -czf ~/twin-flame-union-backup-2026-06-14/A-downloads.tgz   -C ~/Downloads "Twin Flame Union"
tar -czf ~/twin-flame-union-backup-2026-06-14/B-icloud-docs.tgz -C ~/Library/Mobile\ Documents/com~apple~CloudDocs "Twin Flame Union"
tar -czf ~/twin-flame-union-backup-2026-06-14/C-icloud-desktop.tgz -C ~/Library/Mobile\ Documents/com~apple~CloudDocs/Desktop "Twin Flame Union"
```

- [ ] **Step 2: Verify archives are non-empty and contain swift files**

```bash
for f in ~/twin-flame-union-backup-2026-06-14/*.tgz; do
  echo "$f -> $(tar -tzf "$f" | grep -c '\.swift$') swift files, $(du -h "$f" | cut -f1)"
done
```
Expected: A ≈ 95, B ≈ 82, C ≥ 7 swift files; each archive > 0 bytes. **Do not proceed if any archive is empty.**

---

## Task 2: Materialize copy C (the git repo) 🤖

**Files:** Modify (download) `~/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union/**`

- [ ] **Step 1: Force iCloud to download every placeholder in copy C**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
find "$C" -type f ! -name ".*" -exec cat {} > /dev/null \; 2>/dev/null
brctl download "$C" 2>/dev/null || true
```

- [ ] **Step 2: Wait + verify no placeholders remain**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
sleep 5
echo "remaining .icloud placeholders: $(find "$C" -name '*.icloud' | wc -l)"
echo "materialized swift files: $(find "$C" -name '*.swift' | wc -l)"
```
Expected: 0 placeholders; swift count ~90+ (main app + widgets + tests). If placeholders remain after a minute, **fallback**: those files will be sourced from copy B in Task 3.

- [ ] **Step 3: Inspect git status (informational, do not commit yet)**

```bash
cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
git status --short | head -40
git rev-parse --abbrev-ref HEAD   # expect: main (currently has the docs commit 033af34)
```

---

## Task 3: Reconcile build-10 working state into copy C 🤖

**Files:** Modify copy C source files from copy B where B is newer; verify build number = 10.

- [ ] **Step 1: Diff copy B (newest) against copy C main-app target, list differences**

```bash
B="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Twin Flame Union"
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union/Twin Flame Union"
cd "$B"
find . -name "*.swift" | while read -r rel; do
  if [ -f "$C/$rel" ]; then
    diff -q "$B/$rel" "$C/$rel" >/dev/null 2>&1 || echo "DIFFERS: $rel"
  else
    echo "MISSING-IN-C: $rel"
  fi
done
```

- [ ] **Step 2: Copy newer/missing files B → C (only the ones flagged in Step 1)**

For each `DIFFERS`/`MISSING-IN-C` path printed above, copy B's version into C's main target, e.g.:
```bash
B="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Twin Flame Union"
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union/Twin Flame Union"
cp "$B/Views/Settings/SettingsView.swift"      "$C/Views/Settings/SettingsView.swift"
cp "$B/Views/Journey/SolfeggioView.swift"      "$C/Views/Journey/SolfeggioView.swift"
cp "$B/Views/DailyRitualLockView.swift"        "$C/Views/DailyRitualLockView.swift"
cp "$B/Twin_Flame_UnionApp.swift"              "$C/Twin_Flame_UnionApp.swift"
# ...repeat for every path Step 1 flagged.
```

- [ ] **Step 3: Verify the build-10 invariants are present in C**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
echo "--- build number (expect 10) ---"
grep -m1 "CURRENT_PROJECT_VERSION" "$C/Twin Flame Union.xcodeproj/project.pbxproj"
echo "--- account deletion present? (expect >=1) ---"
grep -c "deleteAccount\|Delete Account\|deleteAllData" "$C/Twin Flame Union/Views/Settings/SettingsView.swift"
echo "--- privacy link is github.io (expect >=1) ---"
grep -c "iiprinceii.github.io" "$C/Twin Flame Union/Views/Settings/SettingsView.swift"
```
Expected: `CURRENT_PROJECT_VERSION = 10;`, account-deletion ≥ 1, github.io ≥ 1. If build number ≠ 10, set `CURRENT_PROJECT_VERSION = 10;` in all build configs of `project.pbxproj`.

---

## Task 4: Migrate DreamJournalView to the proxy 🤖

**Files:** Modify `Twin Flame Union/Views/Journey/DreamJournalView.swift`

- [ ] **Step 1: Replace the `do { … } catch { … }` body of `fetchInterpretation()` (lines 802–856)**

Replace from `let apiKey = try loadAPIKey()` through the `interpretation = text` / catch block with:
```swift
        do {
            let stage = stageNames[min(tfStageID, stageNames.count - 1)]

            var dreamDetails = "Dream title: \(entry.title)\n\nDream content: \(entry.content)"
            if !entry.symbols.isEmpty { dreamDetails += "\n\nSymbols present: \(entry.symbols)" }
            if !entry.people.isEmpty { dreamDetails += "\n\nWho appeared: \(entry.people)" }
            if !entry.wakeFeeling.isEmpty { dreamDetails += "\n\nFeeling on wake: \(entry.wakeFeeling)" }
            if entry.isLucid { dreamDetails += "\n\nThis was a lucid dream." }
            if entry.isTwinFlameDream { dreamDetails += "\n\nThe dreamer believes this was a twin flame dream." }
            dreamDetails += "\n\nMy sun sign: \(mySunSign.isEmpty ? "Unknown" : mySunSign)"
            dreamDetails += "\nMy twin flame stage: \(stage)"

            let userMessage = "Interpret this dream through the lens of Morpheus, Hypnos, and the twin flame journey. Be DIRECT. Tell me exactly what this dream means, which deity sent it, and what I need to DO about it.\n\n\(dreamDetails)"

            interpretation = try await ClaudeProxyService.send(
                model: "claude-haiku-4-5-20251001",
                maxTokens: 800,
                system: LoveCoachService.dreamInterpretationPrompt,
                messages: [.init(role: "user", content: userMessage)]
            )
        } catch {
            errorMessage = error.localizedDescription
        }
```

- [ ] **Step 2: Delete the now-dead `loadAPIKey()` (lines 859–869) and the unused `DreamInterpretError` enum**

Delete the entire `private func loadAPIKey() throws -> String { … }` and the `private enum DreamInterpretError: LocalizedError { … }` that follows the view (it was only thrown by the removed code).

- [ ] **Step 3: Verify no Anthropic-direct references remain in this file**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
grep -n "loadAPIKey\|api.anthropic.com\|x-api-key\|DreamInterpretError" "$C/Twin Flame Union/Views/Journey/DreamJournalView.swift" || echo "CLEAN"
```
Expected: `CLEAN`.

---

## Task 5: Delete dead key loaders + scrub key strings 🤖

**Files:** Modify `Twin Flame Union/Services/DailyGuidanceService.swift`, `Twin Flame Union/Services/LoveCoachService.swift`

- [ ] **Step 1: DailyGuidanceService — delete dead `loadAPIKey()` (lines 122–134)**

Delete:
```swift
    // kept for error type compatibility
    private func loadAPIKey() throws -> String {
        guard
            let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
            let config = NSDictionary(contentsOfFile: path),
            let key = config["ANTHROPIC_API_KEY"] as? String,
            !key.isEmpty,
            key != "YOUR_ANTHROPIC_API_KEY"
        else {
            throw DailyGuidanceError.missingAPIKey
        }
        return key
    }
```

- [ ] **Step 2: DailyGuidanceService — scrub the key mention in the error description (line 147)**

Change:
```swift
        case .missingAPIKey:
            return "Anthropic API key not configured. Add ANTHROPIC_API_KEY to Config.plist."
```
to:
```swift
        case .missingAPIKey:
            return "AI service is not configured."
```

- [ ] **Step 3: LoveCoachService — fix the stale header comment (line 6) and error string (line 423)**

Change line 6 `//  Reads ANTHROPIC_API_KEY from Config.plist.` to `//  All Claude calls route through ClaudeProxyService (Supabase Edge Function).`
Change line 423:
```swift
            return "Anthropic API key not configured. Add ANTHROPIC_API_KEY to Config.plist."
```
to:
```swift
            return "AI service is not configured."
```

- [ ] **Step 4: DailyGuidanceService — fix the header comment (line 8)**

Change `//  Reads ANTHROPIC_API_KEY from Config.plist.` to `//  All Claude calls route through ClaudeProxyService (Supabase Edge Function).`

---

## Task 6: Scrub Config.plist + repo-wide verification 🤖

**Files:** Modify `Twin Flame Union/Config.plist`

- [ ] **Step 1: Remove the ANTHROPIC_API_KEY entry from Config.plist**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
PLIST="$C/Twin Flame Union/Config.plist"
/usr/libexec/PlistBuddy -c "Delete :ANTHROPIC_API_KEY" "$PLIST" 2>/dev/null || echo "(key already absent)"
/usr/libexec/PlistBuddy -c "Print" "$PLIST"
```
Expected printout: only `SUPABASE_URL` and `SUPABASE_ANON_KEY` remain.

- [ ] **Step 2: Repo-wide verification — zero key references anywhere**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
grep -rn "ANTHROPIC_API_KEY\|api.anthropic.com\|x-api-key\|sk-ant-" "$C/Twin Flame Union" 2>/dev/null || echo "CLEAN — no key references in app source/bundle"
```
Expected: `CLEAN`.

---

## Task 7: Harden the edge function (non-breaking: allowlist + token cap + CORS) 🤖

**Files:** Modify `supabase/functions/claude-proxy/index.ts`

> These changes do NOT break the live build-10 app (native URLSession ignores CORS; the app already sends only allowed models and ≤1024 tokens).

- [ ] **Step 1: Replace `index.ts` with the hardened base (allowlist + clamp + CORS)**

```typescript
// claude-proxy — Edge Function
// Proxies Claude API calls so the Anthropic key never lives on the device.
// Requires ANTHROPIC_API_KEY set as a Supabase secret.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const ALLOWED_MODELS = new Set([
  "claude-haiku-4-5-20251001",
  "claude-sonnet-4-6",
]);
const MAX_TOKENS_CAP = 1500;

const CORS = {
  "Access-Control-Allow-Origin": "https://twinflameunion.app",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) return json({ error: "ANTHROPIC_API_KEY not configured" }, 500);

  let payload: any;
  try { payload = await req.json(); }
  catch { return json({ error: "Invalid JSON body" }, 400); }

  const { model, max_tokens, system, messages, stream } = payload ?? {};

  if (typeof model !== "string" || !ALLOWED_MODELS.has(model)) {
    return json({ error: "Model not allowed" }, 400);
  }
  if (!Array.isArray(messages) || messages.length === 0) {
    return json({ error: "messages required" }, 400);
  }
  const cappedTokens = Math.min(Number(max_tokens) || 300, MAX_TOKENS_CAP);

  const upstream = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({ model, max_tokens: cappedTokens, system, messages, stream: stream ?? false }),
  });

  return new Response(upstream.body, {
    status: upstream.status,
    headers: { ...CORS, "Content-Type": upstream.headers.get("Content-Type") ?? "application/json" },
  });
});
```

- [ ] **Step 2: Type-check locally (best effort)**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
deno check "$C/supabase/functions/claude-proxy/index.ts" 2>/dev/null || echo "(deno not installed — user verifies on deploy)"
```

---

## Task 8: Add per-IP rate limiting 🤖

**Files:** Create `supabase/migrations/20260614_proxy_rate_limit.sql`; Modify `supabase/functions/claude-proxy/index.ts`

- [ ] **Step 1: Create the rate-limit migration**

```sql
-- 20260614_proxy_rate_limit.sql
create table if not exists public.proxy_usage (
  id bigserial primary key,
  ip text not null,
  created_at timestamptz not null default now()
);
create index if not exists proxy_usage_ip_time on public.proxy_usage (ip, created_at desc);
alter table public.proxy_usage enable row level security;
-- No policies: only the service role (used by the edge function) may read/write.

-- Returns true if the IP is UNDER the limit (and records the hit), false if over.
create or replace function public.check_proxy_rate(p_ip text, p_per_min int default 20, p_per_day int default 300)
returns boolean
language plpgsql
security definer
as $$
declare
  min_count int;
  day_count int;
begin
  select count(*) into min_count from public.proxy_usage
    where ip = p_ip and created_at > now() - interval '1 minute';
  select count(*) into day_count from public.proxy_usage
    where ip = p_ip and created_at > now() - interval '1 day';
  if min_count >= p_per_min or day_count >= p_per_day then
    return false;
  end if;
  insert into public.proxy_usage (ip) values (p_ip);
  return true;
end;
$$;
```

- [ ] **Step 2: Call the limiter from `index.ts`**

Add this import at the top:
```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
```
Add this block after `const cappedTokens = …` and before the `upstream` fetch:
```typescript
  const ip = (req.headers.get("x-forwarded-for") ?? "unknown").split(",")[0].trim();
  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { data: underLimit, error: rlErr } = await admin.rpc("check_proxy_rate", { p_ip: ip });
  if (rlErr) {
    console.error("rate-limit check failed:", rlErr.message); // fail-open on infra error
  } else if (underLimit === false) {
    return json({ error: "Rate limit exceeded. Try again shortly." }, 429);
  }
```

- [ ] **Step 3: Type-check (best effort)**

```bash
C="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
deno check "$C/supabase/functions/claude-proxy/index.ts" 2>/dev/null || echo "(deno not installed — user verifies on deploy)"
```

> **Deferred (not Phase 0):** strict per-user JWT auth (`verify_jwt` + anonymous sign-in in the app). It must ship with an app-side change or it breaks build 10's anon-key calls. Allowlist + token cap + IP rate-limit give immediate non-breaking protection.

---

## Task 9: Commit the consolidated branch 🤖

- [ ] **Step 1: Create branch and stage real files (never blanket-add eviction deletions)**

```bash
cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
git checkout -b consolidate/build-10
git add "Twin Flame Union" "TFWidgets" "supabase" "Twin Flame Union.xcodeproj" 2>/dev/null
git status --short | head -40
```
Review the staged list. If any file shows as deleted (` D `) from un-materialized iCloud content, unstage it (`git restore --staged <path>`) and re-run Task 2 for it or copy from copy B.

- [ ] **Step 2: Commit**

```bash
cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
git commit -m "Phase 0: consolidate build 10 + remove bundled Anthropic key + harden claude-proxy

- DreamJournalView now routes through ClaudeProxyService (no direct api.anthropic.com call)
- Remove ANTHROPIC_API_KEY from Config.plist and delete dead key loaders
- claude-proxy: model allowlist, max_tokens cap, tightened CORS, per-IP rate limit

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git log --oneline -3
```

- [ ] **Step 3: 🧑 Push to GitHub** (needs the user's git credentials)

```bash
cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Desktop/Twin Flame Union"
git push -u origin consolidate/build-10
```
🤖 attempts this; if it fails on auth, the user runs it (`! git push -u origin consolidate/build-10`).

---

## Task 10: Relocate canonical checkout out of iCloud 🤖/🧑

- [ ] **Step 1: Clone from GitHub into ~/Developer (needs Task 9 pushed)**

```bash
mkdir -p ~/Developer
git clone https://github.com/IIprinceII/twin-flame-union.git ~/Developer/twin-flame-union
cd ~/Developer/twin-flame-union
git checkout consolidate/build-10
```

- [ ] **Step 2: Verify the relocated tree is real and complete**

```bash
cd ~/Developer/twin-flame-union
echo "tracked swift files: $(git ls-files '*.swift' | wc -l)"
echo "placeholders (expect 0): $(find . -name '*.icloud' | wc -l)"
grep -rn "ANTHROPIC_API_KEY\|api.anthropic.com" "Twin Flame Union" 2>/dev/null || echo "CLEAN"
grep -m1 "CURRENT_PROJECT_VERSION" "Twin Flame Union.xcodeproj/project.pbxproj"
```
Expected: swift ≥ ~90, 0 placeholders, `CLEAN`, build version 10.

---

## Task 11: 🧑 User verification gate

**Do not mark complete until the user confirms.**

- [ ] **Step 1:** Rotate/revoke the old `sk-ant-…` key at console.anthropic.com; set a spend cap. (Shipped in build 10 — treat as compromised.)
- [ ] **Step 2:** Deploy the function + migration:
```bash
cd ~/Developer/twin-flame-union
supabase db push                       # applies proxy_rate_limit migration
supabase functions deploy claude-proxy
```
- [ ] **Step 3:** Open `~/Developer/twin-flame-union/Twin Flame Union.xcodeproj` in Xcode, build to a device/simulator, smoke-test Seraphina chat, daily guidance, and **Dream Journal interpretation** (the migrated path). Confirm AI features still return text.

---

## Task 12: Finalize — archive old copies + merge to main 🤖 (after Task 11 passes)

- [ ] **Step 1: Archive the old copies (rename, do not delete)**

```bash
mv ~/Downloads/Twin\ Flame\ Union ~/Downloads/Twin\ Flame\ Union.ARCHIVED-2026-06-14
mv ~/Library/Mobile\ Documents/com~apple~CloudDocs/Twin\ Flame\ Union ~/Library/Mobile\ Documents/com~apple~CloudDocs/Twin\ Flame\ Union.ARCHIVED-2026-06-14
mv ~/Library/Mobile\ Documents/com~apple~CloudDocs/Desktop/Twin\ Flame\ Union ~/Library/Mobile\ Documents/com~apple~CloudDocs/Desktop/Twin\ Flame\ Union.ARCHIVED-2026-06-14
```

- [ ] **Step 2: Merge the branch to main and push**

```bash
cd ~/Developer/twin-flame-union
git checkout main && git merge --no-ff consolidate/build-10 -m "Merge Phase 0: consolidation + security"
git push origin main
```

- [ ] **Step 3: Add a canonical-path note to README**

Append to `~/Developer/twin-flame-union/README.md`:
```
## Canonical location
This repo at ~/Developer/twin-flame-union is the single source of truth.
Do not edit the old iCloud/Downloads copies (archived 2026-06-14).
```
Commit + push.

---

## Self-Review notes
- **Spec coverage:** Work item A → Tasks 1,2,3,9,10,12. Work item B → Tasks 4,5,6. Work item C → Tasks 7,8 (JWT explicitly deferred with rationale). User actions → Task 11. ✅
- **Deviation from spec (intentional):** spec ordered "relocate then edit"; plan edits in copy C first, then relocates via clone — safer (all work committed before the network/auth-dependent relocate), same acceptance criteria. Strict per-user JWT auth deferred to avoid breaking the in-review build 10.
- **No placeholders:** all edits show exact code; verifications use real commands with expected output.
