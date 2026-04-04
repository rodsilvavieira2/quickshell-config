import QtQuick
import QtQuick.Effects
import "../designsystem"

RectangularShadow {
    required property var target

    anchors.fill: target
    radius: target && target.radius !== undefined ? target.radius : Tokens.radius.xl
    blur: level
    offset: Qt.vector2d(0.0, 1.0)
    spread: 1
    color: Tokens.color.shadow
    cached: true

    property int level: Tokens.shadow.md
}
