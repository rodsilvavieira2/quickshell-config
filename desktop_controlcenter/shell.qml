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
import Quickshell.Services.Notifications

import "./common"
import "./components"
import "./services"
import "./shared/ui" as DS
import "./shared/designsystem" as Design

PanelWindow {
    id: root

    AudioService { id: audioService }
    NetworkService { id: networkService }
    BrightnessService { id: brightnessService }
    NotificationService { id: notificationService }

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

    Process {
        id: logoffProcess
        command: ["sh", "-c", "loginctl terminate-user \"$USER\""]
        onStarted: root.shouldShow = false
    }

    readonly property color cSurface: Appearance.colors.cSurface
    readonly property color cSurfaceContainer: Appearance.colors.cSurfaceContainer
    readonly property color cSurfaceContainerHigh: Appearance.colors.cSurfaceContainerHigh
    readonly property color cBorder: Appearance.colors.cBorder
    readonly property color cPrimary: Appearance.colors.cPrimary
    readonly property color cSecondary: Appearance.colors.cSecondary
    readonly property color cOnSurface: Appearance.colors.cOnSurface
    readonly property color cOnSurfaceVariant: Appearance.colors.cOnSurfaceVariant
    readonly property color cOnSurfaceDim: Appearance.colors.cOnSurfaceDim

    property bool shouldShow: false
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
        top: 12
        right: 12
    }

    implicitWidth: 456
    implicitHeight: Math.max(320, Math.floor((screen?.height ?? 900) * 0.9))
    color: "transparent"
    visible: shouldShow || panelContent.opacity > 0

    WlrLayershell.namespace: "quickshell:desktop_controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    IpcHandler {
        target: "desktop_controlcenter"

        function toggle() { root.shouldShow = !root.shouldShow; }
        function open() { root.shouldShow = true; }
        function close() { root.shouldShow = false; }
    }

    NotificationServer {
        id: notificationServer
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true

        onNotification: notification => {
            notificationService.addNotification(notification);
        }
    }

    FocusScope {
        id: panelContent
        anchors.fill: parent

        focus: true
        transformOrigin: Item.TopRight
        scale: 0.96
        opacity: 0

        property bool mouseHasEntered: false
        property bool mouseInside: hoverHandler.hovered

        Keys.onEscapePressed: root.shouldShow = false

        Connections {
            target: root

            function onShouldShowChanged() {
                if (root.shouldShow) {
                    panelContent.mouseHasEntered = false;
                    closeTimer.stop();
                }
            }
        }

        Timer {
            id: closeTimer
            interval: 400
            onTriggered: {
                if (!panelContent.mouseInside && panelContent.mouseHasEntered && root.shouldShow) {
                    root.shouldShow = false;
                }
            }
        }

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hovered) {
                    panelContent.mouseHasEntered = true;
                    closeTimer.stop();
                } else if (panelContent.mouseHasEntered && root.shouldShow) {
                    closeTimer.restart();
                }
            }
        }

        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.shouldShow = false
        }

        ParallelAnimation {
            running: root.shouldShow

            NumberAnimation {
                target: panelContent
                property: "scale"
                from: 0.96
                to: 1
                duration: Appearance.animation.medium2
                easing.type: Appearance.animation.emphasizedDecelerate
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

        ParallelAnimation {
            running: !root.shouldShow && panelContent.opacity > 0

            NumberAnimation {
                target: panelContent
                property: "scale"
                to: 0.96
                duration: Appearance.animation.short4
                easing.type: Appearance.animation.emphasizedAccelerate
            }

            NumberAnimation {
                target: panelContent
                property: "opacity"
                to: 0
                duration: Appearance.animation.short4
                easing.type: Appearance.animation.standardAccelerate
            }
        }

        Rectangle {
            id: panel
            anchors.fill: parent
            radius: 34
            clip: true
            color: Qt.rgba(root.cSurface.r, root.cSurface.g, root.cSurface.b, 0.96)
            border.color: Qt.rgba(1, 1, 1, 0.10)
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => { mouse.accepted = true; }
            }

            ColumnLayout {
                id: panelLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 66
                    spacing: 12

                    RowLayout {
                        spacing: 8

                        HeaderButton {
                            iconName: "log-out"
                            label: "Logoff"
                            tooltip: "Log Off"
                            tint: Appearance.colors.warning
                            onClicked: logoffProcess.running = true
                        }

                        HeaderButton {
                            iconName: "lock"
                            label: "Lock"
                            tooltip: "Lock Session"
                            tint: Appearance.colors.info
                            onClicked: lockProcess.running = true
                        }

                        HeaderButton {
                            iconName: "power"
                            label: "Power"
                            tooltip: "Power Menu"
                            tint: Appearance.colors.error
                            onClicked: powerProcess.running = true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        spacing: 2

                        Text {
                            id: timeText
                            Layout.alignment: Qt.AlignRight
                            text: Qt.formatTime(new Date(), "hh:mm")
                            font.family: Appearance.font.family
                            font.pixelSize: Appearance.font.sizeHeader
                            font.bold: true
                            color: root.cOnSurface
                        }

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: Qt.formatDate(new Date(), "dddd, MMMM d")
                            font.family: Appearance.font.family
                            font.pixelSize: 11
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
                }

                Flickable {
                    id: contentFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: contentColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 3200
                    maximumFlickVelocity: 2200

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 4

                        contentItem: Rectangle {
                            radius: 2
                            color: Qt.rgba(1, 1, 1, 0.18)
                        }
                    }

                    ColumnLayout {
                        id: contentColumn
                        width: contentFlick.width
                        height: Math.max(implicitHeight, contentFlick.height)
                        spacing: 14

                        SectionLabel {
                            label: "Controls"
                            badge: notificationService.dnd ? "Focus On" : ""
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 10

                            QuickToggle {
                                iconName: "ethernet"
                                label: "Ethernet"
                                subLabel: networkService.activeEthernet ? "Connected" : "Disconnected"
                                active: networkService.activeEthernet !== null
                                activeColor: Appearance.colors.info
                                onClicked: settingsProcess.running = true
                            }

                            QuickToggle {
                                iconName: "bluetooth"
                                label: "Bluetooth"
                                subLabel: Bluetooth.defaultAdapter?.enabled ? "Available" : "Disabled"
                                active: Bluetooth.defaultAdapter?.enabled ?? false
                                activeColor: Appearance.colors.info
                                onClicked: {
                                    if (Bluetooth.defaultAdapter) {
                                        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                                    }
                                }
                            }

                            QuickToggle {
                                iconName: notificationService.dnd ? "bell-off" : "bell"
                                label: "Notifications"
                                subLabel: notificationService.dnd ? "Do Not Disturb" : "Alerts Enabled"
                                active: notificationService.dnd
                                activeColor: Appearance.colors.warning
                                onClicked: notificationService.toggleDnd()
                            }

                            QuickToggle {
                                iconName: "settings-2"
                                label: "System Settings"
                                subLabel: "Connections and adapters"
                                active: false
                                activeColor: Appearance.colors.cSecondary
                                onClicked: settingsProcess.running = true
                            }
                        }

                        SectionLabel {
                            label: "Levels"
                            badge: brightnessService.available ? "" : "Brightness unavailable"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            VolumeSlider {
                                audio: audioService
                            }

                            BrightnessSlider {
                                visible: brightnessService.available
                                brightness: brightnessService
                            }
                        }

                        SectionLabel {
                            label: "Notifications"
                        }

                        NotificationList {
                            Layout.fillHeight: true
                            Layout.minimumHeight: 280
                            notifs: notificationService
                        }

                        Item {
                            Layout.preferredHeight: 6
                        }
                    }
                }
            }
        }
    }

    component HeaderButton: DS.Chip {
        id: headerBtn

        property string iconName: ""
        property string label: ""
        property string tooltip: ""
        property color tint: Appearance.colors.info

        clickable: true
        horizontalPadding: 12
        verticalPadding: 6
        text: headerBtn.label
        contentColor: Appearance.colors.cOnSurface
        containerColor: Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerHigh, 0.96)
        hoverContainerColor: Design.ThemePalette.withAlpha(tint, 0.18)
        pressedContainerColor: Design.ThemePalette.withAlpha(tint, 0.24)
        borderColor: Design.ThemePalette.withAlpha(tint, 0.30)
        leading: Component {
            DS.LucideIcon {
                name: headerBtn.iconName
                iconSize: 13
                color: headerBtn.tint
            }
        }
        ToolTip.visible: hovered && headerBtn.tooltip !== ""
        ToolTip.text: headerBtn.tooltip
        ToolTip.delay: 400
    }

    component SectionLabel: RowLayout {
        property string label: ""
        property string badge: ""

        Layout.fillWidth: true
        spacing: 8

        Text {
            text: label
            font.family: Appearance.font.family
            font.pixelSize: 10
            font.bold: true
            color: root.cOnSurfaceDim
        }

        DS.Chip {
            visible: badge !== ""
            text: badge
            clickable: false
            horizontalPadding: 10
            verticalPadding: 4
            contentFontSize: 9
            containerColor: Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerHigh, 0.88)
            hoverContainerColor: containerColor
            pressedContainerColor: containerColor
            borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.72)
            contentColor: root.cOnSurfaceVariant
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(1, 1, 1, 0.06)
        }
    }
}
