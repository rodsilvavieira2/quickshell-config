#!/usr/bin/env bash

CACHE_DIR="$HOME/.cache/quickshell/news"
CACHE_FILE="${CACHE_DIR}/news.json"
CACHE_LIMIT=1800  # 30 minutes

FETCHER="$HOME/.config/quickshell/calendar/news_fetcher.py"

mkdir -p "$CACHE_DIR"

trigger_update() {
    if pgrep -f "python3.*news_fetcher.py" > /dev/null; then
        return
    fi
    python3 "$FETCHER" >/dev/null 2>&1 &
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
    echo '{"articles":[],"fetched_at":0}'
    trigger_update
fi
