#!/bin/bash

# Combined CPU and Memory usage with SF Symbols icons

# Get CPU usage (user + system)
CPU_USAGE=$(top -l 2 -n 0 -F -R | grep "CPU usage" | tail -1 | awk '{print int($3 + $5)}')

# Get Memory usage
MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}' | sed 's/%//')
if [ -z "$MEMORY_PRESSURE" ]; then
  # Fallback method using vm_stat
  PAGE_SIZE=$(pagesize)
  STATS=$(vm_stat)

  PAGES_FREE=$(echo "$STATS" | grep "Pages free" | awk '{print $3}' | tr -d '.')
  PAGES_ACTIVE=$(echo "$STATS" | grep "Pages active" | awk '{print $3}' | tr -d '.')
  PAGES_INACTIVE=$(echo "$STATS" | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
  PAGES_WIRED=$(echo "$STATS" | grep "Pages wired down" | awk '{print $4}' | tr -d '.')

  FREE_MEM=$((PAGES_FREE * PAGE_SIZE / 1024 / 1024))
  USED_MEM=$(((PAGES_ACTIVE + PAGES_INACTIVE + PAGES_WIRED) * PAGE_SIZE / 1024 / 1024))
  TOTAL_MEM=$((FREE_MEM + USED_MEM))

  MEMORY_USAGE=$((USED_MEM * 100 / TOTAL_MEM))
else
  MEMORY_USAGE=$MEMORY_PRESSURE
fi

# Update sketchybar with regular foreground color
sketchybar --set system \
  icon.drawing=off \
  label="􀫥 ${CPU_USAGE}%  􀫦 ${MEMORY_USAGE}%"
