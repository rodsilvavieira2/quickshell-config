import QtQuick
import "../shared/designsystem" as Design

Item {
    id: root
    property real value: 0 // 0 to 1
    property color progressColor: Design.Tokens.color.info
    property color backgroundColor: Design.Tokens.color.bg.interactive
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
            color: Design.Tokens.color.text.primary
            font.family: root.fontFamily !== "" ? root.fontFamily : Design.Tokens.font.family.body
            font.pixelSize: Design.Tokens.font.size.body
        }
    }
}
