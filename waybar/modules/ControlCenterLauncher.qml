import QtQuick
import Quickshell

import ".." as Root

Item {
    id: root

    implicitWidth: gearIcon.implicitWidth
    implicitHeight: Root.Config.barHeight

    Text {
        id: gearIcon
        anchors.centerIn: parent
        text: "󰒓" // Gear icon
        color: mouseArea.containsMouse ? Root.Config.mauve : Root.Config.text
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Root.Config.iconSize + 2
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["quickshell", "ipc", "-c", "desktop_controlcenter", "call", "desktop_controlcenter", "toggle"])
        }
    }
}
