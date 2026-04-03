import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import "../common"

Rectangle {
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
    
    radius: 24
    color: surfaceColor
    clip: true
    border.color: Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    
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
        anchors.margins: 16
        spacing: 16
        
        Rectangle {
            Layout.preferredWidth: 72
            Layout.preferredHeight: 72
            radius: 18
            color: Qt.rgba(1, 1, 1, 0.08)
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
            
            Text {
                anchors.centerIn: parent
                text: "󰝚"
                font.family: Appearance.font.family
                font.pixelSize: 32
                color: root.textDim
                visible: albumArt.status !== Image.Ready
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

                Rectangle {
                    radius: 9
                    implicitWidth: statusText.implicitWidth + 12
                    implicitHeight: 18
                    color: root.hasPlayer
                        ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.16)
                        : Qt.rgba(1, 1, 1, 0.06)

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: root.hasPlayer ? (root.isPlaying ? "Playing" : "Paused") : "Idle"
                        font.family: Appearance.font.family
                        font.pixelSize: 9
                        font.bold: true
                        color: root.hasPlayer ? root.accentColor : root.textDim
                    }
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
            
            ControlButton {
                icon: "󰒮"
                buttonEnabled: root.hasPlayer
                onClicked: playerctlProc.run("previous")
            }
            
            Rectangle {
                id: playBtn
                width: 48
                height: 48
                radius: 24
                color: root.hasPlayer ? root.accentColor : Qt.rgba(1, 1, 1, 0.08)
                
                scale: playMouse.pressed ? 0.92 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                
                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: Appearance.font.family
                    font.pixelSize: 24
                    color: root.hasPlayer ? Appearance.colors.cSurface : root.textDim
                }
                
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.hasPlayer
                    onClicked: playerctlProc.run("play-pause")
                }
            }
            
            ControlButton {
                icon: "󰒭"
                buttonEnabled: root.hasPlayer
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
    
    component ControlButton: Rectangle {
        property string icon
        property bool buttonEnabled: true
        signal clicked()
        
        width: 40
        height: 40
        radius: 20
        color: btnMouse.containsMouse && buttonEnabled
            ? Qt.rgba(1, 1, 1, 0.1) 
            : "transparent"
        opacity: buttonEnabled ? 1 : 0.45
        
        scale: btnMouse.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }
        
        Text {
            anchors.centerIn: parent
            text: parent.icon
            font.family: Appearance.font.family
            font.pixelSize: 22
            color: root.textColor
        }
        
        MouseArea {
            id: btnMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            enabled: parent.buttonEnabled
            onClicked: parent.clicked()
        }
    }
}
