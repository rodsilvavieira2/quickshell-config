import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

import ".." as Root
import "../components"

Item {
    id: root

    implicitWidth: iconsRow.implicitWidth
    implicitHeight: iconsRow.implicitHeight

    // Track the default audio sink so its audio properties are populated
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // Network state
    property bool networkConnected: false
    property bool networkIsWifi: false
    property string activeSsid: ""

    Process {
        id: networkCheck
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l.length > 0)
                let wifiLine = lines.find(l => l.startsWith("wifi:connected:"))
                if (wifiLine) {
                    root.networkIsWifi = true
                    root.networkConnected = true
                    root.activeSsid = wifiLine.split(":")[2] || "Wi-Fi"
                } else {
                    root.networkIsWifi = false
                    const ethLine = lines.find(l => l.startsWith("ethernet:connected:"))
                    if (ethLine) {
                        root.networkConnected = true
                        root.activeSsid = "Ethernet"
                    } else {
                        root.networkConnected = false
                        root.activeSsid = ""
                    }
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: networkCheck.running = true
    }

    Row {
        id: iconsRow
        anchors.centerIn: parent
        spacing: Root.Config.pillSpacing

        // Bluetooth icon
        Item {
            id: btItem
            width: btChip.width
            height: btChip.height
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool btEnabled: Bluetooth.defaultAdapter?.enabled ?? false
            readonly property var connectedDevice: {
                const devices = Bluetooth.devices?.values ?? []
                return devices.find(d => d.connected)
            }
            readonly property bool btConnected: connectedDevice !== undefined

            InfoChip {
                id: btChip
                iconSource: btItem.btConnected
                    ? Qt.resolvedUrl("../assets/bluetooth-connected.svg")
                    : (btItem.btEnabled
                        ? Qt.resolvedUrl("../assets/bluetooth.svg")
                        : Qt.resolvedUrl("../assets/bluetooth-off.svg"))
                valueText: btItem.btConnected ? btItem.connectedDevice.name : ""
                backgroundColor: btItem.btConnected ? Root.Config.mauve : Root.Config.chipColor
                iconColor: btItem.btConnected ? Root.Config.crust : Root.Config.subtext0
                labelColor: btItem.btConnected ? Root.Config.crust : Root.Config.subtext0
                valueMaxWidth: 110
                clickable: true
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "settings", "call", "settings", "openCategory", "bluetooth"])
            }
        }

        // Volume icon + label
        Item {
            id: volItem
            readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
            readonly property real volume: {
                const v = Pipewire.defaultAudioSink?.audio?.volume ?? 0
                return isNaN(v) ? 0 : v
            }

            width: volChip.width
            height: volChip.height
            anchors.verticalCenter: parent.verticalCenter

            InfoChip {
                id: volChip
                iconSource: volItem.muted
                    ? Qt.resolvedUrl("../assets/volume-x.svg")
                    : (volItem.volume > 0.33
                        ? Qt.resolvedUrl("../assets/volume-2.svg")
                        : Qt.resolvedUrl("../assets/volume-1.svg"))
                valueText: Math.round(volItem.volume * 100) + "%"
                iconColor: volItem.muted ? Root.Config.red : Root.Config.text
                labelColor: volItem.muted ? Root.Config.red : Root.Config.subtext0
                clickable: true
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "settings", "call", "settings", "toggle"])
            }
        }

        // Network icon
        Item {
            id: netItem
            width: netChip.width
            height: netChip.height
            anchors.verticalCenter: parent.verticalCenter

            InfoChip {
                id: netChip
                iconSource: root.networkConnected
                    ? (root.networkIsWifi
                        ? Qt.resolvedUrl("../assets/wifi.svg")
                        : Qt.resolvedUrl("../assets/ethernet.svg"))
                    : Qt.resolvedUrl("../assets/wifi-off.svg")
                valueText: root.networkConnected ? root.activeSsid : ""
                backgroundColor: root.networkConnected ? Root.Config.blue : Root.Config.chipColor
                iconColor: root.networkConnected ? Root.Config.crust : Root.Config.subtext0
                labelColor: root.networkConnected ? Root.Config.crust : Root.Config.subtext0
                valueMaxWidth: 110
                clickable: true
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "settings", "call", "settings", "openCategory", "network"])
            }
        }
    }
}
