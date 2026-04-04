pragma Singleton

import QtQuick
import "./shared/designsystem"

QtObject {
    readonly property color base: Tokens.color.surface
    readonly property color mantle: Tokens.color.surfaceContainer
    readonly property color crust: Tokens.color.surfaceDim
    readonly property color surface0: Tokens.color.surfaceContainerHigh
    readonly property color surface1: Tokens.color.bg.hover
    readonly property color surface2: Tokens.color.bg.active
    readonly property color text: Tokens.color.text.primary
    readonly property color subtext0: Tokens.color.text.secondary
    readonly property color subtext1: Tokens.color.text.secondary
    readonly property color overlay0: Tokens.color.text.muted
    readonly property color mauve: Tokens.color.secondary
    readonly property color blue: Tokens.color.primary
    readonly property color green: Tokens.color.success
    readonly property color red: Tokens.color.error
    readonly property color yellow: Tokens.color.warning
    readonly property color peach: Tokens.color.warning
    readonly property color teal: Tokens.color.info
    readonly property string textFontFamily: Tokens.font.family.label
    readonly property string iconFontFamily: Tokens.font.family.icon

    readonly property int radius: Tokens.radius.md
    readonly property int barRadius: 32
    readonly property int barHeight: 68
    readonly property int barTopMargin: 10
    readonly property int barBottomGap: 0
    readonly property int barPaddingHorizontal: 12
    readonly property int barPaddingTop: 4
    readonly property int barPaddingBottom: 4
    readonly property int pillPadding: 6
    readonly property int pillSpacing: 8
    readonly property int sectionSpacing: 12
    readonly property int iconSize: 16
    readonly property int iconButtonSize: 22

    readonly property int chipRadius: 999
    readonly property int chipPaddingHorizontal: 12
    readonly property int chipPaddingVertical: 6
    readonly property color chipColor: Qt.rgba(255/255, 255/255, 255/255, 0.10)
    readonly property color chipHoverColor: Qt.rgba(255/255, 255/255, 255/255, 0.14)
    readonly property color chipActiveColor: "#E9DDF7"
    readonly property color activeAccent: Tokens.color.primary

    readonly property int workspaceCount: 5

    readonly property color barColor: Qt.rgba(18/255, 16/255, 28/255, 0.78)
    readonly property color barBorderColor: Qt.rgba(255/255, 255/255, 255/255, 0.05)
    readonly property color dividerColor: Tokens.color.outlineVariant
    readonly property color pillColor: barColor
    readonly property color pillHoverColor: Tokens.color.bg.hover
}
