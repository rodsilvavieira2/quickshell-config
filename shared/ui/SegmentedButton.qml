import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string text: ""
    property bool selected: false

    implicitHeight: Tokens.component.button.heightMd
    implicitWidth: Math.max(88, label.implicitWidth + Tokens.space.s20 * 2)
    radius: Tokens.shape.full
    color: selected ? ThemePalette.withAlpha(Tokens.color.primary, 0.16) : Tokens.color.surfaceContainerHigh
    border.width: Tokens.border.width.thin
    border.color: selected ? Tokens.color.primary : Tokens.color.outlineVariant

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: ThemePalette.withAlpha(selected ? Tokens.color.primary : Tokens.color.text.primary, mouseArea.containsMouse ? Tokens.stateLayer.hover : 0)
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: selected ? Tokens.color.primary : Tokens.color.text.primary
        font.family: Tokens.font.family.label
        font.pixelSize: Tokens.font.size.label
        font.weight: Tokens.font.weight.semibold
    }
}
