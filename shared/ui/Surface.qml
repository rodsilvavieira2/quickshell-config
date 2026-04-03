import QtQuick
import "../designsystem"

Item {
    id: root

    default property alias contentData: content.data
    readonly property Item contentItem: content

    property color backgroundColor: Tokens.color.bg.surface
    property color borderColor: Tokens.color.border.subtle
    property int borderWidth: Tokens.border.width.thin
    property int radius: Tokens.radius.lg
    property int padding: Tokens.component.card.padding
    property int shadowLevel: Tokens.shadow.none

    implicitWidth: Math.max(content.childrenRect.width, content.implicitWidth) + padding * 2
    implicitHeight: Math.max(content.childrenRect.height, content.implicitHeight) + padding * 2

    DesignShadow {
        visible: root.shadowLevel > 0
        target: background
        level: root.shadowLevel
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor
        border.width: root.borderWidth
        border.color: root.borderColor
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
