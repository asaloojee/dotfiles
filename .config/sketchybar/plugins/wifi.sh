#!/bin/bash

# WiFi status with SF Symbols icons
# Uses system_profiler for reliable WiFi info on modern macOS

# Check if WiFi interface (en0) is connected by checking for IP address
WIFI_IP=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')

if [ -z "$WIFI_IP" ]; then
  # No WiFi connection (no IP address)
  ICON="􀙈"         # wifi.slash
  COLOR=0xfff7768e # Red
else
  # WiFi is connected
  ICON="􀙇"         # wifi
  COLOR=0xffc0caf5 # foreground primary
fi

sketchybar --set wifi \
  icon="$ICON" \
  icon.color="$COLOR"
