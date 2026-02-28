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

        Rectangle {
            id: panel
            width: 720
            height: 520
            anchors.centerIn: parent
            color: Appearance.colors.colLayer0
            radius: 16
            border.width: 2
            border.color: "#89b4fa"

            StyledRectangularShadow { target: panel }

            SearchWidget {
                id: searchWidget
                anchors.fill: parent
                anchors.margins: 18
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
