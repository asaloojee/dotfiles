#!/bin/bash

# Battery status with SF Symbols icons and percentage
PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -n "$CHARGING" ]; then
  ICON="􀢋"         # battery.100.bolt (charging)
  COLOR=0xff9ece6a # Green
else
  if [ "$PERCENTAGE" -gt 80 ]; then
    ICON="􀛨"         # battery.100
    COLOR=0xff9ece6a # Green
  elif [ "$PERCENTAGE" -gt 60 ]; then
    ICON="􀺸"         # battery.75
    COLOR=0xff9ece6a # Green
  elif [ "$PERCENTAGE" -gt 40 ]; then
    ICON="􀺶"         # battery.50
    COLOR=0xffe0af68 # Yellow
  elif [ "$PERCENTAGE" -gt 20 ]; then
    ICON="􀛩"         # battery.25
    COLOR=0xffe0af68 # Yellow
  else
    ICON="􁛃"         # battery.0
    COLOR=0xfff7768e # Red
  fi
fi

sketchybar --set battery \
  icon="$ICON" \
  label="${PERCENTAGE}%" \
  icon.color="${COLOR}"
