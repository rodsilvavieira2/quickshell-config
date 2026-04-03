import QtQuick
import QtQuick.Shapes
import "../shared/designsystem" as Design

Item {
    id: root
    property real value: 0 // 0 to 1
    property real thickness: 14
    property color progressColor: Design.Tokens.color.accent.primary
    property color backgroundColor: Design.Tokens.color.bg.interactive
    property string title: ""
    property string subTitle: ""
    property string fontFamily: ""

    width: 140
    height: 140

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        // Background Track
        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.backgroundColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.width / 2; centerY: root.height / 2
                radiusX: root.width / 2 - root.thickness / 2; radiusY: root.height / 2 - root.thickness / 2
                startAngle: 0; sweepAngle: 360
            }
        }

        // Active Fill
        ShapePath {
            strokeWidth: root.thickness
            strokeColor: root.progressColor
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.width / 2; centerY: root.height / 2
                radiusX: root.width / 2 - root.thickness / 2; radiusY: root.height / 2 - root.thickness / 2
                startAngle: -90; sweepAngle: Math.max(root.value * 360, 0.01)
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2
        Text {
            text: root.title
            color: Design.Tokens.color.text.primary
            font.family: root.fontFamily !== "" ? root.fontFamily : Design.Tokens.font.family.display
            font.pixelSize: Math.round(32 * Design.ThemeSettings.uiScale)
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: root.subTitle
            color: Design.Tokens.color.text.secondary
            font.family: root.fontFamily !== "" ? root.fontFamily : Design.Tokens.font.family.body
            font.pixelSize: Design.Tokens.font.size.body
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.subTitle !== ""
        }
    }
}
