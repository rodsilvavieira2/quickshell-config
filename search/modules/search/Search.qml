import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../common/widgets"
import "../../services"

Scope {
    id: root

    IpcHandler {
        target: "search"
        function toggle() { GlobalStates.searchOpen = !GlobalStates.searchOpen }
        function open() { GlobalStates.searchOpen = true }
        function close() { GlobalStates.searchOpen = false }
    }

    PanelWindow {
        id: window
        visible: GlobalStates.searchOpen
        color: "transparent"
        WlrLayershell.namespace: "quickshell:search"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        anchors { top: true; bottom: true; left: true; right: true }

        MouseArea {
            anchors.fill: parent
            onClicked: GlobalStates.searchOpen = false
        }

        Item {
            id: focusCatcher
            anchors.fill: parent
            focus: GlobalStates.searchOpen
            Keys.onEscapePressed: event => {
                GlobalStates.searchOpen = false
                event.accepted = true
            }
        }

        StyledRectangularShadow { target: panel }

        Rectangle {
            id: panel
            width: 640
            height: LauncherSearch.results.length > 0 ? 460 : 76
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -60
            color: Appearance.colors.colLayer0
            radius: 14
            border.width: 1
            border.color: Appearance.colors.colLayer0Border
            clip: true

            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            SearchWidget {
                id: searchWidget
                anchors.fill: parent
            }
        }

        Connections {
            target: GlobalStates
            function onSearchOpenChanged() {
                if (GlobalStates.searchOpen) {
                    searchWidget.searchText = ""
                    LauncherSearch.query = ""
                    searchWidget.focusInput()
                }
            }
        }
    }
}
