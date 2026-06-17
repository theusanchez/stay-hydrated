#!/usr/bin/env bash
# Show current hydration config and where we are in the day.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

if kill_switch_on; then
  echo "🛑 stay-hydrated is OFF (kill switch). No reminders, no locks."
  echo "   Re-enable with /stay-hydrated:on."
  exit 0
fi

if ! has_config; then
  echo "stay-hydrated isn't configured yet."
  echo "Run: /stay-hydrated:setup <ml_per_day> <hours_of_use> [ml_per_glass] [start_time]"
  echo "Ex.: /stay-hydrated:setup 3000 8 250 9"
  exit 0
fi

ensure_day

DAILY_ML=$(cfg daily_ml 3000)
CC_HOURS=$(cfg cc_hours 8)
PER_DRINK_ML=$(cfg per_drink_ml 250)
INTERVAL_MIN=$(cfg interval_min 40)
NUM_DRINKS=$(cfg num_drinks 12)
MAX=$(cfg max_postpones 2)
DRANK=$(read_state drinks_today 0)

echo "💧 stay-hydrated"
echo "   Goal: ${DAILY_ML}ml/day · ${NUM_DRINKS} glasses of ${PER_DRINK_ML}ml over ${CC_HOURS}h · starts $(start_label) · one glass every ${INTERVAL_MIN} min"

if ! day_active; then
  echo "   😴 Off hours — the day starts at $(start_label)."
  exit 0
fi

if goal_met; then
  echo "   🎉 Goal reached today: ${DRANK}/${NUM_DRINKS} glasses. No more reminders until tomorrow."
  exit 0
fi

echo "   Today's progress: ${DRANK}/${NUM_DRINKS} glasses"
REMINDED=$(read_state reminded_at null)
if [[ "$REMINDED" != "null" ]]; then
  GRACE=$(read_state grace_deadline null)
  COUNT=$(read_state postpone_count 0)
  if [[ "$GRACE" != "null" ]]; then
    LEFT=$(mins_ceil "$(secs_until "$GRACE")")
    echo "   ⏰ Reminder ACTIVE — drink ${PER_DRINK_ML}ml. ~${LEFT} min before lock. Postpones: ${COUNT}/${MAX}"
  fi
  echo "   When you drink: /stay-hydrated:drank"
else
  NEXT_DUE=$(read_state next_due 0)
  LEFT=$(mins_ceil "$(secs_until "$NEXT_DUE")")
  echo "   ✅ On track. Next reminder in ~${LEFT} min."
fi
echo "   🛑 Turn it all off: /stay-hydrated:off"
