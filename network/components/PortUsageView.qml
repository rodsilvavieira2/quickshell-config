import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../services"

ColumnLayout {
    id: root
    spacing: 16
    
    RowLayout {
        Layout.fillWidth: true
        
        Text {
            text: "󰈀 Port Usage"
            color: "#cdd6f4"
            font.pixelSize: 24
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
            border.color: portSearchInput.activeFocus ? "#f38ba8" : "#313244"
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
        Layout.fillHeight: true
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
