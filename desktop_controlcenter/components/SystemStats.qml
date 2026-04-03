import QtQuick
import QtQuick.Layouts
import Quickshell

import "../common"

Rectangle {
    id: root
    
    required property var systemUsage
    
    readonly property color surfaceColor: Appearance.colors.cSurfaceContainer
    readonly property color textColor: Appearance.colors.cOnSurface
    readonly property color textDim: Appearance.colors.cOnSurfaceDim
    
    Layout.fillWidth: true
    Layout.preferredHeight: 104

    radius: 22
    color: surfaceColor
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    
    Behavior on color {
        ColorAnimation {
            duration: Appearance.animation.medium2
            easing.type: Appearance.animation.standard
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        StatItem {
            Layout.fillWidth: true
            icon: "󰘚"
            label: "CPU"
            value: root.systemUsage.cpuUsage * 100
            detail: root.systemUsage.cpuTemp
            accentColor: Appearance.colors.error
        }

        StatItem {
            Layout.fillWidth: true
            icon: "󰍛"
            label: "RAM"
            value: (root.systemUsage.memUsed / root.systemUsage.memTotal) * 100
            detail: root.systemUsage.memUsed.toFixed(1) + " / " + root.systemUsage.memTotal.toFixed(1) + " GB"
            accentColor: Appearance.colors.warning
        }

        StatItem {
            Layout.fillWidth: true
            visible: root.systemUsage.hasGpu
            icon: "󰢮"
            label: "GPU"
            value: root.systemUsage.gpuUsage * 100
            detail: root.systemUsage.gpuTemp
            accentColor: Appearance.colors.success
        }
    }
    
    component StatItem: Rectangle {
        property string icon
        property string label
        property real value
        property string detail: ""
        property color accentColor

        radius: 18
        color: Qt.rgba(1, 1, 1, 0.04)
        border.color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: 10
                    color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.16)

                    Text {
                        anchors.centerIn: parent
                        text: icon
                        font.family: Appearance.font.family
                        font.pixelSize: 15
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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 5
                radius: 2.5
                color: Qt.rgba(1, 1, 1, 0.07)

                Rectangle {
                    width: parent.width * Math.min(value / 100, 1)
                    height: parent.height
                    radius: 2.5
                    color: accentColor

                    Behavior on width {
                        NumberAnimation {
                            duration: Appearance.animation.medium2
                            easing.type: Appearance.animation.standard
                        }
                    }
                }
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
