#!/bin/bash

# Toggle caffeinate on/off
# If caffeinate is running, kill it
# If caffeinate is not running, start it in the background

if pgrep -q caffeinate; then
  # Caffeinate is running, kill it
  pkill caffeinate
  osascript -e 'display notification "Sleep is now allowed" with title "Caffeinate Disabled"'
else
  # Caffeinate is not running, start it (prevents display and system sleep)
  caffeinate -d -i -s &
  osascript -e 'display notification "Mac will stay awake" with title "Caffeinate Enabled"'
fi

# Trigger immediate update of the caffeinate item
sketchybar --trigger caffeinate_toggle
