#!/bin/bash

# Trigger update for all aerospace workspaces when window focus changes
# This ensures the focused app name/icon updates within the same workspace

# Get current focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Update all workspace items
for i in {1..5}; do
  sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE"
done
