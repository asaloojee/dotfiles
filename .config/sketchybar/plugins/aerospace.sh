#!/bin/bash

# AeroSpace workspace plugin
# Inactive workspaces: Show only workspace number
# Active workspace: Show workspace number + focused app icon + app name

WORKSPACE_ID=$1

# Source the icon mapping function from sketchybar-app-font
source "$HOME/.config/sketchybar/helpers/icon_map.sh"

# Colors from sketchybarrc
BG_PRIMARY=0xff1a1b26
BG_SECONDARY=0xff24283b
BG_HIGHLIGHT=0xff414868
FG_PRIMARY=0xffc0caf5
ACCENT=0xff7aa2f7

# Get the currently focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Check if this workspace is focused
if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
  # Get the currently focused app in this workspace
  FOCUSED_APP=$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null)

  if [ -n "$FOCUSED_APP" ]; then
    # Get sketchybar-app-font icon for the focused app
    __icon_map "$FOCUSED_APP"
    APP_ICON="$icon_result"

    # Focused workspace with app - show number, icon, and name
    sketchybar --set space.$WORKSPACE_ID \
      background.color=$BG_HIGHLIGHT \
      background.border_color=$ACCENT \
      background.border_width=2

    sketchybar --set space.$WORKSPACE_ID.number \
      icon.color=$ACCENT \
      icon.padding_right=2

    sketchybar --set space.$WORKSPACE_ID.icon \
      icon="$APP_ICON" \
      icon.color=$ACCENT \
      drawing=on

    sketchybar --set space.$WORKSPACE_ID.name \
      label="$FOCUSED_APP" \
      label.color=$ACCENT \
      drawing=on
  else
    # Focused workspace but no windows - show just number with even padding
    sketchybar --set space.$WORKSPACE_ID \
      background.color=$BG_HIGHLIGHT \
      background.border_color=$ACCENT \
      background.border_width=2

    sketchybar --set space.$WORKSPACE_ID.number \
      icon.color=$ACCENT \
      icon.padding_right=6

    sketchybar --set space.$WORKSPACE_ID.icon drawing=off
    sketchybar --set space.$WORKSPACE_ID.name drawing=off
  fi
else
  # Unfocused workspace - show only number with even padding
  sketchybar --set space.$WORKSPACE_ID \
    background.color=$BG_SECONDARY \
    background.border_color=$BG_SECONDARY \
    background.border_width=0

  sketchybar --set space.$WORKSPACE_ID.number \
    icon.color=$FG_PRIMARY \
    icon.padding_right=6

  sketchybar --set space.$WORKSPACE_ID.icon drawing=off
  sketchybar --set space.$WORKSPACE_ID.name drawing=off
fi
