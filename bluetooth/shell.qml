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
    property bool pairingModalOpen: false
    property string focusedScreenName: Hyprland.focusedMonitor?.name ?? ""

    readonly property color panelTone: Design.Tokens.color.surfaceDim
    readonly property color sidebarTone: Design.Tokens.color.surfaceContainer
    readonly property color cardTone: Design.Tokens.color.surfaceContainerHigh
    readonly property color cardToneSoft: Design.Tokens.color.surfaceContainerLow
    readonly property color accentTone: Design.Tokens.color.primary
    readonly property color accentToneStrong: Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.22)
    readonly property color accentToneMuted: Design.Tokens.color.primaryContainer
    readonly property color textPrimaryTone: Design.Tokens.color.text.primary
    readonly property color textSecondaryTone: Design.Tokens.color.text.secondary
    readonly property color textMutedTone: Design.ThemePalette.withAlpha(Design.Tokens.color.text.secondary, 0.82)
    readonly property color borderTone: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.85)
    readonly property color separatorTone: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.42)
    readonly property color highlightTone: Design.Tokens.color.surfaceContainerHighest
    readonly property color successTone: Design.Tokens.color.success

    function resolveScreen() {
        for (let index = 0; index < Quickshell.screens.values.length; index += 1) {
            if (Quickshell.screens.values[index].name === shellRoot.focusedScreenName) {
                return Quickshell.screens.values[index];
            }
        }

        return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
    }

    function openPairingModal() {
        if (!bluetoothService.bluetoothEnabled) return;
        shellRoot.pairingModalOpen = true;
        bluetoothService.startDiscovery();
    }

    function closePairingModal() {
        shellRoot.pairingModalOpen = false;
        bluetoothService.stopDiscovery();
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
            shellRoot.closePairingModal();
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
            onClicked: {
                if (shellRoot.pairingModalOpen) shellRoot.closePairingModal();
                else shellRoot.panelOpen = false;
            }
        }

        FocusScope {
            id: contentFrame
            anchors.centerIn: parent
            width: Math.min(1149, Math.max(1017, (window.screen ? window.screen.width : 1280) - 60))
            height: Math.min(840, Math.max(751, (window.screen ? window.screen.height : 900) - 60))
            opacity: shellRoot.panelOpen ? 1 : 0
            scale: shellRoot.panelOpen ? 1 : 0.985
            focus: shellRoot.panelOpen

            Keys.onEscapePressed: {
                if (shellRoot.pairingModalOpen) shellRoot.closePairingModal();
                else shellRoot.panelOpen = false;
            }

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
                                                : "Ready for your saved Bluetooth devices.")
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
                                    visible: bluetoothService.pairedDevices.length > 0
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.2)
                                    border.width: 1
                                    border.color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.28)

                                    Text {
                                        anchors.centerIn: parent
                                        text: bluetoothService.pairedDevices.length
                                        color: shellRoot.accentTone
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
                                    active: bluetoothService.pairedDevices.length === 0
                                    sourceComponent: sidebarEmptyState
                                }

                                ListView {
                                    anchors.fill: parent
                                    clip: true
                                    spacing: 8
                                    visible: bluetoothService.pairedDevices.length > 0
                                    model: bluetoothService.pairedDevices

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
                            color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.08)
                        }

                        Rectangle {
                            width: 220
                            height: 220
                            radius: width / 2
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 64
                            anchors.verticalCenterOffset: 64
                            color: Design.ThemePalette.withAlpha(Design.Tokens.color.tertiary, 0.05)
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
                            color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.18)
                            border.width: 1
                            border.color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.24)
                            opacity: bluetoothService.bluetoothEnabled ? 1 : 0.45

                            Text {
                                id: scanLabel
                                anchors.centerIn: parent
                                text: "Scan"
                                color: shellRoot.accentTone
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Design.ThemePalette.withAlpha(shellRoot.accentTone, scanMouseArea.pressed ? 0.16 : scanMouseArea.containsMouse ? 0.08 : 0)
                            }

                            MouseArea {
                                id: scanMouseArea
                                anchors.fill: parent
                                enabled: bluetoothService.bluetoothEnabled
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: shellRoot.openPairingModal()
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

                Item {
                    anchors.fill: parent
                    visible: shellRoot.pairingModalOpen
                    z: 10

                    Rectangle {
                        anchors.fill: parent
                        color: Design.ThemePalette.withAlpha(Design.Tokens.color.scrim, 0.28)
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: shellRoot.closePairingModal()
                    }

                    Rectangle {
                        id: pairingModal
                        anchors.centerIn: parent
                        width: 364
                        height: 520
                        radius: 34
                        color: Design.Tokens.color.surfaceBright
                        border.width: 1
                        border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.58)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: mouse => { mouse.accepted = true; }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 22
                            spacing: 16

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    text: "Add a device"
                                    color: Design.Tokens.color.text.primary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: closeMouse.containsMouse
                                        ? Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, 0.08)
                                        : "transparent"

                                    DS.LucideIcon {
                                        anchors.centerIn: parent
                                        name: "x"
                                        iconSize: 16
                                        color: Design.Tokens.color.text.secondary
                                    }

                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: shellRoot.closePairingModal()
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 170

                                Rectangle {
                                    id: outerPulseRing
                                    width: 162
                                    height: 162
                                    radius: 81
                                    anchors.centerIn: parent
                                    color: "transparent"
                                    border.width: 2
                                    border.color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.12)
                                    opacity: 0.22
                                    scale: 1
                                }

                                Rectangle {
                                    id: innerPulseRing
                                    width: 118
                                    height: 118
                                    radius: 59
                                    anchors.centerIn: parent
                                    color: "transparent"
                                    border.width: 2
                                    border.color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.18)
                                    opacity: 0.28
                                    scale: 1
                                }

                                Rectangle {
                                    id: modalBluetoothIcon
                                    width: 46
                                    height: 46
                                    radius: 23
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -18
                                    color: shellRoot.accentTone
                                    scale: 1

                                    DS.LucideIcon {
                                        anchors.centerIn: parent
                                        name: "bluetooth"
                                        iconSize: 20
                                        color: Design.Tokens.color.primaryForeground
                                    }
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 8
                                    text: bluetoothService.scanning ? "Scanning for nearby devices..." : "Nearby devices ready to pair"
                                    color: Design.Tokens.color.text.secondary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                }

                                SequentialAnimation {
                                    id: outerPulseAnimation
                                    running: shellRoot.pairingModalOpen && bluetoothService.scanning
                                    loops: Animation.Infinite

                                    PauseAnimation { duration: 120 }

                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: outerPulseRing
                                            property: "scale"
                                            from: 0.94
                                            to: 1.18
                                            duration: 1600
                                            easing.type: Easing.OutCubic
                                        }

                                        NumberAnimation {
                                            target: outerPulseRing
                                            property: "opacity"
                                            from: 0.28
                                            to: 0.04
                                            duration: 1600
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    ScriptAction {
                                        script: {
                                            outerPulseRing.scale = 0.94;
                                            outerPulseRing.opacity = 0.28;
                                        }
                                    }

                                    onRunningChanged: {
                                        if (!running) {
                                            outerPulseRing.scale = 1;
                                            outerPulseRing.opacity = 0.22;
                                        }
                                    }
                                }

                                SequentialAnimation {
                                    id: innerPulseAnimation
                                    running: shellRoot.pairingModalOpen && bluetoothService.scanning
                                    loops: Animation.Infinite

                                    PauseAnimation { duration: 420 }

                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: innerPulseRing
                                            property: "scale"
                                            from: 0.96
                                            to: 1.14
                                            duration: 1350
                                            easing.type: Easing.OutCubic
                                        }

                                        NumberAnimation {
                                            target: innerPulseRing
                                            property: "opacity"
                                            from: 0.34
                                            to: 0.06
                                            duration: 1350
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    ScriptAction {
                                        script: {
                                            innerPulseRing.scale = 0.96;
                                            innerPulseRing.opacity = 0.34;
                                        }
                                    }

                                    onRunningChanged: {
                                        if (!running) {
                                            innerPulseRing.scale = 1;
                                            innerPulseRing.opacity = 0.28;
                                        }
                                    }
                                }

                                SequentialAnimation {
                                    id: iconPulseAnimation
                                    running: shellRoot.pairingModalOpen && bluetoothService.scanning
                                    loops: Animation.Infinite

                                    NumberAnimation {
                                        target: modalBluetoothIcon
                                        property: "scale"
                                        from: 1
                                        to: 1.08
                                        duration: 720
                                        easing.type: Easing.OutCubic
                                    }

                                    NumberAnimation {
                                        target: modalBluetoothIcon
                                        property: "scale"
                                        from: 1.08
                                        to: 1
                                        duration: 720
                                        easing.type: Easing.OutCubic
                                    }

                                    onRunningChanged: {
                                        if (!running) {
                                            modalBluetoothIcon.scale = 1;
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Loader {
                                    anchors.fill: parent
                                    active: bluetoothService.discoveredDevices.length === 0
                                    sourceComponent: pairingEmptyState
                                }

                                ListView {
                                    anchors.fill: parent
                                    clip: true
                                    spacing: 10
                                    model: bluetoothService.discoveredDevices
                                    visible: bluetoothService.discoveredDevices.length > 0

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }

                                    delegate: Rectangle {
                                        required property var modelData
                                        readonly property bool pairing: bluetoothService.statusKind(modelData) === "pairing"
                                        width: ListView.view.width
                                        height: 62
                                        radius: 22
                                        color: Design.ThemePalette.withAlpha(Design.Tokens.color.secondaryContainer, 0.34)
                                        border.width: 1
                                        border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.32)

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 14
                                            anchors.rightMargin: 14
                                            spacing: 12

                                            DeviceGlyph {
                                                size: 34
                                                device: modelData
                                                typeKey: bluetoothService.typeKey(modelData)
                                                containerColor: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.12)
                                                contentColor: shellRoot.accentTone
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 1

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: bluetoothService.deviceLabel(modelData)
                                                    color: Design.Tokens.color.text.primary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 14
                                                    font.weight: Font.DemiBold
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: pairing ? "Pairing..." : "Ready to pair"
                                                    color: Design.Tokens.color.text.secondary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 11
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            Rectangle {
                                                Layout.preferredWidth: pairLabel.implicitWidth + 22
                                                Layout.preferredHeight: 30
                                                radius: 15
                                                color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.16)
                                                opacity: pairing ? 0.55 : 1

                                                Text {
                                                    id: pairLabel
                                                    anchors.centerIn: parent
                                                    text: pairing ? "Pairing" : "Pair"
                                                    color: shellRoot.accentTone
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                }

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: parent.radius
                                                    color: Design.ThemePalette.withAlpha(shellRoot.accentTone, pairActionMouse.pressed ? 0.16 : pairActionMouse.containsMouse ? 0.08 : 0)
                                                }

                                                MouseArea {
                                                    id: pairActionMouse
                                                    anchors.fill: parent
                                                    enabled: !pairing
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: bluetoothService.pairDevice(modelData)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40

                                Rectangle {
                                    anchors.right: parent.right
                                    width: cancelLabel.implicitWidth + 34
                                    height: 36
                                    radius: 18
                                    color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.14)

                                    Text {
                                        id: cancelLabel
                                        anchors.centerIn: parent
                                        text: "Cancel"
                                        color: shellRoot.accentTone
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: Design.ThemePalette.withAlpha(shellRoot.accentTone, cancelMouse.pressed ? 0.16 : cancelMouse.containsMouse ? 0.08 : 0)
                                    }

                                    MouseArea {
                                        id: cancelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: shellRoot.closePairingModal()
                                    }
                                }
                            }
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
                    text: bluetoothService.bluetoothEnabled ? "No paired devices yet" : "Bluetooth is off"
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
                        ? "Open Scan to discover and pair a nearby device."
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
            id: pairingEmptyState

            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - 24, 250)
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: bluetoothService.scanning ? "Scanning..." : "No nearby devices"
                    horizontalAlignment: Text.AlignHCenter
                    color: Design.Tokens.color.text.primary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: bluetoothService.scanning
                        ? "Keep the device nearby while Bluetooth discovery is active."
                        : "Try scanning again or make sure the device is in pairing mode."
                    horizontalAlignment: Text.AlignHCenter
                    color: Design.Tokens.color.text.secondary
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
                            color: shellRoot.cardTone
                        }

                        Rectangle {
                            width: 208
                            height: 188
                            radius: 38
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 8
                            anchors.verticalCenterOffset: 6
                            rotation: 4
                            color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.08)
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
                                    color: index === 0
                                        ? Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.9)
                                        : Design.ThemePalette.withAlpha(shellRoot.textSecondaryTone, 0.35)
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
                            color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.18)
                            border.width: 1
                            border.color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.24)
                            opacity: bluetoothService.bluetoothEnabled ? 1 : 0.45

                            RowLayout {
                                id: pairButtonRow
                                anchors.centerIn: parent
                                spacing: 8

                                DS.LucideIcon {
                                    name: "plus"
                                    iconSize: 16
                                    color: shellRoot.accentTone
                                }

                                Text {
                                    text: "Pair New Device"
                                    color: shellRoot.accentTone
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: Design.ThemePalette.withAlpha(shellRoot.accentTone, pairMouseArea.pressed ? 0.16 : pairMouseArea.containsMouse ? 0.08 : 0)
                            }

                            MouseArea {
                                id: pairMouseArea
                                anchors.fill: parent
                                enabled: bluetoothService.bluetoothEnabled
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: shellRoot.openPairingModal()
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
                    readonly property var selectedDevice: bluetoothService.selectedDevice
                    readonly property bool hasBattery: selectedDevice && selectedDevice.batteryAvailable
                    readonly property bool isSaved: selectedDevice && (selectedDevice.paired || selectedDevice.bonded || selectedDevice.trusted)
                    readonly property string heroMetricValue: hasBattery
                        ? bluetoothService.batteryPercent(selectedDevice)
                        : (selectedDevice && selectedDevice.connected ? "Active" : "Standby")
                    readonly property string heroMetricLabel: hasBattery ? "Battery remaining" : "Connection state"
                    readonly property string heroMetricBadge: selectedDevice && selectedDevice.connected ? "ACTIVE" : "SAVED"
                    width: parent.width
                    height: detailColumn.implicitHeight + 104

                    ColumnLayout {
                        id: detailColumn
                        width: Math.min(parent.width - 88, 920)
                        anchors.top: parent.top
                        anchors.topMargin: 52
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            Item {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                implicitHeight: heroInfoRow.implicitHeight

                                RowLayout {
                                    id: heroInfoRow
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    spacing: 20

                                    Rectangle {
                                        Layout.preferredWidth: 112
                                        Layout.preferredHeight: 112
                                        radius: 32
                                        color: shellRoot.highlightTone
                                        border.width: 1
                                        border.color: shellRoot.borderTone

                                        DeviceGlyph {
                                            anchors.centerIn: parent
                                            size: 64
                                            device: detailContent.selectedDevice
                                            typeKey: bluetoothService.typeKey(detailContent.selectedDevice)
                                            containerColor: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.18)
                                            contentColor: shellRoot.accentTone
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 8

                                        Rectangle {
                                            implicitWidth: heroStatusLabel.implicitWidth + 28
                                            implicitHeight: 30
                                            radius: 15
                                            color: Design.ThemePalette.withAlpha(bluetoothService.statusColor(detailContent.selectedDevice), 0.18)
                                            border.width: 1
                                            border.color: Design.ThemePalette.withAlpha(bluetoothService.statusColor(detailContent.selectedDevice), 0.28)

                                            Text {
                                                id: heroStatusLabel
                                                anchors.centerIn: parent
                                                text: bluetoothService.baseStatusText(detailContent.selectedDevice, true).toUpperCase()
                                                color: bluetoothService.statusColor(detailContent.selectedDevice)
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                font.weight: Font.Bold
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: bluetoothService.deviceLabel(detailContent.selectedDevice)
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 38
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: bluetoothService.summaryText(detailContent.selectedDevice)
                                            color: shellRoot.textSecondaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 13
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 240
                                Layout.preferredHeight: 136
                                Layout.alignment: Qt.AlignTop
                                radius: 28
                                color: Design.ThemePalette.withAlpha(shellRoot.accentToneMuted, 0.22)
                                border.width: 1
                                border.color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.12)

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 6

                                    RowLayout {
                                        Layout.fillWidth: true

                                        DS.LucideIcon {
                                            name: detailContent.hasBattery ? "bluetooth-connected" : "bluetooth"
                                            iconSize: 16
                                            color: shellRoot.accentTone
                                        }

                                        Item { Layout.fillWidth: true }

                                        Text {
                                            text: detailContent.heroMetricBadge
                                            color: detailContent.selectedDevice && detailContent.selectedDevice.connected
                                                ? Design.Tokens.color.success
                                                : shellRoot.accentTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                        }
                                    }

                                    Item { Layout.fillHeight: true }

                                    Text {
                                        text: detailContent.heroMetricValue
                                        color: shellRoot.textPrimaryTone
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 34
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        text: detailContent.heroMetricLabel
                                        color: shellRoot.textSecondaryTone
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: width > 760 ? 2 : 1
                            columnSpacing: 18
                            rowSpacing: 18

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 104
                                radius: 28
                                color: shellRoot.cardToneSoft
                                border.width: 1
                                border.color: shellRoot.borderTone

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 46
                                        Layout.preferredHeight: 46
                                        radius: 23
                                        color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.08)

                                        DS.LucideIcon {
                                            anchors.centerIn: parent
                                            name: "check"
                                            iconSize: 18
                                            color: shellRoot.accentTone
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 3

                                        Text {
                                            text: "Status"
                                            color: shellRoot.textSecondaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: detailContent.isSaved ? "Saved" : bluetoothService.baseStatusText(detailContent.selectedDevice, true)
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 17
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 104
                                radius: 28
                                color: shellRoot.cardToneSoft
                                border.width: 1
                                border.color: shellRoot.borderTone

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 46
                                        Layout.preferredHeight: 46
                                        radius: 23
                                        color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.08)

                                        DS.LucideIcon {
                                            anchors.centerIn: parent
                                            name: "music-4"
                                            iconSize: 18
                                            color: shellRoot.accentTone
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 3

                                        Text {
                                            text: "Device Type"
                                            color: shellRoot.textSecondaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: bluetoothService.typeLabel(detailContent.selectedDevice)
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 17
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 104
                                radius: 28
                                color: shellRoot.cardToneSoft
                                border.width: 1
                                border.color: shellRoot.borderTone

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 46
                                        Layout.preferredHeight: 46
                                        radius: 23
                                        color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.08)

                                        DS.LucideIcon {
                                            anchors.centerIn: parent
                                            name: "bluetooth"
                                            iconSize: 18
                                            color: shellRoot.accentTone
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 3

                                        Text {
                                            text: "MAC Address"
                                            color: shellRoot.textSecondaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: detailContent.selectedDevice && detailContent.selectedDevice.address
                                                ? detailContent.selectedDevice.address
                                                : "Unavailable"
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 17
                                            font.weight: Font.Bold
                                            wrapMode: Text.WrapAnywhere
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 104
                                radius: 28
                                color: shellRoot.cardToneSoft
                                border.width: 1
                                border.color: shellRoot.borderTone

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 14

                                    Rectangle {
                                        Layout.preferredWidth: 46
                                        Layout.preferredHeight: 46
                                        radius: 23
                                        color: Design.ThemePalette.withAlpha(shellRoot.accentTone, 0.08)

                                        DS.LucideIcon {
                                            anchors.centerIn: parent
                                            name: "wifi"
                                            iconSize: 18
                                            color: shellRoot.accentTone
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 3

                                        Text {
                                            text: "Last Update"
                                            color: shellRoot.textSecondaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: bluetoothService.relativeTime(bluetoothService.lastUpdated(detailContent.selectedDevice))
                                            color: shellRoot.textPrimaryTone
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 17
                                            font.weight: Font.Bold
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
                                    model: bluetoothService.detailRows(detailContent.selectedDevice)

                                    delegate: RowLayout {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        spacing: 18

                                        Text {
                                            Layout.preferredWidth: 160
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
                            visible: bluetoothService.capabilityRows(detailContent.selectedDevice).length > 0
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
                                        model: bluetoothService.capabilityRows(detailContent.selectedDevice)

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
                                        model: bluetoothService.deviceActions(detailContent.selectedDevice)

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
                                                color: primaryVariant ? Design.Tokens.color.primaryForeground : shellRoot.textPrimaryTone
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 13
                                                font.weight: Font.Bold
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                color: Design.ThemePalette.withAlpha(primaryVariant ? Design.Tokens.color.primaryForeground : shellRoot.textPrimaryTone, actionMouseArea.pressed ? 0.16 : actionMouseArea.containsMouse ? 0.08 : 0)
                                            }

                                            MouseArea {
                                                id: actionMouseArea
                                                anchors.fill: parent
                                                enabled: !modelData.disabled && detailContent.selectedDevice !== null
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: bluetoothService.performAction(modelData.id, detailContent.selectedDevice)
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
