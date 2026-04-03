import QtQuick
import Quickshell

import ".." as Root

Item {
    id: root

    implicitWidth: powerIcon.implicitWidth
    implicitHeight: powerIcon.implicitHeight

    Text {
        id: powerIcon
        anchors.centerIn: parent
        text: ""
        color: mouseArea.containsMouse ? Root.Config.red : Root.Config.subtext0
        font.family: Root.Config.iconFontFamily
        font.pixelSize: Root.Config.iconSize

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
