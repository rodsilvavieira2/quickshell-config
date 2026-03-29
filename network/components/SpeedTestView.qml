import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../services"

ScrollView {
    id: root
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    
    ColumnLayout {
        width: root.width
        spacing: 32
        Layout.margins: 24
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "󰓅 Speed Test"
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }
        }
        
        // Gauge Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 24
            Layout.alignment: Qt.AlignHCenter
            
            CircularGauge {
                id: gauge
                Layout.alignment: Qt.AlignHCenter
                isTesting: SpeedTest.isTesting
                value: {
                    if (SpeedTest.isTesting) {
                        if (SpeedTest.downloadSpeed === "Testing...") return 0
                        if (SpeedTest.uploadSpeed === "Waiting...") return parseFloat(SpeedTest.downloadSpeed)
                        return parseFloat(SpeedTest.uploadSpeed)
                    }
                    return 0
                }
                maxValue: 1000
                color: SpeedTest.uploadSpeed === "Waiting..." ? "#94e2d5" : "#cba6f7"
                label: SpeedTest.uploadSpeed === "Waiting..." ? "Mbps (Down)" : "Mbps (Up)"
            }
            
            // Start Button with Glow
            Item {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 56
                Layout.alignment: Qt.AlignHCenter
                
                Rectangle {
                    id: startButton
                    anchors.fill: parent
                    color: SpeedTest.isTesting ? "#f38ba8" : "#94e2d5"
                    radius: 12
                    
                    Text {
                        anchors.centerIn: parent
                        text: SpeedTest.isTesting ? "CANCEL TEST" : "START TEST"
                        color: "#1e1e2e"
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (SpeedTest.isTesting) {
                                SpeedTest.cancelTest()
                            } else {
                                SpeedTest.runTest(Nmcli.activeInterface)
                            }
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                
                MultiEffect {
                    source: startButton
                    anchors.fill: startButton
                    shadowEnabled: true
                    shadowColor: startButton.color
                    shadowBlur: 0.8
                    shadowOpacity: 0.6
                    visible: !SpeedTest.isTesting
                }
            }
        }
        
        // Stats Cards
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            InfoCard {
                label: "PING"
                value: SpeedTest.ping
                icon: "󰓅"
                iconColor: "#fab387" // Peach
            }
            
            InfoCard {
                label: "JITTER"
                value: SpeedTest.jitter
                icon: "󰓼"
                iconColor: "#f9e2af" // Yellow
            }
            
            InfoCard {
                label: "PACKET LOSS"
                value: SpeedTest.packetLoss
                icon: "󰒄"
                iconColor: "#f38ba8" // Red
            }
        }
        
        // Recent Tests Table
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            
            Text {
                text: "Recent Tests"
                color: "#cdd6f4"
                font.pixelSize: 18
                font.bold: true
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
                    
                    Text { text: "DATE"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.fillWidth: true }
                    Text { text: "DOWNLOAD"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 100 }
                    Text { text: "UPLOAD"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 100 }
                    Text { text: "PING"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 80 }
                    Text { text: "LOSS"; color: "#a6adc8"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 80 }
                }
            }
            
            // Table Body
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Repeater {
                    model: SpeedTest.testHistory
                    
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: index % 2 === 0 ? "transparent" : "#181825"
                        radius: 6
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16
                            
                            Text {
                                text: modelData.timestamp
                                color: "#cdd6f4"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: modelData.download
                                color: "#94e2d5"
                                font.pixelSize: 14
                                font.bold: true
                                Layout.preferredWidth: 100
                            }
                            
                            Text {
                                text: modelData.upload
                                color: "#cba6f7"
                                font.pixelSize: 14
                                font.bold: true
                                Layout.preferredWidth: 100
                            }
                            
                            Text {
                                text: modelData.ping
                                color: "#fab387"
                                font.pixelSize: 14
                                Layout.preferredWidth: 80
                            }
                            
                            Text {
                                text: modelData.loss
                                color: "#f38ba8"
                                font.pixelSize: 14
                                Layout.preferredWidth: 80
                            }
                        }
                    }
                }
                
                Text {
                    text: "No recent tests found"
                    color: "#585b70"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignHCenter
                    visible: SpeedTest.testHistory.length === 0
                }
            }
        }
        
        Item { Layout.preferredHeight: 24 }
    }
}
