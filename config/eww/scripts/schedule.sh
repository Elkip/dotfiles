#!/usr/bin/env bash
# Fetches upcoming events from CalDAV and outputs JSON for eww.
# Config in ~/.config/eww/server.secret:
#   CALDAV_URL=http://10.x.x.x:8741/dav.php/calendars/user/default/
#   CALDAV_USER=username
#   CALDAV_PASS=password

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/eww/server.secret"
[[ -f "$CONFIG" ]] && source "$CONFIG"

if [[ -z "$CALDAV_URL" ]]; then
  echo '{"events":[]}'
  exit 0
fi

AUTH=""
[[ -n "$CALDAV_USER" ]] && AUTH="--digest -u ${CALDAV_USER}:${CALDAV_PASS}"

# Get base URL (without trailing slash for joining)
BASE_URL="${CALDAV_URL%/}"
BASE_URL="${BASE_URL%/default}/default"

# Get list of .ics files
ICS_LIST=$(curl -sf --max-time 10 $AUTH -X PROPFIND -H "Depth: 1" "$CALDAV_URL" 2>/dev/null | \
  grep -oE '/dav\.php/[^<]+\.ics' | sort -u)

if [[ -z "$ICS_LIST" ]]; then
  echo '{"events":[]}'
  exit 0
fi

# Date boundaries (seconds since epoch)
NOW=$(date +%s)
END_DATE=$(date -d "+7 days" +%s)

# Fetch all .ics files and extract events
EVENTS=""
while IFS= read -r ics_path; do
  [[ -z "$ics_path" ]] && continue
  
  # Build full URL
  ICS_URL="http://${CALDAV_URL#http://}"
  ICS_URL="${ICS_URL%%/dav.php/*}${ics_path}"
  
  # Fetch the .ics file
  ICAL=$(curl -sf --max-time 5 $AUTH "$ICS_URL" 2>/dev/null)
  [[ -z "$ICAL" ]] && continue
  
  # Parse VEVENT - extract SUMMARY and DTSTART
  EVENT=$(echo "$ICAL" | awk -v now="$NOW" -v end="$END_DATE" '
    BEGIN { in_event=0 }
    /^BEGIN:VEVENT/ { in_event=1; summary=""; dtstart=""; allday=0 }
    /^END:VEVENT/ {
      if (in_event && summary != "" && dtstart != "") {
        # Parse date - handle YYYYMMDD and YYYYMMDDTHHMMSSz formats
        gsub(/\r/, "", dtstart)
        if (length(dtstart) == 8) {
          # All day event: YYYYMMDD
          allday = 1
          cmd = "date -d \"" substr(dtstart,1,4) "-" substr(dtstart,5,2) "-" substr(dtstart,7,2) "\" +%s 2>/dev/null"
        } else {
          # Timed event: YYYYMMDDTHHMMSSz or YYYYMMDDTHHMMSS
          dt = dtstart
          gsub(/Z$/, "", dt)
          cmd = "date -d \"" substr(dt,1,4) "-" substr(dt,5,2) "-" substr(dt,7,2) "T" substr(dt,10,2) ":" substr(dt,12,2) ":" substr(dt,14,2) "\" +%s 2>/dev/null"
        }
        cmd | getline ts
        close(cmd)
        
        if (ts >= now && ts <= end) {
          gsub(/"/, "\\\"", summary)
          printf "{\"summary\":\"%s\",\"start\":\"%s\",\"allday\":%s}\n", summary, dtstart, (allday ? "true" : "false")
        }
      }
      in_event=0
    }
    in_event && /^SUMMARY/ {
      sub(/^SUMMARY[^:]*:/, "")
      gsub(/\r/, "")
      gsub(/\\,/, ",")
      gsub(/\\;/, ";")
      gsub(/\\n/, " ")
      summary = $0
    }
    in_event && /^DTSTART/ {
      sub(/^DTSTART[^:]*:/, "")
      gsub(/\r/, "")
      dtstart = $0
      if ($0 ~ /VALUE=DATE/ || length($0) == 8) allday = 1
    }
  ')
  
  [[ -n "$EVENT" ]] && EVENTS+="$EVENT"$'\n'
done <<< "$ICS_LIST"

# Convert to JSON array, sort, and format
if [[ -z "$EVENTS" ]]; then
  echo '{"events":[]}'
else
  echo "$EVENTS" | jq -sc '
    sort_by(.start) | .[0:8] | map({
      summary: .summary,
      allday: .allday,
      start: .start,
      time: (if .allday then "All day"
             elif (.start | length) == 8 then "All day"
             else (.start | capture("T(?<h>[0-9]{2})(?<m>[0-9]{2})") // null |
                   if . then
                     ((.h | tonumber) % 12 | if . == 0 then 12 else . end | tostring) + ":" + .m +
                     (if (.h | tonumber) >= 12 then " PM" else " AM" end)
                   else "All day" end)
             end),
      date: (.start | capture("(?<y>[0-9]{4})(?<m>[0-9]{2})(?<d>[0-9]{2})") // {m:"??",d:"??"} |
             .m + "/" + .d)
    }) | {events: .}
  ' 2>/dev/null || echo '{"events":[]}'
fi
