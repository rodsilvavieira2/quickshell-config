//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Bluetooth

import "./common"
import "./components"
import "./services"

PanelWindow {
    id: root
    
    // Services
    AudioService { id: audioService }
    NetworkService { id: networkService }
    SystemStatsService { id: systemUsageService }
    MusicService { id: musicService }
    
    // Process launchers
    Process {
        id: settingsProcess
        command: ["nm-connection-editor"]
        onStarted: root.shouldShow = false
    }
    
    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
        onStarted: root.shouldShow = false
    }
    
    Process {
        id: powerProcess
        command: ["wlogout"]
        onStarted: root.shouldShow = false
    }
    
    // Theme colors from Appearance singleton
    readonly property color cSurface: Appearance.colors.cSurface
    readonly property color cSurfaceContainer: Appearance.colors.cSurfaceContainer
    readonly property color cSurfaceContainerHigh: Appearance.colors.cSurfaceContainerHigh
    readonly property color cBorder: Appearance.colors.cBorder
    readonly property color cPrimary: Appearance.colors.cPrimary
    readonly property color cSecondary: Appearance.colors.cSecondary
    readonly property color cOnSurface: Appearance.colors.cOnSurface
    readonly property color cOnSurfaceVariant: Appearance.colors.cOnSurfaceVariant
    readonly property color cOnSurfaceDim: Appearance.colors.cOnSurfaceDim
    
    // Multi-screen support
    property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
    screen: {
        for (let i = 0; i < Quickshell.screens.values.length; i++) {
            if (Quickshell.screens.values[i].name === focusedScreenName) {
                return Quickshell.screens.values[i];
            }
        }
        return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
    }
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 12
        top: 12
    }
    
    implicitWidth: 420
    implicitHeight: Math.min(860, screen?.height ?? 800 - 40)
    color: "transparent"
    visible: shouldShow || panelContent.opacity > 0
    
    property bool shouldShow: false
    
    WlrLayershell.namespace: "quickshell:desktop_controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    IpcHandler {
        target: "desktop_controlcenter"
        function toggle() { root.shouldShow = !root.shouldShow; }
        function open() { root.shouldShow = true; }
        function close() { root.shouldShow = false; }
    }

    FocusScope {
        id: panelContent
        anchors.fill: parent
        
        transformOrigin: Item.TopRight
        scale: 0.94
        opacity: 0
        
        focus: true
        
        Keys.onEscapePressed: root.shouldShow = false
        
        // Tracking mouse for auto-close behavior (ported from remote)
        property bool mouseHasEntered: false
        property bool mouseInside: hoverHandler.hovered
        
        Connections {
            target: root
            function onShouldShowChanged() {
                if (root.shouldShow) {
                    panelContent.mouseHasEntered = false
                    closeTimer.stop()
                }
            }
        }
        
        Timer {
            id: closeTimer
            interval: 400
            onTriggered: {
                if (!panelContent.mouseInside && panelContent.mouseHasEntered && root.shouldShow) {
                    root.shouldShow = false
                }
            }
        }
        
        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hovered) {
                    panelContent.mouseHasEntered = true
                    closeTimer.stop()
                } else if (panelContent.mouseHasEntered && root.shouldShow) {
                    closeTimer.restart()
                }
            }
        }
        
        onVisibleChanged: {
            if (visible) forceActiveFocus()
        }
        
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.shouldShow = false
        }
        
        // Show Animation
        SequentialAnimation {
            running: root.shouldShow
            ParallelAnimation {
                NumberAnimation { 
                    target: panelContent
                    property: "scale"
                    from: 0.94
                    to: 1.0
                    duration: Appearance.animation.medium2
                    easing.type: Appearance.animation.standard
                }
                NumberAnimation { 
                    target: panelContent
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Appearance.animation.medium1
                    easing.type: Appearance.animation.standard
                }
            }
        }
        
        // Hide Animation
        ParallelAnimation {
            running: !root.shouldShow && panelContent.opacity > 0
            NumberAnimation { 
                target: panelContent
                property: "scale"
                to: 0.94
                duration: Appearance.animation.short4
                easing.type: Appearance.animation.standard
            }
            NumberAnimation { 
                target: panelContent
                property: "opacity"
                to: 0
                duration: Appearance.animation.short4
                easing.type: Appearance.animation.standard
            }
        }
        
        Rectangle {
            id: panel
            anchors.fill: parent
            color: root.cSurface
            radius: 24
            border.color: root.cBorder
            border.width: 1
            clip: true
            
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animation.medium2
                    easing.type: Appearance.animation.standard
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => { mouse.accepted = true }
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                // Header Section
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    spacing: 12
                    
                    ColumnLayout {
                        spacing: 2
                        
                        Text {
                            id: timeText
                            text: Qt.formatTime(new Date(), "hh:mm")
                            font.family: Appearance.font.family
                            font.pixelSize: 32
                            font.bold: true
                            color: root.cOnSurface
                        }
                        
                        Text {
                            text: Qt.formatDate(new Date(), "dddd, MMMM d")
                            font.family: Appearance.font.family
                            font.pixelSize: 13
                            font.bold: true
                            color: root.cOnSurfaceVariant
                        }
                        
                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    RowLayout {
                        spacing: 6
                        
                        HeaderButton {
                            icon: "󰒓"
                            tooltip: "Network Settings"
                            onClicked: settingsProcess.running = true
                        }
                        HeaderButton {
                            icon: "󰍜"
                            tooltip: "Lock Session"
                            onClicked: lockProcess.running = true
                        }
                        HeaderButton {
                            icon: "󰐥"
                            tooltip: "Power Menu"
                            onClicked: powerProcess.running = true
                        }
                    }
                }
                
                // Scrollable Content
                Flickable {
                    id: contentFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    contentHeight: contentColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 3000
                    maximumFlickVelocity: 2000
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 4
                        
                        contentItem: Rectangle {
                            radius: 2
                            color: Appearance.colors.cBorder
                            opacity: 0.2
                        }
                    }
                    
                    ColumnLayout {
                        id: contentColumn
                        width: contentFlick.width
                        spacing: 14
                        
                        // Quick Toggles
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 10
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: networkService.activeEthernet ? "󰈀" : "󰖩"
                                label: networkService.activeEthernet ? "Ethernet" : "Wi-Fi"
                                subLabel: networkService.activeEthernet ? "Connected" : (networkService.active?.ssid ?? "Disconnected")
                                active: networkService.activeEthernet || networkService.wifiEnabled
                                activeColor: networkService.activeEthernet ? Appearance.colors.info : Appearance.colors.success
                                onClicked: networkService.toggleWifi()
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰂯"
                                label: "Bluetooth"
                                subLabel: Bluetooth.defaultAdapter?.enabled ? "On" : "Off"
                                active: Bluetooth.defaultAdapter?.enabled ?? false
                                activeColor: Appearance.colors.info
                                onClicked: {
                                    if (Bluetooth.defaultAdapter) {
                                        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.cBorder
                            opacity: 0.1
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            VolumeSlider {
                                Layout.fillWidth: true
                                audio: audioService
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.cBorder
                            opacity: 0.1
                        }
                        
                        SystemStats {
                            Layout.fillWidth: true
                            systemUsage: systemUsageService
                        }
                        
                        MediaCard {
                            Layout.fillWidth: true
                            mpris: musicService
                            visible: musicService.isActive
                        }
                        
                        Item { Layout.preferredHeight: 4 }
                    }
                }
            }
        }
    }
    
    component HeaderButton: Rectangle {
        id: headerBtn
        property string icon
        property string tooltip: ""
        signal clicked()
        
        width: 40
        height: 40
        radius: 20
        color: headerBtnMouse.containsMouse 
            ? Appearance.colors.surface1
            : root.cSurfaceContainer
        
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.short3
                easing.type: Appearance.animation.standard
            }
        }
        
        scale: headerBtnMouse.pressed ? 0.92 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: Appearance.animation.short2
                easing.type: Appearance.animation.standard
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: headerBtn.icon
            font.family: Appearance.font.family
            font.pixelSize: 18
            color: root.cOnSurface
        }
        
        MouseArea {
            id: headerBtnMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: headerBtn.clicked()
        }
        
        ToolTip.visible: headerBtnMouse.containsMouse && headerBtn.tooltip !== ""
        ToolTip.text: headerBtn.tooltip
        ToolTip.delay: 500
    }
}
