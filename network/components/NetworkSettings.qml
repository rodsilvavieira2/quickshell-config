import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../services"

ScrollView {
    id: root
    
    contentWidth: availableWidth
    clip: true
    
    ColumnLayout {
        width: parent.width
        spacing: 24
        
        Component.onCompleted: {
            Nmcli.getWirelessInterfaces(() => {});
            Nmcli.getEthernetInterfaces(() => {});
        }
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Text {
                text: "󰒓"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 28
                color: "#89b4fa" // Blue
            }
            
            Text {
                text: "Settings"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
                font.bold: true
                color: "#cdd6f4" // Text
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // Global Toggles Section
        SettingsSection {
            title: "Global Toggles"
            icon: "󰀱"
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                
                ToggleItem {
                    label: "Wi-Fi"
                    description: "Enable or disable wireless networking"
                    checked: Nmcli.wifiEnabled
                    onToggled: Nmcli.enableWifi(checked, null)
                }
                
                Separator {}
                
                ToggleItem {
                    label: "Network Notifications"
                    description: "Show alerts for connection changes"
                    checked: true // Mock
                    onToggled: console.log("Notifications toggled:", checked)
                }
            }
        }
        
        // Interface Priority/Configuration Section
        SettingsSection {
            title: "Interfaces & Configuration"
            icon: "󰈀"
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Text {
                    text: "Available Interfaces"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#bac2de" // Subtext1
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Repeater {
                        model: Nmcli.wirelessInterfaces
                        delegate: InterfaceItem {
                            name: modelData.device
                            type: "Wireless"
                            state: modelData.state
                            icon: "󰖩"
                        }
                    }
                    
                    Repeater {
                        model: Nmcli.ethernetInterfaces
                        delegate: InterfaceItem {
                            name: modelData.device
                            type: "Ethernet"
                            state: modelData.state
                            icon: "󰈀"
                        }
                    }
                }
                
                Separator {}
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    ActionButton {
                        text: "Configure Proxy"
                        icon: "󰒄"
                        onClicked: console.log("Configure Proxy clicked")
                    }
                    
                    ActionButton {
                        text: "Set Manual IP"
                        icon: "󰖟"
                        onClicked: console.log("Set Manual IP clicked")
                    }
                }
            }
        }
        
        // Advanced Actions Section
        SettingsSection {
            title: "Advanced Actions"
            icon: "󰒓"
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                
                ActionButton {
                    text: "Forget Known Networks"
                    icon: "󱚵"
                    baseColor: "#f38ba8" // Red
                    Layout.fillWidth: true
                    onClicked: console.log("Forget Known Networks clicked")
                }
            }
        }
        
        Item { Layout.preferredHeight: 20 } // Bottom padding
    }
    
    // --- Internal Components ---
    
    component SettingsSection: Rectangle {
        id: section
        property string title
        property string icon
        default property alias content: container.data
        
        Layout.fillWidth: true
        Layout.preferredHeight: layout.implicitHeight + 32
        color: "#181825" // Mantle
        radius: 12
        border.color: "#313244" // Surface0
        border.width: 1
        
        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: section.icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: "#fab387" // Peach
                }
                
                Text {
                    text: section.title
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#cdd6f4" // Text
                }
            }
            
            ColumnLayout {
                id: container
                Layout.fillWidth: true
            }
        }
    }
    
    component ToggleItem: RowLayout {
        id: toggleItem
        property string label
        property string description
        property bool checked
        signal toggled(bool checked)
        
        Layout.fillWidth: true
        spacing: 12
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: toggleItem.label
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.bold: true
                color: "#cdd6f4"
            }
            
            Text {
                text: toggleItem.description
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                color: "#a6adc8" // Subtext0
            }
        }
        
        Switch {
            id: sw
            checked: toggleItem.checked
            onToggled: toggleItem.toggled(checked)
            
            indicator: Rectangle {
                implicitWidth: 40
                implicitHeight: 20
                x: parent.leftPadding
                y: parent.height / 2 - height / 2
                radius: 10
                color: parent.checked ? "#a6e3a1" : "#313244" // Green : Surface0
                
                Rectangle {
                    x: parent.parent.checked ? parent.width - width - 2 : 2
                    y: 2
                    width: 16
                    height: 16
                    radius: 8
                    color: "#1e1e2e" // Base
                    
                    Behavior on x { NumberAnimation { duration: 200 } }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: sw.toggle()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
    
    component InterfaceItem: Rectangle {
        id: ifaceItem
        property string name
        property string type
        property string state
        property string icon
        
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        color: "#313244" // Surface0
        radius: 8
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            
            Text {
                text: ifaceItem.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                color: "#89b4fa" // Blue
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                
                Text {
                    text: ifaceItem.name
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#cdd6f4"
                }
                
                Text {
                    text: ifaceItem.type + " • " + ifaceItem.state
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: "#a6adc8"
                }
            }
            
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: ifaceItem.state.includes("connected") ? "#a6e3a1" : "#f38ba8"
            }
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: console.log("Interface clicked:", ifaceItem.name)
        }
    }
    
    component ActionButton: Rectangle {
        id: btn
        property string text
        property string icon
        property color baseColor: "#89b4fa"
        signal clicked()
        
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: 8
        color: mouseArea.pressed ? Qt.darker(btn.baseColor, 1.2) : (mouseArea.containsMouse ? Qt.lighter(btn.baseColor, 1.1) : btn.baseColor)
        opacity: 0.9
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        RowLayout {
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: btn.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                color: "#1e1e2e"
            }
            
            Text {
                text: btn.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.bold: true
                color: "#1e1e2e"
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.clicked()
            cursorShape: Qt.PointingHandCursor
        }
    }
    
    component Separator: Rectangle {
        Layout.fillWidth: true
        height: 1
        color: "#313244"
    }
}
