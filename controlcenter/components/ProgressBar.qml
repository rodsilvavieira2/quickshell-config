import QtQuick

Item {
    id: root
    property real value: 0 // 0 to 1
    property color progressColor: "#74c7ec"
    property color backgroundColor: "#313244"
    property string text: ""
    
    height: 36
    
    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: height / 2
        color: root.backgroundColor
        
        Rectangle {
            id: fillRect
            height: parent.height
            width: Math.max(parent.height, parent.width * root.value)
            radius: parent.radius
            color: root.progressColor
            anchors.left: parent.left
            
            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: root.text
            color: "#ffffff"
            font.pixelSize: 14
        }
    }
}