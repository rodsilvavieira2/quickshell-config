//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "common"
import "modules"
import "services"

ShellRoot {
    id: root

    IpcHandler {
        target: "github_dashboard"
        function toggle() { GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen }
        function open() { GlobalStates.dashboardOpen = true }
        function close() { GlobalStates.dashboardOpen = false }
    }

    PanelWindow {
        id: dashboardWindow
        visible: GlobalStates.dashboardOpen
        
        WlrLayershell.namespace: "github-dashboard"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        anchors { top: true; bottom: true; left: true; right: true }

        MouseArea {
            anchors.fill: parent
            onClicked: GlobalStates.dashboardOpen = false
        }

        Item {
            id: focusCatcher
            anchors.fill: parent
            focus: GlobalStates.dashboardOpen
            Keys.onEscapePressed: event => {
                GlobalStates.dashboardOpen = false
                event.accepted = true
            }
        }

        color: "transparent"

        DashboardWidget {
            id: widget
            anchors.centerIn: parent
            // Remove the hardcoded fetchQuota from Component.onCompleted and let it run when toggled
        }

        Connections {
            target: GlobalStates
            function onDashboardOpenChanged() {
                if (GlobalStates.dashboardOpen) {
                    widget.fetchData()
                }
            }
        }
    }
}
