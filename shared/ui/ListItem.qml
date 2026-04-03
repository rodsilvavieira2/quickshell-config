import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string title: ""
    property string subtitle: ""
    property string valueText: ""
    property bool selected: false

    implicitHeight: Math.max(Tokens.component.listItem.minHeight, contentLayout.implicitHeight + Tokens.component.listItem.paddingY * 2)
    radius: Tokens.radius.lg
    color: selected ? ThemePalette.withAlpha(Tokens.color.accent.primary, ThemeSettings.isDark ? 0.14 : 0.12) : "transparent"

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
        color: mouseArea.containsMouse ? ThemePalette.withAlpha(Tokens.color.text.primary, ThemeSettings.isDark ? 0.05 : 0.04) : "transparent"
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: Tokens.component.listItem.paddingX
        anchors.rightMargin: Tokens.component.listItem.paddingX
        anchors.topMargin: Tokens.component.listItem.paddingY
        anchors.bottomMargin: Tokens.component.listItem.paddingY
        spacing: Tokens.space.s12

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
            }
        }

        Text {
            visible: root.valueText !== ""
            text: root.valueText
            color: Tokens.color.text.secondary
            font.family: Tokens.font.family.label
            font.pixelSize: Tokens.font.size.label
        }
    }
}
