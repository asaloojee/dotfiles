#!/bin/bash

# WiFi status with SF Symbols icons
# Get WiFi network name using networksetup (more reliable)
WIFI_DEVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
SSID=$(networksetup -getairportnetwork "$WIFI_DEVICE" | awk -F': ' '{print $2}')

if [ "$SSID" = "You are not associated with an AirPort network." ] || [ -z "$SSID" ]; then
  # No WiFi connection
  ICON="􀙈"  # wifi.slash
  LABEL="Disconnected"
  COLOR=0xfff7768e # Red
else
  # Connected - show SSID
  ICON="􀙇"  # wifi
  LABEL="$SSID"
  COLOR=0xff9ece6a # Green
fi

sketchybar --set wifi \
  icon="$ICON" \
  label="$LABEL" \
  icon.color="$COLOR"
