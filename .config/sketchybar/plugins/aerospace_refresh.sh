#!/bin/bash

# Refresh all aerospace workspace indicators
# This script is triggered when workspace changes or app focus changes

# Log that script was called
echo "$(date): Refresh script called!" >> /tmp/sketchybar_refresh.log

# Update all 5 workspace items
for i in {1..5}; do
  "$HOME/.config/sketchybar/plugins/aerospace.sh" "$i"
done
