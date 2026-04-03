import QtQuick
import QtQuick.Layouts
import "../designsystem"

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    default property alias actionData: actions.data
    property alias supportingData: supporting.data

    implicitWidth: layout.implicitWidth
    implicitHeight: Math.max(Tokens.component.topAppBar.height, layout.implicitHeight)

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Tokens.component.topAppBar.paddingX
        anchors.rightMargin: Tokens.component.topAppBar.paddingX
        anchors.topMargin: Tokens.component.topAppBar.paddingY
        anchors.bottomMargin: Tokens.component.topAppBar.paddingY
        spacing: Tokens.space.s16

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.space.s4

            Text {
                visible: root.title !== ""
                text: root.title
                color: Tokens.color.text.primary
                font.family: Tokens.font.family.headline
                font.pixelSize: Tokens.font.size.headline
                font.weight: Tokens.font.weight.semibold
            }

            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                color: Tokens.color.text.secondary
                font.family: Tokens.font.family.body
                font.pixelSize: Tokens.font.size.body
            }

            RowLayout {
                id: supporting
                spacing: Tokens.space.s8
            }
        }

        RowLayout {
            id: actions
            spacing: Tokens.space.s8
        }
    }
}
