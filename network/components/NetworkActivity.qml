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
                    anchors.margins: 12
                    spacing: 16
                    
                    Text { text: "APP"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 150 }
                    Text { text: "PROCESS NAME"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.fillWidth: true }
                    Text { text: "PROTOCOL"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 100 }
                    Text { text: "DOWN/S"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 100 }
                    Text { text: "UP/S"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 100 }
                }
            }
            
            // Table Body
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Repeater {
                    model: (NetworkConnections.connections || []).filter(c => {
                        if (!searchInput.text) return true
                        return (c.appName || "").toLowerCase().includes(searchInput.text.toLowerCase()) ||
                               (c.pid || "").toString().includes(searchInput.text)
                    })
                    
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: index % 2 === 0 ? "transparent" : "#181825"
                        radius: 6
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16
                            
                            RowLayout {
                                Layout.preferredWidth: 150
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
                                }
                            }
                            
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
                                    width: 40
                                    height: 18
                                    radius: 4
                                    color: "#313244"
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.pid
                                        color: "#a6adc8"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                            
                            Text {
                                text: modelData.protocol.toUpperCase()
                                color: "#fab387"
                                font.pixelSize: 14
                                Layout.preferredWidth: 100
                            }
                            
                            Text {
                                text: "N/A"
                                color: "#94e2d5"
                                font.pixelSize: 14
                                Layout.preferredWidth: 100
                            }
                            
                            Text {
                                text: "N/A"
                                color: "#cba6f7"
                                font.pixelSize: 14
                                Layout.preferredWidth: 100
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
        
        Item { Layout.preferredHeight: 24 }
    }
}
