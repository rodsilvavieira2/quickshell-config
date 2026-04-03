import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

DS.Card {
    id: root
    
    required property var mpris
    
    readonly property bool hasPlayer: mpris.isActive
    readonly property bool isPlaying: mpris.musicData.status === "Playing"
    readonly property string trackTitle: mpris.musicData.title
    readonly property string trackArtist: mpris.musicData.artist
    readonly property string artUrl: mpris.musicData.artUrl
    readonly property string timeLabel: mpris.musicData.timeStr
    
    readonly property color surfaceColor: Appearance.colors.cSurfaceContainer
    readonly property color textColor: Appearance.colors.cOnSurface
    readonly property color textDim: Appearance.colors.cOnSurfaceDim
    readonly property color accentColor: Appearance.colors.cPrimary
    
    Layout.fillWidth: true
    Layout.preferredHeight: 120

    radius: Design.Tokens.shape.extraLarge
    backgroundColor: surfaceColor
    borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.84)
    borderWidth: Design.Tokens.border.width.thin
    padding: 16
    shadowLevel: Design.Tokens.shadow.none
    clip: true
    
    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: Appearance.animation.medium2
            easing.type: Appearance.animation.standard
        }
    }
    
    // Background Art (No blur effect for now to maintain compatibility)
    Image {
        id: bgImage
        anchors.fill: parent
        source: root.artUrl
        fillMode: Image.PreserveAspectCrop
        opacity: root.hasPlayer ? 0.28 : 0
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.08, 0.10, 0.13, 0.30) }
            GradientStop { position: 1.0; color: Qt.rgba(0.06, 0.08, 0.11, 0.88) }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 16
        
        DS.Surface {
            Layout.preferredWidth: 72
            Layout.preferredHeight: 72
            padding: 0
            radius: Design.Tokens.shape.large
            backgroundColor: Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerHighest, 0.84)
            borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.68)
            borderWidth: Design.Tokens.border.width.thin
            clip: true
            
            Image {
                id: albumArt
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: status === Image.Ready ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
            
            DS.LucideIcon {
                anchors.centerIn: parent
                visible: albumArt.status !== Image.Ready
                name: "music-4"
                iconSize: 32
                color: root.textDim
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            
            RowLayout {
                spacing: 8

                Text {
                    text: "Now Playing"
                    font.family: Appearance.font.family
                    font.pixelSize: 10
                    font.bold: true
                    color: root.textDim
                }

                DS.Chip {
                    text: root.hasPlayer ? (root.isPlaying ? "Playing" : "Paused") : "Idle"
                    clickable: false
                    horizontalPadding: 10
                    verticalPadding: 4
                    contentFontSize: 9
                    containerColor: root.hasPlayer
                        ? Design.ThemePalette.withAlpha(root.accentColor, 0.16)
                        : Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, 0.06)
                    hoverContainerColor: containerColor
                    pressedContainerColor: containerColor
                    borderColor: "transparent"
                    contentColor: root.hasPlayer ? root.accentColor : root.textDim
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: root.trackTitle || "Nothing playing"
                font.family: Appearance.font.family
                font.pixelSize: 14
                font.bold: true
                color: root.textColor
                elide: Text.ElideRight
                maximumLineCount: 1
            }
            
            Text {
                Layout.fillWidth: true
                text: root.trackArtist || "Open a player to control playback from here"
                font.family: Appearance.font.family
                font.pixelSize: 11
                color: root.textDim
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.hasPlayer ? root.timeLabel : ""
                visible: text !== ""
                font.family: Appearance.font.family
                font.pixelSize: 10
                color: root.textDim
            }
        }
        
        RowLayout {
            spacing: 6
            
            DS.IconButton {
                iconName: "skip-back"
                preferredHeight: 40
                disabled: !root.hasPlayer
                onClicked: playerctlProc.run("previous")
            }
            
            DS.IconButton {
                preferredHeight: 48
                iconName: root.isPlaying ? "pause" : "play"
                iconPixelSize: 24
                variant: root.hasPlayer ? "primary" : "secondary"
                disabled: !root.hasPlayer
                onClicked: playerctlProc.run("play-pause")
            }
            
            DS.IconButton {
                iconName: "skip-forward"
                preferredHeight: 40
                disabled: !root.hasPlayer
                onClicked: playerctlProc.run("next")
            }
        }
    }
    
    Process {
        id: playerctlProc
        function run(cmd) {
            command = ["playerctl", cmd];
            running = true;
        }
    }
}
