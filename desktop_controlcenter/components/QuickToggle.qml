import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"

Rectangle {
    id: root
    
    property string icon: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property color activeColor: Appearance.colors.cPrimary
    property color surfaceColor: Appearance.colors.cSurfaceContainerHigh
    property color textColor: Appearance.colors.cOnSurface
    signal clicked()
    
    Layout.fillWidth: true
    Layout.preferredHeight: 64
    
    radius: 32
    
    color: active ? activeColor : surfaceColor
    
    Behavior on color {
        ColorAnimation { 
            duration: Appearance.animation.medium2
            easing.type: Appearance.animation.standard
        }
    }
    
    scale: toggleMouse.pressed ? 0.96 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: Appearance.animation.short2
            easing.type: Appearance.animation.standard
        }
    }
    
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.active 
            ? Qt.rgba(0, 0, 0, 0.08)
            : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
        opacity: toggleMouse.containsMouse && !toggleMouse.pressed ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.short3
                easing.type: Appearance.animation.standard
            }
        }
    }
    
    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 14
        
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: active 
                ? Qt.rgba(1, 1, 1, 0.25) 
                : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.1)
            
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animation.short4
                    easing.type: Appearance.animation.standard
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: Appearance.font.family
                font.pixelSize: 22
                color: active 
                    ? Qt.rgba(0, 0, 0, 0.87)
                    : root.textColor
                
                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.animation.short4
                        easing.type: Appearance.animation.standard
                    }
                }
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: root.label
                font.family: Appearance.font.family
                font.pixelSize: 14
                font.bold: true
                color: active 
                    ? Qt.rgba(0, 0, 0, 0.87)
                    : root.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
                
                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.animation.short4
                        easing.type: Appearance.animation.standard
                    }
                }
            }
            
            Text {
                text: root.subLabel
                font.family: Appearance.font.family
                font.pixelSize: 12
                color: active 
                    ? Qt.rgba(0, 0, 0, 0.6)
                    : root.textColor
                opacity: active ? 1 : 0.6
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
                
                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.animation.short4
                        easing.type: Appearance.animation.standard
                    }
                }
            }
        }
    }
}
