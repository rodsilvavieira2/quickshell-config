import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property real from: 0
    property real to: 1
    property real value: 0
    property string valueText: ""
    signal valueChanged(real value)

    implicitHeight: contentLayout.implicitHeight + Tokens.component.settingRow.paddingY * 2
    radius: Tokens.component.settingRow.radius
    color: Tokens.color.surfaceContainerLow
    border.width: Tokens.border.width.thin
    border.color: Tokens.color.outlineVariant

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: Tokens.component.settingRow.paddingX
        anchors.rightMargin: Tokens.component.settingRow.paddingX
        anchors.topMargin: Tokens.component.settingRow.paddingY
        anchors.bottomMargin: Tokens.component.settingRow.paddingY
        spacing: Tokens.space.s12

        RowLayout {
            Layout.fillWidth: true
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
                }
            }

            Text {
                visible: root.valueText !== ""
                text: root.valueText
                color: Tokens.color.primary
                font.family: Tokens.font.family.label
                font.pixelSize: Tokens.font.size.label
                font.weight: Tokens.font.weight.semibold
            }
        }

        Slider {
            Layout.fillWidth: true
            from: root.from
            to: root.to
            value: root.value
            onValueChanged: root.valueChanged(value)
        }
    }
}
