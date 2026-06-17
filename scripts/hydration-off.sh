#!/usr/bin/env bash
# KILL SWITCH: disable all reminders and locks immediately. Always safe to run,
# even while a lock is active (this command is whitelisted by the lock hook).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/hydration-lib.sh"
ensure_dir

touch "$DISABLED_FILE"
# Clear any lingering lock/reminder so nothing is left hanging.
write_state reminded_at null grace_deadline null locked false 2>/dev/null

echo "🛑 stay-hydrated is OFF. No reminders, no locks — normal Claude Code."
echo "   Re-enable anytime with /stay-hydrated:on."
