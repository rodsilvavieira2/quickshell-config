import QtQuick
import QtQuick.Layouts

import ".." as Root

Item {
    id: root

    implicitWidth: statusRow.implicitWidth
    implicitHeight: statusRow.implicitHeight

    Row {
        id: statusRow
        anchors.centerIn: parent
        spacing: 10

        // Microphone icon
        Text {
            text: ""
            color: Root.Config.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Root.Config.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
