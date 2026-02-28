//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma IconTheme "eSuru++"
//@ pragma Env QS_ICON_THEME=eSuru++

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

ShellRoot {
    id: shellRoot

    property bool launcherOpen: false
    property var allApps: []
    property var filteredApps: []

    function filterApps(query) {
        if (!query || query.trim() === "") {
            filteredApps = allApps;
            appList.currentIndex = 0;
            return;
        }
        let q = query.toLowerCase().trim();
        filteredApps = allApps.filter(app => {
            const matchName = app.name && app.name.toLowerCase().includes(q);
            const matchGeneric = app.genericName && app.genericName.toLowerCase().includes(q);
            const matchKeyword = app.keywords && app.keywords.some(k => k.toLowerCase().includes(q));
            const matchExec = app.execString && app.execString.toLowerCase().includes(q);
            return matchName || matchGeneric || matchKeyword || matchExec;
        });
        appList.currentIndex = 0;
    }

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            shellRoot.allApps = DesktopEntries.applications.values;
            if (shellRoot.launcherOpen) {
                shellRoot.filterApps(searchInput.text);
            }
        }
    }

    Component.onCompleted: {
        shellRoot.allApps = DesktopEntries.applications.values;
        shellRoot.filterApps("");
    }

    onLauncherOpenChanged: {
        if (launcherOpen) {
            searchInput.text = "";
            filterApps("");
            searchInput.forceActiveFocus();
        }
    }

    IpcHandler {
        target: "applauncher"
        function toggle() {
            shellRoot.launcherOpen = !shellRoot.launcherOpen;
        }
        function open() {
            shellRoot.launcherOpen = true;
        }
        function close() {
            shellRoot.launcherOpen = false;
        }
    }

    PanelWindow {
        id: window
        
        property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedScreenName) {
                    return Quickshell.screens.values[i];
                }
            }
            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }
        
        visible: shellRoot.launcherOpen
        color: "transparent"
        
        WlrLayershell.namespace: "quickshell:applauncher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.launcherOpen = false
        }

        Rectangle {
            id: launcherBox
            width: 600
            height: Math.min(600, layout.implicitHeight)
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -100
            color: "#1e1e2e"
            radius: 12
            border.color: "#89b4fa"
            border.width: 2
            clip: true

            MouseArea {
                anchors.fill: parent
                // Consume clicks inside the launcher so they don't close it
                hoverEnabled: true
                preventStealing: true
            }

            ColumnLayout {
                id: layout
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64

                    RowLayout {
                        anchors.fill: parent
                        
                        TextField {
                            id: searchInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            font.pixelSize: 22
                            color: "#cdd6f4"
                            placeholderText: "Search apps..."
                            placeholderTextColor: "#a6adc8"
                            
                            background: Item {}
                            
                            onTextChanged: shellRoot.filterApps(text)
                            
                            Keys.onUpPressed: event => {
                                appList.decrementCurrentIndex();
                                event.accepted = true;
                            }
                            Keys.onDownPressed: event => {
                                appList.incrementCurrentIndex();
                                event.accepted = true;
                            }
                            Keys.onReturnPressed: event => {
                                if (appList.currentIndex >= 0 && appList.currentIndex < shellRoot.filteredApps.length) {
                                    shellRoot.filteredApps[appList.currentIndex].execute();
                                    shellRoot.launcherOpen = false;
                                }
                                event.accepted = true;
                            }
                            Keys.onEscapePressed: event => {
                                shellRoot.launcherOpen = false;
                                event.accepted = true;
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#313244"
                    visible: shellRoot.filteredApps.length > 0
                }

                ListView {
                    id: appList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(500, contentHeight)
                    Layout.maximumHeight: 500
                    Layout.bottomMargin: 8
                    Layout.topMargin: 8
                    clip: true
                    model: shellRoot.filteredApps
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 4
                    
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        
                        width: appList.width - 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 56
                        radius: 8
                        color: index === appList.currentIndex ? "#313244" : "transparent"
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: appList.currentIndex = index
                            onClicked: {
                                modelData.execute();
                                shellRoot.launcherOpen = false;
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16

                            Image {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                source: Quickshell.iconPath(modelData.icon || "", "application-x-executable")
                                sourceSize: Qt.size(32, 32)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name || ""
                                    color: "#cdd6f4"
                                    font.pixelSize: 16
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.genericName || modelData.comment || ""
                                    color: "#a6adc8"
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
