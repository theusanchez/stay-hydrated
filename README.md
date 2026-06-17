# stay-hydrated 💧

A hydration coach for [Claude Code](https://claude.com/claude-code). It computes how
often you should drink water based on your daily goal and how many hours you use
Claude Code, nudges you when it's time, and **locks every tool until you confirm you
drank** — with up to 2 postpones before a hard lock.

## 🛑 Kill switch (read this first)

This plugin can block tools, so it ships with multiple independent escape hatches.
**Any one of them instantly restores normal Claude Code** — even while a lock is active:

| Escape        | How                                                                    |
| ------------- | ---------------------------------------------------------------------- |
| Turn it off   | `/stay-hydrated:off` (re-enable later with `/stay-hydrated:on`)        |
| Sentinel file | `touch ~/.stay-hydrated/DISABLED` (whitelisted, works while locked)    |
| Env var       | relaunch with `STAY_HYDRATED_OFF=1`                                    |
| Remove it     | disable/uninstall in `/plugin` — slash commands always bypass the lock |

The lock hook is **fail-open**: any error, missing or corrupt state, or kill switch
results in _allow_. It only ever blocks under one explicit, fully-checked condition.
A bug cannot permanently trap you.

## How it works

Claude Code hooks are event-driven, not a background timer — so reminders and locks
surface on your **next interaction** (when you send a prompt or Claude runs a tool).
That's the point: you can't keep working without hydrating.

- **`SessionStart` hook** → anchors the hydration day when you begin/resume working.
- **`UserPromptSubmit` hook** → when the interval is due, injects a "drink water" nudge.
- **`PreToolUse` hook (all tools)** → once the 5-minute window expires, blocks every
  tool with exit code 2 until you confirm. The control commands are always whitelisted,
  so you can never soft-lock yourself.

The interval is `(hours_using_cc × 60) ÷ (daily_ml ÷ ml_per_glass)`.
Example: 3000 ml/day over 8 h with 250 ml glasses → 12 glasses → one every 40 min.

### When the day starts and ends

- **Start** — you set a fixed `start_hour` (default 9). Before that hour the plugin is
  silent. The first interaction after it begins the day: the counter resets and the
  first reminder is anchored one interval later.
- **End** — once you've had your `daily_ml ÷ ml_per_glass` glasses, the goal is met and
  the plugin goes quiet (and never locks) until the next day's start hour.
- Because hooks only fire on interaction, closing Claude Code naturally pauses the timer;
  reopening it resumes (or rolls over to a fresh day).

## Install

```bash
/plugin marketplace add theusanchez/stay-hydrated
/plugin install stay-hydrated@stay-hydrated
```

For local development, load it directly without installing:

```bash
claude --plugin-dir ./stay-hydrated
```

## Usage

Plugin commands are namespaced under `stay-hydrated:`:

```bash
/stay-hydrated:setup 3000 8 250 8:30   # ml/day, hours/day on CC, ml/glass, start time
/stay-hydrated:status                  # progress + where you are in the day
/stay-hydrated:drank                   # confirm you drank → unlock + count the glass
/stay-hydrated:postpone                # buy +5 min (max 2x, then hard lock)
/stay-hydrated:off                     # kill switch — disable reminders and locks
/stay-hydrated:on                      # re-enable after :off
```

The start time accepts a whole hour (`9`) or `HH:MM` (`8:30`).

`setup` full signature: `setup <ml/day> <hours> <ml/glass> <start_time> <grace_min> <max_postpones> <postpone_min>`
(only the first two are required; the rest default to `250 9 5 2 5`).

## State

All state is global to you (not per-project), stored in `~/.stay-hydrated/`
(`config.json` + `state.json`). Override the location with `STAY_HYDRATED_HOME`.

## License

MIT
