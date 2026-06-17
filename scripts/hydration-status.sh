#!/usr/bin/env bash
# Show current hydration config and where we are in the day.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

if kill_switch_on; then
  echo "🛑 stay-hydrated está DESLIGADO (kill switch). Sem lembretes nem travas."
  echo "   Reative com /stay-hydrated:on."
  exit 0
fi

if ! has_config; then
  echo "stay-hydrated não está configurado ainda."
  echo "Rode: /stay-hydrated:setup <ml_por_dia> <horas_de_uso> [ml_por_copo] [hora_inicio]"
  echo "Ex.:  /stay-hydrated:setup 3000 8 250 9"
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
echo "   Meta: ${DAILY_ML}ml/dia · ${NUM_DRINKS} copos de ${PER_DRINK_ML}ml em ${CC_HOURS}h · início $(start_label) · 1 copo a cada ${INTERVAL_MIN} min"

if ! day_active; then
  echo "   😴 Fora do horário — o dia começa às $(start_label)."
  exit 0
fi

if goal_met; then
  echo "   🎉 Meta batida hoje: ${DRANK}/${NUM_DRINKS} copos. Sem mais lembretes até amanhã."
  exit 0
fi

echo "   Progresso de hoje: ${DRANK}/${NUM_DRINKS} copos"
REMINDED=$(read_state reminded_at null)
if [[ "$REMINDED" != "null" ]]; then
  GRACE=$(read_state grace_deadline null)
  COUNT=$(read_state postpone_count 0)
  if [[ "$GRACE" != "null" ]]; then
    LEFT=$(mins_ceil "$(secs_until "$GRACE")")
    echo "   ⏰ Lembrete ATIVO — beba ${PER_DRINK_ML}ml. ~${LEFT} min antes de travar. Adiamentos: ${COUNT}/${MAX}"
  fi
  echo "   Quando beber: /stay-hydrated:drank"
else
  NEXT_DUE=$(read_state next_due 0)
  LEFT=$(mins_ceil "$(secs_until "$NEXT_DUE")")
  echo "   ✅ Em dia. Próximo lembrete em ~${LEFT} min."
fi
echo "   🛑 Desligar tudo: /stay-hydrated:off"
