#!/bin/bash

# AeroSpace workspace plugin
# Shows which workspace is currently focused

WORKSPACE_ID=$1

# Check if this workspace is currently focused
if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
  sketchybar --set space.$WORKSPACE_ID icon.highlight=on
else
  sketchybar --set space.$WORKSPACE_ID icon.highlight=off
fi
