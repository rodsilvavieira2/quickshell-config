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
            
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 280
                height: 280
                
                // Ping Pulse Animation
                Rectangle {
                    id: pulseRing
                    anchors.centerIn: parent
                    width: 240
                    height: 240
                    radius: width / 2
                    color: "transparent"
                    border.width: 4
                    border.color: "#89b4fa"
                    opacity: 0
                    scale: 0.8
                    
                    SequentialAnimation {
                        id: pulseAnim
                        ParallelAnimation {
                            NumberAnimation { target: pulseRing; property: "scale"; from: 0.8; to: 1.5; duration: 800; easing.type: Easing.OutCubic }
                            NumberAnimation { target: pulseRing; property: "opacity"; from: 1.0; to: 0.0; duration: 800; easing.type: Easing.OutCubic }
                        }
                    }
                    
                    Connections {
                        target: SpeedTest
                        function onPingPulse() { pulseAnim.restart() }
                    }
                }

                CircularGauge {
                    id: gauge
                    anchors.centerIn: parent
                    isTesting: SpeedTest.isTesting
                    value: SpeedTest.isTesting ? SpeedTest.liveSpeed : 0
                    maxValue: 1000
                    color: {
                        if (SpeedTest.currentStage === "download") return "#94e2d5"
                        if (SpeedTest.currentStage === "upload") return "#cba6f7"
                        if (SpeedTest.currentStage === "ping") return "#89b4fa"
                        return "#313244"
                    }
                    label: {
                        if (SpeedTest.currentStage === "download") return "Mbps (Down)"
                        if (SpeedTest.currentStage === "upload") return "Mbps (Up)"
                        if (SpeedTest.currentStage === "ping") return "Ping Test"
                        return "Ready"
                    }
                }
            }
            
            // Stage Status and Progress
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4
                visible: SpeedTest.isTesting
                
                Text {
                    text: {
                        const stage = SpeedTest.currentStage
                        if (stage === "ping") return "Analyzing Latency..."
                        if (stage === "download") return "Testing Download Speed..."
                        if (stage === "upload") return "Testing Upload Speed..."
                        return ""
                    }
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: `${SpeedTest.stageTimeRemaining}s remaining`
                    color: "#a6adc8"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            // Controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 24
                
                // Continuous Toggle
                RowLayout {
                    spacing: 8
                    Text {
                        text: "Continuous Mode"
                        color: "#a6adc8"
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Switch {
                        checked: SpeedTest.autoTestEnabled
                        onToggled: SpeedTest.autoTestEnabled = checked
                    }
                }
                
                // Start Button with Glow
                Item {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 56
                    
                    Rectangle {
                        id: startButton
                        anchors.fill: parent
                        color: SpeedTest.isTesting ? "#f38ba8" : (SpeedTest.countdown > 0 ? "#fab387" : "#94e2d5")
                        radius: 12
                        
                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (SpeedTest.isTesting) return "CANCEL TEST"
                                if (SpeedTest.countdown > 0) return `NEXT IN ${SpeedTest.countdown}S`
                                return "START TEST"
                            }
                            color: "#1e1e2e"
                            font.pixelSize: 16
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (SpeedTest.isTesting || SpeedTest.countdown > 0) {
                                    SpeedTest.cancelTest()
                                } else {
                                    SpeedTest.runTest()
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
                text: "Recent Tests (Persistent)"
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
