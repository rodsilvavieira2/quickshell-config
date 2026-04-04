import ".." as Root
import "../shared/designsystem" as Design
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string metricLabel: ""
    property string valueText: ""
    property real value: 0
    property color accentColor: Root.Config.blue
    property color backgroundColor: Root.Config.chipColor
    property color labelColor: Root.Config.text
    property color ringTrackColor: Design.ThemePalette.mix(accentColor, Root.Config.surface2, 0.76)
    readonly property real clampedValue: Math.max(0, Math.min(1, value))

    implicitWidth: contentRow.implicitWidth + Root.Config.metricChipPaddingHorizontal * 2
    implicitHeight: Root.Config.chipHeight
    radius: Root.Config.chipRadius
    color: root.backgroundColor
    border.width: Design.Tokens.border.width.thin
    border.color: "transparent"

    RowLayout {
        id: contentRow

        anchors.centerIn: parent
        spacing: Root.Config.metricChipSpacing

        Item {
            id: gaugeBox

            readonly property real strokeWidth: Root.Config.metricGaugeThickness
            readonly property real diameter: Math.min(width, height) - strokeWidth - 1
            readonly property real radius: diameter / 2
            readonly property real centerX: width / 2
            readonly property real centerY: height / 2
            property real displayValue: 0

            function syncDisplayValue() {
                displayValue = root.clampedValue;
            }

            implicitWidth: Root.Config.metricGaugeSize
            implicitHeight: Root.Config.metricGaugeSize
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
            Layout.alignment: Qt.AlignVCenter
            onDisplayValueChanged: gaugeCanvas.requestPaint()
            onWidthChanged: gaugeCanvas.requestPaint()
            onHeightChanged: gaugeCanvas.requestPaint()
            Component.onCompleted: syncDisplayValue()

            Canvas {
                id: gaugeCanvas

                anchors.fill: parent
                antialiasing: true
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const startAngle = -Math.PI / 2;
                    const endAngle = startAngle + (Math.PI * 2 * gaugeBox.displayValue);
                    ctx.beginPath();
                    ctx.arc(gaugeBox.centerX, gaugeBox.centerY, gaugeBox.radius, 0, Math.PI * 2);
                    ctx.lineWidth = gaugeBox.strokeWidth;
                    ctx.lineCap = "butt";
                    ctx.strokeStyle = root.ringTrackColor;
                    ctx.stroke();
                    if (gaugeBox.displayValue > 0) {
                        ctx.beginPath();
                        ctx.arc(gaugeBox.centerX, gaugeBox.centerY, gaugeBox.radius, startAngle, endAngle);
                        ctx.lineWidth = gaugeBox.strokeWidth;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = root.accentColor;
                        ctx.stroke();
                    }
                    ctx.fillStyle = root.accentColor;
                    ctx.font = "600 " + Root.Config.metricGaugeLabelFontSize + "px \"" + Root.Config.textFontFamily + "\"";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";
                    ctx.fillText(root.metricLabel, gaugeBox.centerX, gaugeBox.centerY);
                }

                Connections {
                    function onClampedValueChanged() {
                        gaugeBox.syncDisplayValue();
                    }

                    target: root
                }

                Connections {
                    function onMetricLabelChanged() {
                        gaugeCanvas.requestPaint();
                    }

                    function onAccentColorChanged() {
                        gaugeCanvas.requestPaint();
                    }

                    function onRingTrackColorChanged() {
                        gaugeCanvas.requestPaint();
                    }

                    target: root
                }

            }

            Behavior on displayValue {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.slow
                    easing.type: Design.Tokens.motion.easing.standard
                }

            }

        }

        Text {
            text: root.valueText
            color: root.labelColor
            font.family: Root.Config.textFontFamily
            font.pixelSize: Root.Config.iconSize - 2
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
            Layout.alignment: Qt.AlignVCenter
        }

    }

}
