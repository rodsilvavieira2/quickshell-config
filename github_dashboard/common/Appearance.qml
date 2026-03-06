pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject colors: QtObject {
        property color colLayer0: "#1e1e2e"            // Base - panel background
        property color colLayer0Border: "#45475a"      // Surface1 - panel border
        property color colLayer1: "#181825"            // Mantle - input area / deeper accent
        property color colLayer1Hover: "#585b70"       // Surface2 - hover states
        property color colLayer2: "#313244"            // Surface0 - icon background
        property color colLayer2Hover: "#45475a"       // Surface1 - icon hover
        property color colOnLayer0: "#cdd6f4"          // Text
        property color colSubtext: "#a6adc8"           // Subtext0 - dimmed subtext
        property color colShadow: "#99000000"          // Shadow
        property color colAccent: "#89b4fa"            // Blue - accent
        property color colAccentSubtle: "#1a89b4fa"    // Blue ~10% opacity - active item bg (AARRGGBB)
        property color colSeparator: "#45475a"         // Surface1 - divider line
        
        // Added for Dashboard
        property color colSuccess: "#a6e3a1"           // Green
        property color colError: "#f38ba8"             // Red
    }

    property QtObject font: QtObject {
        property QtObject family: QtObject {
            property string main: "JetBrains Mono"
            property string title: "JetBrains Mono"
            property string expressive: "JetBrains Mono"
        }
        property QtObject pixelSize: QtObject {
            property int smaller: 12
            property int small: 14
            property int normal: 15
            property int larger: 19
            property int huge: 22
        }
    }

    property QtObject sizes: QtObject {
        property real elevationMargin: 10
    }
}
