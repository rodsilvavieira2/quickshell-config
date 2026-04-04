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

property_is_yes() {
    local info="$1"
    local key="$2"
    printf '%s\n' "$info" | grep -q "${key}: yes"
}

device_name_from_line() {
    local line="$1"
    printf '%s\n' "$line" | cut -d ' ' -f 3-
}

get_status() {
    local power="off"
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        power="on"
    fi

    local connected_json="[]"
    local devices_json="[]"

    if [[ "$power" == "on" ]]; then
        local -a connected_lines=()
        mapfile -t connected_lines < <(bluetoothctl devices Connected 2>/dev/null)

        declare -A connected_map
        local connected_count=0
        local c_line c_mac
        for c_line in "${connected_lines[@]}"; do
            c_mac=$(printf '%s\n' "$c_line" | awk '{print $2}')
            if [[ -n "$c_mac" ]]; then
                connected_map["$c_mac"]=1
                connected_count=$((connected_count + 1))
            fi
        done

        local -a all_device_lines=()
        mapfile -t all_device_lines < <(
            {
                printf '%s\n' "${connected_lines[@]}"
                bluetoothctl devices Paired 2>/dev/null
                bluetoothctl devices 2>/dev/null
            } | awk 'NF' | awk '!seen[$2]++'
        )

        local -a connected_list_objs=()
        local -a paired_list_objs=()
        local -a discovered_list_objs=()

        for line in "${all_device_lines[@]}"; do
            if [[ -z "$line" ]]; then
                continue
            fi

            local mac info fallback_name name icon_type icon profile obj
            mac=$(printf '%s\n' "$line" | awk '{print $2}')
            if [[ -z "$mac" ]]; then
                continue
            fi

            info=$(bluetoothctl info "$mac" 2>/dev/null)
            fallback_name=$(device_name_from_line "$line")

            name=$(printf '%s\n' "$info" | awk -F': ' '/\tName:/ {print $2; exit}')
            if [[ -z "$name" ]]; then
                name="$fallback_name"
            fi
            if [[ -z "$name" ]]; then
                name="$mac"
            fi

            icon_type=$(printf '%s\n' "$info" | awk -F': ' '/\tIcon:/ {print $2; exit}')
            icon=$(get_icon "$icon_type" "$name")

            local is_connected="false"
            if [[ -n "${connected_map[$mac]+x}" ]]; then
                is_connected="true"
            elif [[ $connected_count -eq 0 ]] && property_is_yes "$info" "Connected"; then
                is_connected="true"
            fi

            if [[ "$is_connected" == "true" ]]; then
                profile=$(get_audio_profile "$mac")
                obj=$(jq -n -c \
                    --arg id "$mac" \
                    --arg name "$name" \
                    --arg mac "$mac" \
                    --arg icon "$icon" \
                    --arg profile "$profile" \
                    '{id: $id, name: $name, mac: $mac, icon: $icon, profile: $profile}')
                connected_list_objs+=("$obj")
            else
                local action
                if property_is_yes "$info" "Paired"; then
                    action="Connect"
                else
                    action="Pair"
                fi

                obj=$(jq -n -c \
                    --arg id "$mac" \
                    --arg name "$name" \
                    --arg mac "$mac" \
                    --arg icon "$icon" \
                    --arg action "$action" \
                    '{id: $id, name: $name, mac: $mac, icon: $icon, action: $action}')

                if [[ "$action" == "Connect" ]]; then
                    paired_list_objs+=("$obj")
                else
                    discovered_list_objs+=("$obj")
                fi
            fi
        done

        if [[ ${#connected_list_objs[@]} -gt 0 ]]; then
            connected_json=$(printf '%s\n' "${connected_list_objs[@]}" | jq -s -c '.')
        fi

        local -a all_objs=()
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
    if ! bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
        bluetoothctl pair "$mac" >/dev/null 2>&1
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

scan_on() {
    timeout 5 bluetoothctl scan on >/dev/null 2>&1 || true
}

scan_off() {
    timeout 5 bluetoothctl scan off >/dev/null 2>&1 || true
}

cmd="${1:---status}"
case "$cmd" in
    --status) get_status ;;
    --toggle) toggle_power ;;
    --connect) connect_dev "${2:-}" ;;
    --disconnect) disconnect_dev "${2:-}" ;;
    --scan-on) scan_on ;;
    --scan-off) scan_off ;;
    *) get_status ;;
esac
