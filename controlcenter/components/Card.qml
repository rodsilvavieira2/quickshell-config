import QtQuick

Rectangle {
    id: root
    property string title: ""
    property color titleColor: "#cdd6f4"
    property string fontFamily: ""

    color: "#181825" // Mantle
    radius: 8
    border.color: "#313244"
    border.width: 1

    Text {
        id: titleText
        text: root.title
        color: root.titleColor
        font.family: root.fontFamily !== "" ? root.fontFamily : font.family
        font.pixelSize: 16
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
