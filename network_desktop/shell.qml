//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    IpcHandler {
        target: "networkdesktop"

        function toggle() {
            shellRoot.panelOpen = !shellRoot.panelOpen;
        }

        function open() {
            shellRoot.panelOpen = true;
        }

        function close() {
            shellRoot.panelOpen = false;
        }
    }

    PanelWindow {
        id: panel

        property string focusedScreenName: Hyprland.focusedMonitor?.name ?? ""

        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                const s = Quickshell.screens.values[i];
                if (s.name === focusedScreenName)
                    return s;
            }

            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }

        visible: shellRoot.panelOpen
        color: "#66000000"

        WlrLayershell.namespace: "quickshell:network_desktop"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.panelOpen = false
        }

        Shortcut {
            sequence: "Escape"
            onActivated: shellRoot.panelOpen = false
        }

        Rectangle {
            width: Math.min(parent.width * 0.8, 1120)
            height: Math.min(parent.height * 0.82, 760)
            anchors.centerIn: parent
            radius: 18
            color: "#1e1e2e"
            border.color: "#313244"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                preventStealing: true
            }

            NetworkPopup {
                anchors.fill: parent
                anchors.margins: 18
            }
        }
    }
}
