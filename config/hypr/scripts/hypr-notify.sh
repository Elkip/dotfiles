#!/usr/bin/env bash
# hypr-notify.sh
# Forward selected Hyprland events to notify-send so they show up in swaync
# (and in its notification history).
#
# Requires: socat, libnotify (notify-send), hyprctl. jq is optional (used to
# show the window title for urgent-window notifications).

set -u

APP_NAME="Hyprland"

# Set any of these to 0 to disable that notification type.
NOTIFY_CONFIG_RELOAD=1   # config reloaded / config errors
NOTIFY_MONITORS=1        # monitor connected / disconnected
NOTIFY_URGENT=1          # a window requested attention
NOTIFY_SCREENCAST=1      # screen sharing started / stopped

# --- sanity checks -----------------------------------------------------------

for cmd in socat notify-send hyprctl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "hypr-notify: '$cmd' is not installed" >&2
        exit 1
    fi
done

if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    echo "hypr-notify: HYPRLAND_INSTANCE_SIGNATURE is not set (not running under Hyprland?)" >&2
    exit 1
fi

# Newer Hyprland keeps the socket under $XDG_RUNTIME_DIR, older versions in /tmp.
SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
[[ -S "$SOCK" ]] || SOCK="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

if [[ ! -S "$SOCK" ]]; then
    echo "hypr-notify: could not find Hyprland event socket" >&2
    exit 1
fi

# --- helpers -----------------------------------------------------------------

# notify <urgency> <icon> <title> <body>
notify() {
    notify-send -a "$APP_NAME" -u "$1" -i "$2" "$3" "${4:-}"
}

handle_event() {
    local line=$1
    local event=${line%%>>*}
    local data=${line#*>>}

    case "$event" in
        configreloaded)
            [[ $NOTIFY_CONFIG_RELOAD -eq 1 ]] || return
            sleep 0.3   # give Hyprland a moment to populate the error list
            local errors
            errors=$(hyprctl configerrors 2>/dev/null | sed '/^[[:space:]]*$/d')
            if [[ -n "$errors" && "${errors,,}" != *"no errors"* ]]; then
                notify critical dialog-error "Hyprland config error" "$errors"
            else
                notify low preferences-system "Hyprland" "Config reloaded"
            fi
            ;;

        monitoradded)
            [[ $NOTIFY_MONITORS -eq 1 ]] || return
            notify low video-display "Monitor connected" "$data"
            ;;

        monitorremoved)
            [[ $NOTIFY_MONITORS -eq 1 ]] || return
            notify low video-display "Monitor disconnected" "$data"
            ;;

        urgent)
            [[ $NOTIFY_URGENT -eq 1 ]] || return
            local desc="A window needs your attention"
            if command -v jq >/dev/null 2>&1; then
                local info
                info=$(hyprctl clients -j 2>/dev/null |
                    jq -r --arg a "0x$data" \
                        '.[] | select(.address == $a) | "\(.class): \(.title)"')
                [[ -n "$info" ]] && desc=$info
            fi
            notify normal dialog-information "Window requests attention" "$desc"
            ;;

        screencast)
            [[ $NOTIFY_SCREENCAST -eq 1 ]] || return
            # data is "STATE,OWNER": STATE 1=started 0=stopped, OWNER 0=monitor 1=window
            local state=${data%%,*} owner=${data##*,} what="monitor"
            [[ "$owner" == "1" ]] && what="window"
            if [[ "$state" == "1" ]]; then
                notify normal camera-video "Screen sharing started" "Sharing a $what"
            else
                notify low camera-video "Screen sharing stopped" ""
            fi
            ;;
    esac
}

# --- main loop ---------------------------------------------------------------
# socat exits when Hyprland exits, which ends this script too.

socat -U - "UNIX-CONNECT:${SOCK}" | while IFS= read -r line; do
    handle_event "$line"
done
