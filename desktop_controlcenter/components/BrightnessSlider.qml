import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"

Rectangle {
    id: root

    required property var brightness

    readonly property int currentBrightness: Math.round((brightness?.percentage ?? 0))

    Layout.fillWidth: true
    Layout.preferredHeight: 60

    radius: 24
    color: Appearance.colors.cSurfaceContainerHigh
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 0

        Rectangle {
            id: iconButton
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            Layout.alignment: Qt.AlignVCenter
            radius: 17
            readonly property color accentColor: Appearance.colors.warning
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, iconMouse.containsMouse ? 0.24 : 0.16)

            Text {
                anchors.centerIn: parent
                text: root.currentBrightness > 70 ? "󰃠" : (root.currentBrightness > 30 ? "󰃟" : "󰃞")
                font.family: Appearance.font.family
                font.pixelSize: 18
                color: iconButton.accentColor
            }

            MouseArea {
                id: iconMouse
                anchors.fill: parent
                hoverEnabled: true
            }
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12

            from: 0
            to: 100
            value: root.currentBrightness
            live: false

            onMoved: root.brightness.setBrightness(value / 100)

            background: Item {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 10

                Rectangle {
                    anchors.fill: parent
                    radius: 5
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 5
                    color: Appearance.colors.warning

                    Behavior on width {
                        NumberAnimation {
                            duration: Appearance.animation.short3
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            handle: Rectangle {
                width: 18
                height: 18
                radius: 9
                color: "#f8f8fa"
                border.color: Qt.rgba(0, 0, 0, 0.18)
                border.width: 1
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            }
        }

        Text {
            Layout.preferredWidth: 42
            text: root.currentBrightness + "%"
            font.family: Appearance.font.family
            font.pixelSize: 12
            font.bold: true
            color: Appearance.colors.cOnSurface
            horizontalAlignment: Text.AlignRight
        }
    }
}
