import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import ".." as Root

Item {
    id: root

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property var windowList: []

    function updateWindowList() {
        if (!getClients.running) {
            getClients.running = true;
        }
    }

    Component.onCompleted: {
        updateWindowList();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            root.updateWindowList();
        }
    }

    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            id: clientsCollector
            onStreamFinished: {
                if (clientsCollector.text.length > 0) {
                    try {
                        root.windowList = JSON.parse(clientsCollector.text);
                    } catch (e) {
                        console.error("Failed to parse hyprctl clients: " + e);
                    }
                }
            }
        }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: Root.Config.workspaceCount

            Rectangle {
                id: wsIndicator

                property int wsId: index + 1
                property bool isActive: Hyprland.focusedWorkspace != null && Hyprland.focusedWorkspace.id === wsId
                
                property var wsWindows: root.windowList.filter(w => w.workspace.id === wsId)
                property bool hasWindows: wsWindows.length > 0

                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 7
                
                color: isActive ? Root.Config.mauve : (hasWindows ? Root.Config.surface0 : "transparent")

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                }

                Text {
                    anchors.centerIn: parent
                    text: wsIndicator.wsId
                    color: wsIndicator.isActive ? Root.Config.crust : Root.Config.subtext1
                    font.family: Root.Config.textFontFamily
                    font.pixelSize: 11
                    font.bold: wsIndicator.isActive

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }
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
