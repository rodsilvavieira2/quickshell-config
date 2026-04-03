import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import ".." as Root

Item {
    id: root

    property string timeString: ""
    property string dateString: ""

    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    function updateDateTime() {
        const now = new Date();
        root.timeString = Qt.formatDateTime(now, "hh:mm AP");
        root.dateString = Qt.formatDateTime(now, "dddd, MMMM dd");
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateDateTime()
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
                font.pixelSize: 14
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
    }
}
