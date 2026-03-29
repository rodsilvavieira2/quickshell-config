import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root
    
    color: "#181825"
    radius: 16
    border.color: "#313244"
    border.width: 1
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Text {
                text: "Live Traffic"
                color: "#cdd6f4"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
            }
            
            // Live Indicator
            RowLayout {
                spacing: 8
                
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "#94e2d5" // Teal
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                }
                
                Text {
                    text: "LIVE"
                    color: "#94e2d5" // Teal
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 24
            
            ColumnLayout {
                spacing: 4
                Text { text: "↓ Download"; color: "#a6adc8"; font.pixelSize: 12 }
                Text {
                    text: NetSpeed.downloadMbps.toFixed(2) + " Mbps"
                    color: "#94e2d5" // Teal
                    font.pixelSize: 24
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
            
            ColumnLayout {
                spacing: 4
                Text { text: "↑ Upload"; color: "#a6adc8"; font.pixelSize: 12 }
                Text {
                    text: NetSpeed.uploadMbps.toFixed(2) + " Mbps"
                    color: "#cba6f7" // Mauve
                    font.pixelSize: 24
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
            
            Item { Layout.fillWidth: true }
        }
        
        LargeSpeedChart {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        
        Text {
            text: "Last 60 seconds"
            color: "#585b70"
            font.pixelSize: 11
            font.family: "JetBrainsMono Nerd Font"
            Layout.alignment: Qt.AlignRight
        }
    }
}
