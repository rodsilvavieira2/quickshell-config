import QtQuick
import QtQuick.Layouts
import "../shared/designsystem" as Design

Rectangle {
    id: gaugeCard

    property string icon: ""
    property string title: ""
    property real percentage: 0
    property string subtitle: ""
    property color accentColor: Design.Tokens.color.accent.primary

    color: Design.Tokens.color.bg.elevated
    radius: Design.Tokens.radius.lg
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
                font.family: Design.Tokens.font.family.icon
                color: gaugeCard.accentColor
                font.pixelSize: 24
            }

            Text {
                Layout.fillWidth: true
                text: gaugeCard.title
                font.family: Design.Tokens.font.family.title
                font.pixelSize: Design.Tokens.font.size.title
                color: Design.Tokens.color.text.primary
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
                    ctx.strokeStyle = Design.Tokens.color.bg.surface;
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
                font.family: Design.Tokens.font.family.display
                font.pixelSize: 32
                font.bold: true
                color: gaugeCard.accentColor
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: gaugeCard.subtitle
            font.family: Design.Tokens.font.family.label
            font.pixelSize: Design.Tokens.font.size.body
            color: Design.Tokens.color.text.secondary
        }
    }
}
