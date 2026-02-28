import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    color: "#181825"
    radius: 12
    border.color: "#313244"
    border.width: 1

    property var audioService: null
    property string uiFontFamily: "JetBrainsMono Nerd Font Mono"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 24

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "AUDIO CONTROLS"
            color: "#f5c2e7" // Pink
            font.family: uiFontFamily
            font.pixelSize: 16
            font.bold: true
            font.letterSpacing: 1.1
        }

        // Output Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "󰓃" // Speaker icon
                    color: "#89b4fa"
                    font.family: uiFontFamily
                    font.pixelSize: 18
                }
                
                ComboBox {
                    id: outputCombo
                    Layout.fillWidth: true
                    model: root.audioService ? root.audioService.sinks : []
                    activeFocusOnTab: true
                    
                    background: Rectangle {
                        color: "#313244"
                        radius: 6
                        border.color: outputCombo.activeFocus ? "#cdd6f4" : "transparent"
                        border.width: outputCombo.activeFocus ? 2 : 0
                    }
                    
                    contentItem: Text {
                        text: (root.audioService && root.audioService.sink) ? (root.audioService.sink.description || root.audioService.sink.name || "Unknown") : "None"
                        color: "#cdd6f4"
                        font.family: uiFontFamily
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        leftPadding: 8
                        rightPadding: 8
                    }
                    
                    delegate: ItemDelegate {
                        width: parent.width
                        contentItem: Text {
                            text: modelData.description || modelData.name || "Unknown"
                            color: "#cdd6f4"
                            font.family: uiFontFamily
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#45475a" : "#1e1e2e"
                            radius: 4
                        }
                    }
                    
                    popup: Popup {
                        y: outputCombo.height + 4
                        width: outputCombo.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 4

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: outputCombo.popup.visible ? outputCombo.delegateModel : null
                            currentIndex: outputCombo.highlightedIndex
                        }

                        background: Rectangle {
                            color: "#1e1e2e"
                            border.color: "#313244"
                            border.width: 1
                            radius: 8
                        }
                    }
                    
                    onActivated: function(index) {
                        if (root.audioService && index >= 0) {
                            root.audioService.setAudioSink(model[index]);
                        }
                    }
                }

                Text {
                    text: root.audioService && !isNaN(root.audioService.volume) ? Math.round(root.audioService.volume * 100) + "%" : "0%"
                    color: "#a6adc8"
                    font.family: uiFontFamily
                    font.pixelSize: 13
                    Layout.minimumWidth: 35
                    horizontalAlignment: Text.AlignRight
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    id: outputMuteBtn
                    width: 32
                    height: 32
                    radius: 6
                    color: root.audioService && root.audioService.muted ? "#f38ba8" : "#313244"
                    border.color: activeFocus ? "#cdd6f4" : "transparent"
                    border.width: activeFocus ? 2 : 0
                    activeFocusOnTab: true
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.audioService) root.audioService.toggleMute();
                            event.accepted = true;
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.audioService && root.audioService.muted ? "󰝟" : "󰕾"
                        color: "#cdd6f4"
                        font.family: uiFontFamily
                        font.pixelSize: 16
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.audioService) root.audioService.toggleMute();
                        }
                    }
                }
                
                Slider {
                    id: outputSlider
                    Layout.fillWidth: true
                    activeFocusOnTab: true
                    value: root.audioService && !isNaN(root.audioService.volume) ? root.audioService.volume : 0
                    onMoved: {
                        if (root.audioService) root.audioService.setVolume(value);
                    }
                    background: Rectangle {
                        x: outputSlider.leftPadding
                        y: outputSlider.topPadding + outputSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: outputSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: "#313244"
                        Rectangle {
                            width: outputSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#89b4fa"
                            radius: 3
                        }
                    }
                    handle: Rectangle {
                        x: outputSlider.leftPadding + outputSlider.visualPosition * (outputSlider.availableWidth - width)
                        y: outputSlider.topPadding + outputSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: outputSlider.pressed ? "#b4befe" : "#89b4fa"
                        border.color: outputSlider.activeFocus ? "#cdd6f4" : "transparent"
                        border.width: outputSlider.activeFocus ? 2 : 0
                    }
                }
            }
        }

        // Input Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "󰍬" // Mic icon
                    color: "#f5c2e7"
                    font.family: uiFontFamily
                    font.pixelSize: 18
                }
                
                ComboBox {
                    id: inputCombo
                    Layout.fillWidth: true
                    model: root.audioService ? root.audioService.sources : []
                    activeFocusOnTab: true
                    
                    background: Rectangle {
                        color: "#313244"
                        radius: 6
                        border.color: inputCombo.activeFocus ? "#cdd6f4" : "transparent"
                        border.width: inputCombo.activeFocus ? 2 : 0
                    }
                    
                    contentItem: Text {
                        text: (root.audioService && root.audioService.source) ? (root.audioService.source.description || root.audioService.source.name || "Unknown") : "None"
                        color: "#cdd6f4"
                        font.family: uiFontFamily
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        leftPadding: 8
                        rightPadding: 8
                    }
                    
                    delegate: ItemDelegate {
                        width: parent.width
                        contentItem: Text {
                            text: modelData.description || modelData.name || "Unknown"
                            color: "#cdd6f4"
                            font.family: uiFontFamily
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            color: parent.highlighted ? "#45475a" : "#1e1e2e"
                            radius: 4
                        }
                    }
                    
                    popup: Popup {
                        y: inputCombo.height + 4
                        width: inputCombo.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 4

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: inputCombo.popup.visible ? inputCombo.delegateModel : null
                            currentIndex: inputCombo.highlightedIndex
                        }

                        background: Rectangle {
                            color: "#1e1e2e"
                            border.color: "#313244"
                            border.width: 1
                            radius: 8
                        }
                    }
                    
                    onActivated: function(index) {
                        if (root.audioService && index >= 0) {
                            root.audioService.setAudioSource(model[index]);
                        }
                    }
                }

                Text {
                    text: root.audioService && !isNaN(root.audioService.sourceVolume) ? Math.round(root.audioService.sourceVolume * 100) + "%" : "0%"
                    color: "#a6adc8"
                    font.family: uiFontFamily
                    font.pixelSize: 13
                    Layout.minimumWidth: 35
                    horizontalAlignment: Text.AlignRight
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    id: inputMuteBtn
                    width: 32
                    height: 32
                    radius: 6
                    color: root.audioService && root.audioService.sourceMuted ? "#f38ba8" : "#313244"
                    border.color: activeFocus ? "#cdd6f4" : "transparent"
                    border.width: activeFocus ? 2 : 0
                    activeFocusOnTab: true
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.audioService) root.audioService.toggleSourceMute();
                            event.accepted = true;
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.audioService && root.audioService.sourceMuted ? "󰍭" : "󰍬"
                        color: "#cdd6f4"
                        font.family: uiFontFamily
                        font.pixelSize: 16
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.audioService) root.audioService.toggleSourceMute();
                        }
                    }
                }
                
                Slider {
                    id: inputSlider
                    Layout.fillWidth: true
                    activeFocusOnTab: true
                    value: root.audioService && !isNaN(root.audioService.sourceVolume) ? root.audioService.sourceVolume : 0
                    onMoved: {
                        if (root.audioService) root.audioService.setSourceVolume(value);
                    }
                    background: Rectangle {
                        x: inputSlider.leftPadding
                        y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: inputSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: "#313244"
                        Rectangle {
                            width: inputSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#f5c2e7" // Pink
                            radius: 3
                        }
                    }
                    handle: Rectangle {
                        x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                        y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: inputSlider.pressed ? "#f38ba8" : "#f5c2e7"
                        border.color: inputSlider.activeFocus ? "#cdd6f4" : "transparent"
                        border.width: inputSlider.activeFocus ? 2 : 0
                    }
                }
            }
        }
        
        Item { Layout.fillHeight: true } // Fill remaining space
    }
}