#!/bin/bash

# AeroSpace workspace plugin
# Shows workspace number + all app icons, highlights focused workspace

WORKSPACE_ID=$1

# Source the icon mapping function
source "$HOME/.config/sketchybar/helpers/icon_map.sh"

# Colors from sketchybarrc
BG_PRIMARY=0xff1a1b26
BG_SECONDARY=0xff24283b
BG_HIGHLIGHT=0xff414868
FG_PRIMARY=0xffc0caf5
ACCENT=0xff7aa2f7

# Get the currently focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Get all apps in this workspace (unique app names only)
APPS=$(aerospace list-windows --workspace "$WORKSPACE_ID" --format "%{app-name}" 2>/dev/null | sort -u)

# Build icon string from all apps
ICONS=""
APP_COUNT=0

while IFS= read -r app; do
  if [ -n "$app" ]; then
    __icon_map "$app"
    ICONS="$ICONS$icon_result "
    ((APP_COUNT++))
  fi
done <<<"$APPS"

# Trim trailing space
ICONS=$(echo "$ICONS" | sed 's/[[:space:]]*$//')

# Check if this workspace is focused
if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
  # Focused workspace - highlighted
  sketchybar --set space.$WORKSPACE_ID \
    background.drawing=on \
    background.color=$BG_HIGHLIGHT \
    background.border_color=$ACCENT \
    background.border_width=2 \
    icon="$WORKSPACE_ID" \
    icon.font="JetBrainsMono Nerd Font:Medium:16.0" \
    icon.color=$ACCENT \
    icon.padding_left=10 \
    icon.padding_right=4 \
    label="$ICONS" \
    label.font="sketchybar-app-font:Regular:16.0" \
    label.color=$ACCENT \
    label.drawing=on \
    label.padding_left=4 \
    label.padding_right=10
else
  # Unfocused workspace - regular display
  sketchybar --set space.$WORKSPACE_ID \
    background.drawing=on \
    background.color=$BG_SECONDARY \
    background.border_color=$BG_SECONDARY \
    background.border_width=0 \
    icon="$WORKSPACE_ID" \
    icon.font="JetBrainsMono Nerd Font:Medium:16.0" \
    icon.color=$FG_PRIMARY \
    icon.padding_left=10 \
    icon.padding_right=4 \
    label="$ICONS" \
    label.font="sketchybar-app-font:Regular:16.0" \
    label.color=$FG_PRIMARY \
    label.drawing=on \
    label.padding_left=4 \
    label.padding_right=10
fi
