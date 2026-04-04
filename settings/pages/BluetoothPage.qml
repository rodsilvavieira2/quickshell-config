import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"

PageScaffold {
    id: root

    property string selectedAddress: ""
    property string feedbackKind: "info"
    property string feedbackMessage: ""

    readonly property var bluetoothService: root.context && root.context.bluetoothService ? root.context.bluetoothService : Bluetooth
    readonly property var bluetoothSessionService: root.context && root.context.bluetoothSessionService ? root.context.bluetoothSessionService : null
    readonly property var adapter: bluetoothService && bluetoothService.defaultAdapter ? bluetoothService.defaultAdapter : null
    readonly property var devices: sortedDevices()
    readonly property var connectedDevices: devices.filter(device => device && device.connected)
    readonly property var savedDevices: devices.filter(device => device && !device.connected)

    readonly property color heroCardColor: Design.ThemePalette.mix(
        Design.Tokens.color.primary,
        Design.Tokens.color.surfaceContainerHigh,
        Design.ThemeSettings.isDark ? 0.68 : 0.88
    )
    readonly property color heroCircleColor: Design.ThemePalette.mix(
        Design.Tokens.color.primary,
        Design.Tokens.color.surfaceContainerHighest,
        Design.ThemeSettings.isDark ? 0.32 : 0.64
    )
    readonly property color connectedCardColor: Design.ThemePalette.mix(
        Design.Tokens.color.primary,
        Design.Tokens.color.surfaceContainerHigh,
        Design.ThemeSettings.isDark ? 0.72 : 0.9
    )
    readonly property color pairChipColor: Design.ThemePalette.mix(
        Design.Tokens.color.primary,
        Design.Tokens.color.surfaceContainer,
        Design.ThemeSettings.isDark ? 0.8 : 0.92
    )
    readonly property color savedCardColor: Design.ThemePalette.mix(
        Design.Tokens.color.primary,
        Design.Tokens.color.surfaceContainerLowest,
        Design.ThemeSettings.isDark ? 0.9 : 0.97
    )
    readonly property color heroBorderColor: Design.ThemePalette.withAlpha(
        Design.Tokens.color.primary,
        Design.ThemeSettings.isDark ? 0.24 : 0.14
    )
    readonly property color connectedBorderColor: Design.ThemePalette.withAlpha(
        Design.Tokens.color.primary,
        Design.ThemeSettings.isDark ? 0.28 : 0.16
    )
    readonly property color pairBorderColor: Design.ThemePalette.withAlpha(
        Design.Tokens.color.primary,
        Design.ThemeSettings.isDark ? 0.3 : 0.18
    )
    readonly property color savedBorderColor: Design.ThemePalette.withAlpha(
        Design.Tokens.color.primary,
        Design.ThemeSettings.isDark ? 0.42 : 0.24
    )
    readonly property color subtleAccentColor: Design.ThemePalette.mix(
        Design.Tokens.color.primary,
        Design.Tokens.color.text.primary,
        Design.ThemeSettings.isDark ? 0.54 : 0.76
    )
    readonly property color heroSubtitleColor: Design.ThemePalette.mix(
        Design.Tokens.color.primary,
        Design.Tokens.color.text.primary,
        Design.ThemeSettings.isDark ? 0.66 : 0.82
    )
    readonly property color sectionLabelColor: Design.ThemePalette.withAlpha(
        Design.Tokens.color.text.primary,
        Design.ThemeSettings.isDark ? 0.82 : 0.72
    )

    title: "Bluetooth & Devices"
    description: ""

    function focusEntry(entryId) {
        if (entryId === "devices" && devices.length > 0 && selectedAddress === "") {
            selectedAddress = devices[0] && devices[0].address ? devices[0].address : "";
        }
    }

    function setFeedback(kind, message) {
        feedbackKind = kind;
        feedbackMessage = message || "";
    }

    function deviceArray() {
        const out = [];
        const list = (bluetoothService && bluetoothService.devices && bluetoothService.devices.values)
            ? bluetoothService.devices.values
            : ((Bluetooth.devices && Bluetooth.devices.values) ? Bluetooth.devices.values : []);

        for (let index = 0; index < list.length; index++) {
            out.push(list[index]);
        }

        return out;
    }

    function sortedDevices() {
        return deviceArray().sort((first, second) => {
            return (Number(second.connected) - Number(first.connected))
                || (Number(second.paired) - Number(first.paired))
                || deviceLabel(first).localeCompare(deviceLabel(second));
        });
    }

    function deviceLabel(device) {
        return (device && device.name) || (device && device.deviceName) || (device && device.address) || "Unknown device";
    }

    function adapterLabel() {
        return (adapter && (adapter.name || adapter.alias)) || "This desktop";
    }

    function deviceStatus(device) {
        if (!device)
            return "No device selected";
        if (device.connected)
            return "Connected";
        if (device.pairing)
            return "Pairing";
        if (device.paired)
            return "Not connected";
        return "Available";
    }

    function batteryText(device) {
        if (!device || !device.batteryAvailable)
            return "";

        return Math.round(((device && device.battery) || 0) * 100) + "% battery";
    }

    function statusLine(device) {
        const status = deviceStatus(device);
        const battery = batteryText(device);
        return battery !== "" ? `${status} • ${battery}` : status;
    }

    function deviceIconName(device) {
        const label = deviceLabel(device).toLowerCase();

        if (label.includes("keyboard"))
            return "keyboard";
        if (label.includes("mouse"))
            return "mouse-pointer-2";
        if (label.includes("sony") || label.includes("headphone") || label.includes("buds") || label.includes("airpods"))
            return "music-4";

        return device && device.connected ? "bluetooth-connected" : "bluetooth";
    }

    function connectDevice(device) {
        if (!device)
            return;

        setFeedback("info", "Connecting to " + deviceLabel(device) + "...");
        if (bluetoothSessionService && bluetoothSessionService.connectDevice) {
            bluetoothSessionService.connectDevice(device);
        } else if (device.connect) {
            device.connect();
        } else {
            device.connected = true;
        }
    }

    function disconnectDevice(device) {
        if (!device)
            return;

        setFeedback("info", "Disconnecting " + deviceLabel(device) + "...");
        if (device.disconnect) {
            device.disconnect();
        } else {
            device.connected = false;
        }
    }

    function pairDevice(device) {
        if (!device || !device.pair)
            return;

        setFeedback("info", "Pairing " + deviceLabel(device) + "...");
        device.pair();
    }

    function forgetDevice(device) {
        if (!device || !device.forget)
            return;

        if (bluetoothSessionService && bluetoothSessionService.clearRememberedDevice) {
            bluetoothSessionService.clearRememberedDevice(device && device.address ? device.address : "");
        }
        setFeedback("warning", "Forgetting " + deviceLabel(device) + "...");
        device.forget();
    }

    function primaryAction(device) {
        if (!device)
            return;

        if (device.connected) {
            disconnectDevice(device);
            return;
        }

        if (device.paired) {
            connectDevice(device);
            return;
        }

        pairDevice(device);
    }

    function toggleAdapter(enabled) {
        if (!adapter)
            return;

        adapter.enabled = enabled;
        if (!enabled && adapter.discovering) {
            adapter.discovering = false;
        }
        setFeedback("success", enabled ? "Bluetooth enabled." : "Bluetooth disabled.");
    }

    function startPairingScan() {
        if (!adapter)
            return;

        adapter.enabled = true;
        adapter.discovering = true;
        setFeedback("info", "Bluetooth discovery started.");
    }

    Component.onCompleted: {
        if (devices.length > 0) {
            selectedAddress = devices[0] && devices[0].address ? devices[0].address : "";
        }
    }

    component BluetoothSwitch: Item {
        id: switchRoot

        property bool checked: false
        property bool enabled: true
        signal toggled(bool checked)

        implicitWidth: 56
        implicitHeight: 34

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: switchRoot.checked
                ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, Design.ThemeSettings.isDark ? 0.46 : 0.3)
                : Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerHighest, Design.ThemeSettings.isDark ? 0.92 : 1)
            opacity: switchRoot.enabled ? 1 : Design.Tokens.opacities.disabled

            Rectangle {
                width: 26
                height: 26
                radius: 13
                y: 4
                x: switchRoot.checked ? parent.width - width - 4 : 4
                color: switchRoot.checked ? Design.Tokens.color.primaryForeground : Design.Tokens.color.text.secondary

                Behavior on x {
                    NumberAnimation {
                        duration: Design.Tokens.motion.duration.fast
                        easing.type: Design.Tokens.motion.easing.standard
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: switchRoot.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: switchRoot.toggled(!switchRoot.checked)
        }
    }

    component PairActionChip: Rectangle {
        id: chipRoot

        signal clicked()

        implicitHeight: 52
        implicitWidth: chipRow.implicitWidth + Design.Tokens.space.s24 * 2
        radius: Design.Tokens.radius.pill
        color: root.pairChipColor
        border.width: Design.Tokens.border.width.thin
        border.color: root.pairBorderColor

        Behavior on color {
            ColorAnimation {
                duration: Design.Tokens.motion.duration.fast
                easing.type: Design.Tokens.motion.easing.standard
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Design.ThemePalette.withAlpha(
                Design.Tokens.color.text.primary,
                chipMouseArea.pressed
                    ? Design.Tokens.stateLayer.pressed
                    : chipMouseArea.containsMouse
                        ? Design.Tokens.stateLayer.hover
                        : 0
            )
        }

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: Design.Tokens.space.s12

            DS.LucideIcon {
                Layout.alignment: Qt.AlignVCenter
                name: "plus"
                color: Design.Tokens.color.text.primary
                iconSize: 18
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "Pair New Device"
                color: Design.Tokens.color.text.primary
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.label
                font.weight: Design.Tokens.font.weight.semibold
            }
        }

        MouseArea {
            id: chipMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chipRoot.clicked()
        }
    }

    component DeviceCard: Rectangle {
        id: card

        required property var device
        property bool connectedStyle: false

        readonly property bool selected: root.selectedAddress !== "" && root.selectedAddress === (card.device && card.device.address ? card.device.address : "")
        readonly property color borderTone: selected
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, Design.ThemeSettings.isDark ? 0.5 : 0.34)
            : connectedStyle
                ? root.connectedBorderColor
                : root.savedBorderColor

        Layout.fillWidth: true
        implicitHeight: 74
        radius: 24
        color: connectedStyle ? root.connectedCardColor : root.savedCardColor
        border.width: Design.Tokens.border.width.thin
        border.color: borderTone

        Behavior on color {
            ColorAnimation {
                duration: Design.Tokens.motion.duration.fast
                easing.type: Design.Tokens.motion.easing.standard
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Design.ThemePalette.withAlpha(
                Design.Tokens.color.text.primary,
                deviceMouseArea.pressed
                    ? Design.Tokens.stateLayer.pressed
                    : deviceMouseArea.containsMouse
                        ? Design.Tokens.stateLayer.hover
                        : 0
            )
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Design.Tokens.space.s20
            anchors.rightMargin: Design.Tokens.space.s20
            spacing: Design.Tokens.space.s16

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                Layout.alignment: Qt.AlignVCenter

                DS.LucideIcon {
                    anchors.centerIn: parent
                    name: root.deviceIconName(card.device)
                    color: connectedStyle ? Design.Tokens.color.text.primary : Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, 0.9)
                    iconSize: 20
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: Design.Tokens.space.s4

                Text {
                    Layout.fillWidth: true
                    text: root.deviceLabel(card.device)
                    color: Design.Tokens.color.text.primary
                    font.family: Design.Tokens.font.family.title
                    font.pixelSize: Design.Tokens.font.size.body + 1
                    font.weight: Design.Tokens.font.weight.semibold
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s6

                    Rectangle {
                        visible: connectedStyle
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 7
                        Layout.preferredHeight: 7
                        radius: 4
                        color: root.subtleAccentColor
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.statusLine(card.device)
                        color: connectedStyle ? root.subtleAccentColor : Design.ThemePalette.withAlpha(Design.Tokens.color.text.secondary, 0.92)
                        font.family: Design.Tokens.font.family.caption
                        font.pixelSize: Design.Tokens.font.size.caption
                        font.weight: connectedStyle ? Design.Tokens.font.weight.medium : Design.Tokens.font.weight.regular
                        elide: Text.ElideRight
                    }
                }
            }
        }

        MouseArea {
            id: deviceMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.selectedAddress = card.device && card.device.address ? card.device.address : "";
                root.primaryAction(card.device);
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Design.Tokens.space.s24

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 108
            radius: 30
            color: root.heroCardColor
            border.width: Design.Tokens.border.width.thin
            border.color: root.heroBorderColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Design.Tokens.space.s24
                anchors.rightMargin: Design.Tokens.space.s24
                spacing: Design.Tokens.space.s20

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 58
                    Layout.preferredHeight: 58
                    radius: 29
                    color: root.heroCircleColor

                    DS.LucideIcon {
                        anchors.centerIn: parent
                        name: root.adapter && root.adapter.enabled ? "bluetooth-connected" : "bluetooth"
                        color: Design.Tokens.color.primary
                        iconSize: 24
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Design.Tokens.space.s4

                    Text {
                        Layout.fillWidth: true
                        text: "Bluetooth"
                        color: Design.Tokens.color.text.primary
                        font.family: Design.Tokens.font.family.title
                        font.pixelSize: Design.Tokens.font.size.title
                        font.weight: Design.Tokens.font.weight.bold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.adapter && root.adapter.enabled
                            ? `Discoverable as "${root.adapterLabel()}"`
                            : "Turn on Bluetooth to pair nearby devices."
                        color: root.heroSubtitleColor
                        font.family: Design.Tokens.font.family.body
                        font.pixelSize: Design.Tokens.font.size.body
                        wrapMode: Text.Wrap
                    }
                }

                BluetoothSwitch {
                    Layout.alignment: Qt.AlignVCenter
                    checked: root.adapter ? root.adapter.enabled : false
                    enabled: root.adapter !== null
                    onToggled: checked => root.toggleAdapter(checked)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            PairActionChip {
                Layout.alignment: Qt.AlignLeft
                onClicked: root.startPairingScan()
            }

            Item {
                Layout.fillWidth: true
            }
        }

        DS.FeedbackBlock {
            Layout.fillWidth: true
            visible: feedbackMessage !== ""
            kind: feedbackKind
            title: feedbackKind === "error" ? "Bluetooth action failed" : "Bluetooth action"
            message: feedbackMessage
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: connectedDevices.length > 0
            spacing: Design.Tokens.space.s12

            Text {
                text: "CONNECTED"
                color: root.sectionLabelColor
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.caption
                font.weight: Design.Tokens.font.weight.semibold
                leftPadding: Design.Tokens.space.s8
            }

            Repeater {
                model: connectedDevices

                DeviceCard {
                    required property var modelData
                    device: modelData
                    connectedStyle: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: savedDevices.length > 0
            spacing: Design.Tokens.space.s12

            Text {
                text: "SAVED DEVICES"
                color: root.sectionLabelColor
                font.family: Design.Tokens.font.family.label
                font.pixelSize: Design.Tokens.font.size.caption
                font.weight: Design.Tokens.font.weight.semibold
                leftPadding: Design.Tokens.space.s8
            }

            Repeater {
                model: savedDevices

                DeviceCard {
                    required property var modelData
                    device: modelData
                    connectedStyle: false
                }
            }
        }

        DS.FeedbackBlock {
            Layout.fillWidth: true
            visible: devices.length === 0
            kind: "info"
            title: "No Bluetooth devices shown"
            message: adapter && adapter.enabled
                ? "Use Pair New Device to scan nearby accessories."
                : "Enable the Bluetooth adapter to manage devices."
        }
    }
}
