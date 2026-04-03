import QtQuick

import ".." as Root

Item {
    id: root

    property url iconSource: ""
    property color iconColor: Root.Config.text
    property color hoverIconColor: iconColor
    property color backgroundColor: "transparent"
    property color hoverColor: Root.Config.surface0
    property bool clickable: true
    property int buttonSize: Math.max(Root.Config.iconButtonSize + 8, Root.Config.barHeight - 10)

    signal clicked()

    implicitWidth: buttonSize
    implicitHeight: buttonSize

    Rectangle {
        id: buttonBg
        anchors.centerIn: parent
        width: root.buttonSize
        height: root.buttonSize
        radius: width / 2
        color: mouseArea.pressed
            ? root.hoverColor
            : mouseArea.containsMouse
                ? root.hoverColor
                : root.backgroundColor

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }
    }

    LucideIcon {
        anchors.centerIn: buttonBg
        source: root.iconSource
        color: mouseArea.containsMouse && root.clickable ? root.hoverIconColor : root.iconColor
        iconSize: Root.Config.iconSize
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
