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
    
    readonly property color surfaceColor: Appearance.colors.cSurfaceContainer
    readonly property color textColor: Appearance.colors.cOnSurface
    readonly property color textDim: Appearance.colors.cOnSurfaceDim
    readonly property color accentColor: Appearance.colors.cPrimary
    
    Layout.fillWidth: true
    Layout.preferredHeight: hasPlayer ? 100 : 0
    
    radius: 18
    color: surfaceColor
    clip: true
    visible: hasPlayer
    
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
        opacity: 0.15
        asynchronous: true
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14
        
        Rectangle {
            Layout.preferredWidth: 72
            Layout.preferredHeight: 72
            radius: 12
            color: Appearance.colors.cSurfaceContainerHigh
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
            spacing: 2
            
            Item { Layout.fillHeight: true }
            
            Text {
                Layout.fillWidth: true
                text: root.trackTitle || "No Media"
                font.family: Appearance.font.family
                font.pixelSize: 15
                font.bold: true
                color: root.textColor
                elide: Text.ElideRight
                maximumLineCount: 1
            }
            
            Text {
                Layout.fillWidth: true
                text: root.trackArtist
                font.family: Appearance.font.family
                font.pixelSize: 13
                color: root.textDim
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }
            
            Item { Layout.fillHeight: true }
        }
        
        RowLayout {
            spacing: 4
            
            ControlButton {
                icon: "󰒮"
                onClicked: playerctlProc.run("previous")
            }
            
            Rectangle {
                id: playBtn
                width: 48
                height: 48
                radius: 24
                color: root.accentColor
                
                scale: playMouse.pressed ? 0.92 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                
                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: Appearance.font.family
                    font.pixelSize: 24
                    color: Appearance.colors.cSurface
                }
                
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: playerctlProc.run("play-pause")
                }
            }
            
            ControlButton {
                icon: "󰒭"
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
        signal clicked()
        
        width: 40
        height: 40
        radius: 20
        color: btnMouse.containsMouse 
            ? Qt.rgba(1, 1, 1, 0.1) 
            : "transparent"
        
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
            onClicked: parent.clicked()
        }
    }
}
