#!/usr/bin/env bash
# Adds a new Todoist task to the configured project.

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/eww/server.secret"
[[ -f "$CONFIG" ]] && source "$CONFIG"

if [[ -z "$TODOIST_TOKEN" ]]; then
  notify-send -u critical "Todoist" "No API token configured"
  exit 1
fi

PROJECT="${TODOIST_PROJECT:-Personal}"
API="https://api.todoist.com/api/v1"

# Get project ID
PROJECT_ID=$(curl -sf --max-time 5 \
  -H "Authorization: Bearer $TODOIST_TOKEN" \
  "$API/projects" 2>/dev/null | \
  jq -r --arg name "$PROJECT" '.results[] | select(.name == $name) | .id')

if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
  notify-send -u critical "Todoist" "Project '$PROJECT' not found"
  exit 1
fi

# Prompt for task content
if command -v zenity &>/dev/null; then
  TASK=$(zenity --entry --title="New Task" --text="Add task to $PROJECT:" 2>/dev/null)
elif command -v rofi &>/dev/null; then
  TASK=$(rofi -dmenu -p "New task:" -l 0 2>/dev/null)
else
  TASK=$(kdialog --inputbox "Add task to $PROJECT:" 2>/dev/null)
fi

if [[ -z "$TASK" ]]; then
  exit 0  # User cancelled
fi

# Create the task
RESPONSE=$(curl -sf --max-time 10 -X POST \
  -H "Authorization: Bearer $TODOIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$TASK\", \"project_id\": \"$PROJECT_ID\"}" \
  "$API/tasks" 2>&1)

if [[ $? -eq 0 ]]; then
  notify-send -t 2000 "Todoist" "Task added ✓"
  eww update todoist="$(~/.config/eww/scripts/todoist.sh)" 2>/dev/null
else
  notify-send -u critical "Todoist" "Failed to add task"
fi
