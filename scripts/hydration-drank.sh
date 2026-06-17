#!/usr/bin/env bash
# Confirm hydration: count the glass, reset the cycle, unlock — or finish the day.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

if ! has_config; then
  echo "stay-hydrated não está configurado. Rode: /stay-hydrated:setup"
  exit 0
fi

ensure_day

INTERVAL_MIN=$(cfg interval_min 40)
NUM_DRINKS=$(cfg num_drinks 12)

if ! day_active; then
  echo "💧 Registrado, mas o dia de hidratação só começa às $(start_label) — fora disso não conto pra meta."
  exit 0
fi

DRANK=$(read_state drinks_today 0)
DRANK=$(( DRANK + 1 ))

if (( DRANK >= NUM_DRINKS )); then
  write_state drinks_today "$DRANK" goal_met true reminded_at null grace_deadline null postpone_count 0 locked false
  echo "🎉 Meta batida! ${DRANK}/${NUM_DRINKS} copos hoje. Sem mais lembretes até amanhã às $(start_label)."
else
  NEXT=$(( $(now) + INTERVAL_MIN * 60 ))
  write_state drinks_today "$DRANK" next_due "$NEXT" reminded_at null grace_deadline null postpone_count 0 locked false
  echo "💧 Boa! ${DRANK}/${NUM_DRINKS} copos hoje. Tools liberadas. Próximo lembrete em ${INTERVAL_MIN} min."
fi
