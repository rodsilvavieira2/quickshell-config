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
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

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

        DS.OverlayScrim {
            anchors.fill: parent
            MouseArea {
                anchors.fill: parent
                onClicked: GlobalStates.searchOpen = false
            }
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

        DS.Panel {
            id: panel
            width: 556
            height: LauncherSearch.results.length > 0 ? 392 : 72
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -42
            padding: 12
            clipContent: false
            backgroundColor: Design.ThemePalette.withAlpha(
                Design.Tokens.color.surfaceContainer,
                Design.ThemeSettings.isDark ? 0.94 : 0.90
            )
            borderColor: Design.ThemePalette.withAlpha(
                Design.Tokens.color.outlineVariant,
                Design.ThemeSettings.isDark ? 0.82 : 0.72
            )
            shadowLevel: Design.Tokens.shadow.lg

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
