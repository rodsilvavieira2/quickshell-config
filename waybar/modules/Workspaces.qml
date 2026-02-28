import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import ".." as Root

Item {
    id: root

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Root.Config.pillSpacing

        Repeater {
            model: Root.Config.workspaceCount

            Rectangle {
                id: wsIndicator

                property int wsId: index + 1
                property bool isActive: Hyprland.focusedWorkspace != null && Hyprland.focusedWorkspace.id === wsId

                Layout.preferredWidth: isActive ? 18 : 8
                Layout.preferredHeight: 8
                radius: Root.Config.radius
                color: isActive ? Root.Config.mauve : Root.Config.overlay0

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("workspace " + wsIndicator.wsId)
                    }
                }
            }
        }
    }
}
