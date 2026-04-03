import QtQuick
import QtQuick.Controls
import "../designsystem"

Item {
    id: root

    property alias from: control.from
    property alias to: control.to
    property alias value: control.value
    readonly property bool pressed: control.pressed

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
            radius: Tokens.shape.full
            color: Tokens.color.surfaceContainerHighest

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: Tokens.color.primary
            }
        }

        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 18
            implicitHeight: 18
            radius: width / 2
            color: Tokens.color.primary
            border.width: Tokens.border.width.thin
            border.color: control.pressed ? Tokens.color.text.inverse : Tokens.color.primary
        }
    }
}
