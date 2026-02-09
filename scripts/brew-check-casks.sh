#!/usr/bin/env bash
#
# Brew Cask Version Checker
#
# Checks installed Homebrew casks against latest available versions,
# including self-updating (greedy) casks that brew normally skips.
# Outputs a ready-to-use reinstall command for any outdated casks.
#
# Usage:
#   brew-check-casks.sh          # Check all installed casks
#   brew-check-casks.sh --quiet  # Only output the reinstall command

set -euo pipefail

QUIET=false
[[ "${1:-}" == "--quiet" ]] && QUIET=true

BREW="/opt/homebrew/bin/brew"

if ! command -v "$BREW" &>/dev/null; then
  echo "Error: Homebrew not found at $BREW" >&2
  exit 1
fi

# brew outdated --cask --greedy is safe — it only reads, never modifies
outdated=$("$BREW" outdated --cask --greedy --verbose 2>/dev/null)

if [[ -z "$outdated" ]]; then
  [[ "$QUIET" == false ]] && echo "All casks are up to date."
  exit 0
fi

# Collect cask names for the reinstall command
cask_names=()
while IFS= read -r line; do
  # Format: "cask-name (installed_version) < latest_version"
  name=$(echo "$line" | awk '{print $1}')
  cask_names+=("$name")
done <<< "$outdated"

if [[ "$QUIET" == false ]]; then
  echo "Outdated casks (${#cask_names[@]}):"
  echo ""
  echo "$outdated"
  echo ""
fi

echo "brew reinstall --cask --force ${cask_names[*]}"
