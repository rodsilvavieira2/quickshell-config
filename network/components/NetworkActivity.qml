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
    
    property bool active: false
    onActiveChanged: NetworkConnections.active = active
    
    ColumnLayout {
        width: root.width
        spacing: 24
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            
            Text {
                text: "󰈀 Network Activity"
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }
        }
        
        // Info Cards
        GridLayout {
            columns: 4
            Layout.fillWidth: true
            Layout.margins: 16
            columnSpacing: 16
            rowSpacing: 16
            
            InfoCard {
                label: "IP Address"
                value: Nmcli.ethernetDeviceDetails?.ipAddress || "N/A"
                icon: "󰩟"
                iconColor: "#89b4fa" // Blue
            }
            
            InfoCard {
                label: "Gateway"
                value: Nmcli.ethernetDeviceDetails?.gateway || "N/A"
                icon: "󰒄"
                iconColor: "#a6e3a1" // Green
            }
            
            InfoCard {
                label: "DNS"
                value: Nmcli.ethernetDeviceDetails?.dns?.join(", ") || "N/A"
                icon: "󰖩"
                iconColor: "#f9e2af" // Yellow
            }
            
            InfoCard {
                label: "MAC Address"
                value: Nmcli.ethernetDeviceDetails?.macAddress || "N/A"
                icon: "󰇧"
                iconColor: "#cba6f7" // Mauve
            }
        }
        
        // Live Traffic Chart
        LiveTrafficChart {
            Layout.fillWidth: true
            Layout.preferredHeight: 300
            Layout.margins: 16
        }
        
        // Active Connections Table
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            spacing: 16
            
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Active Connections"
                    color: "#cdd6f4"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                // Search Bar
                Rectangle {
                    width: 250
                    height: 36
                    color: "#181825"
                    radius: 8
                    border.color: searchInput.activeFocus ? "#94e2d5" : "#313244"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Text {
                            text: "󰍉"
                            color: "#a6adc8"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                        }
                        
                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: "#cdd6f4"
                            font.pixelSize: 14
                            selectByMouse: true
                            
                            Text {
                                text: "Filter processes..."
                                color: "#585b70"
                                font.pixelSize: 14
                                visible: !parent.text && !parent.activeFocus
                            }
                        }
                    }
                }
            }
            
            // Table Header
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#181825"
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 16
                    
                    Text { 
                        text: "APP"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 150
                        Layout.minimumWidth: 150
                        Layout.maximumWidth: 150
                    }
                    Text { 
                        text: "PROCESS NAME"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text { 
                        text: "PROTOCOL"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 100
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 100
                    }
                    Text { 
                        text: "DOWN/S"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 100
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 100
                        horizontalAlignment: Text.AlignRight 
                    }
                    Text { 
                        text: "UP/S"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 100
                        Layout.minimumWidth: 100
                        Layout.maximumWidth: 100
                        horizontalAlignment: Text.AlignRight 
                    }
                }
            }
            
            // Table Body
            ScrollView {
                id: bodyScroll
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(bodyLayout.implicitHeight, 500)
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: bodyLayout
                    width: bodyScroll.width
                    spacing: 4
                    
                    Repeater {
                        model: (NetworkConnections.connections || []).filter(c => {
                            if (!searchInput.text) return true
                            return (c.appName || "").toLowerCase().includes(searchInput.text.toLowerCase()) ||
                                   (c.pid || "").toString().includes(searchInput.text)
                        })
                        
                        delegate: Rectangle {
                            id: rowRoot
                            Layout.fillWidth: true
                            height: 48
                            color: index % 2 === 0 ? "transparent" : "#181825"
                            radius: 6
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 16
                                
                                // APP Column
                                RowLayout {
                                    Layout.preferredWidth: 150
                                    Layout.minimumWidth: 150
                                    Layout.maximumWidth: 150
                                    spacing: 8
                                    Text {
                                        text: "󰈀"
                                        color: "#94e2d5"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 16
                                    }
                                    Text {
                                        text: modelData.appName
                                        color: "#cdd6f4"
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                                
                                // PROCESS NAME Column
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Text {
                                        text: modelData.appName
                                        color: "#cdd6f4"
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                    }
                                    Rectangle {
                                        width: 45
                                        height: 18
                                        radius: 4
                                        color: "#313244"
                                        visible: modelData.pid !== "Grouped"
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.pid
                                            color: "#a6adc8"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                    Text {
                                        text: `(${modelData.count} sockets)`
                                        color: "#585b70"
                                        font.pixelSize: 12
                                    }
                                    
                                    Item { Layout.fillWidth: true } // Spacer to keep content on the left
                                }
                                
                                // PROTOCOL Column
                                Text {
                                    text: modelData.protocols
                                    color: "#fab387"
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 100
                                    Layout.minimumWidth: 100
                                    Layout.maximumWidth: 100
                                }
                                
                                // DOWN/S Column
                                Text {
                                    text: modelData.rxSpeed > 0.01 ? modelData.rxSpeed.toFixed(2) + " Mbps" : "0.00 Mbps"
                                    color: modelData.rxSpeed > 0.01 ? "#94e2d5" : "#585b70"
                                    font.pixelSize: 14
                                    font.bold: modelData.rxSpeed > 0.01
                                    Layout.preferredWidth: 100
                                    Layout.minimumWidth: 100
                                    Layout.maximumWidth: 100
                                    horizontalAlignment: Text.AlignRight
                                }
                                
                                // UP/S Column
                                Text {
                                    text: modelData.txSpeed > 0.01 ? modelData.txSpeed.toFixed(2) + " Mbps" : "0.00 Mbps"
                                    color: modelData.txSpeed > 0.01 ? "#cba6f7" : "#585b70"
                                    font.pixelSize: 14
                                    font.bold: modelData.txSpeed > 0.01
                                    Layout.preferredWidth: 100
                                    Layout.minimumWidth: 100
                                    Layout.maximumWidth: 100
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                    
                    Text {
                        text: "No active connections found"
                        color: "#585b70"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                        visible: (NetworkConnections.connections || []).length === 0
                    }
                }
            }
        }
        
        // Listening Ports Table
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            spacing: 16
            
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "󰈀 Port Usage"
                    color: "#cdd6f4"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                    font.family: "JetBrainsMono Nerd Font"
                }
                
                // Search Bar
                Rectangle {
                    width: 250
                    height: 36
                    color: "#181825"
                    radius: 8
                    border.color: portSearchInput.activeFocus ? "#f38ba8" : "#313244" // Pinkish border for port search
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Text {
                            text: "󰍉"
                            color: "#a6adc8"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                        }
                        
                        TextInput {
                            id: portSearchInput
                            Layout.fillWidth: true
                            color: "#cdd6f4"
                            font.pixelSize: 14
                            selectByMouse: true
                            
                            Text {
                                text: "Filter ports or processes..."
                                color: "#585b70"
                                font.pixelSize: 14
                                visible: !parent.text && !parent.activeFocus
                            }
                        }
                    }
                }
            }
            
            // Table Header
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#181825"
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 16
                    
                    Text { 
                        text: "PORT"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 80
                        Layout.minimumWidth: 80
                        Layout.maximumWidth: 80
                    }
                    Text { 
                        text: "PROTOCOL"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 80
                        Layout.minimumWidth: 80
                        Layout.maximumWidth: 80
                    }
                    Text { 
                        text: "ADDRESS"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 150
                        Layout.minimumWidth: 150
                        Layout.maximumWidth: 150
                    }
                    Text { 
                        text: "PROCESS"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                    }
                    Text { 
                        text: "PID"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.bold: true
                        Layout.preferredWidth: 60
                        Layout.minimumWidth: 60
                        Layout.maximumWidth: 60
                        horizontalAlignment: Text.AlignRight 
                    }
                }
            }
            
            // Table Body
            ScrollView {
                id: portBodyScroll
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(portBodyLayout.implicitHeight, 400)
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: portBodyLayout
                    width: portBodyScroll.width
                    spacing: 4
                    
                    Repeater {
                        model: (NetworkConnections.listeningPorts || []).filter(p => {
                            if (!portSearchInput.text) return true
                            const search = portSearchInput.text.toLowerCase()
                            return p.port.toLowerCase().includes(search) ||
                                   p.processName.toLowerCase().includes(search) ||
                                   p.protocol.toLowerCase().includes(search) ||
                                   p.pid.toString().includes(search)
                        })
                        
                        delegate: Rectangle {
                            id: portRowRoot
                            Layout.fillWidth: true
                            height: 48
                            color: index % 2 === 0 ? "transparent" : "#181825"
                            radius: 6
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 16
                                
                                // PORT Column
                                Text {
                                    text: modelData.port
                                    color: "#f38ba8" // Red/Pink for ports
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.preferredWidth: 80
                                    Layout.minimumWidth: 80
                                    Layout.maximumWidth: 80
                                }
                                
                                // PROTOCOL Column
                                Text {
                                    text: modelData.protocol
                                    color: "#fab387" // Orange
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 80
                                    Layout.minimumWidth: 80
                                    Layout.maximumWidth: 80
                                }
                                
                                // ADDRESS Column
                                Text {
                                    text: modelData.address === "0.0.0.0" ? "ANY (IPv4)" : (modelData.address === "::" ? "ANY (IPv6)" : modelData.address)
                                    color: "#a6adc8"
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    Layout.preferredWidth: 150
                                    Layout.minimumWidth: 150
                                    Layout.maximumWidth: 150
                                }
                                
                                // PROCESS Column
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Text {
                                        text: "󱪠"
                                        color: "#f38ba8"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 16
                                        visible: modelData.processName !== "Unknown"
                                    }
                                    
                                    Text {
                                        text: modelData.processName
                                        color: "#cdd6f4"
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                                
                                // PID Column
                                Text {
                                    text: modelData.pid
                                    color: "#585b70"
                                    font.pixelSize: 12
                                    font.bold: true
                                    Layout.preferredWidth: 60
                                    Layout.minimumWidth: 60
                                    Layout.maximumWidth: 60
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                    
                    Text {
                        text: "No listening ports found"
                        color: "#585b70"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                        visible: (NetworkConnections.listeningPorts || []).length === 0
                    }
                }
            }
        }
        
        Item { Layout.preferredHeight: 24 }
    }
}
