# stay-hydrated 💧

A hydration coach for [Claude Code](https://claude.com/claude-code). It computes how
often you should drink water based on your daily goal and how many hours you use
Claude Code, nudges you when it's time, and **locks every tool until you confirm you
drank** — with up to 2 postpones before a hard lock.

## How it works

Claude Code hooks are event-driven, not a background timer — so reminders and locks
surface on your **next interaction** (when you send a prompt or Claude runs a tool).
That's the point: you can't keep working without hydrating.

- **`UserPromptSubmit` hook** → when the interval is due, injects a "drink water" nudge.
- **`PreToolUse` hook (all tools)** → once the 5-minute window expires, blocks every
  tool with exit code 2 until you confirm. The control commands are always whitelisted,
  so you can never soft-lock yourself.

The interval is `(hours_using_cc × 60) ÷ (daily_ml ÷ ml_per_glass)`.
Example: 3000 ml/day over 8 h with 250 ml glasses → 12 glasses → one every 40 min.

## Install

```bash
/plugin marketplace add <your-username>/stay-hydrated
/plugin install stay-hydrated
```

Or for local development, point a marketplace at this directory.

## Usage

```bash
/stay-hydrated setup 3000 8 250   # ml/day, hours/day on Claude Code, ml/glass
/stay-hydrated status             # where you are in the cycle
/stay-hydrated drank              # confirm you drank → unlock + restart timer
/stay-hydrated postpone           # buy +5 min (max 2x, then hard lock)
```

`setup` accepts extra tuning args: `setup <ml/day> <hours> <ml/glass> <grace_min> <max_postpones> <postpone_min>`.

## State

All state is global to you (not per-project), stored in `~/.stay-hydrated/`
(`config.json` + `state.json`). Override the location with `STAY_HYDRATED_HOME`.

## License

MIT
