import QtQuick
import "../designsystem"

Button {
    id: root

    property string icon: ""
    property string iconName: ""
    property url iconSource: ""
    property int iconPixelSize: Tokens.component.button.iconSize

    implicitWidth: preferredHeight
    text: ""
    variant: "ghost"

    LucideIcon {
        id: vectorIcon
        anchors.centerIn: parent
        visible: root.iconName !== "" || root.iconSource.toString().length > 0
        name: root.iconName
        source: root.iconSource
        color: root.contentColor
        iconSize: root.iconPixelSize
    }

    Text {
        anchors.centerIn: parent
        visible: !vectorIcon.visible && root.icon !== ""
        text: root.icon
        color: root.contentColor
        font.family: Tokens.font.family.icon
        font.pixelSize: root.iconPixelSize
        font.weight: Tokens.font.weight.medium
    }
}
