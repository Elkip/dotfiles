#!/usr/bin/env bash
# Randomly selects a qylock theme on boot

THEMES_DIR="$HOME/Downloads/qylock/themes"
CONFIG_DIR="$HOME/.config/qylock"
CONFIG_FILE="$CONFIG_DIR/theme"

# Get list of themes (excluding subdirs like clockwork/orbital)
mapfile -t THEMES < <(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

if [[ ${#THEMES[@]} -eq 0 ]]; then
    echo "No themes found in $THEMES_DIR"
    exit 1
fi

# Pick a random theme
RANDOM_THEME="${THEMES[RANDOM % ${#THEMES[@]}]}"

# Handle themes with variants (clockwork, etc.)
if [[ -d "$THEMES_DIR/$RANDOM_THEME" ]] && [[ ! -f "$THEMES_DIR/$RANDOM_THEME/Main.qml" ]]; then
    # Theme has subdirectories (variants), pick one
    mapfile -t VARIANTS < <(find "$THEMES_DIR/$RANDOM_THEME" -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
    if [[ ${#VARIANTS[@]} -gt 0 ]]; then
        RANDOM_VARIANT="${VARIANTS[RANDOM % ${#VARIANTS[@]}]}"
        RANDOM_THEME="$RANDOM_THEME/$RANDOM_VARIANT"
    fi
fi

# Save theme
mkdir -p "$CONFIG_DIR"
echo "$RANDOM_THEME" > "$CONFIG_FILE"

echo "Selected qylock theme: $RANDOM_THEME"
