pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../shared/designsystem"

Singleton {
    id: root

    property QtObject palette: QtObject {
        property color base: Tokens.color.bg.surface
        property color mantle: Tokens.color.bg.elevated
        property color crust: Tokens.color.bg.canvas
        property color text: Tokens.color.text.primary
        property color subtext0: Tokens.color.text.secondary
        property color subtext1: Tokens.color.text.secondary
        property color surface0: Tokens.color.bg.interactive
        property color surface1: Tokens.color.bg.hover
        property color surface2: Tokens.color.bg.active
        property color overlay0: Tokens.color.text.muted
        property color blue: Tokens.color.accent.primary
        property color sapphire: ThemePalette.mix(Tokens.color.accent.primary, Tokens.color.info, 0.35)
        property color mauve: Tokens.color.accent.hover
        property color green: Tokens.color.success
        property color red: Tokens.color.error
        property color yellow: Tokens.color.warning
        property color peach: Tokens.color.warning
    }

    property QtObject font: QtObject {
        property string family: Tokens.font.family.body
        property int sizeSmall: Tokens.font.size.label
        property int sizeNormal: Tokens.font.size.body
    }
}
