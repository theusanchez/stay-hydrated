#!/usr/bin/env bash
# Re-enable stay-hydrated after a kill-switch /stay-hydrated:off.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"

rm -f "$DISABLED_FILE"

if [[ -n "${STAY_HYDRATED_OFF:-}" ]]; then
  echo "✅ Sentinel removed, but STAY_HYDRATED_OFF is still set in this session."
  echo "   Unset it (or restart Claude Code without it) to actually re-enable."
else
  echo "✅ stay-hydrated re-enabled. Reminders resume next cycle."
fi
