#!/usr/bin/env bash
# PreToolUse (all tools): once the reminder grace window expires, block every
# tool with exit 2 until the user confirms hydration. The control scripts
# (drank/postpone/status/setup) are always whitelisted so the user can unlock.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../scripts/hydration-lib.sh"

INPUT=$(cat)
has_config || exit 0

# Whitelist: never block the hydration control scripts themselves.
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if echo "$CMD" | grep -qE 'hydration-(drank|postpone|status|setup)\.sh'; then
  exit 0
fi

ensure_day
day_active || exit 0    # before the day's start hour → never lock
goal_met && exit 0      # daily goal reached → never lock

REMINDED=$(read_state reminded_at null)
[[ "$REMINDED" == "null" ]] && exit 0

GRACE=$(read_state grace_deadline null)
[[ "$GRACE" == "null" ]] && exit 0

NOW=$(now)
(( NOW <= GRACE )) && exit 0   # still within the grace window — allow work

# Grace expired → lock.
PER_DRINK_ML=$(cfg per_drink_ml 250)
MAX=$(cfg max_postpones 2)
COUNT=$(read_state postpone_count 0)
write_state locked true

if (( COUNT >= MAX )); then
  echo "🔒 HIDRATAÇÃO OBRIGATÓRIA — sem mais adiamentos (${COUNT}/${MAX}). Beba ${PER_DRINK_ML}ml de água e rode /stay-hydrated:drank para liberar as tools." >&2
else
  LEFT=$(( MAX - COUNT ))
  echo "🔒 HORA DA ÁGUA — beba ${PER_DRINK_ML}ml e rode /stay-hydrated:drank. Ou /stay-hydrated:postpone para +tempo (restam ${LEFT} adiamento(s))." >&2
fi
exit 2
