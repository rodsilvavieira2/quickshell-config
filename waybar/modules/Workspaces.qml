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
        spacing: Root.Config.pillSpacing

        Repeater {
            model: Root.Config.workspaceCount

            Rectangle {
                id: wsIndicator

                property int wsId: index + 1
                property bool isActive: Hyprland.focusedWorkspace != null && Hyprland.focusedWorkspace.id === wsId
                
                // Get up to 4 windows for this workspace
                property var wsWindows: root.windowList.filter(w => w.workspace.id === wsId).slice(0, 4)
                property bool hasWindows: wsWindows.length > 0

                // We change width based on how many icons are shown
                Layout.preferredWidth: hasWindows ? (wsWindows.length * 18 + 4) : (isActive ? 18 : 8)
                Layout.preferredHeight: hasWindows ? 20 : 8
                radius: hasWindows ? 4 : Root.Config.radius
                color: hasWindows ? "transparent" : (isActive ? Root.Config.mauve : Root.Config.overlay0)

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    visible: parent.hasWindows

                    Repeater {
                        model: wsIndicator.wsWindows

                        Image {
                            required property var modelData

                            property var appEntry: DesktopEntries.heuristicLookup(modelData.class || modelData.initialClass)
                            property string iconPath: Quickshell.iconPath(appEntry?.icon ?? modelData.class ?? modelData.initialClass ?? "application-x-executable", "image-missing")

                            source: iconPath
                            width: 16
                            height: 16
                            sourceSize: Qt.size(width, height)
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }

                // Small active indicator line for when an icon is showing
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: -6
                    width: 12
                    height: 2
                    radius: 1
                    color: Root.Config.mauve
                    visible: parent.isActive && parent.hasWindows
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
