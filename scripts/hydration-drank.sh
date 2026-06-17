#!/usr/bin/env bash
# Confirm hydration: count the glass, reset the cycle, unlock — or finish the day.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

if ! has_config; then
  echo "stay-hydrated isn't configured yet. Run: /stay-hydrated:setup"
  exit 0
fi

ensure_day

INTERVAL_MIN=$(cfg interval_min 40)
NUM_DRINKS=$(cfg num_drinks 12)

if ! day_active; then
  echo "💧 Noted, but the hydration day only starts at $(start_label) — outside that it doesn't count toward your goal."
  exit 0
fi

DRANK=$(read_state drinks_today 0)
DRANK=$(( DRANK + 1 ))

if (( DRANK >= NUM_DRINKS )); then
  write_state drinks_today "$DRANK" goal_met true reminded_at null grace_deadline null postpone_count 0 locked false
  echo "🎉 Goal reached! ${DRANK}/${NUM_DRINKS} glasses today. No more reminders until tomorrow at $(start_label)."
else
  NEXT=$(( $(now) + INTERVAL_MIN * 60 ))
  write_state drinks_today "$DRANK" next_due "$NEXT" reminded_at null grace_deadline null postpone_count 0 locked false
  echo "💧 Nice! ${DRANK}/${NUM_DRINKS} glasses today. Tools unlocked. Next reminder in ${INTERVAL_MIN} min."
fi
