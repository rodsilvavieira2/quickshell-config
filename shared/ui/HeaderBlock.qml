import QtQuick
import QtQuick.Layouts
import "../designsystem"

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    default property alias actionData: actions.data

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: Tokens.space.s12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.space.s4

            Text {
                visible: root.title !== ""
                text: root.title
                color: Tokens.color.text.primary
                font.family: Tokens.font.family.title
                font.pixelSize: Tokens.font.size.title
                font.weight: Tokens.font.weight.semibold
            }

            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                color: Tokens.color.text.secondary
                font.family: Tokens.font.family.caption
                font.pixelSize: Tokens.font.size.caption
                font.weight: Tokens.font.weight.medium
            }
        }

        RowLayout {
            id: actions
            spacing: Tokens.space.s8
        }
    }
}
