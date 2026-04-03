import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    property alias text: field.text
    property alias placeholderText: field.placeholderText
    signal accepted()

    implicitWidth: 320
    implicitHeight: Tokens.component.searchBar.height
    radius: Tokens.component.searchBar.radius
    color: Tokens.color.surfaceContainerHigh
    border.width: Tokens.border.width.thin
    border.color: field.activeFocus ? Tokens.color.focusRing : Tokens.color.outlineVariant

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.space.s16
        anchors.rightMargin: Tokens.space.s8
        spacing: Tokens.space.s12

        Text {
            text: "󰍉"
            color: Tokens.color.text.secondary
            font.family: Tokens.font.family.icon
            font.pixelSize: Tokens.font.size.body
        }

        TextField {
            id: field
            Layout.fillWidth: true
            background: null
            color: Tokens.color.text.primary
            selectedTextColor: Tokens.color.text.inverse
            selectionColor: Tokens.color.primary
            placeholderTextColor: Tokens.color.text.secondary
            font.family: Tokens.font.family.body
            font.pixelSize: Tokens.font.size.body
            leftPadding: 0
            rightPadding: 0
            onAccepted: root.accepted()
        }

        IconButton {
            visible: field.text.length > 0
            icon: "󰅖"
            preferredHeight: 36
            onClicked: field.clear()
        }
    }
}
