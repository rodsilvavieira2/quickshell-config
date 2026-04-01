//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    IpcHandler {
        target: "music"
        function toggle() { shellRoot.panelOpen = !shellRoot.panelOpen; }
        function open()   { shellRoot.panelOpen = true; }
        function close()  { shellRoot.panelOpen = false; }
    }

    PanelWindow {
        id: window
        visible: shellRoot.panelOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:music"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true; bottom: true; left: true; right: true
        }

        // Background dismiss
        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.panelOpen = false
        }

        Shortcut {
            sequence: "Escape"
            onActivated: shellRoot.panelOpen = false
        }

        // Popup container — 700×620 matching the example layout table
        Item {
            width: 700
            height: 620
            anchors.centerIn: parent

            // Consume clicks so the background dismiss doesn't fire
            MouseArea { anchors.fill: parent; preventStealing: true }

            MusicPopup {
                anchors.fill: parent
            }
        }
    }
}
