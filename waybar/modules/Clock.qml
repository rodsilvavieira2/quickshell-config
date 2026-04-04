import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import ".." as Root
import "../shared/ui" as DS

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
        id: contentArea
        anchors.centerIn: parent
        implicitWidth: clockLayout.implicitWidth
        implicitHeight: clockLayout.implicitHeight
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "calendar", "call", "calendar", "toggle"])

        RowLayout {
            id: clockLayout
            anchors.centerIn: parent
            spacing: 8

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.timeString
                color: Qt.rgba(255/255, 255/255, 255/255, 0.92)
                font.family: Root.Config.textFontFamily
                font.pixelSize: 16
                font.weight: 600
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: 4
                implicitHeight: 4
                radius: 2
                color: Qt.rgba(255/255, 255/255, 255/255, 0.4)
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.dateString
                color: Qt.rgba(255/255, 255/255, 255/255, 0.72)
                font.family: Root.Config.textFontFamily
                font.pixelSize: 14
                font.weight: 500
            }
        }
    }
}
