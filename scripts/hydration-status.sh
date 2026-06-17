#!/usr/bin/env bash
# Show current hydration config and where we are in the cycle.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

if ! has_config; then
  echo "stay-hydrated não está configurado ainda."
  echo "Rode: /stay-hydrated setup <ml_por_dia> <horas_de_uso> [ml_por_gole]"
  echo "Ex.:  /stay-hydrated setup 3000 8 250"
  exit 0
fi

DAILY_ML=$(cfg daily_ml 3000)
CC_HOURS=$(cfg cc_hours 8)
PER_DRINK_ML=$(cfg per_drink_ml 250)
INTERVAL_MIN=$(cfg interval_min 40)
NUM_DRINKS=$(cfg num_drinks 12)
MAX=$(cfg max_postpones 2)

REMINDED=$(read_state reminded_at null)
NEXT_DUE=$(read_state next_due 0)
GRACE=$(read_state grace_deadline null)
COUNT=$(read_state postpone_count 0)

echo "💧 stay-hydrated"
echo "   Meta: ${DAILY_ML}ml/dia · ${NUM_DRINKS} goles de ${PER_DRINK_ML}ml em ${CC_HOURS}h · 1 gole a cada ${INTERVAL_MIN} min"
if [[ "$REMINDED" != "null" ]]; then
  if [[ "$GRACE" != "null" ]]; then
    LEFT=$(mins_ceil "$(secs_until "$GRACE")")
    echo "   ⏰ Lembrete ATIVO — beba ${PER_DRINK_ML}ml. ~${LEFT} min antes de travar. Adiamentos: ${COUNT}/${MAX}"
  fi
  echo "   Quando beber: /stay-hydrated drank"
else
  LEFT=$(mins_ceil "$(secs_until "$NEXT_DUE")")
  echo "   ✅ Em dia. Próximo lembrete em ~${LEFT} min."
fi
