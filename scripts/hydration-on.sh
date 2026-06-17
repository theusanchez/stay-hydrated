#!/usr/bin/env bash
# Re-enable stay-hydrated after a kill-switch /stay-hydrated:off.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

rm -f "$DISABLED_FILE"

if [[ -n "${STAY_HYDRATED_OFF:-}" ]]; then
  echo "✅ Sentinela removida, mas a variável STAY_HYDRATED_OFF ainda está setada nesta sessão."
  echo "   Saia dessa env (ou reinicie o Claude Code sem ela) para reativar de fato."
else
  echo "✅ stay-hydrated reativado. Lembretes voltam no próximo ciclo."
fi
