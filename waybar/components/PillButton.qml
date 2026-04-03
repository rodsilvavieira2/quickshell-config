import QtQuick

import ".." as Local
import "../shared/ui" as DS

Item {
    id: root

    property color baseColor: "transparent"
    property color hoverColor: Local.Config.mantle
    default property alias content: container.data
    signal clicked()

    implicitWidth: pill.implicitWidth
    implicitHeight: parent ? parent.height : pill.implicitHeight

    DS.Chip {
        id: pill
        anchors.fill: parent
        clickable: true
        containerColor: root.baseColor
        hoverContainerColor: root.hoverColor
        pressedContainerColor: root.hoverColor
        borderColor: "transparent"
        horizontalPadding: Local.Config.chipPaddingHorizontal
        verticalPadding: Local.Config.chipPaddingVertical
        onClicked: root.clicked()
    }

    Item {
        id: container
        parent: pill.contentItem
        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height
    }
}
