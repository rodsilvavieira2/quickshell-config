import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import ".." as Root
import "../shared/ui" as DS

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

            DS.WorkspaceChip {
                id: wsIndicator

                property int wsId: index + 1
                property bool isActive: Hyprland.focusedWorkspace != null && Hyprland.focusedWorkspace.id === wsId
                
                property var wsWindows: root.windowList.filter(w => w.workspace.id === wsId)
                property bool hasWindows: wsWindows.length > 0

                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: 22
                text: String(wsIndicator.wsId)
                selected: isActive
                occupied: hasWindows
                clickable: true
                onClicked: Hyprland.dispatch("workspace " + wsIndicator.wsId)
            }
        }
    }
}
