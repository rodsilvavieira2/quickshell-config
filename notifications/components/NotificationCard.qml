import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    
    required property var notif
    required property bool isPopup
    
    signal closeClicked()
    signal actionClicked(string actionId)
    
    width: 380
    height: layout.implicitHeight + 24
    
    color: notif.urgency === "critical" ? "#311825" : "#181825" // Mantle (darker) or Critical red tint
    radius: 12
    border.color: notif.urgency === "critical" ? "#f38ba8" : (isPopup ? "#89b4fa" : "#313244")
    border.width: isPopup ? 2 : 1
    
    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            // App Icon
            Image {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                source: Quickshell.iconPath(notif.appIcon || "dialog-information")
                sourceSize: Qt.size(24, 24)
            }
            
            Text {
                Layout.fillWidth: true
                text: notif.appName || "Notification"
                color: "#a6adc8"
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }
            
            Text {
                text: notif.time || ""
                color: "#a6adc8"
                font.pixelSize: 12
            }
            
            MouseArea {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                cursorShape: Qt.PointingHandCursor
                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: "#f38ba8"
                    font.bold: true
                    font.pixelSize: 16
                }
                onClicked: root.closeClicked()
            }
        }
        
        // Body
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            // Optional Image
            Image {
                visible: notif.image !== ""
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                Layout.alignment: Qt.AlignTop
                source: notif.image !== "" ? (notif.image.startsWith("/") ? "file://" + notif.image : notif.image) : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(64, 64)
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 4
                
                Text {
                    Layout.fillWidth: true
                    text: notif.summary || ""
                    color: "#cdd6f4"
                    font.pixelSize: 15
                    font.bold: true
                    wrapMode: Text.Wrap
                }
                
                Text {
                    Layout.fillWidth: true
                    text: notif.body || ""
                    color: "#a6adc8"
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    visible: text !== ""
                }
            }
        }
        
        // Actions
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: notif.actions && notif.actions.length > 0
            
            Repeater {
                model: notif.actions
                delegate: Button {
                    Layout.fillWidth: true
                    text: modelData.text
                    background: Rectangle {
                        color: "#313244"
                        radius: 6
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#cdd6f4"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: root.actionClicked(modelData.identifier)
                }
            }
        }
    }
}
