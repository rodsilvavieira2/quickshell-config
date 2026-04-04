import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

Item {
    id: root

    required property var brightness

    readonly property int currentBrightness: Math.round(brightness && brightness.percentage !== undefined ? brightness.percentage : 0)
    readonly property color surfaceColor: Appearance.colors.cSurfaceContainerHigh

    Layout.fillWidth: true
    Layout.preferredHeight: 56
    implicitHeight: Layout.preferredHeight

    Rectangle {
        anchors.fill: parent
        radius: Design.Tokens.radius.pill
        color: root.surfaceColor
        border.width: 1
        border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.68)

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 4
            radius: Design.Tokens.radius.pill
            width: Math.max(36, control.visualPosition * (parent.width - 8))
            color: Design.Tokens.color.secondaryContainer
        }

        Slider {
            id: control
            anchors.fill: parent
            from: 0
            to: 100
            live: true
            value: root.currentBrightness

            background: Item { }
            handle: Rectangle {
                implicitWidth: 24
                implicitHeight: 24
                radius: 12
                color: Qt.rgba(1, 1, 1, control.pressed ? 0.12 : 0)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, control.pressed ? 0.16 : 0)
                x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                y: control.topPadding + control.availableHeight / 2 - height / 2
            }
            onMoved: {
                if (root.brightness && root.brightness.setBrightness) {
                    root.brightness.setBrightness(value / 100);
                }
            }
        }

        Connections {
            target: root

            function onCurrentBrightnessChanged() {
                if (!control.pressed) {
                    control.value = root.currentBrightness;
                }
            }
        }

        Component.onCompleted: control.value = root.currentBrightness

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
                color: Design.Tokens.color.surfaceContainer

                DS.LucideIcon {
                    anchors.centerIn: parent
                    name: "sun-medium"
                    color: Appearance.colors.warning
                    iconSize: 16
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 44
                text: root.currentBrightness + "%"
                font.family: Appearance.font.family
                font.pixelSize: 13
                font.weight: Design.Tokens.font.weight.medium
                color: Appearance.colors.cOnSurface
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
