//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma IconTheme "Suru++"
//@ pragma Env QS_ICON_THEME=Suru++

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "./shared/designsystem" as Design

ShellRoot {
    id: shellRoot

    property bool menuOpen: false
    property int currentIndex: 0

    onMenuOpenChanged: {
        if (menuOpen) {
            currentIndex = 0;
            focusCatcher.forceActiveFocus();
        }
    }

    function triggerCurrentAction() {
        shellRoot.menuOpen = false;
        if (shellRoot.currentIndex === 0) shutdownProc.running = true;
        else if (shellRoot.currentIndex === 1) rebootProc.running = true;
        else if (shellRoot.currentIndex === 2) exitProc.running = true;
    }

    IpcHandler {
        target: "powermenu"
        function toggle() {
            shellRoot.menuOpen = !shellRoot.menuOpen;
        }
        function open() {
            shellRoot.menuOpen = true;
        }
        function close() {
            shellRoot.menuOpen = false;
        }
    }

    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }

    Process {
        id: exitProc
        command: ["hyprctl", "dispatch", "exit"]
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
        
        visible: shellRoot.menuOpen
        color: Design.Tokens.color.scrim
        
        WlrLayershell.namespace: "quickshell:powermenu"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Invisible background area to catch clicks and close the menu
        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.menuOpen = false
        }

        Item {
            id: focusCatcher
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: event => {
                shellRoot.menuOpen = false;
                event.accepted = true;
            }
            Keys.onLeftPressed: event => {
                shellRoot.currentIndex = (shellRoot.currentIndex > 0) ? shellRoot.currentIndex - 1 : 2;
                event.accepted = true;
            }
            Keys.onRightPressed: event => {
                shellRoot.currentIndex = (shellRoot.currentIndex < 2) ? shellRoot.currentIndex + 1 : 0;
                event.accepted = true;
            }
            Keys.onTabPressed: event => {
                if (event.modifiers & Qt.ShiftModifier) {
                    shellRoot.currentIndex = (shellRoot.currentIndex > 0) ? shellRoot.currentIndex - 1 : 2;
                } else {
                    shellRoot.currentIndex = (shellRoot.currentIndex < 2) ? shellRoot.currentIndex + 1 : 0;
                }
                event.accepted = true;
            }
            Keys.onBacktabPressed: event => {
                shellRoot.currentIndex = (shellRoot.currentIndex > 0) ? shellRoot.currentIndex - 1 : 2;
                event.accepted = true;
            }
            Keys.onReturnPressed: event => {
                shellRoot.triggerCurrentAction();
                event.accepted = true;
            }
            Keys.onEnterPressed: event => {
                shellRoot.triggerCurrentAction();
                event.accepted = true;
            }
        }

        Rectangle {
            id: menuBox
            width: layout.implicitWidth + 48
            height: layout.implicitHeight + 48
            anchors.centerIn: parent
            color: Design.Tokens.color.bg.surface
            radius: Design.Tokens.radius.lg
            border.color: Design.Tokens.color.border.strong
            border.width: Design.Tokens.border.width.strong

            // Consume clicks inside the menu box so it doesn't close when clicked
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
            }

            RowLayout {
                id: layout
                anchors.centerIn: parent
                spacing: 16

                Repeater {
                    model: [
                        {
                            name: "Shutdown",
                            cmd: "shutdown",
                            iconPath: "file:///usr/share/icons/Suru++/apps/symbolic/system-shutdown-symbolic.svg"
                        },
                        {
                            name: "Restart",
                            cmd: "reboot",
                            iconPath: "file:///usr/share/icons/Suru++/apps/symbolic/system-reboot-symbolic.svg"
                        },
                        {
                            name: "Exit",
                            cmd: "exit",
                            iconPath: "file:///usr/share/icons/Suru++/apps/symbolic/system-log-out-symbolic.svg"
                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        
                        width: 120
                        height: 120
                        radius: Design.Tokens.radius.md
                        color: index === shellRoot.currentIndex ? Design.Tokens.color.bg.interactive : "transparent"
                        
                        MouseArea {
                            id: btnMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: shellRoot.currentIndex = index
                            onClicked: shellRoot.triggerCurrentAction()
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                source: modelData.iconPath
                                sourceSize: Qt.size(48, 48)
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.name
                                color: Design.Tokens.color.text.primary
                                font.family: Design.Tokens.font.family.body
                                font.pixelSize: Design.Tokens.font.size.body
                                font.weight: Design.Tokens.font.weight.semibold
                            }
                        }
                    }
                }
            }
        }
    }
}
