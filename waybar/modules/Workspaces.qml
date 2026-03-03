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

                property int iconSpacing: 6
                property int iconSize: 16
                property int pillHorizontalPadding: 8

                // Dynamic width: if it has windows, calculate width based on icons; if not, standard dot/pill
                Layout.preferredWidth: hasWindows ? (wsWindows.length * iconSize + Math.max(0, wsWindows.length - 1) * iconSpacing + pillHorizontalPadding * 2) : (isActive ? 24 : 12)
                Layout.preferredHeight: hasWindows ? 26 : 12
                radius: hasWindows ? 13 : 6
                
                // Color logic: if active and has windows -> a slightly lighter surface or bordered
                // If inactive and has windows -> standard surface
                // If active and empty -> mauve pill
                // If inactive and empty -> overlay0 dot
                color: hasWindows ? (isActive ? Root.Config.surface2 : Root.Config.surface1) : (isActive ? Root.Config.mauve : Root.Config.overlay0)

                border.color: isActive && hasWindows ? Root.Config.mauve : "transparent"
                border.width: isActive && hasWindows ? 1 : 0

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
                }
                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
                }
                Behavior on radius {
                    NumberAnimation { duration: 250; easing.type: Easing.OutQuint }
                }
                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: wsIndicator.iconSpacing
                    visible: parent.hasWindows

                    Repeater {
                        model: wsIndicator.wsWindows

                        Image {
                            required property var modelData

                            property var appEntry: DesktopEntries.heuristicLookup(modelData.class || modelData.initialClass)
                            property string iconPath: Quickshell.iconPath(appEntry?.icon ?? modelData.class ?? modelData.initialClass ?? "application-x-executable", "image-missing")

                            source: iconPath
                            width: wsIndicator.iconSize
                            height: wsIndicator.iconSize
                            sourceSize: Qt.size(width, height)
                            fillMode: Image.PreserveAspectFit
                        }
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
