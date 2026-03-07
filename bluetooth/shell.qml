//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    IpcHandler {
        target: "bluetooth"
        function toggle() { 
            shellRoot.panelOpen = !shellRoot.panelOpen; 
            if (shellRoot.panelOpen) {
                deviceList.forceActiveFocus();
                deviceList.currentIndex = 0;
            }
        }
        function open() { 
            shellRoot.panelOpen = true; 
            deviceList.forceActiveFocus();
            deviceList.currentIndex = 0;
        }
        function close() { shellRoot.panelOpen = false; }
    }

    PanelWindow {
        id: window
        visible: shellRoot.panelOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:bluetooth"
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
            height: 600
            anchors.centerIn: parent
            color: "#1e1e2e"
            radius: 16
            border.color: "#313244"
            border.width: 2

            MouseArea { anchors.fill: parent; preventStealing: true }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "Bluetooth"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#cdd6f4"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Adapter Power Toggle (macOS style)
                    Switch {
                        id: bluetoothToggle
                        checked: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
                        Layout.alignment: Qt.AlignVCenter
                        
                        indicator: Rectangle {
                            implicitWidth: 42
                            implicitHeight: 24
                            radius: 12
                            color: bluetoothToggle.checked ? "#89b4fa" : "#313244"
                            border.color: bluetoothToggle.checked ? "#89b4fa" : "#45475a"

                            Rectangle {
                                x: bluetoothToggle.checked ? parent.width - width - 3 : 3
                                y: 3
                                width: 18
                                height: 18
                                radius: 9
                                color: bluetoothToggle.checked ? "#1e1e2e" : "#cdd6f4"
                                
                                Behavior on x {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                                }
                            }
                        }

                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                            }
                        }
                    }

                    // Scan Icon Button
                    Button {
                        id: scanButton
                        property bool isDiscovering: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering
                        visible: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
                        
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        
                        background: Rectangle {
                            color: "transparent"
                        }

                        contentItem: Text {
                            text: scanButton.isDiscovering ? "󰑐" : "󰑓"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 20
                            color: scanButton.isDiscovering ? "#89b4fa" : "#a6adc8"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            
                            RotationAnimator on rotation {
                                from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                                running: scanButton.isDiscovering
                            }
                        }
                        
                        onClicked: {
                            if (Bluetooth.defaultAdapter) {
                                Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering;
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#313244"
                }

                // Device List
                ListView {
                    id: deviceList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    focus: true
                    keyNavigationEnabled: true

                    Keys.onReturnPressed: {
                        if (currentItem && currentItem.deviceData && !currentItem.isProcessing) {
                            currentItem.isProcessing = true;
                            let d = currentItem.deviceData;
                            if (d.connected) {
                                d.connected = false;
                            } else if (d.paired) {
                                d.connected = true;
                            } else {
                                d.pair();
                            }
                        }
                    }

                    // Dynamically sort devices: Connected first, then Paired, then alphabetically
                    model: {
                        let arr = [];
                        if (Bluetooth.devices && Bluetooth.devices.values) {
                            for (let i = 0; i < Bluetooth.devices.values.length; i++) {
                                arr.push(Bluetooth.devices.values[i]);
                            }
                        }
                        return arr.sort(function(a, b) { 
                            return (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name); 
                        });
                    }

                    delegate: Rectangle {
                        property var deviceData: modelData
                        property bool isProcessing: false

                        Connections {
                            target: deviceData
                            function onConnectedChanged() {
                                isProcessing = false;
                            }
                            function onPairedChanged() {
                                isProcessing = false;
                            }
                        }

                        width: ListView.view.width
                        height: 60
                        color: ListView.isCurrentItem ? Qt.rgba(205/255, 214/255, 244/255, 0.1) : (modelData.connected ? Qt.rgba(137/255, 180/255, 250/255, 0.15) : "#181825")
                        radius: 12
                        border.color: ListView.isCurrentItem ? "#cdd6f4" : (modelData.connected ? "#89b4fa" : "#313244")
                        border.width: ListView.isCurrentItem ? 2 : 1

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                deviceList.forceActiveFocus();
                                deviceList.currentIndex = index;
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // Device Icon
                            Text {
                                text: modelData.icon === "audio-card" || modelData.icon === "audio-headphones" ? "󰋋" :
                                      modelData.icon === "input-keyboard" ? "󰌌" :
                                      modelData.icon === "input-mouse" ? "󰍽" :
                                      modelData.icon === "phone" ? "󰄜" : "󰂯"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 20
                                color: modelData.connected ? "#89b4fa" : "#a6adc8"
                            }

                            // Device Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.name || "Unknown Device"
                                    font.pixelSize: 14
                                    color: "#cdd6f4"
                                    font.bold: modelData.connected
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                                    font.pixelSize: 12
                                    color: modelData.connected ? "#a6e3a1" : "#a6adc8"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // Loading Indicator
                            Text {
                                text: "󰑐"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                color: "#89b4fa"
                                visible: isProcessing
                                Layout.alignment: Qt.AlignVCenter
                                RotationAnimator on rotation {
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: isProcessing
                                }
                            }

                            // Connect/Disconnect Button
                            Button {
                                text: modelData.connected ? "󰌿" : "󰌷"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                visible: (modelData.paired || modelData.connected) && !isProcessing
                                
                                background: Rectangle {
                                    color: "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: modelData.connected ? "#f38ba8" : "#89b4fa"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    isProcessing = true;
                                    if (modelData.connected) {
                                        modelData.connected = false;
                                    } else {
                                        modelData.connected = true;
                                    }
                                }
                            }

                            // Pair Button
                            Button {
                                text: "Pair"
                                font.pixelSize: 12
                                visible: !modelData.paired && !modelData.connected && !isProcessing
                                
                                background: Rectangle {
                                    color: "#313244"
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: "#cdd6f4"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    isProcessing = true;
                                    modelData.pair();
                                }
                            }
                        }
                    }

                    // Placeholder if Bluetooth is off or no devices found
                    Text {
                        anchors.centerIn: parent
                        text: (Bluetooth.defaultAdapter && !Bluetooth.defaultAdapter.enabled) ? "Bluetooth is disabled" : "No devices found"
                        color: "#a6adc8"
                        font.pixelSize: 14
                        visible: deviceList.count === 0
                    }
                }
            }
        }
    }
}