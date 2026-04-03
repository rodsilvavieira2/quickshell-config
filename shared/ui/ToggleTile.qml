import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool disabled: false

    implicitHeight: 86
    radius: Tokens.shape.extraLarge
    color: checked
        ? Tokens.color.primaryContainer
        : Tokens.color.surfaceContainer
    border.width: Tokens.border.width.thin
    border.color: checked ? Tokens.color.primary : Tokens.color.outlineVariant
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
        color: ThemePalette.withAlpha(checked ? Tokens.color.primary : Tokens.color.text.primary, Tokens.stateLayer.hover)
        opacity: mouseArea.containsMouse ? 1 : 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Tokens.space.s16
        spacing: Tokens.space.s12

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: Tokens.shape.large
            color: checked
                ? ThemePalette.withAlpha(Tokens.color.primary, 0.14)
                : Tokens.color.surfaceContainerHighest

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: checked ? Tokens.color.primary : Tokens.color.icon.primary
                font.family: Tokens.font.family.icon
                font.pixelSize: 18
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.space.s4

            Text {
                text: root.title
                color: checked ? Tokens.color.text.primary : Tokens.color.text.primary
                font.family: Tokens.font.family.label
                font.pixelSize: Tokens.font.size.body
                font.weight: Tokens.font.weight.semibold
            }

            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                color: checked ? Tokens.color.text.secondary : Tokens.color.text.secondary
                font.family: Tokens.font.family.caption
                font.pixelSize: Tokens.font.size.caption
            }
        }
    }
}
