import QtQuick
import "../designsystem"

Item {
    id: root

    property real value: 0
    property color trackColor: Tokens.color.surfaceContainerHighest
    property color indicatorColor: Tokens.color.primary
    property int thickness: 6
    property int radius: thickness / 2

    readonly property real clampedValue: Math.max(0, Math.min(1, value))

    implicitWidth: 160
    implicitHeight: thickness

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.trackColor
    }

    Rectangle {
        width: parent.width * root.clampedValue
        height: parent.height
        radius: root.radius
        color: root.indicatorColor

        Behavior on width {
            NumberAnimation {
                duration: Tokens.motion.duration.medium
                easing.type: Tokens.motion.easing.standard
            }
        }
    }
}
