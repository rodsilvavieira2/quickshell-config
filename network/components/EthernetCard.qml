import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root
    
    required property var device
    
    width: parent ? parent.width : 400
    height: layout.implicitHeight + 24
    color: device.connected ? "#313244" : "#181825"
    radius: 12
    border.color: device.connected ? "#89b4fa" : "#313244"
    border.width: device.connected ? 2 : 1

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "󰈀"
                color: device.connected ? "#89b4fa" : "#a6adc8"
                font.pixelSize: 32
                font.family: "JetBrainsMono Nerd Font"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: device.interface || "Ethernet Interface"
                    color: device.connected ? "#89b4fa" : "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: device.connected ? "Connected" : "Disconnected"
                    color: "#a6adc8"
                    font.pixelSize: 13
                }
            }

            Button {
                text: device.connected ? "Disconnect" : "Connect"
                font.pixelSize: 13
                background: Rectangle {
                    color: device.connected ? "#f38ba8" : "#89b4fa"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "#1e1e2e"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: {
                    if (device.connected) {
                        Nmcli.bringInterfaceDown(device.interface, null);
                    } else {
                        Nmcli.bringInterfaceUp(device.interface, null);
                    }
                }
            }

            Button {
                text: "Reconnect"
                font.pixelSize: 13
                visible: device.connected
                background: Rectangle {
                    color: "#fab387" // Peach
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "#1e1e2e"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: {
                    Nmcli.bringInterfaceDown(device.interface, () => {
                        Nmcli.bringInterfaceUp(device.interface, null);
                    });
                }
            }
        }
        
        // Show Details if Connected and Details are available
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#45475a"
            visible: device.connected && Nmcli.ethernetDeviceDetails !== null
        }

        GridLayout {
            columns: 2
            rowSpacing: 10
            columnSpacing: 16
            Layout.fillWidth: true
            visible: device.connected && Nmcli.ethernetDeviceDetails !== null

            // IP Address
            Text { text: "IP Address:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.ipAddress || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // Gateway
            Text { text: "Gateway:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.gateway || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // DNS
            Text { text: "DNS:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails && Nmcli.ethernetDeviceDetails.dns ? Nmcli.ethernetDeviceDetails.dns.join(", ") || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // MAC Address
            Text { text: "MAC Address:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.macAddress || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // Speed
            Text { text: "Speed:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.speed || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }
        }
    }
}
