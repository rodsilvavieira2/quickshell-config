import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

import ".." as Root

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

    Process {
        id: networkCheck
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l.length > 0)
                root.networkIsWifi = lines.some(l => l.startsWith("wifi:connected"))
                const hasEthernet = lines.some(l => l.startsWith("ethernet:connected"))
                root.networkConnected = root.networkIsWifi || hasEthernet
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
        spacing: 10

        // Bluetooth icon
        Item {
            width: btIcon.implicitWidth
            height: btIcon.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool btEnabled: Bluetooth.defaultAdapter?.enabled ?? false
            readonly property bool btConnected: {
                const devices = Bluetooth.devices?.values ?? []
                return devices.some(d => d.connected)
            }

            Text {
                id: btIcon
                text: parent.btConnected ? "󰂱" : (parent.btEnabled ? "󰂯" : "󰂲")
                color: parent.btConnected ? Root.Config.blue : Root.Config.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Root.Config.iconSize
                anchors.centerIn: parent

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "network_desktop", "call", "networkdesktop", "toggle"])
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

            width: volRow.implicitWidth
            height: volRow.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            Row {
                id: volRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: volItem.muted ? "󰖁" : (volItem.volume > 0.66 ? "󰕾" : (volItem.volume > 0.33 ? "󰖀" : "󰕿"))
                    color: volItem.muted ? Root.Config.red : Root.Config.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Root.Config.iconSize
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                Text {
                    text: Math.round(volItem.volume * 100) + "%"
                    color: volItem.muted ? Root.Config.red : Root.Config.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Root.Config.iconSize - 2
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "music", "call", "music", "toggle"])
            }
        }

        // Network icon
        Item {
            width: netIcon.implicitWidth
            height: netIcon.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: netIcon
                text: root.networkConnected ? (root.networkIsWifi ? "󰤨" : "󰈀") : "󰤭"
                color: root.networkConnected ? Root.Config.green : Root.Config.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Root.Config.iconSize
                anchors.centerIn: parent

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "network_desktop", "call", "networkdesktop", "toggle"])
            }
        }
    }
}
