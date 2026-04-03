import QtQuick
import QtQuick.Layouts
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

DS.Card {
    id: root
    
    required property var systemUsage
    
    readonly property color surfaceColor: Appearance.colors.cSurfaceContainer
    readonly property color textColor: Appearance.colors.cOnSurface
    readonly property color textDim: Appearance.colors.cOnSurfaceDim
    
    Layout.fillWidth: true
    Layout.preferredHeight: 104
    padding: 12
    radius: Design.Tokens.shape.extraLarge
    backgroundColor: root.surfaceColor
    borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.82)
    borderWidth: Design.Tokens.border.width.thin
    shadowLevel: Design.Tokens.shadow.none
    
    RowLayout {
        anchors.fill: parent
        spacing: 10

        StatItem {
            Layout.fillWidth: true
            iconName: "cpu"
            label: "CPU"
            value: root.systemUsage.cpuUsage * 100
            detail: root.systemUsage.cpuTemp
            accentColor: Appearance.colors.error
        }

        StatItem {
            Layout.fillWidth: true
            iconName: "memory-stick"
            label: "RAM"
            value: (root.systemUsage.memUsed / root.systemUsage.memTotal) * 100
            detail: root.systemUsage.memUsed.toFixed(1) + " / " + root.systemUsage.memTotal.toFixed(1) + " GB"
            accentColor: Appearance.colors.warning
        }

        StatItem {
            Layout.fillWidth: true
            visible: root.systemUsage.hasGpu
            iconName: "microchip"
            label: "GPU"
            value: root.systemUsage.gpuUsage * 100
            detail: root.systemUsage.gpuTemp
            accentColor: Appearance.colors.success
        }
    }
    
    component StatItem: DS.Surface {
        property string iconName
        property string label
        property real value
        property string detail: ""
        property color accentColor

        padding: 12
        radius: Design.Tokens.shape.large
        backgroundColor: Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerHighest, 0.9)
        borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.72)
        borderWidth: Design.Tokens.border.width.thin

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                DS.Surface {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    padding: 0
                    radius: Design.Tokens.shape.medium
                    backgroundColor: Design.ThemePalette.withAlpha(accentColor, 0.16)
                    borderWidth: 0

                    DS.LucideIcon {
                        anchors.centerIn: parent
                        name: iconName
                        iconSize: 15
                        color: accentColor
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: label
                        font.family: Appearance.font.family
                        font.pixelSize: 11
                        font.bold: true
                        color: root.textDim
                    }

                    Text {
                        text: Math.round(value) + "%"
                        font.family: Appearance.font.family
                        font.pixelSize: 17
                        font.bold: true
                        color: root.textColor
                    }
                }
            }

            DS.ProgressBar {
                Layout.fillWidth: true
                thickness: 5
                value: value / 100
                indicatorColor: accentColor
                trackColor: Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, 0.08)
            }

            Text {
                Layout.fillWidth: true
                text: detail
                visible: text !== ""
                font.family: Appearance.font.family
                font.pixelSize: 10
                color: root.textDim
                elide: Text.ElideRight
            }
        }
    }
}
