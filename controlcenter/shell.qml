//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
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

ShellRoot {
    id: shellRoot

    AudioService { id: audioService }
    NetworkService { id: networkService }
    BrightnessService { id: brightnessService }
    NotificationService { id: notificationService }

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
    property string focusedScreenName: Hyprland.focusedMonitor && Hyprland.focusedMonitor.name
        ? Hyprland.focusedMonitor.name
        : ""

    function resolveScreen() {
        for (let i = 0; i < Quickshell.screens.values.length; i++) {
            if (Quickshell.screens.values[i].name === focusedScreenName) {
                return Quickshell.screens.values[i];
            }
        }

        return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
    }

    function openSettings(categoryId) {
        shellRoot.shouldShow = false;
        if (categoryId && categoryId.length > 0) {
            Quickshell.execDetached(["quickshell", "ipc", "-c", "settings", "call", "settings", "openCategory", categoryId]);
        } else {
            Quickshell.execDetached(["quickshell", "ipc", "-c", "settings", "call", "settings", "open"]);
        }
    }

    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
        onStarted: shellRoot.shouldShow = false
    }

    Process {
        id: powerProcess
        command: ["wlogout"]
        onStarted: shellRoot.shouldShow = false
    }

    Process {
        id: logoffProcess
        command: ["sh", "-c", "loginctl terminate-user \"$USER\""]
        onStarted: shellRoot.shouldShow = false
    }

    IpcHandler {
        target: "controlcenter"

        function toggle() { shellRoot.shouldShow = !shellRoot.shouldShow; }
        function open() { shellRoot.shouldShow = true; }
        function close() { shellRoot.shouldShow = false; }
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

    PanelWindow {
        id: root

        property alias shouldShow: shellRoot.shouldShow
        property alias focusedScreenName: shellRoot.focusedScreenName

        readonly property color cSurface: shellRoot.cSurface
        readonly property color cSurfaceContainer: shellRoot.cSurfaceContainer
        readonly property color cSurfaceContainerHigh: shellRoot.cSurfaceContainerHigh
        readonly property color cBorder: shellRoot.cBorder
        readonly property color cPrimary: shellRoot.cPrimary
        readonly property color cSecondary: shellRoot.cSecondary
        readonly property color cOnSurface: shellRoot.cOnSurface
        readonly property color cOnSurfaceVariant: shellRoot.cOnSurfaceVariant
        readonly property color cOnSurfaceDim: shellRoot.cOnSurfaceDim

        function openSettings(categoryId) {
            shellRoot.openSettings(categoryId);
        }

        screen: shellRoot.resolveScreen()

        anchors {
            top: true
            right: true
        }

        margins {
            top: 18
            right: 18
        }

        implicitWidth: 404
        implicitHeight: Math.max(420, Math.floor(((screen && screen.height) ? screen.height : 900) * 0.9))
        color: "transparent"
        visible: shouldShow || panelContent.opacity > 0

        WlrLayershell.namespace: "quickshell:controlcenter"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

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
            radius: 28
            clip: true
            color: root.cSurface
            border.color: Design.ThemePalette.withAlpha(root.cBorder, 0.50)
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, Design.ThemeSettings.isDark ? 0.34 : 0.16)
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 20
                shadowBlur: 0.9
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => { mouse.accepted = true; }
            }

            ColumnLayout {
                id: panelLayout
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Flickable {
                    id: contentFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: Math.max(contentColumn.implicitHeight, height)
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
                        implicitWidth: width
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            HeaderActionTile {
                                Layout.fillWidth: true
                                iconName: "log-out"
                                label: "Logoff"
                                tooltip: "Log Off"
                                onClicked: logoffProcess.running = true
                            }

                            HeaderActionTile {
                                Layout.fillWidth: true
                                iconName: "lock"
                                label: "Lock"
                                tooltip: "Lock Session"
                                onClicked: lockProcess.running = true
                            }

                            HeaderActionTile {
                                Layout.fillWidth: true
                                iconName: "power"
                                label: "Power"
                                tooltip: "Power Menu"
                                onClicked: powerProcess.running = true
                            }
                        }

                        SectionTitle {
                            text: "Controls"
                        }

                        SectionGroup {
                            Layout.fillWidth: true

                            GridLayout {
                                width: parent.width
                                implicitWidth: width
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 10

                                QuickToggle {
                                    iconName: "ethernet"
                                    label: "Network"
                                    subLabel: !networkService.networkingEnabled
                                        ? "Disabled"
                                        : (networkService.activeConnection || (networkService.activeEthernet ? "Connected" : "Idle"))
                                    active: networkService.networkingEnabled
                                    variant: "highlighted"
                                    showChevron: true
                                    activeColor: Appearance.colors.cPrimary
                                    onClicked: networkService.toggleNetworking(() => {})
                                }

                                QuickToggle {
                                    iconName: "bluetooth"
                                    label: "Bluetooth"
                                    subLabel: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? "Available" : "Disabled"
                                    active: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
                                    variant: "highlighted"
                                    activeColor: Appearance.colors.cPrimary
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
                                    active: false
                                    variant: "neutral"
                                    activeColor: Appearance.colors.warning
                                    onClicked: notificationService.toggleDnd()
                                }

                                QuickToggle {
                                    iconName: "settings-2"
                                    label: "System Settings"
                                    subLabel: "Connections and adapters"
                                    active: false
                                    variant: "neutral"
                                    showChevron: true
                                    activeColor: Appearance.colors.cSecondary
                                    onClicked: root.openSettings("")
                                }
                            }
                        }

                        SectionTitle {
                            text: "Levels"
                        }

                        SectionGroup {
                            Layout.fillWidth: true

                            ColumnLayout {
                                width: parent.width
                                implicitWidth: width
                                spacing: 8

                                Rectangle {
                                    Layout.alignment: Qt.AlignLeft
                                    visible: !brightnessService.available
                                    implicitWidth: brightnessPillLabel.implicitWidth + 30
                                    Layout.preferredHeight: 40
                                    radius: Design.Tokens.radius.pill
                                    color: root.cSurfaceContainerHigh
                                    border.width: 1
                                    border.color: Design.ThemePalette.withAlpha(root.cBorder, 0.42)

                                    Text {
                                        id: brightnessPillLabel
                                        anchors.centerIn: parent
                                        text: "Brightness unavailable"
                                        font.family: Appearance.font.family
                                        font.pixelSize: 14
                                        font.weight: Design.Tokens.font.weight.medium
                                        color: Design.ThemePalette.withAlpha(root.cOnSurface, 0.68)
                                    }
                                }

                                BrightnessSlider {
                                    visible: brightnessService.available
                                    brightness: brightnessService
                                }

                                VolumeSlider {
                                    audio: audioService
                                }
                            }
                        }

                        SectionTitle {
                            text: "Notifications"
                        }

                        SectionGroup {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 252
                            padding: 0

                            NotificationList {
                                anchors.fill: parent
                                notifs: notificationService
                            }
                        }

                        Item { Layout.preferredHeight: 2 }
                    }
                }
            }
        }
    }

    component HeaderActionTile: Item {
        id: headerTile

        property string iconName: ""
        property string label: ""
        property string tooltip: ""
        signal clicked()

        readonly property bool hovered: mouseArea.containsMouse
        readonly property bool pressed: mouseArea.pressed

        Layout.preferredHeight: 68
        implicitHeight: 68
        scale: pressed ? 0.98 : 1

        Behavior on scale {
            NumberAnimation {
                duration: Appearance.animation.short4
                easing.type: Appearance.animation.standard
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: hovered ? root.cSurfaceContainerHigh : root.cSurfaceContainer
            border.width: 1
            border.color: Design.ThemePalette.withAlpha(root.cBorder, hovered ? 0.56 : 0.42)

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Qt.rgba(1, 1, 1, pressed ? 0.05 : 0)
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 4

            DS.LucideIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: headerTile.iconName
                iconSize: 20
                color: root.cOnSurface
            }

            Text {
                text: headerTile.label
                font.family: Appearance.font.family
                font.pixelSize: 14
                font.weight: Design.Tokens.font.weight.medium
                color: root.cOnSurface
                horizontalAlignment: Text.AlignHCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerTile.clicked()
        }

        ToolTip.visible: hovered && tooltip !== ""
        ToolTip.text: tooltip
        ToolTip.delay: 400
    }

    component SectionTitle: Text {
        font.family: Appearance.font.family
        font.pixelSize: 16
        font.weight: Design.Tokens.font.weight.medium
        color: root.cOnSurface
    }

    component SectionGroup: DS.Surface {
        backgroundColor: root.cSurfaceContainer
        borderColor: Design.ThemePalette.withAlpha(root.cBorder, 0.42)
        borderWidth: 1
        radius: 20
        padding: 12
        clipContent: true
        shadowLevel: Design.Tokens.shadow.none
    }
    }

    PanelWindow {
        id: floatingNotifications

        screen: shellRoot.resolveScreen()

        anchors {
            top: true
            right: true
        }

        margins {
            top: 18
            right: 18
        }

        implicitWidth: notificationStack.implicitWidth
        implicitHeight: notificationStack.implicitHeight
        color: "transparent"
        visible: !shellRoot.shouldShow && notificationService.floatingNotifications.length > 0

        WlrLayershell.namespace: "quickshell:controlcenter:notifications"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        FloatingNotificationStack {
            id: notificationStack
            anchors.top: parent.top
            anchors.right: parent.right
            notifs: notificationService
        }
    }
}
