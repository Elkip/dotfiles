#!/usr/bin/env bash
# Checks unread mail count via IMAP (ProtonMail Bridge or other).
# Config in ~/.config/eww/server.secret:
#   IMAP_HOST=127.0.0.1
#   IMAP_PORT=1143
#   IMAP_USER=your-email@proton.me
#   IMAP_PASS=bridge-password

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/eww/server.secret"
[[ -f "$CONFIG" ]] && source "$CONFIG"

# Defaults for ProtonMail Bridge
IMAP_HOST="${IMAP_HOST:-127.0.0.1}"
IMAP_PORT="${IMAP_PORT:-1143}"

if [[ -z "$IMAP_USER" || -z "$IMAP_PASS" ]]; then
  echo '{"unread":0,"error":"no imap config"}'
  exit 0
fi

# IMAP requires CRLF line endings
CR=$'\r'

# Connect to IMAP and get UNSEEN count
RESPONSE=$(timeout 10 openssl s_client -connect "${IMAP_HOST}:${IMAP_PORT}" -starttls imap -quiet 2>/dev/null <<EOF
a LOGIN "$IMAP_USER" "$IMAP_PASS"${CR}
b STATUS INBOX (UNSEEN)${CR}
c LOGOUT${CR}
EOF
)

if [[ -z "$RESPONSE" ]]; then
  echo '{"unread":0,"error":"connection failed"}'
  exit 0
fi

# Check for login failure
if echo "$RESPONSE" | grep -qi "NO\|BAD.*LOGIN\|authentication failed"; then
  echo '{"unread":0,"error":"auth failed"}'
  exit 0
fi

# Parse UNSEEN count from response like: * STATUS "INBOX" (UNSEEN 5)
UNSEEN=$(echo "$RESPONSE" | grep -oP 'UNSEEN \K[0-9]+' | head -1)
UNSEEN="${UNSEEN:-0}"

echo "{\"unread\":${UNSEEN}}"
