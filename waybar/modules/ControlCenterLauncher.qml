import QtQuick
import Quickshell

import ".." as Root
import "../components"

Item {
    id: root

    implicitWidth: launcherButton.implicitWidth
    implicitHeight: launcherButton.implicitHeight

    IconButton {
        id: launcherButton
        anchors.centerIn: parent
        iconSource: Qt.resolvedUrl("../assets/settings-2.svg")
        iconColor: Root.Config.text
        hoverIconColor: Root.Config.mauve
        hoverColor: Root.Config.surface0
        onClicked: {
            Quickshell.execDetached(["quickshell", "ipc", "-c", "controlcenter", "call", "controlcenter", "toggle"])
        }
    }
}
