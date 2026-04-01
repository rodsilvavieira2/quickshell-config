#!/bin/bash

# Keeping the cache in the same place so we don't break anything else
CACHE_DIR="$HOME/.cache/quickshell/schedule"
CACHE_FILE="${CACHE_DIR}/schedule.json"
CACHE_LIMIT=600 # 1 Hour

UPDATER_SCRIPT="$HOME/.config/quickshell/calendar/schedule/get_schedule.py"

mkdir -p "$CACHE_DIR"

trigger_update() {
    # PREVENT OVERLAP: Check if the python script is already running
    if pgrep -f "python3.*get_schedule.py" > /dev/null; then
        return # Silently exit if an update is already in progress
    fi
    
    # Run directly using system python instead of nix-shell for Arch Linux compatibility
    python3 "$UPDATER_SCRIPT" >/dev/null 2>&1 &
}

if [ -f "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
    
    current_time=$(date +%s)
    file_time=$(stat -c %Y "$CACHE_FILE")
    age=$((current_time - file_time))
    
    if [ "$age" -gt "$CACHE_LIMIT" ]; then
        trigger_update
    fi
else
    # Valid placeholder with "link"
    echo '{ "header": "Loading...", "lessons": [], "link": "" }'
    trigger_update
fi
