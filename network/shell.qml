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

    onPanelOpenChanged: NetSpeed.active = panelOpen

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
            width: parent.width * 0.70
            height: parent.height * 0.85
            anchors.centerIn: parent
            color: "#1e1e2e"
            radius: 16
            border.color: "#313244"
            border.width: 2
            
            MouseArea { anchors.fill: parent; preventStealing: true }
            
            ColumnLayout {
                id: layout
                anchors.fill: parent
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
                    Layout.fillHeight: true
                    clip: true
                    spacing: 12
                    focus: true
                    keyNavigationEnabled: true
                    keyNavigationWraps: true
                    highlightMoveDuration: 150
                    boundsBehavior: Flickable.StopAtBounds

                    model: Nmcli.ethernetDevices

                    // Reset to first card and focus list whenever panel opens
                    Connections {
                        target: shellRoot
                        function onPanelOpenChanged() {
                            if (shellRoot.panelOpen) {
                                networksList.currentIndex = 0
                                networksList.forceActiveFocus()
                            }
                        }
                    }

                    // Tab / Enter / Space — delegate to the focused card
                    Keys.onPressed: event => {
                        const item = networksList.currentItem
                        if (!item) return

                        if (event.key === Qt.Key_Tab) {
                            item.card.cycleFocus(event.modifiers & Qt.ShiftModifier ? -1 : 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                   || event.key === Qt.Key_Space) {
                            item.card.activateAction()
                            event.accepted = true
                        }
                    }

                    delegate: Item {
                        id: delegateItem
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        height: card.height

                        property alias card: card

                        EthernetCard {
                            id: card
                            width: parent.width
                            device: delegateItem.modelData
                            isSelected: delegateItem.ListView.isCurrentItem
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
