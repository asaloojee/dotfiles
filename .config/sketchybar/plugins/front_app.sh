#!/bin/bash

# Get the name of the frontmost application
FRONT_APP=$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null || echo "$INFO")

# Fallback to AppleScript if aerospace command fails
if [ -z "$FRONT_APP" ]; then
  FRONT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')
fi

sketchybar --set front_app label="$FRONT_APP"
