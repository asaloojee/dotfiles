#!/bin/bash

# Docker Desktop status with SF Symbols icons
# Checks if Docker daemon is running

# Check if Docker Desktop is running by checking the Docker daemon
if pgrep -q "Docker Desktop" || pgrep -q "com.docker.backend" 2>/dev/null; then
  # Docker Desktop is running, check if Docker is actually responsive
  if docker info &>/dev/null; then
    # Docker is running and responsive
    ICON=":docker:"  # shippingbox.fill
    COLOR=0xff7aa2f7 # Blue
  else
    # Docker Desktop is starting up
    ICON=":docker:"  # shippingbox.fill
    COLOR=0xffe0af68 # Yellow
  fi
else
  # Docker Desktop is not running
  ICON=":docker:"  # shippingbox
  COLOR=0xff565f89 # Dim gray
fi

sketchybar --set docker \
  icon="$ICON" \
  icon.color="$COLOR" \
  icon.font="sketchybar-app-font:Regular:18.0"
