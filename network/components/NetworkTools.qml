import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ScrollView {
    id: root
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ColumnLayout {
        width: root.width
        spacing: 32
        Layout.margins: 24

        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "󰛳 Network Tools"
                font.pixelSize: 24
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }
        }

        // Ping Section
        ToolSection {
            title: "Ping"
            icon: "󰓅"
            placeholder: "Enter host (e.g. google.com)"
            command: "ping"
            args: ["-c", "4"]
        }

        // Traceroute Section
        ToolSection {
            title: "Traceroute"
            icon: "󰒄"
            placeholder: "Enter host (e.g. google.com)"
            command: "traceroute"
        }

        // DNS Lookup Section
        ToolSection {
            title: "DNS Lookup"
            icon: "󰖩"
            placeholder: "Enter domain (e.g. google.com)"
            command: "dig"
            args: ["+short"]
        }
        
        Item { Layout.preferredHeight: 24 }
    }

    component ToolSection: ColumnLayout {
        property string title
        property string icon
        property string placeholder
        property string command
        property var args: []
        
        spacing: 16
        Layout.fillWidth: true

        RowLayout {
            spacing: 12
            
            Text {
                text: icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: "#89b4fa"
            }
            
            Text {
                text: title
                font.pixelSize: 18
                font.bold: true
                color: "#cdd6f4"
            }
        }

        RowLayout {
            spacing: 12
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#181825"
                radius: 8
                border.color: input.activeFocus ? "#89b4fa" : "#313244"
                border.width: 1

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    selectByMouse: true
                    verticalAlignment: TextInput.AlignVCenter

                    Text {
                        text: placeholder
                        color: "#585b70"
                        font.pixelSize: 14
                        visible: !parent.text && !parent.activeFocus
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onAccepted: runButton.clicked()
                }
            }

            Button {
                id: runButton
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                enabled: input.text.length > 0 && !proc.running
                
                contentItem: Text {
                    text: proc.running ? "Running..." : "Run"
                    color: runButton.enabled ? "#1e1e2e" : "#585b70"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: proc.running ? "#fab387" : (runButton.enabled ? "#a6e3a1" : "#313244")
                    radius: 8
                }

                onClicked: {
                    outputArea.text = "";
                    proc.command = [command, ...args, input.text];
                    proc.running = true;
                }
            }
            
            Button {
                id: stopButton
                Layout.preferredWidth: 80
                Layout.preferredHeight: 40
                visible: proc.running
                
                contentItem: Text {
                    text: "Stop"
                    color: "#1e1e2e"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "#f38ba8"
                    radius: 8
                }

                onClicked: proc.running = false
            }
            
            Button {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 40
                visible: !proc.running && outputArea.text.length > 0
                
                contentItem: Text {
                    text: "Clear"
                    color: "#cdd6f4"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "#313244"
                    radius: 8
                }

                onClicked: outputArea.text = ""
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            color: "#11111b"
            radius: 8
            border.color: "#313244"
            border.width: 1

            ScrollView {
                anchors.fill: parent
                anchors.margins: 8
                clip: true

                TextArea {
                    id: outputArea
                    readOnly: true
                    color: "#a6e3a1"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    wrapMode: Text.WrapAnywhere
                    background: null
                    selectByMouse: true
                    
                    onTextChanged: {
                        cursorPosition = text.length
                    }
                }
            }
        }

        Process {
            id: proc
            stdout: SplitParser {
                onRead: data => outputArea.text += data + "\n"
            }
            stderr: SplitParser {
                onRead: data => outputArea.text += "Error: " + data + "\n"
            }
        }
    }
}
