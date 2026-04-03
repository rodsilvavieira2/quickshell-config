import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string icon: ""
    property string text: ""
    property bool selected: false

    implicitHeight: Tokens.component.drawer.itemHeight
    radius: Tokens.component.drawer.itemRadius
    color: selected ? ThemePalette.withAlpha(Tokens.color.primary, 0.16) : "transparent"
    border.width: selected ? Tokens.border.width.thin : 0
    border.color: selected ? ThemePalette.withAlpha(Tokens.color.primary, 0.34) : "transparent"

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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.space.s16
        anchors.rightMargin: Tokens.space.s16
        spacing: Tokens.space.s12

        Text {
            text: root.icon
            color: selected ? Tokens.color.primary : Tokens.color.text.secondary
            font.family: Tokens.font.family.icon
            font.pixelSize: Tokens.font.size.body
        }

        Text {
            text: root.text
            color: selected ? Tokens.color.text.primary : Tokens.color.text.primary
            font.family: Tokens.font.family.label
            font.pixelSize: Tokens.font.size.label
            font.weight: Tokens.font.weight.semibold
            Layout.fillWidth: true
        }
    }
}
