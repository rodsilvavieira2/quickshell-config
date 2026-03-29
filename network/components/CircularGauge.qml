import QtQuick
import QtQuick.Layouts

Item {
    id: root
    
    property real value: 0
    property real maxValue: 1000
    property color color: "#94e2d5"
    property string label: "Mbps"
    property bool isTesting: false
    
    width: 240
    height: 240
    
    onValueChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onMaxValueChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        
        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            const centerX = width / 2
            const centerY = height / 2
            const radius = Math.min(width, height) / 2 - 10
            
            // Background track
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0.75 * Math.PI, 2.25 * Math.PI)
            ctx.strokeStyle = "#313244"
            ctx.lineWidth = 12
            ctx.lineCap = "round"
            ctx.stroke()
            
            // Progress arc
            const progress = Math.min(root.value / root.maxValue, 1.0)
            const endAngle = 0.75 * Math.PI + progress * 1.5 * Math.PI
            
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0.75 * Math.PI, endAngle)
            ctx.strokeStyle = root.color
            ctx.lineWidth = 12
            ctx.lineCap = "round"
            ctx.stroke()
            
            // Glow effect
            ctx.shadowBlur = 15
            ctx.shadowColor = root.color
            ctx.stroke()
        }
    }
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4
        
        Text {
            text: root.isTesting ? root.value.toFixed(1) : "READY"
            color: "#cdd6f4"
            font.pixelSize: root.isTesting ? 48 : 32
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            Layout.alignment: Qt.AlignHCenter
        }
        
        Text {
            text: root.label
            color: "#a6adc8"
            font.pixelSize: 14
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            visible: root.isTesting
        }
    }
}
