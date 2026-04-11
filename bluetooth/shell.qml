//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

import "./components"
import "./services"
import "./shared/designsystem" as Design
import "./shared/ui" as DS

ShellRoot {
    id: shellRoot

    property bool panelOpen: false
    property string focusedScreenName: Hyprland.focusedMonitor?.name ?? ""

    property color panelTone: "#17141c"
    property color sidebarTone: "#1f1b25"
    property color cardTone: "#2d2834"
    property color cardToneSoft: "#25212d"
    property color accentTone: "#6c4dc2"
    property color accentToneStrong: "#5a3fa2"
    property color accentToneMuted: "#7c6b98"
    property color textPrimaryTone: "#f3eefc"
    property color textSecondaryTone: "#b0a8bf"
    property color textMutedTone: "#8a8298"
    property color borderTone: "#312b39"
    property color separatorTone: "#2a2532"
    property color highlightTone: "#3a3442"
    property color successTone: "#7bd88f"

    function resolveScreen() {
        for (let index = 0; index < Quickshell.screens.values.length; index += 1) {
            if (Quickshell.screens.values[index].name === shellRoot.focusedScreenName) {
                return Quickshell.screens.values[index];
            }
        }

        return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
    }

    IpcHandler {
        target: "bluetooth"

        function toggle() {
            shellRoot.panelOpen = !shellRoot.panelOpen;
        }

        function open() {
            shellRoot.panelOpen = true;
        }

        function close() {
            shellRoot.panelOpen = false;
        }
    }

    PanelWindow {
        id: window

        screen: shellRoot.resolveScreen()
        color: "transparent"
        visible: shellRoot.panelOpen || contentFrame.opacity > 0

        WlrLayershell.namespace: "quickshell:bluetooth"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: shellRoot.panelOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        BluetoothService {
            id: bluetoothService
            panelVisible: shellRoot.panelOpen
        }

        DS.OverlayScrim {
            anchors.fill: parent
            opacity: contentFrame.opacity * 0.92
        }

        MouseArea {
            anchors.fill: parent
            enabled: shellRoot.panelOpen
            onClicked: shellRoot.panelOpen = false
        }

        FocusScope {
            id: contentFrame
            anchors.centerIn: parent
            width: Math.min(1040, Math.max(920, (window.screen ? window.screen.width : 1280) - 48))
            height: Math.min(760, Math.max(680, (window.screen ? window.screen.height : 900) - 48))
            opacity: shellRoot.panelOpen ? 1 : 0
            scale: shellRoot.panelOpen ? 1 : 0.985
            focus: shellRoot.panelOpen

            Keys.onEscapePressed: shellRoot.panelOpen = false

            Behavior on opacity {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.slow
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Design.Tokens.motion.duration.slow
                    easing.type: Design.Tokens.motion.easing.standard
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 34
                color: shellRoot.panelTone
                border.width: 1
                border.color: shellRoot.borderTone
                clip: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => { mouse.accepted = true; }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 272
                        Layout.fillHeight: true

                        Rectangle {
                            anchors.fill: parent
                            color: shellRoot.sidebarTone
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 18
                            anchors.topMargin: 22
                            anchors.bottomMargin: 22
                            spacing: 0

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.bottomMargin: 22
                                spacing: 14

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.88)

                                    DS.LucideIcon {
                                        anchors.centerIn: parent
                                        name: bluetoothService.bluetoothEnabled ? "bluetooth" : "bluetooth-off"
                                        iconSize: 18
                                        color: shellRoot.textPrimaryTone
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: "Bluetooth"
                                        color: shellRoot.textPrimaryTone
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 20
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        text: bluetoothService.bluetoothEnabled ? "On" : "Off"
                                        color: bluetoothService.bluetoothEnabled ? shellRoot.successTone : shellRoot.textMutedTone
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.bottomMargin: 20
                                implicitHeight: systemStatusColumn.implicitHeight + 28
                                radius: 22
                                color: shellRoot.cardTone
                                border.width: 1
                                border.color: shellRoot.borderTone

                                ColumnLayout {
                                    id: systemStatusColumn
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 10

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            Layout.fillWidth: true
                                            text: "System Status"
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                        }

                                        Rectangle {
                                            width: 44
                                            height: 26
                                            radius: 13
                                            color: bluetoothService.bluetoothEnabled ? shellRoot.accentTone : shellRoot.highlightTone
                                            border.width: 1
                                            border.color: bluetoothService.bluetoothEnabled ? shellRoot.accentTone : shellRoot.separatorTone
                                            opacity: bluetoothService.bluetoothAvailable ? 1 : 0.45

                                            Rectangle {
                                                width: 20
                                                height: 20
                                                radius: 10
                                                x: bluetoothService.bluetoothEnabled ? parent.width - width - 3 : 3
                                                y: 3
                                                color: bluetoothService.bluetoothEnabled ? shellRoot.textPrimaryTone : shellRoot.textSecondaryTone

                                                Behavior on x {
                                                    NumberAnimation {
                                                        duration: 120
                                                        easing.type: Easing.OutCubic
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                enabled: bluetoothService.bluetoothAvailable
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (bluetoothService.adapter) {
                                                        bluetoothService.adapter.enabled = !bluetoothService.bluetoothEnabled;
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: bluetoothService.bluetoothEnabled
                                            ? (bluetoothService.adapter && bluetoothService.adapter.discoverable
                                                ? "Visible to all nearby devices as\n\"" + bluetoothService.adapterName + "\""
                                                : "Ready for paired devices and nearby discovery.")
                                            : "Turn Bluetooth on to connect or pair devices."
                                        color: shellRoot.textSecondaryTone
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        wrapMode: Text.Wrap
                                        lineHeight: 1.35
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.bottomMargin: 12
                                spacing: 8

                                Text {
                                    Layout.fillWidth: true
                                    text: "Paired Devices"
                                    color: shellRoot.textPrimaryTone
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 15
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    visible: bluetoothService.sortedDevices.length > 0
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: shellRoot.accentTone

                                    Text {
                                        anchors.centerIn: parent
                                        text: bluetoothService.sortedDevices.length
                                        color: shellRoot.textPrimaryTone
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Loader {
                                    anchors.fill: parent
                                    active: bluetoothService.sortedDevices.length === 0
                                    sourceComponent: sidebarEmptyState
                                }

                                ListView {
                                    anchors.fill: parent
                                    clip: true
                                    spacing: 8
                                    visible: bluetoothService.sortedDevices.length > 0
                                    model: bluetoothService.sortedDevices

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }

                                    delegate: BluetoothDeviceRow {
                                        required property var modelData
                                        width: ListView.view.width
                                        device: modelData
                                        service: bluetoothService
                                        selected: bluetoothService.selectedAddress === bluetoothService.deviceAddress(modelData)
                                        onClicked: bluetoothService.setSelectedDevice(modelData)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.topMargin: 20
                            anchors.bottomMargin: 20
                            width: 1
                            color: shellRoot.separatorTone
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            width: 460
                            height: 460
                            radius: width / 2
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: -24
                            color: Design.ThemePalette.withAlpha(shellRoot.accentToneStrong, 0.08)
                        }

                        Rectangle {
                            width: 220
                            height: 220
                            radius: width / 2
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 64
                            anchors.verticalCenterOffset: 64
                            color: Design.ThemePalette.withAlpha("#61b26f", 0.045)
                        }

                        Rectangle {
                            id: scanButton
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 20
                            anchors.rightMargin: 18
                            z: 2
                            width: scanLabel.implicitWidth + 34
                            height: 30
                            radius: 15
                            color: shellRoot.accentToneMuted
                            opacity: bluetoothService.bluetoothEnabled ? 1 : 0.45

                            Text {
                                id: scanLabel
                                anchors.centerIn: parent
                                text: bluetoothService.scanning ? "Scanning..." : "Scan"
                                color: "#231f2b"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Design.ThemePalette.withAlpha("#ffffff", scanMouseArea.pressed ? 0.16 : scanMouseArea.containsMouse ? 0.08 : 0)
                            }

                            MouseArea {
                                id: scanMouseArea
                                anchors.fill: parent
                                enabled: bluetoothService.bluetoothEnabled
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: bluetoothService.toggleDiscovery()
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            active: bluetoothService.selectedDevice === null
                            sourceComponent: contentEmptyState
                        }

                        Loader {
                            anchors.fill: parent
                            active: bluetoothService.selectedDevice !== null
                            sourceComponent: deviceDetailView
                        }
                    }
                }
            }
        }

        Component {
            id: sidebarEmptyState

            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - 32, 210)
                spacing: 8

                DS.LucideIcon {
                    Layout.alignment: Qt.AlignHCenter
                    name: bluetoothService.bluetoothEnabled ? "bluetooth" : "bluetooth-off"
                    iconSize: 22
                    color: shellRoot.textMutedTone
                }

                Text {
                    Layout.fillWidth: true
                    text: bluetoothService.bluetoothEnabled ? "No devices found" : "Bluetooth is off"
                    horizontalAlignment: Text.AlignHCenter
                    color: shellRoot.textPrimaryTone
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: bluetoothService.bluetoothEnabled
                        ? "Use Scan to discover nearby devices."
                        : "Turn Bluetooth on to begin pairing."
                    horizontalAlignment: Text.AlignHCenter
                    color: shellRoot.textSecondaryTone
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }
            }
        }

        Component {
            id: contentEmptyState

            Item {
                anchors.fill: parent

                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 80, 430)
                    spacing: 22

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 248
                        Layout.preferredHeight: 220

                        Rectangle {
                            width: 208
                            height: 188
                            radius: 38
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -4
                            rotation: -2
                            color: "#393540"
                        }

                        Rectangle {
                            width: 208
                            height: 188
                            radius: 38
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 8
                            anchors.verticalCenterOffset: 6
                            rotation: 4
                            color: Design.ThemePalette.withAlpha("#463f53", 0.24)
                            z: -1
                        }

                        Rectangle {
                            width: 74
                            height: 74
                            radius: 37
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -6
                            color: shellRoot.accentToneMuted

                            Rectangle {
                                anchors.centerIn: parent
                                width: 40
                                height: 40
                                radius: 20
                                color: Design.ThemePalette.withAlpha(shellRoot.panelTone, 0.28)
                            }

                            DS.LucideIcon {
                                anchors.centerIn: parent
                                name: "bluetooth"
                                iconSize: 28
                                color: shellRoot.textPrimaryTone
                            }
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 28
                            spacing: 7

                            Repeater {
                                model: 3

                                Rectangle {
                                    required property int index
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: index === 0 ? "#d8cbff" : "#726b81"
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: bluetoothService.bluetoothEnabled ? "Select a device" : "Bluetooth is off"
                        horizontalAlignment: Text.AlignHCenter
                        color: shellRoot.textPrimaryTone
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 23
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: bluetoothService.bluetoothEnabled
                            ? "Choose a device from the sidebar to manage its connection, battery status, and advanced settings."
                            : "Turn Bluetooth back on to reconnect saved devices or discover a new one nearby."
                        horizontalAlignment: Text.AlignHCenter
                        color: shellRoot.textSecondaryTone
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                        lineHeight: 1.45
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48

                        Rectangle {
                            id: pairButton
                            anchors.centerIn: parent
                            width: pairButtonRow.implicitWidth + 42
                            height: 46
                            radius: 23
                            color: shellRoot.accentToneMuted
                            opacity: bluetoothService.bluetoothEnabled ? 1 : 0.45

                            RowLayout {
                                id: pairButtonRow
                                anchors.centerIn: parent
                                spacing: 8

                                DS.LucideIcon {
                                    name: "plus"
                                    iconSize: 16
                                    color: "#231f2b"
                                }

                                Text {
                                    text: "Pair New Device"
                                    color: "#231f2b"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Design.ThemePalette.withAlpha("#ffffff", pairMouseArea.pressed ? 0.16 : pairMouseArea.containsMouse ? 0.08 : 0)
                            }

                            MouseArea {
                                id: pairMouseArea
                                anchors.fill: parent
                                enabled: bluetoothService.bluetoothEnabled
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: bluetoothService.toggleDiscovery()
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: deviceDetailView

            Flickable {
                clip: true
                contentWidth: width
                contentHeight: detailContent.height
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                Item {
                    id: detailContent
                    width: parent.width
                    height: detailColumn.implicitHeight + 120

                    ColumnLayout {
                        id: detailColumn
                        width: Math.min(parent.width - 112, 760)
                        anchors.top: parent.top
                        anchors.topMargin: 82
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 18

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: heroColumn.implicitHeight + 40
                            radius: 34
                            color: shellRoot.cardTone
                            border.width: 1
                            border.color: shellRoot.borderTone

                            ColumnLayout {
                                id: heroColumn
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 18

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 18

                                    Rectangle {
                                        width: 108
                                        height: 108
                                        radius: 32
                                        color: shellRoot.highlightTone

                                        DeviceGlyph {
                                            anchors.centerIn: parent
                                            size: 58
                                            device: bluetoothService.selectedDevice
                                            typeKey: bluetoothService.typeKey(bluetoothService.selectedDevice)
                                            containerColor: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.24)
                                            contentColor: shellRoot.textPrimaryTone
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 6

                                        Text {
                                            Layout.fillWidth: true
                                            text: bluetoothService.deviceLabel(bluetoothService.selectedDevice)
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 28
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: bluetoothService.summaryText(bluetoothService.selectedDevice)
                                            color: shellRoot.textSecondaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 13
                                            wrapMode: Text.Wrap
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Rectangle {
                                                implicitWidth: statusLabel.implicitWidth + 24
                                                implicitHeight: 30
                                                radius: 15
                                                color: Design.ThemePalette.withAlpha(bluetoothService.statusColor(bluetoothService.selectedDevice), 0.22)
                                                border.width: 1
                                                border.color: Design.ThemePalette.withAlpha(bluetoothService.statusColor(bluetoothService.selectedDevice), 0.34)

                                                Text {
                                                    id: statusLabel
                                                    anchors.centerIn: parent
                                                    text: bluetoothService.baseStatusText(bluetoothService.selectedDevice, true)
                                                    color: shellRoot.textPrimaryTone
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.weight: Font.DemiBold
                                                }
                                            }

                                            Rectangle {
                                                visible: bluetoothService.selectedDevice && bluetoothService.selectedDevice.batteryAvailable
                                                implicitWidth: batteryLabel.implicitWidth + 24
                                                implicitHeight: 30
                                                radius: 15
                                                color: shellRoot.highlightTone
                                                border.width: 1
                                                border.color: shellRoot.borderTone

                                                Text {
                                                    id: batteryLabel
                                                    anchors.centerIn: parent
                                                    text: bluetoothService.batteryPercent(bluetoothService.selectedDevice)
                                                    color: shellRoot.textPrimaryTone
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.weight: Font.DemiBold
                                                }
                                            }

                                            Rectangle {
                                                implicitWidth: typeLabel.implicitWidth + 24
                                                implicitHeight: 30
                                                radius: 15
                                                color: shellRoot.highlightTone
                                                border.width: 1
                                                border.color: shellRoot.borderTone

                                                Text {
                                                    id: typeLabel
                                                    anchors.centerIn: parent
                                                    text: bluetoothService.typeLabel(bluetoothService.selectedDevice)
                                                    color: shellRoot.textSecondaryTone
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: shellRoot.separatorTone
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 74
                                        radius: 24
                                        color: shellRoot.cardToneSoft
                                        border.width: 1
                                        border.color: shellRoot.borderTone

                                        Column {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 18
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 4

                                            Text {
                                                text: "Last Update"
                                                color: shellRoot.textMutedTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                            }

                                            Text {
                                                text: bluetoothService.relativeTime(bluetoothService.lastUpdated(bluetoothService.selectedDevice))
                                                color: shellRoot.textPrimaryTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 74
                                        radius: 24
                                        color: shellRoot.cardToneSoft
                                        border.width: 1
                                        border.color: shellRoot.borderTone

                                        Column {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 18
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 4

                                            Text {
                                                text: "Connection"
                                                color: shellRoot.textMutedTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                            }

                                            Text {
                                                text: bluetoothService.selectedDevice.connected ? "Active" : "Standby"
                                                color: shellRoot.textPrimaryTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 74
                                        radius: 24
                                        color: shellRoot.cardToneSoft
                                        border.width: 1
                                        border.color: shellRoot.borderTone

                                        Column {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 18
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 4

                                            Text {
                                                text: "Saved"
                                                color: shellRoot.textMutedTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                            }

                                            Text {
                                                text: (bluetoothService.selectedDevice.paired || bluetoothService.selectedDevice.bonded || bluetoothService.selectedDevice.trusted) ? "Yes" : "No"
                                                color: shellRoot.textPrimaryTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 16
                                                font.weight: Font.DemiBold
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: detailsColumn.implicitHeight + 40
                            radius: 30
                            color: shellRoot.cardToneSoft
                            border.width: 1
                            border.color: shellRoot.borderTone

                            ColumnLayout {
                                id: detailsColumn
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 14

                                Text {
                                    text: "Details"
                                    color: shellRoot.textPrimaryTone
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                Repeater {
                                    model: bluetoothService.detailRows(bluetoothService.selectedDevice)

                                    delegate: RowLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 18

                                        Text {
                                            Layout.preferredWidth: 136
                                            text: modelData.label
                                            color: shellRoot.textMutedTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.value
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 13
                                            wrapMode: Text.WrapAnywhere
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            visible: bluetoothService.capabilityRows(bluetoothService.selectedDevice).length > 0
                            implicitHeight: capabilityColumn.implicitHeight + 40
                            radius: 30
                            color: shellRoot.cardToneSoft
                            border.width: 1
                            border.color: shellRoot.borderTone

                            ColumnLayout {
                                id: capabilityColumn
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 14

                                Text {
                                    text: "Capabilities"
                                    color: shellRoot.textPrimaryTone
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                Flow {
                                    width: capabilityColumn.width
                                    spacing: 10

                                    Repeater {
                                        model: bluetoothService.capabilityRows(bluetoothService.selectedDevice)

                                        delegate: Rectangle {
                                            required property string modelData
                                            height: 34
                                            radius: 17
                                            color: shellRoot.highlightTone
                                            border.width: 1
                                            border.color: shellRoot.borderTone
                                            width: capabilityText.implicitWidth + 24

                                            Text {
                                                id: capabilityText
                                                anchors.centerIn: parent
                                                text: modelData
                                                color: shellRoot.textSecondaryTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: actionsColumn.implicitHeight + 40
                            radius: 30
                            color: shellRoot.cardToneSoft
                            border.width: 1
                            border.color: shellRoot.borderTone

                            ColumnLayout {
                                id: actionsColumn
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 14

                                Text {
                                    text: "Quick Actions"
                                    color: shellRoot.textPrimaryTone
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                Flow {
                                    id: actionFlow
                                    width: actionsColumn.width
                                    spacing: 10

                                    Repeater {
                                        model: bluetoothService.deviceActions(bluetoothService.selectedDevice)

                                        delegate: Rectangle {
                                            required property var modelData
                                            readonly property bool primaryVariant: modelData.variant === "primary"
                                            readonly property bool ghostVariant: modelData.variant === "ghost"
                                            width: Math.min(220, Math.max(180, actionFlow.width / 2 - 8))
                                            height: 44
                                            radius: 22
                                            color: primaryVariant ? shellRoot.accentToneMuted : ghostVariant ? "transparent" : shellRoot.highlightTone
                                            border.width: ghostVariant ? 1 : 0
                                            border.color: ghostVariant ? shellRoot.borderTone : "transparent"
                                            opacity: modelData.disabled ? 0.45 : 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                color: primaryVariant ? "#231f2b" : shellRoot.textPrimaryTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 13
                                                font.weight: Font.Bold
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                color: Design.ThemePalette.withAlpha("#ffffff", actionMouseArea.pressed ? 0.16 : actionMouseArea.containsMouse ? 0.08 : 0)
                                            }

                                            MouseArea {
                                                id: actionMouseArea
                                                anchors.fill: parent
                                                enabled: !modelData.disabled && bluetoothService.selectedDevice !== null
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: bluetoothService.performAction(modelData.id, bluetoothService.selectedDevice)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
