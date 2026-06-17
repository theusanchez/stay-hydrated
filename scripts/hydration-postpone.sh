#!/usr/bin/env bash
# Postpone an active reminder, up to max_postpones times.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

if ! has_config; then
  echo "stay-hydrated não está configurado. Rode: /stay-hydrated setup"
  exit 0
fi

REMINDED=$(read_state reminded_at null)
if [[ "$REMINDED" == "null" ]]; then
  echo "Nada pra adiar — nenhum lembrete ativo agora. 💧"
  exit 0
fi

MAX=$(cfg max_postpones 2)
POSTPONE_MIN=$(cfg postpone_min 5)
COUNT=$(read_state postpone_count 0)

if (( COUNT >= MAX )); then
  echo "🚫 Sem mais adiamentos (${COUNT}/${MAX}). Beba água e rode: /stay-hydrated drank"
  exit 0
fi

COUNT=$(( COUNT + 1 ))
NEW_GRACE=$(( $(now) + POSTPONE_MIN * 60 ))
write_state postpone_count "$COUNT" grace_deadline "$NEW_GRACE" locked false
LEFT=$(( MAX - COUNT ))
echo "⏳ Adiado +${POSTPONE_MIN} min (${COUNT}/${MAX}). Restam ${LEFT} adiamento(s) antes do bloqueio."
