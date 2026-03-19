#!/usr/bin/env bash
#
# Caffeinate display for 1-3 hours
#
# Usage:
#   caff        # 1 hour (default)
#   caff 2      # 2 hours
#   caff 3      # 3 hours

hours=${1:-1}

if ! [[ "$hours" =~ ^[1-3]$ ]]; then
    echo "Usage: caff [1-3]"
    exit 1
fi

echo "☕ Keeping display awake for $hours hour(s)..."
caffeinate -d -t $((hours * 3600))
