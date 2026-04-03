//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: shellRoot

    property bool wallpaperOpen: false

    IpcHandler {
        target: "wallpaper"

        function toggle() {
            shellRoot.wallpaperOpen = !shellRoot.wallpaperOpen;
        }

        function open() {
            shellRoot.wallpaperOpen = true;
        }

        function close() {
            shellRoot.wallpaperOpen = false;
        }
    }

    PanelWindow {
        id: window

        property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""

        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedScreenName) {
                    return Quickshell.screens.values[i];
                }
            }

            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }

        visible: shellRoot.wallpaperOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:wallpaper"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.32)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.wallpaperOpen = false
        }

        Item {
            anchors.fill: parent
            anchors.margins: 36

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            WallpaperPicker {
                id: picker

                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                focus: shellRoot.wallpaperOpen

                onCloseRequested: shellRoot.wallpaperOpen = false
            }
        }
    }
}
