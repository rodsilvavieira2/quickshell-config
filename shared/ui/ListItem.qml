import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property string valueText: ""
    property string trailingIcon: ""
    property bool selected: false
    property bool disabled: false

    implicitHeight: Math.max(Tokens.component.listItem.minHeight, contentLayout.implicitHeight + Tokens.component.listItem.paddingY * 2)
    radius: Tokens.shape.large
    color: selected ? ThemePalette.withAlpha(Tokens.color.primary, Tokens.stateLayer.selected) : "transparent"
    border.width: selected ? Tokens.border.width.thin : 0
    border.color: selected ? ThemePalette.withAlpha(Tokens.color.primary, 0.28) : "transparent"
    opacity: disabled ? Tokens.opacities.disabled : 1

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: !root.disabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: mouseArea.containsMouse ? ThemePalette.withAlpha(Tokens.color.text.primary, Tokens.stateLayer.hover) : "transparent"
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: Tokens.component.listItem.paddingX
        anchors.rightMargin: Tokens.component.listItem.paddingX
        anchors.topMargin: Tokens.component.listItem.paddingY
        anchors.bottomMargin: Tokens.component.listItem.paddingY
        spacing: Tokens.space.s12

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: selected ? Tokens.color.primary : Tokens.color.icon.secondary
            font.family: Tokens.font.family.icon
            font.pixelSize: Tokens.font.size.title
            Layout.alignment: Qt.AlignTop
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.space.s4

            Text {
                text: root.title
                color: Tokens.color.text.primary
                font.family: Tokens.font.family.body
                font.pixelSize: Tokens.font.size.body
                font.weight: Tokens.font.weight.medium
            }

            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                color: Tokens.color.text.secondary
                font.family: Tokens.font.family.caption
                font.pixelSize: Tokens.font.size.caption
                wrapMode: Text.Wrap
            }
        }

        Text {
            visible: root.valueText !== ""
            text: root.valueText
            color: selected ? Tokens.color.primary : Tokens.color.text.secondary
            font.family: Tokens.font.family.label
            font.pixelSize: Tokens.font.size.label
        }

        Text {
            visible: root.trailingIcon !== ""
            text: root.trailingIcon
            color: Tokens.color.icon.secondary
            font.family: Tokens.font.family.icon
            font.pixelSize: Tokens.font.size.body
        }
    }
}
