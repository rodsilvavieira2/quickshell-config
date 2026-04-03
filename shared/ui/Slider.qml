import QtQuick
import QtQuick.Controls
import "../designsystem"

Item {
    id: root

    property alias from: control.from
    property alias to: control.to
    property alias value: control.value

    implicitWidth: 240
    implicitHeight: 30

    Slider {
        id: control
        anchors.fill: parent

        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.availableWidth
            height: 6
            radius: Tokens.radius.pill
            color: Tokens.color.bg.interactive

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: Tokens.color.accent.primary
            }
        }

        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 18
            implicitHeight: 18
            radius: width / 2
            color: Tokens.color.text.primary
            border.width: Tokens.border.width.thin
            border.color: Tokens.color.border.subtle
        }
    }
}
