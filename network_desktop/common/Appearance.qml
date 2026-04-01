pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject colors: QtObject {
        // Catppuccin Mocha Dark (fixed palette)
        property color base: "#1e1e2e"
        property color mantle: "#181825"
        property color crust: "#11111b"
        property color surface0: "#313244"
        property color surface1: "#45475a"
        property color surface2: "#585b70"
        property color text: "#cdd6f4"
        property color subtext0: "#a6adc8"
        property color overlay0: "#6c7086"
        property color overlay1: "#7f849c"
        property color blue: "#89b4fa"
        property color mauve: "#cba6f7"
        property color pink: "#f5c2e7"
        property color sapphire: "#74c7ec"
        property color green: "#a6e3a1"
        property color yellow: "#f9e2af"
        property color red: "#f38ba8"
        property color maroon: "#eba0ac"
        property color peach: "#fab387"
    }
}
