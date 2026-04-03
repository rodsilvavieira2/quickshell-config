pragma Singleton

import QtQuick
import "./shared/designsystem"

QtObject {
    readonly property color base: Tokens.color.bg.surface
    readonly property color mantle: Tokens.color.bg.elevated
    readonly property color crust: Tokens.color.bg.canvas
    readonly property color surface0: Tokens.color.bg.interactive
    readonly property color surface1: Tokens.color.bg.hover
    readonly property color surface2: Tokens.color.bg.active
    readonly property color text: Tokens.color.text.primary
    readonly property color subtext0: Tokens.color.text.secondary
    readonly property color subtext1: Tokens.color.text.secondary
    readonly property color overlay0: Tokens.color.text.muted
    readonly property color mauve: Tokens.color.accent.hover
    readonly property color blue: Tokens.color.accent.primary
    readonly property color green: Tokens.color.success
    readonly property color red: Tokens.color.error
    readonly property color yellow: Tokens.color.warning
    readonly property color peach: Tokens.color.warning
    readonly property color teal: Tokens.color.info

    readonly property int radius: Tokens.radius.md
    readonly property int barRadius: 0
    readonly property int barHeight: 34
    readonly property int barTopMargin: 0
    readonly property int barBottomGap: 0
    readonly property int barPaddingHorizontal: 12
    readonly property int barPaddingTop: 4
    readonly property int barPaddingBottom: 6
    readonly property int pillPadding: 6
    readonly property int pillSpacing: 6
    readonly property int sectionSpacing: 12
    readonly property int iconSize: 14
    readonly property int iconButtonSize: 22

    readonly property int chipRadius: Tokens.radius.sm
    readonly property int chipPaddingHorizontal: 8
    readonly property int chipPaddingVertical: 4
    readonly property color chipColor: "transparent"
    readonly property color chipHoverColor: Tokens.color.bg.hover
    readonly property color chipActiveColor: Tokens.color.bg.active
    readonly property color activeAccent: Tokens.color.accent.primary

    readonly property int workspaceCount: 10

    readonly property color barColor: Tokens.color.bg.elevated
    readonly property color barBorderColor: Tokens.color.border.subtle
    readonly property color dividerColor: Tokens.color.border.subtle
    readonly property color pillColor: barColor
    readonly property color pillHoverColor: Tokens.color.bg.hover
}
