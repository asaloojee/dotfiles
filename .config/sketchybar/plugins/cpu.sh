#!/bin/bash

# CPU usage with colored SF Symbol icon

# Get CPU usage (user + system)
CPU_USAGE=$(top -l 2 -n 0 -F -R | grep "CPU usage" | tail -1 | awk '{print int($3 + $5)}')

# Determine CPU icon color based on usage
if [ "$CPU_USAGE" -gt 80 ]; then
  CPU_COLOR=0xfff7768e # Red
elif [ "$CPU_USAGE" -gt 50 ]; then
  CPU_COLOR=0xffe0af68 # Yellow
else
  CPU_COLOR=0xff9ece6a # Green
fi

sketchybar --set cpu \
  icon="􀫥" \
  icon.color="$CPU_COLOR" \
  label="${CPU_USAGE}%"
