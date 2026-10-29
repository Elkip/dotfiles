#!/usr/bin/env bash
# Prints current weather as one JSON object. Needs: curl, jq.
# Leave LOCATION empty to auto-detect by IP, or set e.g. "Detroit" or "48201".
LOCATION="Pittsburgh"

fallback='{"icon":"❔","temp":"--","desc":"Unavailable","feels":"--","humidity":"--","wind":"--"}'

data=$(curl -sf --max-time 10 "https://wttr.in/${LOCATION// /+}?format=j1") || { echo "$fallback"; exit 0; }
code=$(jq -r '.current_condition[0].weatherCode' <<<"$data" 2>/dev/null)

case "$code" in
  113) icon="☀️" ;;
  116) icon="⛅" ;;
  119|122) icon="☁️" ;;
  143|248|260) icon="🌫️" ;;
  200|386|389|392|395) icon="⛈️" ;;
  176|263|266|293|296|299|302|305|308|353|356|359) icon="🌧️" ;;
  179|182|185|227|230|311|314|317|320|323|326|329|332|335|338|350|362|365|368|371|374|377) icon="🌨️" ;;
  *) icon="🌡️" ;;
esac

# Imperial units. For metric swap temp_F/FeelsLikeF/windspeedMiles
# for temp_C/FeelsLikeC/windspeedKmph (and change "mph" to "km/h" in eww.yuck).
jq -c --arg icon "$icon" '
  .current_condition[0] | {
    icon: $icon,
    temp: .temp_F,
    desc: .weatherDesc[0].value,
    feels: .FeelsLikeF,
    humidity: .humidity,
    wind: .windspeedMiles
  }' <<<"$data" 2>/dev/null || echo "$fallback"
