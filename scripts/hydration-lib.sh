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
