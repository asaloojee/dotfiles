#!/bin/bash

# Volume level with mute detection
VOLUME=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ]; then
  ICON="󰖁"
else
  if [ "$VOLUME" -gt 50 ]; then
    ICON="󰕾"
  elif [ "$VOLUME" -gt 0 ]; then
    ICON="󰖀"
  else
    ICON="󰕿"
  fi
fi

sketchybar --set volume \
  icon="$ICON" \
  label="${VOLUME}%"
