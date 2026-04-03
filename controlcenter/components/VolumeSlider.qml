import QtQuick
import QtQuick.Layouts
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

Item {
    id: root

    required property var audio

    readonly property real safeVolume: (audio && audio.volume !== undefined && !isNaN(audio.volume)) ? audio.volume : 0
    readonly property int currentVolume: Math.round(safeVolume * 100)
    readonly property bool isMuted: audio && audio.muted !== undefined ? audio.muted : false

    readonly property color surfaceColor: Appearance.colors.cSurfaceContainerHigh
    readonly property color textColor: Appearance.colors.cOnSurface

    Layout.fillWidth: true
    Layout.preferredHeight: 60
    implicitHeight: Layout.preferredHeight

    DS.Surface {
        anchors.fill: parent
        variant: "surfaceContainerHigh"
        radius: Design.Tokens.shape.extraLarge
        backgroundColor: root.surfaceColor
        borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.9)
        borderWidth: Design.Tokens.border.width.thin
        padding: 0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 16
            spacing: 0

            DS.Chip {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignVCenter
                clickable: true
                containerColor: "transparent"
                hoverContainerColor: Design.ThemePalette.withAlpha(root.textColor, 0.10)
                pressedContainerColor: Design.ThemePalette.withAlpha(root.textColor, 0.14)
                borderColor: "transparent"
                horizontalPadding: 8
                verticalPadding: 8
                leading: Component {
                    DS.LucideIcon {
                        name: root.isMuted ? "volume-x" : (root.currentVolume > 33 ? "volume-2" : "volume-1")
                        color: root.isMuted ? Appearance.colors.error : root.textColor
                        iconSize: 18
                    }
                }
                onClicked: {
                    if (root.audio && root.audio.toggleMute) {
                        root.audio.toggleMute()
                    }
                }
            }

            DS.Slider {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 12
                Layout.alignment: Qt.AlignVCenter
                from: 0
                to: 100
                value: root.currentVolume
                onMoved: {
                    if (root.audio && root.audio.setVolume) {
                        root.audio.setVolume(value / 100)
                    }
                }
            }

            Text {
                Layout.rightMargin: 16
                Layout.preferredWidth: 40
                text: root.currentVolume + "%"
                font.family: Appearance.font.family
                font.pixelSize: 12
                font.bold: true
                color: root.textColor
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
