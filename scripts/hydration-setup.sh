#!/usr/bin/env bash
# Usage: hydration-setup.sh <daily_ml> <cc_hours> [per_drink_ml] [start_hour] [grace_min] [max_postpones] [postpone_min]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"
ensure_dir

DAILY_ML="${1:-3000}"
CC_HOURS="${2:-8}"
PER_DRINK_ML="${3:-250}"
START_RAW="${4:-9}"
GRACE_MIN="${5:-5}"
MAX_POSTPONES="${6:-2}"
POSTPONE_MIN="${7:-5}"

# start time accepts "9" or "8:30"
if [[ "$START_RAW" == *:* ]]; then
  START_HOUR="${START_RAW%%:*}"; START_MIN="${START_RAW##*:}"
else
  START_HOUR="$START_RAW"; START_MIN=0
fi
START_HOUR=$(( 10#${START_HOUR:-9} ))
START_MIN=$(( 10#${START_MIN:-0} ))
(( START_HOUR < 0 || START_HOUR > 23 )) && START_HOUR=9
(( START_MIN < 0 || START_MIN > 59 )) && START_MIN=0

# Drinks needed, then interval between them across the working window.
NUM_DRINKS=$(( (DAILY_ML + PER_DRINK_ML - 1) / PER_DRINK_ML ))
(( NUM_DRINKS < 1 )) && NUM_DRINKS=1
INTERVAL_MIN=$(( (CC_HOURS * 60) / NUM_DRINKS ))
(( INTERVAL_MIN < 1 )) && INTERVAL_MIN=1

jq -n \
  --argjson daily_ml "$DAILY_ML" \
  --argjson cc_hours "$CC_HOURS" \
  --argjson per_drink_ml "$PER_DRINK_ML" \
  --argjson start_hour "$START_HOUR" \
  --argjson start_minute "$START_MIN" \
  --argjson grace_min "$GRACE_MIN" \
  --argjson max_postpones "$MAX_POSTPONES" \
  --argjson postpone_min "$POSTPONE_MIN" \
  --argjson interval_min "$INTERVAL_MIN" \
  --argjson num_drinks "$NUM_DRINKS" \
  '{daily_ml:$daily_ml, cc_hours:$cc_hours, per_drink_ml:$per_drink_ml, start_hour:$start_hour, start_minute:$start_minute, grace_min:$grace_min, max_postpones:$max_postpones, postpone_min:$postpone_min, interval_min:$interval_min, num_drinks:$num_drinks}' \
  > "$CONFIG_FILE"

# Neutral state — the day activates on the first interaction after start_hour.
write_state day '"none"' drinks_today 0 goal_met false \
  next_due 0 reminded_at null grace_deadline null postpone_count 0 locked false

rm -f "$DISABLED_FILE"  # a fresh setup re-enables the plugin

echo "✅ stay-hydrated configurado."
echo "   Meta: ${DAILY_ML}ml/dia em ${CC_HOURS}h de uso → ${NUM_DRINKS} copos de ${PER_DRINK_ML}ml"
echo "   Início do dia: $(start_label) · 1 copo a cada ${INTERVAL_MIN} min"
echo "   Janela de ${GRACE_MIN} min · ${MAX_POSTPONES} adiamentos de ${POSTPONE_MIN} min"
ensure_day
if day_active; then
  echo "   Dia ativo — próximo lembrete em ${INTERVAL_MIN} min."
else
  echo "   Aguardando $(start_label) para começar a contar."
fi
echo "   🛑 Kill switch a qualquer momento: /stay-hydrated:off (ou desative em /plugin)."
