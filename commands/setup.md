---
description: Configure your hydration goal — daily ml, hours/day on Claude Code, ml per glass, start hour
argument-hint: "<ml_per_day> <hours_per_day> [ml_per_glass] [start_hour]"
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*)
---

Run `${CLAUDE_PLUGIN_ROOT}/scripts/hydration-setup.sh` with these arguments: `$ARGUMENTS`.

The args are: `<ml_per_day> <hours_per_day> [ml_per_glass] [start_hour]` (glass defaults to 250ml, start_hour to 9).
If the user gave no numbers, ask them: how many ml/day is your goal, how many hours/day do you use Claude Code, ml per glass (default 250), and what hour your day starts (default 9) — then run the script.

Show the script output to the user verbatim.
