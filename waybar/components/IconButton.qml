import QtQuick

import ".." as Root

Rectangle {
    id: root

    property url iconSource: ""
    property color iconColor: Root.Config.text
    property color hoverIconColor: iconColor
    property color backgroundColor: "transparent"
    property color hoverColor: Root.Config.surface0
    property bool clickable: true

    signal clicked()

    readonly property bool hovered: mouseArea.containsMouse

    implicitWidth: Root.Config.iconButtonSize + Root.Config.chipPaddingHorizontal
    implicitHeight: Root.Config.iconButtonSize + Root.Config.chipPaddingVertical
    radius: Root.Config.chipRadius
    color: hovered && clickable ? hoverColor : backgroundColor

    Behavior on color {
        ColorAnimation { duration: 140 }
    }

    LucideIcon {
        anchors.centerIn: parent
        source: root.iconSource
        color: root.hovered && root.clickable ? root.hoverIconColor : root.iconColor
        iconSize: Root.Config.iconSize

        Behavior on color {
            ColorAnimation { duration: 140 }
        }
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
