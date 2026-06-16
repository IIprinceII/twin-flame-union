#!/bin/bash
# Fails if any forbidden health-claim / phantom-tier phrase reappears in the app source.
set -uo pipefail
ROOT="${1:-Twin Flame Union}"
DENY=(
  "Cellular Restoration"
  "Upgrade to Premium"
  "Premium feature"
  "carrying them to elimination organs"
  "shift your vibration in minutes"
  "directly influence the energy state of any structure in your body"
  "The blood/energy system will excrete"
)
fail=0
for phrase in "${DENY[@]}"; do
  if grep -rn --include="*.swift" -F "$phrase" "$ROOT" >/dev/null 2>&1; then
    echo "FORBIDDEN PHRASE FOUND: \"$phrase\""
    grep -rn --include="*.swift" -F "$phrase" "$ROOT"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "claim-lint: clean"
exit $fail
