#!/usr/bin/env bash
# Confirm hydration: reset the cycle and unlock.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

if ! has_config; then
  echo "stay-hydrated não está configurado. Rode: /stay-hydrated setup"
  exit 0
fi

INTERVAL_MIN=$(cfg interval_min 40)
PER_DRINK_ML=$(cfg per_drink_ml 250)
NEXT=$(( $(now) + INTERVAL_MIN * 60 ))
write_state next_due "$NEXT" reminded_at null grace_deadline null postpone_count 0 locked false

echo "💧 Boa! ${PER_DRINK_ML}ml registrados. Tools liberadas. Próximo lembrete em ${INTERVAL_MIN} min."
