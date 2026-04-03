pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color text: "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color subtext1: "#bac2de"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color overlay0: "#6c7086"
    readonly property color overlay1: "#7f849c"
    readonly property color blue: "#89b4fa"
    readonly property color mauve: "#cba6f7"
    readonly property color lavender: "#b4befe"
    readonly property color peach: "#fab387"
    readonly property color green: "#a6e3a1"
    readonly property color red: "#f38ba8"
    readonly property color flamingo: "#f2cdcd"

    property QtObject colors: QtObject {
        property color cSurface: root.base
        property color cSurfaceContainer: root.mantle
        property color cSurfaceContainerHigh: root.surface0
        property color cBorder: root.surface2
        property color cPrimary: root.mauve
        property color cSecondary: root.blue
        property color cOnSurface: root.text
        property color cOnSurfaceVariant: root.subtext0
        property color cOnSurfaceDim: root.overlay0
        
        // Additional semantic colors
        property color warning: root.peach
        property color info: root.blue
        property color error: root.red
        property color success: root.green
    }

    property QtObject font: QtObject {
        property string family: "JetBrainsMono Nerd Font"
        property int sizeHeader: 34
        property int sizeTitle: 16
        property int sizeNormal: 14
        property int sizeSmall: 13
        property int sizeExtraSmall: 12
    }

    // Material 3 Style Animations
    property QtObject animation: QtObject {
        property int short1: 50
        property int short2: 100
        property int short3: 150
        property int short4: 200
        property int medium1: 250
        property int medium2: 300
        property int medium3: 350
        property int medium4: 400
        property int long1: 450
        property int long2: 500
        
        // Easing curves matching Material 3
        property var standard: Easing.OutCubic
        property var standardDecelerate: Easing.OutCubic
        property var standardAccelerate: Easing.InCubic
        property var emphasizedDecelerate: Easing.OutExpo
        property var emphasizedAccelerate: Easing.InExpo
    }
}
