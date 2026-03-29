import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../services"

ScrollView {
    id: root
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    property string connectingSsid: ""
    property bool isConnecting: false

    ColumnLayout {
        width: root.width
        spacing: 24
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            spacing: 16

            Text {
                text: "󰖩 Wi-Fi Scanner"
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }

            // Scan Button
            Button {
                id: scanButton
                flat: true
                enabled: !Nmcli.scanning
                
                contentItem: RowLayout {
                    spacing: 8
                    Text {
                        text: Nmcli.scanning ? "󱑔" : "󰑐"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: "#89b4fa"
                        
                        RotationAnimation on rotation {
                            running: Nmcli.scanning
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                    Text {
                        text: "Scan"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#cdd6f4"
                    }
                }
                
                background: Rectangle {
                    implicitWidth: 100
                    implicitHeight: 36
                    color: scanButton.hovered ? "#313244" : "#181825"
                    radius: 8
                    border.color: "#313244"
                    border.width: 1
                }
                
                onClicked: Nmcli.rescanWifi()
            }
        }

        // Network List
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            spacing: 8

            Repeater {
                model: Nmcli.networks
                
                delegate: NetworkItem {
                    ssid: modelData.ssid
                    strength: modelData.strength
                    isSecure: modelData.isSecure
                    isActive: modelData.active
                    security: modelData.security
                    bssid: modelData.bssid
                }
            }
            
            Text {
                text: "No networks found. Try scanning."
                color: "#585b70"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                visible: Nmcli.networks.length === 0 && !Nmcli.scanning
            }
            
            Text {
                text: "Scanning for networks..."
                color: "#89b4fa"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                visible: Nmcli.networks.length === 0 && Nmcli.scanning
            }
        }
        
        Item { Layout.fillHeight: true }
    }

    // Password Popup
    Popup {
        id: passwordPopup
        anchors.centerIn: parent
        width: 320
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string ssid: ""
        property string bssid: ""

        background: Rectangle {
            color: "#1e1e2e"
            radius: 12
            border.color: "#313244"
            border.width: 2
            
            // Shadow effect
            layer.enabled: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: "Connect to " + passwordPopup.ssid
                color: "#cdd6f4"
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#181825"
                radius: 8
                border.color: passwordInput.activeFocus ? "#89b4fa" : "#313244"
                border.width: 1

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    echoMode: TextInput.Password
                    focus: true
                    verticalAlignment: TextInput.AlignVCenter
                    
                    Text {
                        text: "Enter password..."
                        color: "#585b70"
                        font.pixelSize: 14
                        visible: !parent.text && !parent.activeFocus
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onAccepted: connectButton.clicked()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    id: cancelButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    onClicked: passwordPopup.close()
                    
                    background: Rectangle {
                        color: cancelButton.hovered ? "#313244" : "#181825"
                        radius: 6
                        border.color: "#313244"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: "Cancel"
                        color: "#cdd6f4"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: connectButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    onClicked: {
                        root.isConnecting = true;
                        root.connectingSsid = passwordPopup.ssid;
                        Nmcli.connectToNetwork(passwordPopup.ssid, passwordInput.text, passwordPopup.bssid, result => {
                            root.isConnecting = false;
                            if (result.success) {
                                passwordPopup.close();
                            } else {
                                // Error handling could be added here
                                console.warn("Connection failed: " + result.error);
                            }
                        });
                    }
                    
                    background: Rectangle {
                        color: connectButton.hovered ? "#b4befe" : "#89b4fa"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: "Connect"
                        color: "#1e1e2e"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    component NetworkItem: Rectangle {
        id: item
        required property string ssid
        required property int strength
        required property bool isSecure
        required property bool isActive
        required property string security
        required property string bssid

        Layout.fillWidth: true
        height: 64
        color: isActive ? "#313244" : (mouseArea.containsMouse ? "#181825" : "transparent")
        radius: 10
        border.color: isActive ? "#89b4fa" : "transparent"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Signal Icon
            Text {
                text: {
                    if (strength >= 80) return "󰤨";
                    if (strength >= 60) return "󰤥";
                    if (strength >= 40) return "󰤢";
                    if (strength >= 20) return "󰤟";
                    return "󰤭";
                }
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                color: isActive ? "#89b4fa" : (strength > 50 ? "#a6e3a1" : (strength > 25 ? "#f9e2af" : "#f38ba8"))
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: ssid
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 8
                    Text {
                        text: strength + "%"
                        color: "#a6adc8"
                        font.pixelSize: 12
                    }
                    Text {
                        text: isSecure ? "󰌾 " + security : "󰌿 Open"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // Status / Action
            RowLayout {
                spacing: 12
                
                Text {
                    visible: root.isConnecting && root.connectingSsid === ssid
                    text: "Connecting..."
                    color: "#f9e2af"
                    font.pixelSize: 12
                    font.italic: true
                }

                Text {
                    visible: isActive && !(root.isConnecting && root.connectingSsid === ssid)
                    text: "Connected"
                    color: "#a6e3a1"
                    font.pixelSize: 12
                    font.bold: true
                }

                Button {
                    id: itemConnectButton
                    visible: !isActive && !(root.isConnecting && root.connectingSsid === ssid)
                    onClicked: {
                        root.isConnecting = true;
                        root.connectingSsid = ssid;
                        Nmcli.connectToNetworkWithPasswordCheck(ssid, isSecure, result => {
                            if (result.needsPassword) {
                                root.isConnecting = false;
                                passwordPopup.ssid = ssid;
                                passwordPopup.bssid = bssid;
                                passwordInput.text = "";
                                passwordPopup.open();
                            } else if (result.success) {
                                root.isConnecting = false;
                            } else {
                                root.isConnecting = false;
                            }
                        }, bssid);
                    }
                    
                    background: Rectangle {
                        implicitWidth: 80
                        implicitHeight: 30
                        color: itemConnectButton.hovered ? "#b4befe" : "#89b4fa"
                        radius: 6
                    }
                    
                    contentItem: Text {
                        text: "Connect"
                        color: "#1e1e2e"
                        font.bold: true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    id: disconnectButton
                    visible: isActive && !(root.isConnecting && root.connectingSsid === ssid)
                    onClicked: Nmcli.disconnectFromNetwork()
                    
                    background: Rectangle {
                        implicitWidth: 90
                        implicitHeight: 30
                        color: disconnectButton.hovered ? "#f38ba8" : "transparent"
                        radius: 6
                        border.color: "#f38ba8"
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: "Disconnect"
                        color: disconnectButton.hovered ? "#1e1e2e" : "#f38ba8"
                        font.bold: true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
