import QtQuick
import QtQuick.Layouts

Rectangle {
    id: heroCard

    property string icon: ""
    property string title: ""
    property string mainValue: ""
    property string mainLabel: ""
    property string secondaryValue: ""
    property string secondaryLabel: ""
    property real usage: 0
    property real tempProgress: 0
    property color accentColor: "#89b4fa"

    color: "#313244"
    radius: 16
    clip: true

    // Background fill based on usage
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * heroCard.usage
        color: Qt.rgba(heroCard.accentColor.r, heroCard.accentColor.g, heroCard.accentColor.b, 0.15)
        radius: 16
        
        Behavior on width {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: heroCard.icon
                font.family: "JetBrainsMono Nerd Font"
                color: heroCard.accentColor
                font.pixelSize: 24
            }

            Text {
                Layout.fillWidth: true
                text: heroCard.title
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: "#cdd6f4"
            }
        }

        // Content
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Column {
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true
                spacing: 8

                Row {
                    spacing: 8
                    Text {
                        text: heroCard.secondaryValue
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: "#cdd6f4"
                        font.bold: true
                    }
                    Text {
                        text: heroCard.secondaryLabel
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: "#a6adc8"
                        anchors.baseline: parent.children[0].baseline
                    }
                }

                // Temp progress bar
                Rectangle {
                    width: parent.width * 0.5
                    height: 8
                    radius: 4
                    color: Qt.rgba(heroCard.accentColor.r, heroCard.accentColor.g, heroCard.accentColor.b, 0.2)

                    Rectangle {
                        height: parent.height
                        width: parent.width * heroCard.tempProgress
                        radius: 4
                        color: heroCard.accentColor
                        
                        Behavior on width {
                            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
                        }
                    }
                }
            }
        }
    }

    // Right-aligned main values
    Column {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 32
        spacing: 4
        
        Text {
            anchors.right: parent.right
            text: heroCard.mainLabel
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color: "#a6adc8"
        }
        Text {
            anchors.right: parent.right
            text: heroCard.mainValue
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 36
            font.bold: true
            color: heroCard.accentColor
        }
    }
}
