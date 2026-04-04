import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

Item {
    id: root

    required property var audio

    readonly property real safeVolume: (audio && audio.volume !== undefined && !isNaN(audio.volume)) ? audio.volume : 0
    readonly property int currentVolume: Math.round(safeVolume * 100)
    readonly property int maxVolume: 140
    readonly property int displayedVolume: Math.max(0, Math.min(maxVolume, currentVolume))
    readonly property bool isMuted: audio && audio.muted !== undefined ? audio.muted : false
    readonly property bool isOverdriven: displayedVolume > 100

    readonly property color surfaceColor: Appearance.colors.cSurfaceContainerHigh
    readonly property color textColor: Appearance.colors.cOnSurface
    readonly property color fillColor: isOverdriven ? Appearance.colors.error : Appearance.colors.cPrimary

    Layout.fillWidth: true
    Layout.preferredHeight: 56
    implicitHeight: Layout.preferredHeight

    Rectangle {
        anchors.fill: parent
        radius: Design.Tokens.radius.pill
        color: root.surfaceColor
        border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.68)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 8

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
                color: muteButtonArea.pressed
                    ? Design.Tokens.color.surfaceContainerHighest
                    : Design.Tokens.color.surfaceContainer

                DS.LucideIcon {
                    anchors.centerIn: parent
                    name: root.isMuted ? "volume-x" : (root.displayedVolume > 33 ? "volume-2" : "volume-1")
                    color: root.isMuted || root.isOverdriven ? Appearance.colors.error : root.textColor
                    iconSize: 16
                }

                MouseArea {
                    id: muteButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.audio && root.audio.toggleMute) {
                            root.audio.toggleMute();
                        }
                    }
                }
            }

            Slider {
                id: control
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                from: 0
                to: root.maxVolume
                live: true
                value: root.displayedVolume
                implicitHeight: 28
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0

                background: Rectangle {
                    x: control.leftPadding
                    y: control.topPadding + control.availableHeight / 2 - height / 2
                    width: control.availableWidth
                    height: 8
                    radius: 4
                    color: Design.Tokens.color.surfaceContainer

                    Rectangle {
                        id: activeTrack
                        width: control.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        color: root.fillColor

                        Behavior on width {
                            enabled: !control.pressed
                            NumberAnimation {
                                duration: Appearance.animation.short4
                                easing.type: Appearance.animation.standard
                            }
                        }
                    }
                }

                handle: Rectangle {
                    x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                    y: control.topPadding + control.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: root.fillColor
                    border.width: 2
                    border.color: root.surfaceColor
                    scale: control.pressed ? 1.08 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: Appearance.animation.short4
                            easing.type: Appearance.animation.standard
                        }
                    }
                }

                onMoved: {
                    if (root.audio && root.audio.setVolume) {
                        root.audio.setVolume(value / 100);
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 52
                text: root.displayedVolume + "%"
                font.family: Appearance.font.family
                font.pixelSize: 13
                font.weight: Design.Tokens.font.weight.medium
                color: root.isOverdriven ? Appearance.colors.error : root.textColor
                horizontalAlignment: Text.AlignRight
            }
        }

        Connections {
            target: root

            function onCurrentVolumeChanged() {
                if (!control.pressed) {
                    control.value = root.displayedVolume;
                }
            }
        }
    }
}
