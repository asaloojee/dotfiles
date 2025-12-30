#!/usr/bin/env zsh
#
# Tailscale Nuclear Reset
#
# This script forcefully stops and restarts Tailscale when normal methods fail.
# Use this for troubleshooting only - it's overkill for normal usage.
#
# Usage:
#   tailscale-nuclear-reset.sh stop    # Nuclear shutdown
#   tailscale-nuclear-reset.sh start   # Start after nuclear shutdown
#   tailscale-nuclear-reset.sh restart # Full nuclear restart

set -e

function tailscale-nuclear-stop() {
    echo "🛑 Shutting down Tailscale completely (nuclear option)..."

    # Try graceful shutdown first
    tailscale down 2>/dev/null || true

    # Stop all Homebrew services
    brew services stop tailscale 2>/dev/null || true
    sudo brew services stop tailscale 2>/dev/null || true

    # Unload LaunchAgents/Daemons
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.tailscale.plist 2>/dev/null || true
    sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.tailscale.plist 2>/dev/null || true

    # Nuclear option: kill all tailscale processes
    pkill -9 tailscaled 2>/dev/null || true
    sudo pkill -9 tailscaled 2>/dev/null || true

    echo "✅ Tailscale fully stopped"
}

function tailscale-nuclear-start() {
    echo "🚀 Starting Tailscale..."

    sudo brew services start tailscale
    sleep 2

    tailscale up 2>/dev/null || {
        echo "⚠️  Automatic connection failed"
        echo "   Run 'tailscale up' manually if needed"
    }

    echo "✅ Tailscale started"
}

function tailscale-nuclear-restart() {
    tailscale-nuclear-stop
    echo ""
    sleep 1
    tailscale-nuclear-start
}

function show-usage() {
    echo "Usage: $(basename $0) {stop|start|restart}"
    echo ""
    echo "Commands:"
    echo "  stop     - Nuclear shutdown of Tailscale"
    echo "  start    - Start Tailscale after nuclear shutdown"
    echo "  restart  - Full nuclear restart"
    echo ""
    echo "Note: This is a troubleshooting script. For normal usage, use:"
    echo "  brew services restart tailscale"
    exit 1
}

# Main
case "${1:-}" in
    stop)
        tailscale-nuclear-stop
        ;;
    start)
        tailscale-nuclear-start
        ;;
    restart)
        tailscale-nuclear-restart
        ;;
    *)
        show-usage
        ;;
esac
