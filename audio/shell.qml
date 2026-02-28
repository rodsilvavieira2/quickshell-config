//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "./components"

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    AudioService {
        id: globalAudioService
    }

    IpcHandler {
        target: "audio"
        function toggle() { 
            shellRoot.panelOpen = !shellRoot.panelOpen; 
            if (shellRoot.panelOpen) {
                audioCard.forceActiveFocus();
            }
        }
        function open() { 
            shellRoot.panelOpen = true; 
            audioCard.forceActiveFocus();
        }
        function close() { shellRoot.panelOpen = false; }
    }

    PanelWindow {
        id: window
        visible: shellRoot.panelOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:audio"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true; bottom: true; left: true; right: true
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
            width: 450
            height: 350
            anchors.centerIn: parent
            color: "#1e1e2e"
            radius: 16
            border.color: "#313244"
            border.width: 2

            MouseArea { anchors.fill: parent; preventStealing: true }

            AudioCard {
                id: audioCard
                focus: true
                anchors.fill: parent
                // Remove the internal border since the parent Rectangle handles it
                border.width: 0 
                color: "transparent"
                
                audioService: globalAudioService
                uiFontFamily: "JetBrainsMono Nerd Font"
            }
        }
    }
}