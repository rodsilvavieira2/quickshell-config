import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    
    property int currentIndex: 0
    signal tabSelected(int index)
    
    width: 72
    color: "#181825" // Mantle
    radius: 16
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16
        
        SidebarItem {
            icon: "󰈀"
            tooltip: "Network Activity"
            active: root.currentIndex === 0
            onClicked: {
                root.currentIndex = 0
                root.tabSelected(0)
            }
        }
        
        SidebarItem {
            icon: "󰓅"
            tooltip: "Speed Test"
            active: root.currentIndex === 1
            onClicked: {
                root.currentIndex = 1
                root.tabSelected(1)
            }
        }
        
        SidebarItem {
            icon: "󰖩"
            tooltip: "Wi-Fi Scanner"
            active: root.currentIndex === 2
            onClicked: {
                root.currentIndex = 2
                root.tabSelected(2)
            }
        }
        
        SidebarItem {
            icon: "󰓼"
            tooltip: "Network Tools"
            active: root.currentIndex === 3
            onClicked: {
                root.currentIndex = 3
                root.tabSelected(3)
            }
        }
        
        Item { Layout.fillHeight: true }
        
        SidebarItem {
            icon: "󰒓"
            tooltip: "Settings"
            active: root.currentIndex === 4
            onClicked: {
                root.currentIndex = 4
                root.tabSelected(4)
            }
        }
    }
    
    component SidebarItem: Rectangle {
        id: item
        required property string icon
        required property string tooltip
        property bool active: false
        signal clicked()
        
        Layout.preferredWidth: 48
        Layout.preferredHeight: 48
        radius: 12
        color: active ? "#313244" : "transparent" // Surface0
        
        Behavior on color { ColorAnimation { duration: 200 } }
        
        Text {
            anchors.centerIn: parent
            text: item.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 24
            color: item.active ? "#89b4fa" : "#a6adc8" // Blue : Subtext0
            
            Behavior on color { ColorAnimation { duration: 200 } }
        }
        
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: item.clicked()
            cursorShape: Qt.PointingHandCursor
        }
        
        ToolTip.visible: ma.containsMouse
        ToolTip.text: item.tooltip
        ToolTip.delay: 500
    }
}
