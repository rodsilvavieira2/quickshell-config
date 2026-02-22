import QtQuick

Item {
    id: root
    required property Flickable target
    property bool vertical: true
    property int fadeSize: 18

    anchors.fill: target
    visible: target.contentHeight > target.height || target.contentWidth > target.width

    Rectangle {
        id: startFade
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: root.vertical ? root.fadeSize : parent.height
        width: root.vertical ? parent.width : root.fadeSize
        visible: root.vertical ? target.contentY > 0 : target.contentX > 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#000000" }
            GradientStop { position: 1.0; color: "#00000000" }
        }
        opacity: 0.25
    }

    Rectangle {
        id: endFade
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: root.vertical ? root.fadeSize : parent.height
        width: root.vertical ? parent.width : root.fadeSize
        visible: root.vertical ? (target.contentY < target.contentHeight - target.height) : (target.contentX < target.contentWidth - target.width)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#000000" }
        }
        opacity: 0.25
    }
}
