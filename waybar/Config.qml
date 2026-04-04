import "./shared/designsystem"
import QtQuick
pragma Singleton

QtObject {
    readonly property color base: Tokens.color.surface
    readonly property color mantle: Tokens.color.surfaceContainerLow
    readonly property color crust: Tokens.color.surfaceContainerLowest
    readonly property color surface0: Tokens.color.surfaceContainer
    readonly property color surface1: Tokens.color.surfaceContainerHigh
    readonly property color surface2: Tokens.color.surfaceContainerHighest
    readonly property color text: Tokens.color.text.primary
    readonly property color subtext0: Tokens.color.text.secondary
    readonly property color subtext1: Tokens.color.text.secondary
    readonly property color overlay0: Tokens.color.text.muted
    readonly property color primaryContainer: Tokens.color.primaryContainer
    readonly property color primaryContainerForeground: Tokens.color.primaryContainerForeground
    readonly property color secondaryContainer: Tokens.color.secondaryContainer
    readonly property color secondaryContainerForeground: Tokens.color.secondaryContainerForeground
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
    readonly property int barRadius: Math.round(barHeight / 2)
    readonly property int barHeight: 56
    readonly property int barTopMargin: 10
    readonly property int barBottomGap: 0
    readonly property int barPaddingHorizontal: 12
    readonly property int barPaddingTop: 4
    readonly property int barPaddingBottom: 4
    readonly property int contentHeight: barHeight - barPaddingTop - barPaddingBottom
    readonly property int chipHeight: 36
    readonly property int workspaceChipSize: 34
    readonly property int trayItemSize: 32
    readonly property int pillPadding: 6
    readonly property int pillSpacing: 6
    readonly property int sectionSpacing: 10
    readonly property int iconSize: 16
    readonly property int iconButtonSize: 36
    readonly property int clockTimeFontSize: 15
    readonly property int clockDateFontSize: 13
    readonly property int chipRadius: 999
    readonly property int chipPaddingHorizontal: 12
    readonly property int chipPaddingVertical: 6
    readonly property int metricChipPaddingHorizontal: 10
    readonly property int metricChipSpacing: 8
    readonly property int metricGaugeSize: 24
    readonly property int metricGaugeThickness: 3
    readonly property int metricGaugeLabelFontSize: 8
    readonly property color chipColor: Tokens.color.surfaceContainerHigh
    readonly property color chipHoverColor: Tokens.color.surfaceContainerHighest
    readonly property color chipActiveColor: Tokens.color.primaryContainer
    readonly property color chipActiveForeground: Tokens.color.primaryContainerForeground
    readonly property color activeAccent: Tokens.color.primary
    readonly property int workspaceCount: 5
    readonly property color barColor: Tokens.color.surface
    readonly property color barBorderColor: Tokens.color.outlineVariant
    readonly property color dividerColor: Tokens.color.outlineVariant
    readonly property color pillColor: Tokens.color.surfaceContainerLow
    readonly property color pillHoverColor: Tokens.color.surfaceContainer
}
