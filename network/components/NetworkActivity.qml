import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../services"

ScrollView {
    id: root
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    
    ColumnLayout {
        width: root.width
        spacing: 24
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            
            Text {
                text: "󰈀 Network Activity"
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }
        }
        
        // Info Cards
        GridLayout {
            columns: 4
            Layout.fillWidth: true
            Layout.margins: 16
            columnSpacing: 16
            rowSpacing: 16
            
            InfoCard {
                label: "IP Address"
                value: Nmcli.ethernetDeviceDetails?.ipAddress || "N/A"
                icon: "󰩟"
                iconColor: "#89b4fa" // Blue
            }
            
            InfoCard {
                label: "Gateway"
                value: Nmcli.ethernetDeviceDetails?.gateway || "N/A"
                icon: "󰒄"
                iconColor: "#a6e3a1" // Green
            }
            
            InfoCard {
                label: "DNS"
                value: Nmcli.ethernetDeviceDetails?.dns?.join(", ") || "N/A"
                icon: "󰖩"
                iconColor: "#f9e2af" // Yellow
            }
            
            InfoCard {
                label: "MAC Address"
                value: Nmcli.ethernetDeviceDetails?.macAddress || "N/A"
                icon: "󰇧"
                iconColor: "#cba6f7" // Mauve
            }
        }
        
        // Live Traffic Chart
        LiveTrafficChart {
            Layout.fillWidth: true
            Layout.preferredHeight: 350
            Layout.margins: 16
        }
        
        Item { Layout.fillHeight: true }
        Item { Layout.preferredHeight: 24 }
    }
}
