import QtQuick
import "../shared/designsystem" as Design

Rectangle {
    id: root
    property string title: ""
    property color titleColor: Design.Tokens.color.text.primary
    property string fontFamily: ""

    color: Design.Tokens.color.bg.elevated
    radius: Design.Tokens.radius.lg
    border.color: Design.Tokens.color.border.subtle
    border.width: Design.Tokens.border.width.thin

    Text {
        id: titleText
        text: root.title
        color: root.titleColor
        font.family: root.fontFamily !== "" ? root.fontFamily : Design.Tokens.font.family.title
        font.pixelSize: Design.Tokens.font.size.title
        font.bold: true
        font.letterSpacing: 1.1
        visible: root.title !== ""
        anchors {
            top: parent.top
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
    }
}
