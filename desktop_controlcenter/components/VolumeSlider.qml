import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"

Rectangle {
    id: root
    
    required property var audio
    
    readonly property int currentVolume: Math.round((audio.volume ?? 0) * 100)
    readonly property bool isMuted: audio.muted ?? false
    
    readonly property color surfaceColor: Appearance.colors.cSurfaceContainerHigh
    readonly property color textColor: Appearance.colors.cOnSurface
    readonly property color accentColor: Appearance.colors.success
    
    Layout.fillWidth: true
    Layout.preferredHeight: 48
    
    radius: 24
    color: surfaceColor
    
    Behavior on color {
        ColorAnimation {
            duration: Appearance.animation.medium2
            easing.type: Appearance.animation.standard
        }
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        Rectangle {
            id: muteBtn
            Layout.preferredWidth: 48
            Layout.fillHeight: true
            radius: 24
            color: muteMouse.containsMouse 
                ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.1) 
                : "transparent"
            
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animation.short3
                    easing.type: Appearance.animation.standard
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.isMuted ? "󰝟" : (root.currentVolume > 66 ? "󰕾" : (root.currentVolume > 33 ? "󰖀" : "󰕿"))
                font.family: Appearance.font.family
                font.pixelSize: 20
                color: root.isMuted ? Appearance.colors.error : root.textColor
                
                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.animation.short3
                        easing.type: Appearance.animation.standard
                    }
                }
            }
            
            MouseArea {
                id: muteMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.audio.toggleMute()
            }
        }
        
        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: 12
            
            from: 0
            to: 100
            value: root.currentVolume
            live: true
            
            onMoved: root.audio.setVolume(value / 100)
            
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 48
                width: slider.availableWidth
                height: implicitHeight
                radius: 24
                color: "transparent"
                
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 24
                    color: root.accentColor
                    opacity: 0.2
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: Appearance.animation.short2
                            easing.type: Appearance.animation.standard
                        }
                    }
                }
            }
            
            handle: Rectangle {
                visible: false
            }
        }
        
        Text {
            Layout.rightMargin: 16
            Layout.preferredWidth: 40
            text: root.currentVolume + "%"
            font.family: Appearance.font.family
            font.pixelSize: 13
            font.bold: true
            color: root.textColor
            horizontalAlignment: Text.AlignRight
        }
    }
}
