import QtQuick
import QtQuick.Layouts

Rectangle {
    id: gaugeCard

    property string icon: ""
    property string title: ""
    property real percentage: 0
    property string subtitle: ""
    property color accentColor: "#89b4fa"

    color: "#313244"
    radius: 16
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: gaugeCard.icon
                font.family: "JetBrainsMono Nerd Font"
                color: gaugeCard.accentColor
                font.pixelSize: 24
            }

            Text {
                Layout.fillWidth: true
                text: gaugeCard.title
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: "#cdd6f4"
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                id: canvas
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width

                property real animPercentage: gaugeCard.percentage

                Behavior on animPercentage {
                    NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
                }

                onAnimPercentageChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const cx = width / 2;
                    const cy = height / 2;
                    const radius = (width - 16) / 2;
                    const startAngle = 0.75 * Math.PI;
                    const sweepAngle = 1.5 * Math.PI;

                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, startAngle, startAngle + sweepAngle);
                    ctx.lineWidth = 14;
                    ctx.lineCap = "round";
                    ctx.strokeStyle = "#1e1e2e";
                    ctx.stroke();

                    if (animPercentage > 0) {
                        ctx.beginPath();
                        ctx.arc(cx, cy, radius, startAngle, startAngle + sweepAngle * animPercentage);
                        ctx.lineWidth = 14;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = gaugeCard.accentColor;
                        ctx.stroke();
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: Math.round(gaugeCard.percentage * 100) + "%"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 32
                font.bold: true
                color: gaugeCard.accentColor
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: gaugeCard.subtitle
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: "#a6adc8"
        }
    }
}
