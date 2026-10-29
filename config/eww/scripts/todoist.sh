#!/usr/bin/env bash
# Fetches Todoist tasks from a specific project. Outputs JSON for eww.
# Config in ~/.config/eww/server.secret:
#   TODOIST_TOKEN=your-api-token
#   TODOIST_PROJECT=Personal

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/eww/server.secret"
[[ -f "$CONFIG" ]] && source "$CONFIG"

if [[ -z "$TODOIST_TOKEN" ]]; then
  echo '{"tasks":[],"project_id":null,"error":"no todoist config"}'
  exit 0
fi

PROJECT="${TODOIST_PROJECT:-Personal}"
API="https://api.todoist.com/api/v1"

# Get the project ID
PROJECTS=$(curl -sf --max-time 10 \
  -H "Authorization: Bearer $TODOIST_TOKEN" \
  "$API/projects" 2>/dev/null)

PROJECT_ID=$(echo "$PROJECTS" | jq -r --arg name "$PROJECT" '.results[] | select(.name == $name) | .id' 2>/dev/null)

if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
  echo '{"tasks":[],"project_id":null,"error":"project not found"}'
  exit 0
fi

# Fetch tasks for this project
TASKS=$(curl -sf --max-time 10 \
  -H "Authorization: Bearer $TODOIST_TOKEN" \
  "$API/tasks?project_id=$PROJECT_ID" 2>/dev/null)

if [[ -z "$TASKS" ]]; then
  echo "{\"tasks\":[],\"project_id\":\"$PROJECT_ID\",\"error\":\"fetch failed\"}"
  exit 0
fi

# Format tasks for display (v1 API returns {results: [...]})
echo "$TASKS" | jq -c --arg project_id "$PROJECT_ID" '
  {
    project_id: $project_id,
    tasks: (.results | sort_by(.due.date // "9999-99-99") | sort_by(-.priority) | .[0:10] | map({
      id: .id,
      content: .content,
      priority: .priority,
      due: (if .due then
              (if .due.datetime then
                (.due.datetime | split("T")[1] | split(":")[0:2] | join(":"))
              else
                .due.date
              end)
            else null end),
      overdue: (if .due.date then (.due.date < (now | strftime("%Y-%m-%d"))) else false end)
    }))
  }
' 2>/dev/null || echo "{\"tasks\":[],\"project_id\":\"$PROJECT_ID\"}"
