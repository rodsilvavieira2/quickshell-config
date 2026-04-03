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
    Layout.preferredHeight: 88

    radius: 26
    color: active
        ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.22)
        : surfaceColor
    border.color: active
        ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.34)
        : Qt.rgba(1, 1, 1, 0.08)
    border.width: 1
    
    Behavior on color {
        ColorAnimation { 
            duration: Appearance.animation.medium2
            easing.type: Appearance.animation.standard
        }
    }
    
    scale: toggleMouse.pressed ? 0.985 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: Appearance.animation.short2
            easing.type: Appearance.animation.standard
        }
    }
    
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Qt.rgba(1, 1, 1, 0.06)
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
        anchors.margins: 18
        spacing: 12
        
        Rectangle {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 18
            color: active
                ? Qt.rgba(1, 1, 1, 0.14)
                : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
            
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
                font.pixelSize: 19
                color: active ? Appearance.colors.cOnSurface : root.textColor
                
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
            spacing: 3

            RowLayout {
                spacing: 6

                Text {
                    text: root.label
                    font.family: Appearance.font.family
                    font.pixelSize: 13
                    font.bold: true
                    color: active ? Appearance.colors.cOnSurface : root.textColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 7
                    Layout.preferredHeight: 7
                    radius: 3.5
                    color: active ? activeColor : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.28)
                }
            }

            Text {
                text: root.subLabel
                font.family: Appearance.font.family
                font.pixelSize: 11
                color: Appearance.colors.cOnSurfaceVariant
                opacity: 1
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
