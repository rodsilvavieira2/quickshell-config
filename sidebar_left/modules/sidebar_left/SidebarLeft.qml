import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import "../../services"
import "../../shared/ui" as DS
import "../../shared/designsystem" as Design

Scope {
    id: root

    function resolveScreen() {
        const focusedName = Hyprland.focusedMonitor?.name ?? "";
        for (let index = 0; index < Quickshell.screens.values.length; index++) {
            const screen = Quickshell.screens.values[index];
            if (screen.name === focusedName) return screen;
        }
        return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
    }

    IpcHandler {
        target: "sidebar_left"

        function toggle() { SidebarState.open = !SidebarState.open; }
        function open() { SidebarState.open = true; }
        function close() { SidebarState.open = false; }
    }

    PanelWindow {
        id: window

        screen: root.resolveScreen()
        visible: SidebarState.open || panel.opacity > 0.01
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.namespace: "quickshell:sidebar_left"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: SidebarState.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        DS.OverlayScrim {
            anchors.fill: parent
            opacity: SidebarState.open ? (Design.ThemeSettings.isDark ? 0.44 : 0.20) : 0
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.normal
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: SidebarState.open = false
            }
        }

        Item {
            anchors.fill: parent
            focus: SidebarState.open

            Keys.onEscapePressed: event => {
                SidebarState.open = false;
                event.accepted = true;
            }
        }

        DS.Panel {
            id: panel

            z: 1
            width: Math.min(456, Math.max(396, window.width * 0.34))
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 18
            anchors.bottomMargin: 18
            x: SidebarState.open ? 18 : -width - 28
            padding: 0
            clipContent: true
            opacity: SidebarState.open ? 1 : 0
            backgroundColor: Design.ThemePalette.withAlpha(
                Design.Tokens.color.surfaceContainer,
                Design.ThemeSettings.isDark ? 0.96 : 0.92
            )
            borderColor: Design.ThemePalette.withAlpha(
                Design.Tokens.color.outlineVariant,
                Design.ThemeSettings.isDark ? 0.86 : 0.72
            )
            shadowLevel: Design.Tokens.shadow.lg

            Behavior on x {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.slow
                    easing.type: Design.Tokens.motion.easing.decelerate
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.normal
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
            }

            SidebarPanelContent {
                id: content
                anchors.fill: parent
            }
        }

        Connections {
            target: SidebarState

            function onOpenChanged() {
                if (SidebarState.open) {
                    Qt.callLater(content.focusCurrentTab);
                }
            }
        }
    }
}
