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
            opacity: contentFrame.opacity
        }

        MouseArea {
            anchors.fill: parent
            enabled: shellRoot.panelOpen
            onClicked: shellRoot.panelOpen = false
        }

        FocusScope {
            id: contentFrame
            anchors.centerIn: parent
            width: Math.min(1180, Math.max(880, (window.screen ? window.screen.width : 1280) - 64))
            height: Math.min(820, Math.max(680, (window.screen ? window.screen.height : 900) - 64))
            opacity: shellRoot.panelOpen ? 1 : 0
            scale: shellRoot.panelOpen ? 1 : 0.98
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
                radius: 36
                color: Design.Tokens.color.surface
                border.width: Design.Tokens.border.width.thin
                border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.72)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => { mouse.accepted = true; }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: Design.Tokens.space.s24
                spacing: Design.Tokens.space.s20

                DS.Panel {
                    Layout.preferredWidth: 392
                    Layout.fillHeight: true
                    clipContent: true
                    backgroundColor: Design.Tokens.color.surfaceContainer
                    radius: 32

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Design.Tokens.space.s16

                        Text {
                            text: "Device Overview"
                            color: Design.Tokens.color.text.primary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Design.Tokens.font.size.title
                            font.weight: Design.Tokens.font.weight.semibold
                        }

                        Text {
                            text: "Bluetooth state, discoverability, and real-time reconnect feedback."
                            color: Design.Tokens.color.text.secondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Design.Tokens.font.size.label
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        DS.SwitchRow {
                            Layout.fillWidth: true
                            title: "Bluetooth"
                            subtitle: bluetoothService.bluetoothEnabled
                                ? "Powered on and ready for paired devices."
                                : "Turn it on to reconnect and discover devices."
                            checked: bluetoothService.bluetoothEnabled
                            rowEnabled: bluetoothService.bluetoothAvailable
                            onToggled: checked => {
                                if (bluetoothService.adapter) {
                                    bluetoothService.adapter.enabled = checked;
                                }
                            }
                        }

                        DS.SwitchRow {
                            Layout.fillWidth: true
                            title: "Discoverable"
                            subtitle: bluetoothService.bluetoothEnabled
                                ? (bluetoothService.adapter && bluetoothService.adapter.discoverable
                                    ? bluetoothService.adapterName + " can be seen by nearby devices."
                                    : "Keep this desktop visible when you want to pair something new.")
                                : "Bluetooth needs to be on first."
                            checked: bluetoothService.adapter ? bluetoothService.adapter.discoverable : false
                            rowEnabled: bluetoothService.bluetoothEnabled
                            onToggled: checked => {
                                if (bluetoothService.adapter) {
                                    bluetoothService.adapter.discoverable = checked;
                                }
                            }
                        }

                        DS.FeedbackBlock {
                            Layout.fillWidth: true
                            kind: bluetoothService.feedbackKind
                            title: bluetoothService.feedbackTitle
                            message: bluetoothService.feedbackMessage
                        }

                        Text {
                            text: "DEVICES"
                            color: Design.Tokens.color.text.secondary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: Design.Tokens.font.size.small
                            font.weight: Design.Tokens.font.weight.semibold
                            opacity: 0.9
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 28
                            color: Design.Tokens.color.surfaceContainerLow
                            border.width: Design.Tokens.border.width.thin
                            border.color: Design.Tokens.color.outlineVariant

                            Loader {
                                anchors.fill: parent
                                active: bluetoothService.sortedDevices.length === 0
                                sourceComponent: emptyDevicesState
                            }

                            ListView {
                                anchors.fill: parent
                                anchors.margins: Design.Tokens.space.s12
                                spacing: Design.Tokens.space.s12
                                clip: true
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
                }

                DS.Panel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clipContent: true
                    backgroundColor: Design.Tokens.color.surfaceContainerHigh
                    radius: 34

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Design.Tokens.space.s16

                        DS.TopAppBar {
                            Layout.fillWidth: true
                            title: "Bluetooth & Devices"
                            subtitle: "Manage Bluetooth devices and connection status."

                            DS.Button {
                                text: bluetoothService.scanning ? "Scanning..." : "Add Device"
                                variant: bluetoothService.scanning ? "tonal" : "primary"
                                disabled: !bluetoothService.bluetoothEnabled
                                onClicked: bluetoothService.toggleDiscovery()
                            }
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentWidth: width
                            contentHeight: detailColumn.implicitHeight
                            boundsBehavior: Flickable.StopAtBounds

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }

                            ColumnLayout {
                                id: detailColumn
                                width: parent.width
                                spacing: Design.Tokens.space.s16

                                DS.Card {
                                    Layout.fillWidth: true
                                    backgroundColor: Design.Tokens.color.surfaceContainerHighest
                                    radius: 28

                                    RowLayout {
                                        id: summaryLayout
                                        width: parent.width
                                        spacing: Design.Tokens.space.s16

                                        DeviceGlyph {
                                            Layout.alignment: Qt.AlignTop
                                            size: 72
                                            device: bluetoothService.selectedDevice
                                            typeKey: bluetoothService.typeKey(bluetoothService.selectedDevice)
                                            containerColor: Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.14)
                                            contentColor: Design.Tokens.color.primary
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: Design.Tokens.space.s8

                                            Text {
                                                text: bluetoothService.selectedDevice
                                                    ? bluetoothService.deviceLabel(bluetoothService.selectedDevice)
                                                    : "No device selected"
                                                color: Design.Tokens.color.text.primary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Design.Tokens.font.size.headline
                                                font.weight: Design.Tokens.font.weight.semibold
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: bluetoothService.summaryText(bluetoothService.selectedDevice)
                                                color: Design.Tokens.color.text.secondary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: Design.Tokens.font.size.label
                                                wrapMode: Text.Wrap
                                                Layout.fillWidth: true
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: Design.Tokens.space.s8
                                                visible: bluetoothService.selectedDevice !== null

                                                DS.Chip {
                                                    text: bluetoothService.baseStatusText(bluetoothService.selectedDevice, true)
                                                    contentColor: Design.Tokens.color.text.primary
                                                    selectedContentColor: Design.Tokens.color.text.primary
                                                    borderColor: Design.ThemePalette.withAlpha(bluetoothService.statusColor(bluetoothService.selectedDevice), 0.35)
                                                    containerColor: Design.ThemePalette.withAlpha(bluetoothService.statusColor(bluetoothService.selectedDevice), 0.14)
                                                    hoverContainerColor: containerColor
                                                    pressedContainerColor: containerColor
                                                }

                                                DS.Chip {
                                                    visible: bluetoothService.selectedDevice && bluetoothService.selectedDevice.batteryAvailable
                                                    text: "Battery " + bluetoothService.batteryPercent(bluetoothService.selectedDevice)
                                                    contentColor: Design.Tokens.color.text.primary
                                                    selectedContentColor: Design.Tokens.color.text.primary
                                                    borderColor: Design.Tokens.color.outlineVariant
                                                    containerColor: Design.Tokens.color.surfaceContainerLow
                                                    hoverContainerColor: containerColor
                                                    pressedContainerColor: containerColor
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "DEVICE DETAILS"
                                    color: Design.Tokens.color.text.secondary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Design.Tokens.font.size.small
                                    font.weight: Design.Tokens.font.weight.semibold
                                }

                                DS.Card {
                                    Layout.fillWidth: true
                                    visible: bluetoothService.selectedDevice !== null
                                    backgroundColor: Design.Tokens.color.surfaceContainer

                                    ColumnLayout {
                                        id: detailsLayout
                                        width: parent.width
                                        spacing: Design.Tokens.space.s12

                                        Repeater {
                                            model: bluetoothService.detailRows(bluetoothService.selectedDevice)

                                            delegate: RowLayout {
                                                required property var modelData
                                                Layout.fillWidth: true
                                                spacing: Design.Tokens.space.s16

                                                Text {
                                                    text: modelData.label
                                                    color: Design.Tokens.color.text.secondary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: Design.Tokens.font.size.label
                                                    Layout.preferredWidth: 140
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.value
                                                    color: Design.Tokens.color.text.primary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: Design.Tokens.font.size.body
                                                    wrapMode: Text.WrapAnywhere
                                                }
                                            }
                                        }
                                    }
                                }

                                DS.Card {
                                    Layout.fillWidth: true
                                    visible: bluetoothService.capabilityRows(bluetoothService.selectedDevice).length > 0
                                    backgroundColor: Design.Tokens.color.surfaceContainer

                                    ColumnLayout {
                                        id: capabilitiesLayout
                                        width: parent.width
                                        spacing: Design.Tokens.space.s12

                                        Text {
                                            text: "Capabilities"
                                            color: Design.Tokens.color.text.primary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: Design.Tokens.font.size.body
                                            font.weight: Design.Tokens.font.weight.semibold
                                        }

                                        Repeater {
                                            model: bluetoothService.capabilityRows(bluetoothService.selectedDevice)

                                            delegate: Rectangle {
                                                required property string modelData
                                                Layout.fillWidth: true
                                                implicitHeight: 40
                                                radius: 20
                                                color: Design.Tokens.color.surfaceContainerLow
                                                border.width: Design.Tokens.border.width.thin
                                                border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.88)

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData
                                                    color: Design.Tokens.color.text.primary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: Design.Tokens.font.size.label
                                                    font.weight: Design.Tokens.font.weight.medium
                                                }
                                            }
                                        }
                                    }
                                }

                                DS.Card {
                                    Layout.fillWidth: true
                                    backgroundColor: Design.Tokens.color.surfaceContainer

                                    ColumnLayout {
                                        id: actionsLayout
                                        width: parent.width
                                        spacing: Design.Tokens.space.s16

                                        Text {
                                            text: "Actions"
                                            color: Design.Tokens.color.text.primary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: Design.Tokens.font.size.body
                                            font.weight: Design.Tokens.font.weight.semibold
                                        }

                                        Flow {
                                            width: actionsLayout.width
                                            spacing: Design.Tokens.space.s12

                                            Repeater {
                                                model: bluetoothService.deviceActions(bluetoothService.selectedDevice)

                                                delegate: DS.Button {
                                                    required property var modelData
                                                    text: modelData.label
                                                    variant: modelData.variant
                                                    disabled: modelData.disabled || bluetoothService.selectedDevice === null
                                                    onClicked: bluetoothService.performAction(modelData.id, bluetoothService.selectedDevice)
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: 4
                                }
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: emptyDevicesState

            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - 48, 280)
                spacing: Design.Tokens.space.s12

                DeviceGlyph {
                    Layout.alignment: Qt.AlignHCenter
                    size: 64
                    typeKey: "generic"
                    containerColor: Design.Tokens.color.secondaryContainer
                    contentColor: Design.Tokens.color.secondaryContainerForeground
                }

                Text {
                    Layout.fillWidth: true
                    text: bluetoothService.bluetoothEnabled ? "No Bluetooth devices yet" : "Bluetooth is currently off"
                    horizontalAlignment: Text.AlignHCenter
                    color: Design.Tokens.color.text.primary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Design.Tokens.font.size.title
                    font.weight: Design.Tokens.font.weight.semibold
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: bluetoothService.bluetoothEnabled
                        ? "Saved devices and nearby discoveries will appear here. Use Add Device to start scanning."
                        : "Turn Bluetooth on to reconnect paired devices and see nearby peripherals."
                    horizontalAlignment: Text.AlignHCenter
                    color: Design.Tokens.color.text.secondary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Design.Tokens.font.size.label
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
