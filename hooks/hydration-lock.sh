#!/usr/bin/env bash
# PreToolUse (all tools): blocks tools only when a hydration reminder's grace
# window has expired.
#
# FAIL-OPEN BY DESIGN: any error, missing/corrupt state, or kill switch results
# in exit 0 (allow). This hook must NEVER be able to trap the user — exit 2 only
# happens at the very end, under one explicit, fully-checked condition.
#
# KILL SWITCH — any ONE of these instantly restores normal Claude Code:
#   • /stay-hydrated:off                         (works even while locked)
#   • touch ~/.stay-hydrated/DISABLED            (whitelisted, works while locked)
#   • relaunch Claude Code with STAY_HYDRATED_OFF=1
#   • disable or remove the plugin in /plugin    (slash commands bypass this lock)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../scripts/hydration-lib.sh" 2>/dev/null || exit 0

INPUT=$(cat)

kill_switch_on && exit 0        # kill switch → never lock
has_config || exit 0

# Whitelist: never block hydration control commands or the kill switch itself.
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if echo "$CMD" | grep -qE 'hydration-(drank|postpone|status|setup|off|on)\.sh|stay-hydrated/DISABLED|STAY_HYDRATED_OFF'; then
  exit 0
fi

ensure_day 2>/dev/null
day_active || exit 0            # before the day's start time → never lock
goal_met && exit 0             # daily goal reached → never lock

REMINDED=$(read_state reminded_at null)
[[ "$REMINDED" == "null" ]] && exit 0
GRACE=$(read_state grace_deadline null)
[[ "$GRACE" == "null" ]] && exit 0
NOW=$(now)
(( NOW <= GRACE )) && exit 0    # still within the grace window → allow work

# Grace expired → lock (the only path that returns exit 2).
PER_DRINK_ML=$(cfg per_drink_ml 250)
MAX=$(cfg max_postpones 2)
COUNT=$(read_state postpone_count 0)
write_state locked true 2>/dev/null

ESC="Travou e não devia? /stay-hydrated:off desliga tudo (ou desative o plugin em /plugin)."
if (( COUNT >= MAX )); then
  echo "🔒 HIDRATAÇÃO OBRIGATÓRIA — sem mais adiamentos (${COUNT}/${MAX}). Beba ${PER_DRINK_ML}ml e rode /stay-hydrated:drank. ${ESC}" >&2
else
  LEFT=$(( MAX - COUNT ))
  echo "🔒 HORA DA ÁGUA — beba ${PER_DRINK_ML}ml e rode /stay-hydrated:drank (ou /stay-hydrated:postpone, restam ${LEFT}). ${ESC}" >&2
fi
exit 2
