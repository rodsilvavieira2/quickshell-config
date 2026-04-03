import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property var model: []
    property int currentIndex: 0
    signal activated(int index)

    implicitHeight: Math.max(Tokens.component.settingRow.minHeight, contentLayout.implicitHeight + Tokens.component.settingRow.paddingY * 2)
    radius: Tokens.component.settingRow.radius
    color: Tokens.color.surfaceContainerLow
    border.width: Tokens.border.width.thin
    border.color: Tokens.color.outlineVariant

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

        SelectField {
            Layout.preferredWidth: 220
            model: root.model
            currentIndex: root.currentIndex
            onActivated: index => root.activated(index)
        }
    }
}
