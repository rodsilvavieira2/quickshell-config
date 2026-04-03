import QtQuick
import "../designsystem"

Item {
    id: root

    default property alias contentData: content.data

    property color backgroundColor: Tokens.color.bg.surface
    property color borderColor: Tokens.color.border.subtle
    property int borderWidth: Tokens.border.width.thin
    property int radius: Tokens.radius.lg
    property int padding: Tokens.component.card.padding
    property int shadowLevel: Tokens.shadow.none

    implicitWidth: content.implicitWidth + padding * 2
    implicitHeight: content.implicitHeight + padding * 2

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
