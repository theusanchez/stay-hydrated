#!/usr/bin/env bash
# Usage: hydration-setup.sh <daily_ml> <cc_hours> [per_drink_ml] [grace_min] [max_postpones] [postpone_min]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"
ensure_dir

DAILY_ML="${1:-3000}"
CC_HOURS="${2:-8}"
PER_DRINK_ML="${3:-250}"
GRACE_MIN="${4:-5}"
MAX_POSTPONES="${5:-2}"
POSTPONE_MIN="${6:-5}"

# Drinks needed, then interval between them across the working window.
NUM_DRINKS=$(( (DAILY_ML + PER_DRINK_ML - 1) / PER_DRINK_ML ))
(( NUM_DRINKS < 1 )) && NUM_DRINKS=1
INTERVAL_MIN=$(( (CC_HOURS * 60) / NUM_DRINKS ))
(( INTERVAL_MIN < 1 )) && INTERVAL_MIN=1

jq -n \
  --argjson daily_ml "$DAILY_ML" \
  --argjson cc_hours "$CC_HOURS" \
  --argjson per_drink_ml "$PER_DRINK_ML" \
  --argjson grace_min "$GRACE_MIN" \
  --argjson max_postpones "$MAX_POSTPONES" \
  --argjson postpone_min "$POSTPONE_MIN" \
  --argjson interval_min "$INTERVAL_MIN" \
  --argjson num_drinks "$NUM_DRINKS" \
  '{daily_ml:$daily_ml, cc_hours:$cc_hours, per_drink_ml:$per_drink_ml, grace_min:$grace_min, max_postpones:$max_postpones, postpone_min:$postpone_min, interval_min:$interval_min, num_drinks:$num_drinks}' \
  > "$CONFIG_FILE"

# Fresh state: first reminder one interval from now.
NEXT=$(( $(now) + INTERVAL_MIN * 60 ))
write_state next_due "$NEXT" reminded_at null grace_deadline null postpone_count 0 locked false

echo "✅ stay-hydrated configurado."
echo "   Meta: ${DAILY_ML}ml/dia em ${CC_HOURS}h de uso → ${NUM_DRINKS} copos de ${PER_DRINK_ML}ml"
echo "   Lembrete a cada ${INTERVAL_MIN} min · janela de ${GRACE_MIN} min · ${MAX_POSTPONES} adiamentos de ${POSTPONE_MIN} min"
echo "   Próximo lembrete em ${INTERVAL_MIN} min."
