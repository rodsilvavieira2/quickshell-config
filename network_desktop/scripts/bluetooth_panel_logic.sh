#!/usr/bin/env bash

set -u

CACHE_DIR="/tmp/quickshell_networkdesktop_cache"
mkdir -p "$CACHE_DIR"

get_icon() {
    local type
    local name
    type=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    name=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    if [[ "$type" == *"headset"* ]] || [[ "$type" == *"headphone"* ]] || [[ "$name" == *"headphone"* ]] || [[ "$name" == *"buds"* ]] || [[ "$name" == *"pods"* ]]; then
        echo "🎧"
    elif [[ "$type" == *"audio"* ]] || [[ "$type" == *"speaker"* ]] || [[ "$name" == *"speaker"* ]]; then
        echo "󰓃"
    elif [[ "$type" == *"phone"* ]] || [[ "$name" == *"phone"* ]] || [[ "$name" == *"iphone"* ]] || [[ "$name" == *"android"* ]]; then
        echo "󰄜"
    elif [[ "$type" == *"mouse"* ]] || [[ "$name" == *"mouse"* ]]; then
        echo "󰍽"
    elif [[ "$type" == *"keyboard"* ]] || [[ "$name" == *"keyboard"* ]]; then
        echo "󰌓"
    else
        echo "󰂯"
    fi
}

get_audio_profile() {
    local mac="$1"
    local mac_us
    mac_us=$(echo "$mac" | tr ':' '_')
    local active
    active=$(pactl list cards 2>/dev/null | grep -i -A 20 "Name:.*$mac_us" | grep -i "Active Profile:" | head -n 1 | cut -d: -f2 | xargs)

    if [[ -z "$active" || "$active" == "off" ]]; then
        echo "None"
        return
    fi

    if [[ "$active" == *"a2dp"* ]]; then
        echo "Hi-Fi (A2DP)"
        return
    fi

    if [[ "$active" == *"headset"* || "$active" == *"hfp"* ]]; then
        echo "Headset (HFP)"
        return
    fi

    echo "Connected"
}

get_status() {
    local power="off"
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        power="on"
    fi

    local connected_json="[]"
    local devices_json="[]"

    if [[ "$power" == "on" ]]; then
        local paired_macs
        paired_macs=$(bluetoothctl devices Paired 2>/dev/null | cut -d ' ' -f 2)
        mapfile -t devices < <(bluetoothctl devices 2>/dev/null)

        local -a connected_list_objs
        local -a paired_list_objs
        local -a discovered_list_objs

        mapfile -t connected_info_lines < <(bluetoothctl devices Connected 2>/dev/null)
        local connected_macs
        connected_macs=$(printf '%s\n' "${connected_info_lines[@]}" | awk '{for(i=1;i<=NF;i++) if($i~/^([0-9A-F]{2}:){5}[0-9A-F]{2}$/) print $i}')

        for c_line in "${connected_info_lines[@]}"; do
            if [[ -z "$c_line" ]]; then
                continue
            fi

            local connected_mac cache_file name info icon_type icon profile bat obj
            connected_mac=$(echo "$c_line" | cut -d ' ' -f 2)
            cache_file="$CACHE_DIR/bt_stat_${connected_mac//:/_}"

            if [[ -f "$cache_file" ]]; then
                # shellcheck disable=SC1090
                source "$cache_file"
            else
                name=$(echo "$c_line" | cut -d ' ' -f 3-)
                info=$(bluetoothctl info "$connected_mac" 2>/dev/null)
                icon_type=$(echo "$info" | grep "Icon:" | cut -d: -f2 | xargs)
                icon=$(get_icon "$icon_type" "$name")
                profile=$(get_audio_profile "$connected_mac")
                {
                    echo "CACHE_NAME=\"$name\""
                    echo "CACHE_ICON=\"$icon\""
                    echo "CACHE_PROFILE=\"$profile\""
                } > "$cache_file"
                CACHE_NAME="$name"
                CACHE_ICON="$icon"
                CACHE_PROFILE="$profile"
            fi

            bat=$(bluetoothctl info "$connected_mac" 2>/dev/null | awk '/Battery Percentage:/ {gsub(/.*\(/,""); gsub(/\).*/,""); print}')
            if [[ -z "$bat" || "$bat" == "?" ]]; then
                bat="0"
            fi

            obj=$(jq -n -c \
                --arg id "$connected_mac" \
                --arg name "$CACHE_NAME" \
                --arg mac "$connected_mac" \
                --arg icon "$CACHE_ICON" \
                \
                --arg profile "$CACHE_PROFILE" \
                '{id: $id, name: $name, mac: $mac, icon: $icon, profile: $profile}')
            connected_list_objs+=("$obj")
        done

        if [[ ${#connected_list_objs[@]} -gt 0 ]]; then
            connected_json=$(printf '%s\n' "${connected_list_objs[@]}" | jq -s -c '.')
        fi

        for line in "${devices[@]}"; do
            if [[ -z "$line" ]]; then
                continue
            fi

            local mac name icon action obj
            mac=$(echo "$line" | cut -d ' ' -f 2)
            if echo "$connected_macs" | grep -q "$mac"; then
                continue
            fi

            name=$(echo "$line" | cut -d ' ' -f 3-)
            icon=$(get_icon "unknown" "$name")

            if echo "$paired_macs" | grep -q "$mac"; then
                action="Connect"
            else
                action="Pair"
            fi

            obj=$(jq -n -c --arg id "$mac" --arg name "$name" --arg mac "$mac" --arg icon "$icon" --arg action "$action" '{id: $id, name: $name, mac: $mac, icon: $icon, action: $action}')
            if [[ "$action" == "Connect" ]]; then
                paired_list_objs+=("$obj")
            else
                discovered_list_objs+=("$obj")
            fi
        done

        local -a all_objs
        all_objs=("${paired_list_objs[@]}" "${discovered_list_objs[@]}")
        if [[ ${#all_objs[@]} -gt 0 ]]; then
            devices_json=$(printf '%s\n' "${all_objs[@]}" | jq -s -c '.')
        fi
    fi

    jq -n -c \
        --arg power "$power" \
        --argjson connected "$connected_json" \
        --argjson devices "$devices_json" \
        '{power: $power, connected: $connected, devices: $devices}'
}

toggle_power() {
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        bluetoothctl power off >/dev/null 2>&1
    else
        bluetoothctl power on >/dev/null 2>&1
    fi
}

connect_dev() {
    local mac="${1:-}"
    if [[ -z "$mac" ]]; then
        return
    fi
    bluetoothctl trust "$mac" >/dev/null 2>&1
    bluetoothctl connect "$mac" >/dev/null 2>&1
}

disconnect_dev() {
    local mac="${1:-}"
    if [[ -z "$mac" ]]; then
        return
    fi
    rm -f "$CACHE_DIR/bt_stat_${mac//:/_}" >/dev/null 2>&1
    bluetoothctl disconnect "$mac" >/dev/null 2>&1
}

cmd="${1:---status}"
case "$cmd" in
    --status) get_status ;;
    --toggle) toggle_power ;;
    --connect) connect_dev "${2:-}" ;;
    --disconnect) disconnect_dev "${2:-}" ;;
    *) get_status ;;
esac
