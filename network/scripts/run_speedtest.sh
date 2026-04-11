#!/usr/bin/env bash

set -euo pipefail

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

if command -v speedtest >/dev/null 2>&1; then
    exec speedtest --accept-license --accept-gdpr
fi

if command -v speedtest-cli >/dev/null 2>&1; then
    exec speedtest-cli --simple
fi

if command -v fast >/dev/null 2>&1; then
    exec fast --single-line
fi

echo "No supported speedtest command found." >&2
echo "Install one of: speedtest, speedtest-cli, or fast." >&2
exit 1
