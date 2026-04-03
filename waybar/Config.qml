pragma Singleton
import QtQuick

QtObject {
    // Catppuccin Mocha Palette
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color text: "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color subtext1: "#bac2de"
    readonly property color overlay0: "#6c7086"
    readonly property color mauve: "#cba6f7"
    readonly property color blue: "#89b4fa"
    readonly property color green: "#a6e3a1"
    readonly property color red: "#f38ba8"
    readonly property color yellow: "#f9e2af"
    readonly property color peach: "#fab387"
    readonly property color teal: "#94e2d5"

    // Geometry
    readonly property int radius: 10
    readonly property int barRadius: 0
    readonly property int barHeight: 31
    readonly property int barTopMargin: 0
    readonly property int barBottomGap: 0
    readonly property int barPaddingHorizontal: 12
    readonly property int barPaddingTop: 4
    readonly property int barPaddingBottom: 5
    readonly property int pillPadding: 6
    readonly property int pillSpacing: 6
    readonly property int sectionSpacing: 12
    readonly property int iconSize: 15
    readonly property int iconButtonSize: 22

    // InfoChip properties
    readonly property int chipRadius: 7
    readonly property int chipPaddingHorizontal: 8
    readonly property int chipPaddingVertical: 4
    readonly property color chipColor: "transparent"
    readonly property color chipHoverColor: surface0
    readonly property color chipActiveColor: surface1
    readonly property color activeAccent: blue

    // Configurable
    readonly property int workspaceCount: 10

    // Bar styling
    readonly property color barColor: mantle
    readonly property color barBorderColor: surface0
    readonly property color dividerColor: surface0
    readonly property color pillColor: barColor
    readonly property color pillHoverColor: surface1
}
