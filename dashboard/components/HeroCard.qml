import QtQuick
import QtQuick.Layouts
import "../shared/designsystem" as Design

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
    property color accentColor: Design.Tokens.color.accent.primary

    color: Design.Tokens.color.bg.elevated
    radius: Design.Tokens.radius.lg
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
                font.family: Design.Tokens.font.family.icon
                color: heroCard.accentColor
                font.pixelSize: 24
            }

            Text {
                Layout.fillWidth: true
                text: heroCard.title
                font.family: Design.Tokens.font.family.title
                font.pixelSize: Design.Tokens.font.size.title
                color: Design.Tokens.color.text.primary
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
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: 16
                        color: Design.Tokens.color.text.primary
                        font.bold: true
                    }
                    Text {
                        text: heroCard.secondaryLabel
                        font.family: Design.Tokens.font.family.label
                        font.pixelSize: Design.Tokens.font.size.body
                        color: Design.Tokens.color.text.secondary
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
            font.family: Design.Tokens.font.family.label
            font.pixelSize: 16
            color: Design.Tokens.color.text.secondary
        }
        Text {
            anchors.right: parent.right
            text: heroCard.mainValue
            font.family: Design.Tokens.font.family.display
            font.pixelSize: 36
            font.bold: true
            color: heroCard.accentColor
        }
    }
}
