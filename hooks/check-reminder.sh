#!/usr/bin/env bash
# UserPromptSubmit: when the interval is due, start a reminder window and
# inject a visible nudge into context. Never blocks the prompt itself.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../scripts/hydration-lib.sh"

cat >/dev/null  # drain stdin (hook input JSON, unused)

kill_switch_on && exit 0  # kill switch → stay silent
has_config || exit 0
ensure_day
day_active || exit 0    # before the day's start hour → stay silent
goal_met && exit 0      # daily goal reached → done until tomorrow

PER_DRINK_ML=$(cfg per_drink_ml 250)
GRACE_MIN=$(cfg grace_min 5)
MAX=$(cfg max_postpones 2)

NOW=$(now)
REMINDED=$(read_state reminded_at null)
NEXT_DUE=$(read_state next_due 0)
COUNT=$(read_state postpone_count 0)

inject() { jq -n --arg c "$1" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit", additionalContext:$c}}'; }

ESC="To turn the whole thing off: /stay-hydrated:off (or disable the plugin in /plugin)."

if [[ "$REMINDED" != "null" ]]; then
  # Reminder already active — keep surfacing it until resolved.
  inject "💧 HYDRATION PENDING: tell the user to drink ${PER_DRINK_ML}ml of water now. They unlock with /stay-hydrated:drank (or /stay-hydrated:postpone, ${COUNT}/${MAX} used). ${ESC} Surface this clearly before answering."
  exit 0
fi

if (( NOW >= NEXT_DUE )); then
  GRACE_DEADLINE=$(( NOW + GRACE_MIN * 60 ))
  write_state reminded_at "$NOW" grace_deadline "$GRACE_DEADLINE" postpone_count 0 locked false
  inject "💧 TIME TO HYDRATE: tell the user to drink ${PER_DRINK_ML}ml of water within ${GRACE_MIN} min. After that, tools lock until they run /stay-hydrated:drank. They may /stay-hydrated:postpone up to ${MAX}x. ${ESC} Surface this clearly before answering."
  exit 0
fi

exit 0
