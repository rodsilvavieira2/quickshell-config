import QtQuick
import Quickshell

import ".." as Root
import "../shared/ui" as DS

Item {
    id: root

    implicitWidth: powerIcon.implicitWidth
    implicitHeight: powerIcon.implicitHeight

    DS.LucideIcon {
        id: powerIcon
        anchors.centerIn: parent
        name: "power"
        color: mouseArea.containsMouse ? Root.Config.red : Root.Config.subtext0
        iconSize: Root.Config.iconSize

        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("Power menu triggered")
        }
    }
}
