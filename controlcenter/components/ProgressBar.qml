import QtQuick

Item {
    id: root
    property real value: 0 // 0 to 1
    property color progressColor: "#74c7ec"
    property color backgroundColor: "#313244"
    property string text: ""
    property real cornerRadius: height / 2
    property string fontFamily: ""
    
    height: 32
    
    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.backgroundColor
        
        Rectangle {
            id: fillRect
            height: parent.height
            width: Math.max(parent.height, parent.width * root.value)
            radius: root.cornerRadius
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
            font.family: root.fontFamily !== "" ? root.fontFamily : font.family
            font.pixelSize: 14
        }
    }
}
