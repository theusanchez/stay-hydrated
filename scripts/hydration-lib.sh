#!/usr/bin/env bash
# Shared helpers + state model for stay-hydrated.
# State lives in $HOME/.stay-hydrated so it is global across projects/sessions.

STATE_DIR="${STAY_HYDRATED_HOME:-$HOME/.stay-hydrated}"
CONFIG_FILE="$STATE_DIR/config.json"
STATE_FILE="$STATE_DIR/state.json"

now() { date +%s; }

ensure_dir() { mkdir -p "$STATE_DIR"; }

has_config() { [[ -f "$CONFIG_FILE" ]]; }

cfg() { # cfg <key> <default>
  if has_config; then
    local v; v=$(jq -r --arg k "$1" '.[$k] // empty' "$CONFIG_FILE")
    [[ -n "$v" ]] && { echo "$v"; return; }
  fi
  echo "$2"
}

read_state() { # read_state <key> <default>
  if [[ -f "$STATE_FILE" ]]; then
    local v; v=$(jq -r --arg k "$1" '.[$k] // empty' "$STATE_FILE")
    [[ -n "$v" ]] && { echo "$v"; return; }
  fi
  echo "$2"
}

# write_state key1 val1 key2 val2 ...  (vals written as raw JSON; quote strings yourself)
write_state() {
  ensure_dir
  [[ -f "$STATE_FILE" ]] || echo '{}' > "$STATE_FILE"
  local filter='.' ; local args=()
  local i=1
  while [[ $# -gt 0 ]]; do
    local k="$1"; local val="$2"; shift 2
    filter+=" | .[\$k${i}] = (\$v${i} | fromjson)"
    args+=(--arg "k${i}" "$k" --arg "v${i}" "$val")
    i=$((i+1))
  done
  local tmp; tmp=$(mktemp)
  jq "${args[@]}" "$filter" "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
}

# Minutes/seconds left until an epoch (floored, never negative)
secs_until() { local t=$1; local n; n=$(now); local d=$(( t - n )); (( d < 0 )) && d=0; echo "$d"; }
mins_ceil() { local s=$1; echo $(( (s + 59) / 60 )); }

today_str() { date +%Y-%m-%d; }

# Epoch of today's configured start hour (portable: no `date -d`).
start_epoch() {
  local sh; sh=$(cfg start_hour 9)
  local n; n=$(now)
  local H M S secs mid
  H=$(date +%H); M=$(date +%M); S=$(date +%S)
  secs=$(( 10#$H * 3600 + 10#$M * 60 + 10#$S ))
  mid=$(( n - secs ))
  echo $(( mid + sh * 3600 ))
}

# The hydration day is active between today's start hour and the next day's.
# Reminders only fire while active; before the start hour we stay silent.
day_active() {
  local n start today day
  n=$(now); start=$(start_epoch); today=$(today_str)
  day=$(read_state day none)
  (( n >= start )) && [[ "$day" == "$today" ]]
}

goal_met() { [[ "$(read_state goal_met false)" == "true" ]]; }

# Roll the day over: deactivate before the start hour, and start a fresh cycle
# (reset counter, re-anchor next reminder) on the first activity after it.
# Idempotent — safe to call from every hook.
ensure_day() {
  has_config || return 0
  local n start today day interval next
  n=$(now); start=$(start_epoch); today=$(today_str)
  day=$(read_state day none)
  interval=$(cfg interval_min 40)

  if (( n < start )); then
    # Before today's start hour: yesterday's day is over.
    if [[ "$day" != "none" && "$day" < "$today" ]]; then
      write_state day '"none"' reminded_at null grace_deadline null locked false
    fi
    return 0
  fi

  # At/after the start hour → today should be the active day.
  if [[ "$day" != "$today" ]]; then
    next=$(( n + interval * 60 ))
    write_state day "\"$today\"" drinks_today 0 goal_met false \
      next_due "$next" reminded_at null grace_deadline null postpone_count 0 locked false
  fi
}
