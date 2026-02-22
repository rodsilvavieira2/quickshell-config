pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject colors: QtObject {
        property color colLayer0: "#1e1e2e"
        property color colLayer0Border: "#313244"
        property color colLayer1: "#1e1e2e"
        property color colLayer1Hover: "#313244"
        property color colLayer2: "#313244"
        property color colLayer2Hover: "#313244"
        property color colOnLayer0: "#cdd6f4"
        property color colSubtext: "#a6adc8"
        property color colShadow: "#66000000"
    }

    property QtObject font: QtObject {
        property QtObject family: QtObject {
            property string main: "JetBrains Mono"
            property string title: "JetBrains Mono"
            property string expressive: "JetBrains Mono"
        }
        property QtObject pixelSize: QtObject {
            property int smaller: 12
            property int small: 15
            property int normal: 16
            property int larger: 19
            property int huge: 22
        }
    }

    property QtObject sizes: QtObject {
        property real elevationMargin: 10
    }
}
