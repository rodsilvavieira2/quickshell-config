pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "functions"

Singleton {
    id: root

    property QtObject colors: QtObject {
        property color colBackground: "#1e1e2e"
        property color colSurface: "#181825"
        property color colLayer1: "#1e1e2e"
        property color colLayer2: "#313244"
        property color colLayer3: "#45475a"
        property color colLayer4: "#585b70"
        property color colOnLayer0: "#cdd6f4"
        property color colSubtext: "#a6adc8"
        property color colBorder: "#313244"
        property color colShadow: "#66000000"
        property color colPrimary: "#89b4fa"
        property color colOnPrimary: "#11111b"
        property color colCritical: "#f38ba8"
        property color colOnCritical: "#11111b"
        property color colTooltip: "#313244"
        property color colOnTooltip: "#cdd6f4"
    }

    property QtObject rounding: QtObject {
        property int verysmall: 6
        property int small: 8
        property int normal: 12
        property int large: 16
        property int full: 9999
    }

    property QtObject font: QtObject {
        property QtObject family: QtObject {
            property string main: "JetBrains Mono"
            property string title: "JetBrains Mono"
            property string expressive: "JetBrains Mono"
        }
        property QtObject pixelSize: QtObject {
            property int smaller: 11
            property int small: 13
            property int normal: 15
            property int larger: 18
            property int huge: 22
        }
    }

    property QtObject animationCurves: QtObject {
        readonly property list<real> expressiveDefaultSpatial: [0.25, 0.8, 0.2, 1.0, 1, 1]
        readonly property list<real> expressiveFastSpatial: [0.22, 0.7, 0.2, 1.0, 1, 1]
        readonly property real expressiveDefaultSpatialDuration: 220
        readonly property real expressiveFastDuration: 160
    }

    property QtObject animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }

        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveFastDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveFastSpatial
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
                }
            }
        }
    }

    property QtObject sizes: QtObject {
        property real elevationMargin: 10
        property real notificationPopupWidth: 360
        property real panelWidth: 380
    }
}
