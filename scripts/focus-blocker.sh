#!/bin/bash

# === CONFIGURATION ===
# Add sites you want to block (one per line)
BLOCKED_SITES=(
  "reddit.com"
  "www.reddit.com"
  "carryology.com"
  "www.carryology.com"
  "packhacker.com"
  "www.packhacker.com"
  "gearmoose.com"
  "www.gearmoose.com"
  "uncrate.com"
  "www.uncrate.com"
  "hiconsumption.com"
  "www.hiconsumption.com"
  "gearpatrol.com"
  "www.gearpatrol.com"
  "wornandwound.com"
  "www.wornandwound.com"
  "ablogtowatch.com"
  "www.ablogtowatch.com"
)

HOSTS_FILE="/etc/hosts"
MARKER_START="# >>> FOCUS-BLOCKER-START"
MARKER_END="# >>> FOCUS-BLOCKER-END"

# === PASSWORD SETUP ===
# On first run, it creates a password hash file.
# You'll need this password to unblock sites.
HASH_FILE="$HOME/.focus_blocker_hash"

hash_password() {
  # Using SHA-256; not military-grade, but sufficient for self-control
  echo -n "$1" | shasum -a 256 | awk '{print $1}'
}

setup_password() {
  echo "=== First-time setup ==="
  echo "Choose a long, annoying password you won't want to type often."
  echo "(That's the point.)"
  echo ""
  read -s -p "Enter new password: " pass1
  echo ""
  read -s -p "Confirm password: " pass2
  echo ""
  if [ "$pass1" != "$pass2" ]; then
    echo "Passwords don't match. Try again."
    exit 1
  fi
  if [ ${#pass1} -lt 12 ]; then
    echo "Password must be at least 12 characters. Make it painful to type."
    exit 1
  fi
  hash_password "$pass1" > "$HASH_FILE"
  chmod 600 "$HASH_FILE"
  echo "Password saved."
}

verify_password() {
  read -s -p "Enter your focus-blocker password to unblock: " pass
  echo ""
  local input_hash
  input_hash=$(hash_password "$pass")
  local stored_hash
  stored_hash=$(cat "$HASH_FILE")
  if [ "$input_hash" != "$stored_hash" ]; then
    echo "Wrong password."
    exit 1
  fi
}

# === BLOCK / UNBLOCK ===

block_sites() {
  # Check if already blocked
  if grep -q "$MARKER_START" "$HOSTS_FILE" 2>/dev/null; then
    echo "Sites are already blocked. Stay focused!"
    exit 0
  fi

  echo "" | sudo tee -a "$HOSTS_FILE" > /dev/null
  echo "$MARKER_START" | sudo tee -a "$HOSTS_FILE" > /dev/null
  for site in "${BLOCKED_SITES[@]}"; do
    echo "127.0.0.1  $site" | sudo tee -a "$HOSTS_FILE" > /dev/null
  done
  echo "$MARKER_END" | sudo tee -a "$HOSTS_FILE" > /dev/null

  # Flush DNS cache so changes take effect immediately
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder 2>/dev/null

  echo ""
  echo "Blocked ${#BLOCKED_SITES[@]} sites. Time to focus."
}

unblock_sites() {
  if ! grep -q "$MARKER_START" "$HOSTS_FILE" 2>/dev/null; then
    echo "Nothing is currently blocked."
    exit 0
  fi

  verify_password

  # Remove everything between (and including) the markers
  sudo sed -i '' "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"

  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder 2>/dev/null

  echo "Sites unblocked. Use your freedom wisely."
}

show_status() {
  if grep -q "$MARKER_START" "$HOSTS_FILE" 2>/dev/null; then
    echo "Status: BLOCKING"
    echo "Blocked sites:"
    sed -n "/$MARKER_START/,/$MARKER_END/p" "$HOSTS_FILE" | grep "127.0.0.1" | awk '{print "  - " $2}'
  else
    echo "Status: NOT BLOCKING"
  fi
}

# === MAIN ===

# First-run password setup
if [ ! -f "$HASH_FILE" ]; then
  setup_password
fi

case "${1:-}" in
  on|block)
    block_sites
    ;;
  off|unblock)
    unblock_sites
    ;;
  status)
    show_status
    ;;
  reset-password)
    verify_password
    rm "$HASH_FILE"
    setup_password
    ;;
  *)
    echo "Usage: focus [on|off|status|reset-password]"
    echo ""
    echo "  on    — Block distracting sites (no password needed)"
    echo "  off   — Unblock sites (password required)"
    echo "  status — Show current blocking status"
    echo "  reset-password — Change your password"
    ;;
esac
