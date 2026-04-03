import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal toggled(bool checked)

    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool rowEnabled: true

    implicitHeight: Math.max(Tokens.component.settingRow.minHeight, contentLayout.implicitHeight + Tokens.component.settingRow.paddingY * 2)
    radius: Tokens.component.settingRow.radius
    color: Tokens.color.surfaceContainerLow
    border.width: Tokens.border.width.thin
    border.color: Tokens.color.outlineVariant
    opacity: rowEnabled ? 1 : Tokens.opacities.disabled

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.rowEnabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: ThemePalette.withAlpha(Tokens.color.text.primary, mouseArea.containsMouse ? Tokens.stateLayer.hover : 0)
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: Tokens.component.settingRow.paddingX
        anchors.rightMargin: Tokens.component.settingRow.paddingX
        anchors.topMargin: Tokens.component.settingRow.paddingY
        anchors.bottomMargin: Tokens.component.settingRow.paddingY
        spacing: Tokens.space.s16

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

        Rectangle {
            Layout.preferredWidth: 52
            Layout.preferredHeight: 32
            radius: Tokens.shape.full
            color: root.checked ? Tokens.color.primary : Tokens.color.surfaceContainerHighest
            border.width: Tokens.border.width.thin
            border.color: root.checked ? Tokens.color.primary : Tokens.color.outlineVariant

            Rectangle {
                width: 24
                height: 24
                radius: 12
                x: root.checked ? parent.width - width - 4 : 4
                y: 4
                color: root.checked ? Tokens.color.primaryForeground : Tokens.color.text.secondary

                Behavior on x {
                    NumberAnimation {
                        duration: Tokens.motion.duration.fast
                        easing.type: Tokens.motion.easing.standard
                    }
                }
            }
        }
    }
}
