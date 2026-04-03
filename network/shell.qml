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
import "./shared/designsystem" as Design

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    onPanelOpenChanged: {
        NetSpeed.active = panelOpen;
        updateConnectionStatus();
    }

    function updateConnectionStatus() {
        const idx = sidebar.currentIndex;
        NetworkConnections.active = panelOpen && (idx === 0 || idx === 1 || idx === 2);
    }

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
        color: Design.Tokens.color.scrim

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
            color: Design.Tokens.color.bg.surface
            radius: Design.Tokens.radius.lg
            border.color: Design.Tokens.color.border.strong
            border.width: Design.Tokens.border.width.strong
            
            MouseArea { anchors.fill: parent; preventStealing: true }
            
            RowLayout {
                id: layout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Sidebar {
                    id: sidebar
                    Layout.fillHeight: true
                    onTabSelected: index => {
                        stackLayout.currentIndex = index;
                        shellRoot.updateConnectionStatus();
                    }
                }

                StackLayout {
                    id: stackLayout
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: sidebar.currentIndex

                    NetworkActivity {
                        id: networkActivity
                    }

                    ActiveConnectionsView {
                        id: activeConnectionsView
                    }

                    PortUsageView {
                        id: portUsageView
                    }

                    SpeedTestView {
                        id: speedTestView
                    }

                    NetworkSettings {
                        id: networkSettings
                    }
                }
            }
        }
    }
}
