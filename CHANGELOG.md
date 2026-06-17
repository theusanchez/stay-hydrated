# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-17

### Added

- **Day lifecycle.** A fixed start time (`start_hour`/`start_minute`) defines when the
  hydration day begins; before it the plugin is silent. The day is anchored on the first
  interaction after the start time and by the `SessionStart` hook.
- **Daily goal.** Tracks glasses drunk per day (`ml_per_day ÷ ml_per_glass`). Once the
  goal is met, reminders and locks stop until the next day.
- **`HH:MM` start time.** `setup` now accepts a whole hour (`9`) or minutes (`8:30`).
- **Kill switch (fail-open).** Four independent ways to instantly restore normal Claude
  Code, even while a lock is active: `/stay-hydrated:off` (+ `/stay-hydrated:on`), the
  sentinel file `~/.stay-hydrated/DISABLED`, the env var `STAY_HYDRATED_OFF=1`, or
  disabling the plugin in `/plugin`.
- **Self-healing state.** Corrupt `state.json` is reset automatically on the next write.

### Changed

- The lock hook is now **fail-open**: any error, missing/corrupt state, or kill switch
  results in _allow_. It only blocks under one explicit, fully-checked condition.
- Adopted the official plugin layout (`.claude-plugin/plugin.json`) and added a
  `marketplace.json` so the repo is its own marketplace.
- Commands are namespaced under `stay-hydrated:` (e.g. `/stay-hydrated:drank`).
- User-facing wording: "glass/copo" instead of the misleading "sip/gole".

## [0.1.0] - 2026-06-17

### Added

- Initial release: hydration reminders on a computed interval, a `PreToolUse` tool lock
  (exit code 2) until you confirm you drank, up to 2 postpones before a hard lock, and
  the `setup` / `drank` / `postpone` / `status` commands.

[0.2.0]: https://github.com/theusanchez/stay-hydrated/releases/tag/v0.2.0
[0.1.0]: https://github.com/theusanchez/stay-hydrated/releases/tag/v0.1.0
