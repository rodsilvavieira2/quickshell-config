import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import ".." as Root

Item {
    id: root

    property string timeString: ""
    property string dateString: ""
    property string weatherIcon: ""
    property string weatherTemp: "--°C"
    readonly property string weatherScriptPath: Qt.resolvedUrl("../../calendar/weather.sh").toString().replace(/^file:\/\//, "")

    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    function updateDateTime() {
        const now = new Date();
        root.timeString = Qt.formatDateTime(now, "hh:mm:ss AP");
        root.dateString = Qt.formatDateTime(now, "dddd, MMMM dd");
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateDateTime()
    }

    Process {
        id: weatherPoller
        command: ["bash", "-c", '"' + root.weatherScriptPath + '" --json >/dev/null 2>&1; "' + root.weatherScriptPath + '" --current-icon; "' + root.weatherScriptPath + '" --current-temp']
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length >= 2) {
                    root.weatherIcon = lines[0] || "";
                    root.weatherTemp = lines[1] || "--°C";
                }
            }
        }
    }

    Timer {
        interval: 900000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherPoller.running = true
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "calendar", "call", "calendar", "toggle"])
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 16

        ColumnLayout {
            spacing: -2

            Text {
                text: root.timeString
                color: Root.Config.blue
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: root.dateString
                color: Root.Config.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
            }
        }

        RowLayout {
            spacing: 6

            Text {
                text: root.weatherIcon
                color: Root.Config.yellow
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
            }

            Text {
                text: root.weatherTemp
                color: Root.Config.peach
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.bold: true
            }
        }
    }
}
