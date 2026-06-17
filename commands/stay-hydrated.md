---
description: Hydration coach — setup goals, confirm you drank, postpone, or check status
argument-hint: "[setup <ml_dia> <horas> [ml_gole]] | drank | postpone | status"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*)
---

Run the matching stay-hydrated control script and show its output to the user verbatim. Do not add commentary.

Arguments: `$ARGUMENTS`

Routing:

- starts with `setup` → run `${CLAUDE_PLUGIN_ROOT}/scripts/hydration-setup.sh` with the remaining args (ml_per_day cc_hours [ml_per_drink]). If the user gave no numbers, ask them: how many ml/day, how many hours/day do you use Claude Code, and ml per sip (default 250).
- `drank` → run `${CLAUDE_PLUGIN_ROOT}/scripts/hydration-drank.sh`
- `postpone` → run `${CLAUDE_PLUGIN_ROOT}/scripts/hydration-postpone.sh`
- `status` or empty → run `${CLAUDE_PLUGIN_ROOT}/scripts/hydration-status.sh`
