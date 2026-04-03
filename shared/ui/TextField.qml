import QtQuick
import QtQuick.Controls
import "../designsystem"

TextField {
    id: root

    implicitHeight: Tokens.component.input.height
    color: Tokens.color.text.primary
    selectedTextColor: Tokens.color.text.inverse
    selectionColor: Tokens.color.accent.primary
    font.family: Tokens.font.family.body
    font.pixelSize: Tokens.font.size.body
    leftPadding: Tokens.component.input.paddingX
    rightPadding: Tokens.component.input.paddingX
    topPadding: 0
    bottomPadding: 0
    placeholderTextColor: Tokens.color.text.muted

    background: Rectangle {
        radius: Tokens.component.input.radius
        color: Tokens.color.bg.interactive
        border.width: Tokens.border.width.thin
        border.color: root.activeFocus ? Tokens.color.focusRing : Tokens.color.border.subtle
    }
}
