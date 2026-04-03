import QtQuick
import "../designsystem"

Button {
    id: root

    property string icon: ""
    property int iconPixelSize: Tokens.component.button.iconSize

    implicitWidth: preferredHeight
    text: ""
    variant: "ghost"

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.contentColor
        font.family: Tokens.font.family.icon
        font.pixelSize: root.iconPixelSize
        font.weight: Tokens.font.weight.medium
    }
}
