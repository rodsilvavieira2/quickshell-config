import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    property alias text: field.text
    property alias placeholderText: field.placeholderText
    readonly property TextField inputField: field
    signal accepted()
    signal escapePressed()
    signal upPressed()
    signal downPressed()

    function forceFocus() {
        field.forceActiveFocus();
    }

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

        LucideIcon {
            name: "search"
            color: Tokens.color.text.secondary
            iconSize: Tokens.font.size.body + 1
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
            Keys.onEscapePressed: event => {
                root.escapePressed()
                event.accepted = true
            }
            Keys.onUpPressed: event => {
                root.upPressed()
                event.accepted = true
            }
            Keys.onDownPressed: event => {
                root.downPressed()
                event.accepted = true
            }
        }

        IconButton {
            visible: field.text.length > 0
            iconName: "x"
            preferredHeight: 36
            onClicked: field.clear()
        }
    }
}
