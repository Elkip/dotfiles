#!/usr/bin/env bash
# Completes a Todoist task and triggers eww refresh.
# Usage: todoist-complete.sh <task_id>

TASK_ID="$1"
if [[ -z "$TASK_ID" ]]; then
  echo "Usage: $0 <task_id>" >&2
  exit 1
fi

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/eww/server.secret"
[[ -f "$CONFIG" ]] && source "$CONFIG"

if [[ -z "$TODOIST_TOKEN" ]]; then
  notify-send -u critical "Todoist" "No API token configured"
  exit 1
fi

API="https://api.todoist.com/api/v1"

# Complete the task
RESPONSE=$(curl -sf --max-time 10 -X POST \
  -H "Authorization: Bearer $TODOIST_TOKEN" \
  "$API/tasks/${TASK_ID}/close" 2>&1)

if [[ $? -eq 0 ]]; then
  notify-send -t 2000 "Todoist" "Task completed ✓"
  eww update todoist="$(~/.config/eww/scripts/todoist.sh)" 2>/dev/null
else
  notify-send -u critical "Todoist" "Failed to complete task"
fi
