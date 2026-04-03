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
    readonly property int barHeight: 32
    readonly property int barMargin: 4
    readonly property int pillPadding: 6
    readonly property int pillSpacing: 4
    readonly property int iconSize: 14

    // InfoChip properties
    readonly property int chipRadius: 6
    readonly property int chipPaddingHorizontal: 8
    readonly property int chipPaddingVertical: 4
    readonly property color chipColor: "transparent"
    readonly property color chipHoverColor: surface0
    readonly property color chipActiveColor: surface1
    readonly property color activeAccent: mauve

    // Configurable
    readonly property int workspaceCount: 10

    // Transparent pill background
    readonly property color pillColor: Qt.rgba(49/255, 50/255, 68/255, 0.85)
    readonly property color pillHoverColor: surface1
}
