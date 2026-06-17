#!/usr/bin/env bash
# SessionStart: anchor the hydration day when you begin/resume working.
# ensure_day is idempotent — it only resets on a genuine day rollover.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../scripts/hydration-lib.sh"

cat >/dev/null  # drain stdin (hook input JSON, unused)
kill_switch_on && exit 0  # kill switch → do nothing
has_config || exit 0
ensure_day
exit 0
