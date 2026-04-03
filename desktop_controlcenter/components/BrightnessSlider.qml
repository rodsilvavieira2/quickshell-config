import QtQuick
import QtQuick.Layouts
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

Item {
    id: root

    required property var brightness

    readonly property int currentBrightness: Math.round(brightness && brightness.percentage !== undefined ? brightness.percentage : 0)

    Layout.fillWidth: true
    Layout.preferredHeight: 60
    implicitHeight: Layout.preferredHeight

    DS.Surface {
        anchors.fill: parent
        variant: "surfaceContainerHigh"
        radius: Design.Tokens.shape.extraLarge
        backgroundColor: Appearance.colors.cSurfaceContainerHigh
        borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.9)
        borderWidth: Design.Tokens.border.width.thin
        padding: 0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 16
            spacing: 0

            DS.Chip {
                id: iconButton
                readonly property color accentColor: Appearance.colors.warning
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter
                clickable: false
                containerColor: Design.ThemePalette.withAlpha(accentColor, 0.16)
                hoverContainerColor: containerColor
                pressedContainerColor: containerColor
                borderColor: "transparent"
                horizontalPadding: 8
                verticalPadding: 8
                leading: Component {
                    DS.LucideIcon {
                        name: "sun-medium"
                        color: iconButton.accentColor
                        iconSize: 18
                    }
                }
            }

            DS.Slider {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.alignment: Qt.AlignVCenter
                from: 0
                to: 100
                value: root.currentBrightness
                onMoved: {
                    if (root.brightness && root.brightness.setBrightness) {
                        root.brightness.setBrightness(value / 100)
                    }
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
}
