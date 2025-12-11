#!/bin/bash

# Caffeinate status with SF Symbols icons
# Checks if caffeinate is running (prevents sleep)

# Check if caffeinate process is running (excluding this grep)
if pgrep -q caffeinate; then
  # Caffeinate is active
  ICON="􀸙"         # cup.and.saucer.fill (awake)
  COLOR=0xffe0af68 # Yellow (warning that sleep is prevented)
else
  # Normal state (sleep allowed)
  ICON="􀸘"         # moon.zzz.fill (can sleep)
  COLOR=0xffe0af68 # Yellow (warning that sleep is prevented)
fi

sketchybar --set caffeinate \
  icon="$ICON" \
  icon.color="$COLOR"
