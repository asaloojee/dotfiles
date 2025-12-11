#!/bin/bash

# Battery status with icon and percentage
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -n "$CHARGING" ]; then
  ICON="󰂄"
  COLOR=0xff9ece6a  # Green
else
  if [ "$PERCENTAGE" -gt 80 ]; then
    ICON="󰁹"
  elif [ "$PERCENTAGE" -gt 60 ]; then
    ICON="󰂀"
  elif [ "$PERCENTAGE" -gt 40 ]; then
    ICON="󰁾"
  elif [ "$PERCENTAGE" -gt 20 ]; then
    ICON="󰁼"
  else
    ICON="󰁺"
    COLOR=0xfff7768e  # Red
  fi
fi

sketchybar --set battery \
  icon="$ICON" \
  label="${PERCENTAGE}%" \
  icon.color="${COLOR:-0xff9ece6a}"
