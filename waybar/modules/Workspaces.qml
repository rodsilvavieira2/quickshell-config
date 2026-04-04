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

    property var activeWorkspaceIds: {
        let ids = [];
        if (Hyprland.focusedWorkspace != null) {
            ids.push(Hyprland.focusedWorkspace.id);
        }
        for (let i = 0; i < root.windowList.length; i++) {
            if (root.windowList[i].workspace && root.windowList[i].workspace.id > 0) {
                if (ids.indexOf(root.windowList[i].workspace.id) === -1) {
                    ids.push(root.windowList[i].workspace.id);
                }
            }
        }
        ids.sort(function(a, b) { return a - b; });
        if (ids.length === 0) ids = [1];
        return ids;
    }

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
            model: root.activeWorkspaceIds

            DS.WorkspaceChip {
                id: wsIndicator

                property int wsId: modelData
                property bool isActive: Hyprland.focusedWorkspace != null && Hyprland.focusedWorkspace.id === wsId
                
                property var wsWindows: root.windowList.filter(w => w.workspace.id === wsId)
                property bool hasWindows: wsWindows.length > 0

                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                text: String(wsIndicator.wsId)
                selected: isActive
                occupied: hasWindows
                clickable: true

                chipRadius: 999
                containerColor: "transparent"
                hoverContainerColor: Qt.rgba(255/255, 255/255, 255/255, 0.05)
                pressedContainerColor: Qt.rgba(255/255, 255/255, 255/255, 0.10)
                selectedContainerColor: "#E9DDF7"
                borderColor: Qt.rgba(255/255, 255/255, 255/255, 0.18)
                selectedBorderColor: "transparent"
                contentColor: Qt.rgba(255/255, 255/255, 255/255, 0.72)
                selectedContentColor: "#2E2436"
                contentFontSize: 14

                onClicked: Hyprland.dispatch("workspace " + wsIndicator.wsId)
            }
        }
    }
}
