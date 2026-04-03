pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../shared/designsystem"

Singleton {
    id: root

    readonly property color base: Tokens.color.bg.surface
    readonly property color mantle: Tokens.color.bg.elevated
    readonly property color crust: Tokens.color.bg.canvas
    readonly property color text: Tokens.color.text.primary
    readonly property color subtext0: Tokens.color.text.secondary
    readonly property color subtext1: Tokens.color.text.secondary
    readonly property color surface0: Tokens.color.bg.interactive
    readonly property color surface1: Tokens.color.bg.hover
    readonly property color surface2: Tokens.color.bg.active
    readonly property color overlay0: Tokens.color.text.muted
    readonly property color overlay1: Tokens.color.text.secondary
    readonly property color blue: Tokens.color.accent.primary
    readonly property color mauve: Tokens.color.accent.hover
    readonly property color lavender: ThemePalette.mix(Tokens.color.accent.primary, ThemePalette.white, ThemeSettings.isDark ? 0.18 : 0.02)
    readonly property color peach: Tokens.color.warning
    readonly property color green: Tokens.color.success
    readonly property color red: Tokens.color.error
    readonly property color flamingo: ThemePalette.mix(Tokens.color.error, Tokens.color.accent.primary, 0.35)

    property QtObject colors: QtObject {
        property color cSurface: root.base
        property color cSurfaceContainer: root.mantle
        property color cSurfaceContainerHigh: root.surface0
        property color cBorder: Tokens.color.border.strong
        property color cPrimary: Tokens.color.accent.primary
        property color cSecondary: Tokens.color.accent.hover
        property color cOnSurface: Tokens.color.text.primary
        property color cOnSurfaceVariant: Tokens.color.text.secondary
        property color cOnSurfaceDim: Tokens.color.text.muted
        property color warning: Tokens.color.warning
        property color info: Tokens.color.info
        property color error: Tokens.color.error
        property color success: Tokens.color.success
    }

    property QtObject font: QtObject {
        property string family: Tokens.font.family.body
        property int sizeHeader: Tokens.font.size.display
        property int sizeTitle: Tokens.font.size.title
        property int sizeNormal: Tokens.font.size.body
        property int sizeSmall: Tokens.font.size.label
        property int sizeExtraSmall: Tokens.font.size.caption
    }

    property QtObject animation: QtObject {
        property int short1: 50
        property int short2: 100
        property int short3: Tokens.motion.duration.fast
        property int short4: Tokens.motion.duration.normal
        property int medium1: 220
        property int medium2: 280
        property int medium3: 340
        property int medium4: 400
        property int long1: 450
        property int long2: 500
        property var standard: Tokens.motion.easing.standard
        property var standardDecelerate: Tokens.motion.easing.decelerate
        property var standardAccelerate: Tokens.motion.easing.accelerate
        property var emphasizedDecelerate: Easing.OutExpo
        property var emphasizedAccelerate: Easing.InExpo
    }
}
