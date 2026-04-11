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
        iconSource: Qt.resolvedUrl("../assets/sidebar-left.svg")
        iconColor: Root.Config.text
        hoverIconColor: Root.Config.blue
        hoverColor: Root.Config.surface0
        onClicked: Quickshell.execDetached([
            "bash",
            "-lc",
            "quickshell ipc -c sidebar_left call sidebar_left toggle >/dev/null 2>&1 || (quickshell -c sidebar_left >/dev/null 2>&1 &)"
        ])
    }
}
