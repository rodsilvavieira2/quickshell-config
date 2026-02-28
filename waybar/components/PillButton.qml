import QtQuick
import QtQuick.Layouts

import ".." as Local

Rectangle {
    id: root
    
    // Default properties that can be overridden
    property color baseColor: "transparent"
    property color hoverColor: Local.Config.mantle
    default property alias content: container.data
    signal clicked()
    
    width: container.implicitWidth + Local.Config.paddingHorizontal * 2
    height: parent.height
    radius: Local.Config.radius
    
    // Animated color transition
    color: mouseArea.containsMouse ? hoverColor : baseColor
    Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }
    
    Item {
        id: container
        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
