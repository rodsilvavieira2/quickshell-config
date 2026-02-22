import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property real value: 0 // 0 to 1
    property real thickness: 14
    property color progressColor: "#b4befe"
    property color backgroundColor: "#313244"
    property string title: ""
    property string subTitle: ""

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
            color: "#ffffff"
            font.pixelSize: 32
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: root.subTitle
            color: "#a6adc8"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.subTitle !== ""
        }
    }
}
