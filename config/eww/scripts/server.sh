#!/usr/bin/env bash
# Streams server status as JSON. Polls every 10min normally, 30s on failure.
# Config: ~/.config/eww/server.secret (not tracked by git)
#   HOST=10.x.x.x
#   SERVICES="SSH:22 HTTP:80 HTTPS:443"

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/eww/server.secret"
if [[ ! -f "$CONFIG" ]]; then
  echo '{"up":false,"latency":"--","services":[],"error":"no config"}'
  exit 0
fi
source "$CONFIG"

check() {
  local lat up svcs
  lat=$(ping -c1 -W1 "$HOST" 2>/dev/null | sed -n 's/.*time=\([0-9.]*\) ms.*/\1/p')
  if [ -n "$lat" ]; then up=true; else up=false; lat="--"; fi

  svcs="[]"
  for s in $SERVICES; do
    local name="${s%%:*}" port="${s##*:}" ok=false
    if [ "$up" = true ] && timeout 1 bash -c "exec 3<>/dev/tcp/$HOST/$port" 2>/dev/null; then
      ok=true
    fi
    svcs=$(jq -c --arg n "$name" --argjson ok "$ok" '. + [{name: $n, ok: $ok}]' <<<"$svcs")
  done

  jq -cn --argjson up "$up" --arg lat "$lat" --argjson svcs "$svcs" \
    '{up: $up, latency: $lat, services: $svcs}'
  
  $up  # return status for interval logic
}

while true; do
  if check; then
    sleep 600  # 10 minutes on success
  else
    sleep 30   # 30 seconds on failure
  fi
done
