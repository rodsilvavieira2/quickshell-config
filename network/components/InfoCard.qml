import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    
    required property string label
    required property string value
    required property string icon
    property color iconColor: "#89b4fa"
    
    Layout.fillWidth: true
    Layout.preferredHeight: 80
    color: "#181825"
    radius: 12
    border.color: "#313244"
    border.width: 1
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        Rectangle {
            width: 48
            height: 48
            radius: 24
            color: Qt.rgba(root.iconColor.r, root.iconColor.g, root.iconColor.b, 0.1)
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.iconColor
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            Text {
                text: root.label.toUpperCase()
                color: "#a6adc8"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1
            }
            
            Text {
                text: root.value
                color: "#cdd6f4"
                font.pixelSize: 14
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }
}
