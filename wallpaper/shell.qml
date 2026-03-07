//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: shellRoot

    property bool wallpaperOpen: false
    property var allWallpapers: []
    property var filteredWallpapers: []
    property string selectedWallpaperPath: ""
    property string activeWallpaperPath: ""
    property string activeWallpaperName: ""

    IpcHandler {
        target: "wallpaper"
        function toggle() { shellRoot.wallpaperOpen = !shellRoot.wallpaperOpen; }
        function open() { shellRoot.wallpaperOpen = true; }
        function close() { shellRoot.wallpaperOpen = false; }
    }

    onWallpaperOpenChanged: {
        if (wallpaperOpen) {
            refreshWallpapers();
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    Process {
        id: findWallpapersProc
        command: ["find", "/home/rodrigo/Documents/Wallpapers", "-type", "f", "-iregex", ".*\\.\\(jpg\\|jpeg\\|png\\|webp\\)"]
        running: false
        stdout: StdioCollector {
            id: findCollector
            onStreamFinished: {
                let out = findCollector.text.trim();
                if (out.length > 0) {
                    let paths = out.split("\n");
                    let items = [];
                    for (let i = 0; i < paths.length; i++) {
                        let path = paths[i];
                        let name = path.substring(path.lastIndexOf("/") + 1);
                        name = name.substring(0, name.lastIndexOf("."));
                        items.push({ path: path, name: name });
                    }
                    items.sort((a, b) => a.name.localeCompare(b.name));
                    shellRoot.allWallpapers = items;
                    shellRoot.filteredWallpapers = items;
                    
                    if (shellRoot.selectedWallpaperPath === "" && items.length > 0) {
                        shellRoot.selectedWallpaperPath = items[0].path;
                        shellRoot.activeWallpaperName = items[0].name;
                    }
                } else {
                    shellRoot.allWallpapers = [];
                    shellRoot.filteredWallpapers = [];
                }
            }
        }
    }

    Process {
        id: readActiveWallpaperProc
        command: ["sh", "-c", "cat ~/.cache/current_wallpaper 2>/dev/null || true"]
        running: false
        stdout: StdioCollector {
            id: readActiveCollector
            onStreamFinished: {
                let path = readActiveCollector.text.trim();
                if (path !== "") {
                    shellRoot.activeWallpaperPath = path;
                    shellRoot.selectedWallpaperPath = path;
                    let name = path.substring(path.lastIndexOf("/") + 1);
                    name = name.substring(0, name.lastIndexOf("."));
                    shellRoot.activeWallpaperName = name;
                }
            }
        }
    }

    function refreshWallpapers() {
        findWallpapersProc.running = true;
    }

    Component.onCompleted: {
        readActiveWallpaperProc.running = true;
        refreshWallpapers();
    }

    function applyWallpaper(path) {
        if (path !== "") {
            Quickshell.execDetached(["/home/rodrigo/.config/hypr/scripts/wall", path]);
            shellRoot.activeWallpaperPath = path;
            for (let i = 0; i < shellRoot.allWallpapers.length; i++) {
                if (shellRoot.allWallpapers[i].path === path) {
                    shellRoot.activeWallpaperName = shellRoot.allWallpapers[i].name;
                    break;
                }
            }
        }
    }

    function filterWallpapers(query) {
        if (!query || query.trim() === "") {
            filteredWallpapers = allWallpapers;
            return;
        }
        let q = query.toLowerCase().trim();
        filteredWallpapers = allWallpapers.filter(w => {
            return w.name.toLowerCase().includes(q);
        });
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
        
        visible: shellRoot.wallpaperOpen
        color: "transparent"
        
        WlrLayershell.namespace: "quickshell:wallpaper"
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
            onClicked: shellRoot.wallpaperOpen = false
        }

        // Main Container
        Rectangle {
            id: mainContainer
            width: parent.width * 0.8
            height: parent.height * 0.8
            anchors.centerIn: parent
            color: "#1e1e2e"
            border.color: "#89b4fa"
            border.width: 2
            radius: 10
            clip: true
            
            Shortcut {
                sequence: "Esc"
                onActivated: shellRoot.wallpaperOpen = false
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
                // consume clicks
            }

            // Top Section (Search Bar)
            Item {
                id: topSection
                width: parent.width
                height: 60
                anchors.top: parent.top

                TextField {
                    id: searchInput
                    width: 400
                    height: 32
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 2 // Margin top 16, bottom 12 -> shifted slightly
                    
                    font.pixelSize: 13
                    color: "#cdd6f4"
                    placeholderText: "Search"
                    placeholderTextColor: "#a6adc8"
                    
                    leftPadding: 30
                    rightPadding: 12
                    topPadding: 4
                    bottomPadding: 4

                    background: Rectangle {
                        color: "#181825"
                        radius: 6
                        border.width: 1
                        border.color: searchInput.activeFocus ? "#89b4fa" : "#313244"

                        Image {
                            source: "file:///home/rodrigo/.config/quickshell/wallpaper/resources/search.svg"
                            width: 16
                            height: 16
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: 0.6
                            sourceSize: Qt.size(16, 16)
                        }
                    }

                    onTextChanged: shellRoot.filterWallpapers(text)
                    
                    Keys.onEscapePressed: event => {
                        shellRoot.wallpaperOpen = false;
                        event.accepted = true;
                    }
                    
                    KeyNavigation.down: gridView
                }
            }

            // Footer Area
            Item {
                id: footerSection
                width: parent.width
                height: 60
                anchors.bottom: parent.bottom

                Rectangle {
                    id: applyBtn
                    width: Math.max(80, applyText.implicitWidth + 32)
                    height: 32
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 24
                    anchors.bottomMargin: 20
                    radius: 6
                    
                    activeFocusOnTab: true
                    KeyNavigation.up: gridView
                    
                    color: applyMouseArea.pressed ? "#89dceb" : (applyMouseArea.containsMouse || applyBtn.activeFocus ? "#b4befe" : "#89b4fa")
                    border.width: applyBtn.activeFocus ? 2 : 0
                    border.color: "#cba6f7"

                    Text {
                        id: applyText
                        anchors.centerIn: parent
                        text: "Apply"
                        color: "#11111b"
                        font.pixelSize: 13
                        font.bold: true
                        font.family: ".AppleSystemUIFont, Segoe UI, sans-serif"
                    }

                    MouseArea {
                        id: applyMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            shellRoot.applyWallpaper(shellRoot.selectedWallpaperPath);
                        }
                    }
                    
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            shellRoot.applyWallpaper(shellRoot.selectedWallpaperPath);
                            event.accepted = true;
                        }
                    }
                }
            }

            // Bottom Gallery
            Item {
                id: gallerySection
                width: parent.width
                height: Math.max(180, parent.height * 0.45) // make the gallery scale to take around 45% of the height
                anchors.bottom: footerSection.top
                clip: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 20
                    ScrollBar.vertical: ScrollBar {
                        width: 12
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 12
                            implicitHeight: 20
                            radius: 6
                            color: parent.hovered || parent.pressed ? "#585b70" : "#45475a"
                        }
                        background: Item {} // Transparent
                    }

                    GridView {
                        id: gridView
                        boundsBehavior: Flickable.StopAtBounds
                        cellWidth: 160
                        cellHeight: 119
                        model: shellRoot.filteredWallpapers
                        clip: true
                        activeFocusOnTab: true
                        focus: true
                        
                        KeyNavigation.up: searchInput
                        KeyNavigation.down: applyBtn
                        
                        onCurrentIndexChanged: {
                            if (activeFocus && currentIndex >= 0 && currentIndex < shellRoot.filteredWallpapers.length) {
                                shellRoot.selectedWallpaperPath = shellRoot.filteredWallpapers[currentIndex].path;
                                shellRoot.activeWallpaperName = shellRoot.filteredWallpapers[currentIndex].name;
                            }
                        }
                        
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                                if (currentIndex >= 0 && currentIndex < shellRoot.filteredWallpapers.length) {
                                    shellRoot.applyWallpaper(shellRoot.filteredWallpapers[currentIndex].path);
                                }
                                event.accepted = true;
                            }
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: 144
                            height: 103

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 6

                                Rectangle {
                                    Layout.preferredWidth: 144
                                    Layout.preferredHeight: 81
                                    radius: 6
                                    color: "#181825"
                                    border.width: modelData.path === shellRoot.selectedWallpaperPath ? 2 : 1
                                    border.color: modelData.path === shellRoot.selectedWallpaperPath ? "#89b4fa" : (thumbMouseArea.containsMouse ? "#89dceb" : "#313244")
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 6
                                        color: "transparent"
                                        border.width: 2
                                        border.color: "#cba6f7"
                                        visible: gridView.activeFocus && gridView.currentIndex === index
                                    }
                                    
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: modelData.path === shellRoot.selectedWallpaperPath ? 2 : 1
                                        source: "file://" + modelData.path
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        sourceSize.width: 144
                                        sourceSize.height: 81
                                    }

                                    MouseArea {
                                        id: thumbMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            gridView.forceActiveFocus();
                                            gridView.currentIndex = index;
                                            shellRoot.selectedWallpaperPath = modelData.path;
                                            shellRoot.activeWallpaperName = modelData.name;
                                        }
                                        onDoubleClicked: {
                                            shellRoot.applyWallpaper(modelData.path);
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: "#cdd6f4"
                                    font.pixelSize: 12
                                    font.family: ".AppleSystemUIFont, Segoe UI, sans-serif"
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                id: dividerLine
                width: parent.width
                height: 1
                color: "#313244"
                anchors.bottom: gallerySection.top
            }

            // Middle Section
            Item {
                id: middleSection
                width: parent.width
                anchors.top: topSection.bottom
                anchors.bottom: dividerLine.top

                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -10 // Padding top 0, bottom 20 logic
                    spacing: 12

                    // Preview Image
                    Rectangle {
                        width: 400
                        height: 225
                        radius: 8
                        border.width: 2
                        border.color: "#89b4fa"
                        color: "#181825"
                        clip: true
                        Layout.alignment: Qt.AlignHCenter

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: shellRoot.selectedWallpaperPath !== "" ? "file://" + shellRoot.selectedWallpaperPath : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 400
                            sourceSize.height: 225
                        }

                        // Checkmark Badge
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "#89b4fa"
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 8
                            visible: shellRoot.activeWallpaperPath === shellRoot.selectedWallpaperPath && shellRoot.selectedWallpaperPath !== ""

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }

                    // Title Label
                    Text {
                        text: shellRoot.activeWallpaperName !== "" ? shellRoot.activeWallpaperName : "Nebula"
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        font.bold: true
                        font.family: ".AppleSystemUIFont, Segoe UI, sans-serif"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}