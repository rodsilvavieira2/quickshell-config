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
    Layout.preferredHeight: 72
    
    radius: 16
    color: surfaceColor
    
    Behavior on color {
        ColorAnimation {
            duration: Appearance.animation.medium2
            easing.type: Appearance.animation.standard
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 0
        
        Item { Layout.fillWidth: true }
        
        StatItem {
            icon: "󰘚"
            label: "CPU"
            value: root.systemUsage.cpuUsage * 100
            accentColor: Appearance.colors.error
        }
        
        Item { Layout.fillWidth: true }
        
        Rectangle {
            width: 1
            height: 40
            color: Appearance.colors.cBorder
            opacity: 0.2
        }
        
        Item { Layout.fillWidth: true }
        
        StatItem {
            icon: "󰍛"
            label: "RAM"
            value: (root.systemUsage.memUsed / root.systemUsage.memTotal) * 100
            accentColor: Appearance.colors.warning
        }
        
        Item { Layout.fillWidth: true }
        
        Rectangle {
            visible: root.systemUsage.hasGpu
            width: 1
            height: 40
            color: Appearance.colors.cBorder
            opacity: 0.2
        }
        
        Item { 
            Layout.fillWidth: true 
            visible: root.systemUsage.hasGpu
        }
        
        StatItem {
            visible: root.systemUsage.hasGpu
            icon: "󰢮"
            label: "GPU"
            value: root.systemUsage.gpuUsage * 100
            accentColor: Appearance.colors.success
        }
        
        Item { 
            Layout.fillWidth: true 
            visible: root.systemUsage.hasGpu
        }
    }
    
    component StatItem: ColumnLayout {
        property string icon
        property string label
        property real value
        property color accentColor
        
        spacing: 4
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6
            
            Text {
                text: icon
                font.family: Appearance.font.family
                font.pixelSize: 16
                color: accentColor
            }
            
            Text {
                text: Math.round(value) + "%"
                font.family: Appearance.font.family
                font.pixelSize: 16
                font.bold: true
                color: root.textColor
            }
        }
        
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: 3
            radius: 1.5
            color: Appearance.colors.cBorder
            opacity: 0.2
            
            Rectangle {
                width: parent.width * Math.min(value / 100, 1)
                height: parent.height
                radius: 1.5
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
            Layout.alignment: Qt.AlignHCenter
            text: label
            font.family: Appearance.font.family
            font.pixelSize: 10
            font.bold: true
            color: root.textDim
        }
    }
}
