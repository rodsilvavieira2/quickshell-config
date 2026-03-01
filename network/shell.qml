//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "./services"
import "./components"

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    IpcHandler {
        target: "network"
        function toggle() { shellRoot.panelOpen = !shellRoot.panelOpen; }
        function open() { shellRoot.panelOpen = true; }
        function close() { shellRoot.panelOpen = false; }
    }

    PanelWindow {
        id: networkWindow
        
        property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedScreenName) {
                    return Quickshell.screens.values[i];
                }
            }
            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }
        
        visible: shellRoot.panelOpen
        color: "#66000000"

        WlrLayershell.namespace: "quickshell:network"
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
            width: 440
            height: Math.min(layout.implicitHeight + 40, parent.height * 0.8)
            anchors.centerIn: parent
            color: "#1e1e2e"
            radius: 16
            border.color: "#313244"
            border.width: 2
            
            MouseArea { anchors.fill: parent; preventStealing: true }
            
            ColumnLayout {
                id: layout
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                spacing: 16
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "󰈀 Ethernet"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                        font.bold: true
                        color: "#cdd6f4"
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "×"
                        font.pixelSize: 16
                        background: Rectangle { color: "#313244"; radius: 6 }
                        contentItem: Text { text: parent.text; color: "#f38ba8"; font.bold: true; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter }
                        onClicked: shellRoot.panelOpen = false
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#313244"
                }

                // Ethernet List
                ListView {
                    id: networksList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(100, Math.min(contentHeight, 400))
                    clip: true
                    spacing: 12
                    
                    model: Nmcli.ethernetDevices
                    
                    delegate: Item {
                        required property var modelData
                        width: ListView.view.width
                        height: card.height
                        
                        EthernetCard {
                            id: card
                            width: parent.width
                            device: parent.modelData
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "No Ethernet devices found"
                        color: "#a6adc8"
                        font.pixelSize: 16
                        visible: parent.count === 0
                    }
                }
            }
        }
    }
}
