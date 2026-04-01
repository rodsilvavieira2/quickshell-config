import re
import os

with open('/home/rodrigo/.config/quickshell/example/quickshell/network/NetworkPopup.qml', 'r') as f:
    text = f.read()

# Fix imports
text = text.replace('import "../"', 'import "./common"')

# Replace MatugenColors with Appearance.colors
text = re.sub(r'MatugenColors \{ id: _theme \}\n\s*readonly property color base: _theme\.base.*readonly property color peach: _theme\.peach', 
              r'readonly property QtObject _theme: Appearance.colors\n'
              r'    readonly property color base: _theme.base\n'
              r'    readonly property color mantle: _theme.mantle\n'
              r'    readonly property color crust: _theme.crust\n'
              r'    readonly property color text: _theme.text\n'
              r'    readonly property color subtext0: _theme.subtext0\n'
              r'    readonly property color overlay0: _theme.overlay0\n'
              r'    readonly property color overlay1: _theme.overlay1\n'
              r'    readonly property color surface0: _theme.surface0\n'
              r'    readonly property color surface1: _theme.surface1\n'
              r'    readonly property color surface2: _theme.surface2\n'
              r'    \n'
              r'    readonly property color mauve: _theme.mauve\n'
              r'    readonly property color pink: _theme.pink\n'
              r'    readonly property color sapphire: _theme.sapphire\n'
              r'    readonly property color blue: _theme.blue\n'
              r'    readonly property color red: _theme.red\n'
              r'    readonly property color maroon: _theme.maroon\n'
              r'    readonly property color peach: _theme.peach', text, flags=re.DOTALL)

# Scripts directory
text = text.replace('Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/network"', 'Quickshell.env("HOME") + "/.config/quickshell/network_desktop/scripts"')

# Modes
text = text.replace('"wifi"', '"ethernet"')
text = text.replace('activeMode === "wifi" ? "bt" : "wifi"', 'activeMode === "ethernet" ? "bt" : "ethernet"')

# Variables and IDs
text = text.replace('wifiAccent', 'ethernetAccent')
text = text.replace('window.sapphire', 'window.sapphire') # ethernet Accent is sapphire
text = text.replace('isWifiConn', 'isEthernetConn')
text = text.replace('wifiConnected', 'ethernetConnected')
text = text.replace('wifiList', 'ethernetList')
text = text.replace('wifiPower', 'ethernetPower')
text = text.replace('wifiPoller', 'ethernetPoller')
text = text.replace('wifiPendingReset', 'ethernetPendingReset')
text = text.replace('wifiTabMa', 'ethernetTabMa')

# JSON fields
text = text.replace('lastWifiJson', 'lastEthernetJson')
text = text.replace('lastWifiSsid', 'lastEthernetIface')
text = text.replace('targetWifiSsid', 'targetEthernetIface')
text = text.replace('strongestWifiSsid', 'strongestEthernetIface')
text = text.replace('processWifiJson', 'processEthernetJson')
text = text.replace('wifi_panel_logic.sh', 'ethernet_panel_logic.sh')

# ssid -> id for ethernet (since scripts use id instead of ssid)
# But we need to be careful not to replace it in bt
# Let's replace 'ssid' with 'id' specifically for ethernet
text = re.sub(r'activeMode === "ethernet" \? ([\w\.]+)\.ssid : ([\w\.]+)\.mac', r'activeMode === "ethernet" ? \1.id : \2.mac', text)
text = re.sub(r'activeMode === "ethernet" \? ([\w\.]+)\.ssid : ([\w\.]+)\.name', r'activeMode === "ethernet" ? \1.id : \2.name', text)
text = re.sub(r'\.ssid', '.id', text) # Be careful, this replaces all `.ssid`. The bt json doesn't have `ssid`, so this is safe.
text = re.sub(r'ssid:', 'id:', text)
text = text.replace('id: d.id || "", id: d.id || ""', 'id: d.id || ""')

# Icons
text = text.replace('"󰤨"', '"󰈀"') # Wifi icon
text = text.replace('"󰤮"', '"󰈀"') # Offline icon
text = text.replace('"󰖪"', '"󰈀"') # Wave icon

# Words
text = text.replace('"Wi-Fi"', '"Ethernet"')

# Update info nodes for ethernet
info_nodes_orig = """                if (window.activeMode === "ethernet") {
                    let sigValue = obj.signal !== undefined ? obj.signal + "%" : "Calculating...";
                    nodes.push({ id: "sig_" + i, name: sigValue, icon: obj.icon || "󰈀", action: "Signal Strength", isInfoNode: true, isActionable: false, parentIndex: cIndex });
                    nodes.push({ id: "sec_" + i, name: obj.security || "Open", icon: "󰦝", action: "Security", isInfoNode: true, isActionable: false, parentIndex: cIndex });
                    if (obj.ip) nodes.push({ id: "ip_" + i, name: obj.ip, icon: "󰩟", action: "IP Address", isInfoNode: true, isActionable: false, parentIndex: cIndex });
                    if (obj.freq) nodes.push({ id: "freq_" + i, name: obj.freq, icon: "󰖧", action: "Band", isInfoNode: true, isActionable: false, parentIndex: cIndex });
                } else {"""

info_nodes_new = """                if (window.activeMode === "ethernet") {
                    if (obj.state) nodes.push({ id: "state_" + i, name: obj.state, icon: "󰈀", action: "Status", isInfoNode: true, isActionable: false, parentIndex: cIndex });
                    if (obj.ip) nodes.push({ id: "ip_" + i, name: obj.ip, icon: "󰩟", action: "IP Address", isInfoNode: true, isActionable: false, parentIndex: cIndex });
                    if (obj.speed) nodes.push({ id: "speed_" + i, name: obj.speed, icon: "󰖧", action: "Speed", isInfoNode: true, isActionable: false, parentIndex: cIndex });
                } else {"""

text = text.replace(info_nodes_orig, info_nodes_new)

# Update ethernet actions
text = text.replace('nmcli device disconnect $(nmcli -t -f DEVICE,TYPE d | grep ethernet | cut -d: -f1 | head -n1)', 
                    'bash " + window.scriptsDir + "/ethernet_panel_logic.sh --disconnect \'" + coreContainer.myDevice.id + "\'')

text = text.replace('nmcli device ethernet connect \'" + id + "\'', 
                    'bash " + window.scriptsDir + "/ethernet_panel_logic.sh --connect \'" + id + "\'')

# Power toggle
text = text.replace('Quickshell.execDetached(["nmcli", "radio", "ethernet", window.ethernetPower]);',
                    'Quickshell.execDetached(["bash", window.scriptsDir + "/ethernet_panel_logic.sh", "--toggle"]);')

with open('/home/rodrigo/.config/quickshell/network_desktop/NetworkPopup.qml', 'w') as f:
    f.write(text)

print("Successfully generated NetworkPopup.qml")
