#!/usr/bin/env bash
#
# Install Scripts
#
# This script installs utility scripts to ~/.local/bin
# Run this when setting up a new Mac or updating scripts
#
# Usage:
#   ./scripts/install.sh           # Install all scripts
#   ./scripts/install.sh --force   # Overwrite existing scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.local/bin"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Check if --force flag is provided
FORCE=false
if [[ "$1" == "--force" ]]; then
    FORCE=true
fi

echo "📦 Installing scripts from $SCRIPT_DIR to $TARGET_DIR"
echo ""

# Find all executable scripts (excluding this install script)
for script in "$SCRIPT_DIR"/*.sh; do
    # Skip this install script itself
    if [[ "$(basename "$script")" == "install.sh" ]]; then
        continue
    fi

    script_name=$(basename "$script")
    target_path="$TARGET_DIR/$script_name"

    # Check if script already exists
    if [[ -f "$target_path" ]] && [[ "$FORCE" != true ]]; then
        echo -e "${YELLOW}⚠️  $script_name already exists${NC}"
        echo "   Use --force to overwrite, or remove manually"
        continue
    fi

    # Copy script and make it executable
    cp "$script" "$target_path"
    chmod +x "$target_path"
    echo -e "${GREEN}✅ Installed $script_name${NC}"
done

echo ""
echo "🎉 Script installation complete!"
echo ""
echo "Available scripts:"
ls -1 "$TARGET_DIR"/*.sh 2>/dev/null | xargs -n1 basename || echo "  (none)"
