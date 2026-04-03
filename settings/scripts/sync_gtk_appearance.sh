#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-dark}"
FONT_NAME="${2:-Noto Sans 12}"
GTK3="$HOME/.config/gtk-3.0/settings.ini"
GTK4="$HOME/.config/gtk-4.0/settings.ini"
XSETTINGS="$HOME/.config/xsettingsd/xsettingsd.conf"

prefer_dark=1
if [[ "$MODE" == "light" ]]; then
    prefer_dark=0
fi

mkdir -p "$(dirname "$GTK3")" "$(dirname "$GTK4")" "$(dirname "$XSETTINGS")"
touch "$GTK3" "$GTK4" "$XSETTINGS"

update_ini() {
    local file="$1"
    local key="$2"
    local value="$3"

    if ! grep -q '^\[Settings\]' "$file" 2>/dev/null; then
        printf '[Settings]\n' > "$file"
    fi

    if grep -q "^${key}=" "$file"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$file"
    fi
}

update_ini "$GTK3" "gtk-font-name" "$FONT_NAME"
update_ini "$GTK4" "gtk-font-name" "$FONT_NAME"
update_ini "$GTK3" "gtk-application-prefer-dark-theme" "$prefer_dark"
update_ini "$GTK4" "gtk-application-prefer-dark-theme" "$prefer_dark"

if ! grep -q '^Net/ThemeName' "$XSETTINGS"; then
    printf 'Net/ThemeName "Adwaita"\n' >> "$XSETTINGS"
fi
if ! grep -q '^Net/IconThemeName' "$XSETTINGS"; then
    printf 'Net/IconThemeName "Reversal-purple-dark"\n' >> "$XSETTINGS"
fi

if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface font-name "$FONT_NAME" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.interface color-scheme "$( [[ "$prefer_dark" -eq 1 ]] && echo prefer-dark || echo default )" >/dev/null 2>&1 || true
fi

if pgrep -x xsettingsd >/dev/null 2>&1; then
    pkill -HUP xsettingsd >/dev/null 2>&1 || true
fi
