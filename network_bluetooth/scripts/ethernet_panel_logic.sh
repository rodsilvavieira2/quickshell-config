#!/usr/bin/env bash

set -u

get_status() {
    local networking="off"
    if nmcli networking 2>/dev/null | grep -qi "enabled"; then
        networking="on"
    fi

    local iface
    iface=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2=="ethernet" {print $1; exit}')

    if [[ "$networking" != "on" ]]; then
        jq -n -c --arg power "off" --arg iface "${iface:-}" '{power: $power, iface: $iface, connected: null}'
        return 0
    fi

    local line
    line=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null | awk -F: '$2=="ethernet" && $3=="connected" {print; exit}')

    if [[ -z "${line}" ]]; then
        jq -n -c --arg power "on" --arg iface "${iface:-}" '{power: $power, iface: $iface, connected: null}'
        return 0
    fi

    local state connection ip speed
    iface=$(printf '%s' "$line" | cut -d: -f1)
    state=$(printf '%s' "$line" | cut -d: -f3)
    connection=$(printf '%s' "$line" | cut -d: -f4-)

    ip=$(ip -4 addr show dev "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -n1)
    if [[ -z "${ip}" ]]; then
        ip="No IP"
    fi

    speed="Unknown"
    if [[ -r "/sys/class/net/$iface/speed" ]]; then
        speed=$(cat "/sys/class/net/$iface/speed" 2>/dev/null)
        if [[ "$speed" =~ ^[0-9]+$ ]]; then
            speed="${speed} Mb/s"
        else
            speed="Unknown"
        fi
    fi

    jq -n -c \
        --arg power "on" \
        --arg iface "$iface" \
        --arg id "$iface" \
        --arg icon "󰈀" \
        --arg name "${connection:-Ethernet}" \
        --arg state "$state" \
        --arg ip "$ip" \
        --arg speed "$speed" \
        '{power: $power, iface: $iface, connected: {id: $id, iface: $iface, icon: $icon, name: $name, state: $state, ip: $ip, speed: $speed}}'
}

toggle_power() {
    if nmcli networking 2>/dev/null | grep -qi "enabled"; then
        nmcli networking off >/dev/null 2>&1
    else
        nmcli networking on >/dev/null 2>&1
    fi
}

disconnect_iface() {
    local iface="${1:-}"
    if [[ -n "$iface" ]]; then
        nmcli device disconnect "$iface" >/dev/null 2>&1
    fi
}

connect_iface() {
    local iface="${1:-}"
    if [[ -n "$iface" ]]; then
        nmcli device connect "$iface" >/dev/null 2>&1
    fi
}

cmd="${1:---status}"
case "$cmd" in
    --status) get_status ;;
    --toggle) toggle_power ;;
    --disconnect) disconnect_iface "${2:-}" ;;
    --connect) connect_iface "${2:-}" ;;
    *) get_status ;;
esac
