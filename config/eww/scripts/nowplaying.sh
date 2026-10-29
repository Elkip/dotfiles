#!/usr/bin/env bash
# Streams now-playing state as one JSON line per change (for eww deflisten).
# Needs: playerctl, jq, curl.

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/eww-art"
mkdir -p "$CACHE"
SEP=$'\x1f'

# Eww can only load local images, so remote art (Spotify, browsers) is cached.
art_path() {
  local url="$1" f
  case "$url" in
    file://*) printf '%s' "${url#file://}" ;;
    http*)
      f="$CACHE/$(printf '%s' "$url" | md5sum | cut -d' ' -f1)"
      if [ ! -s "$f" ]; then
        curl -sfL --max-time 10 -o "$f" "$url" || { rm -f "$f"; return; }
      fi
      printf '%s' "$f" ;;
  esac
}

emit() {
  jq -cn --arg status "$1" --arg artist "$2" --arg title "$3" --arg art "$4" \
    '{status: $status, artist: $artist, title: $title, art: $art}'
}

emit "Stopped" "" "Nothing playing" ""

while true; do
  playerctl --follow metadata \
    --format "{{status}}${SEP}{{artist}}${SEP}{{title}}${SEP}{{mpris:artUrl}}" 2>/dev/null |
  while IFS="$SEP" read -r status artist title url; do
    [ -z "$title" ] && title="Nothing playing"
    emit "$status" "$artist" "$title" "$(art_path "$url")"
  done

  # playerctl exits when the last player closes; reset and wait for the next one
  emit "Stopped" "" "Nothing playing" ""
  sleep 2
done
