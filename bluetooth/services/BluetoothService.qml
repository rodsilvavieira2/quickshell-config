import QtQuick
import Quickshell.Bluetooth

Item {
    id: root

    property bool panelVisible: false
    property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    property int reconnectMaxAttempts: 3
    property int reconnectTimeoutMs: 7000
    property int reconnectRetryDelayMs: 2200
    property int reconnectCooldownMs: 45000

    property var attemptMap: ({})
    property var touchMap: ({})
    property var pendingPairMap: ({})
    property int deviceRevision: 0
    property string selectedAddress: ""

    readonly property bool bluetoothAvailable: root.adapter !== null
    readonly property bool bluetoothEnabled: root.adapter && root.adapter.enabled
    readonly property bool scanning: root.adapter && root.adapter.discovering
    readonly property string adapterName: {
        if (!root.adapter) return "Bluetooth adapter";
        return root.adapter.name && root.adapter.name.length > 0 ? root.adapter.name : "Bluetooth adapter";
    }
    readonly property var devices: root.adapter && root.adapter.devices ? root.adapter.devices.values : []
    readonly property var sortedDevices: {
        root.deviceRevision;
        root.attemptMap;

        const next = root.devices ? root.devices.slice() : [];
        next.sort((left, right) => {
            const priorityDiff = root.statusPriority(left) - root.statusPriority(right);
            if (priorityDiff !== 0) return priorityDiff;

            const leftUpdated = root.lastUpdated(left);
            const rightUpdated = root.lastUpdated(right);
            if (leftUpdated !== rightUpdated) return rightUpdated - leftUpdated;

            return root.deviceLabel(left).localeCompare(root.deviceLabel(right));
        });

        return next;
    }
    readonly property var selectedDevice: root.findDevice(root.selectedAddress)
    readonly property int activeAttemptCount: {
        const attempts = root.attemptMap;
        let count = 0;
        for (const key in attempts) {
            const phase = attempts[key].phase || "";
            if (phase === "connecting" || phase === "retrying" || phase === "waiting") {
                count += 1;
            }
        }
        return count;
    }
    readonly property int failedAttemptCount: {
        const attempts = root.attemptMap;
        let count = 0;
        for (const key in attempts) {
            const phase = attempts[key].phase || "";
            if (phase === "failed" || phase === "unavailable") {
                count += 1;
            }
        }
        return count;
    }
    readonly property string feedbackKind: {
        if (!root.bluetoothAvailable) return "warning";
        if (!root.bluetoothEnabled) return "warning";
        if (root.activeAttemptCount > 0) return "info";
        if (root.failedAttemptCount > 0) return "warning";
        if (root.scanning) return "info";
        return "success";
    }
    readonly property string feedbackTitle: {
        if (!root.bluetoothAvailable) return "Bluetooth unavailable";
        if (!root.bluetoothEnabled) return "Bluetooth is off";
        if (root.activeAttemptCount > 0) return "Reconnecting paired devices";
        if (root.failedAttemptCount > 0) return "Some devices need attention";
        if (root.scanning) return "Scanning for nearby devices";
        return "Bluetooth is ready";
    }
    readonly property string feedbackMessage: {
        if (!root.bluetoothAvailable) return "No Bluetooth adapter is currently available through BlueZ.";
        if (!root.bluetoothEnabled) return "Turn Bluetooth on to reconnect paired devices or discover something new.";
        if (root.activeAttemptCount > 0) {
            return root.activeAttemptCount === 1
                ? "A saved device is reconnecting in the background."
                : root.activeAttemptCount + " saved devices are reconnecting in the background.";
        }
        if (root.failedAttemptCount > 0) {
            return root.failedAttemptCount === 1
                ? "One device did not reconnect automatically. Select it to retry or forget it."
                : root.failedAttemptCount + " devices did not reconnect automatically. Select one to retry or forget it.";
        }
        if (root.scanning) return "Nearby Bluetooth devices will appear here while discovery is active.";
        return "Paired devices can reconnect automatically when they come back into range.";
    }

    function nowMs() {
        return Date.now();
    }

    function deviceAddress(device) {
        if (!device) return "";
        return device.address && device.address.length > 0 ? device.address : device.dbusPath;
    }

    function deviceLabel(device) {
        if (!device) return "Unknown Device";
        const preferredName = device.name && device.name.length > 0 ? device.name : device.deviceName;
        if (preferredName && preferredName.length > 0) return preferredName;
        if (device.address && device.address.length > 0) return device.address;
        return "Unknown Device";
    }

    function copyMap(source) {
        return Object.assign({}, source || {});
    }

    function setMapValue(mapName, key, value, removeWhenFalsy) {
        const next = root.copyMap(root[mapName]);
        if (removeWhenFalsy && !value) {
            delete next[key];
        } else {
            next[key] = value;
        }
        root[mapName] = next;
    }

    function setAttempt(address, patch) {
        const next = root.copyMap(root.attemptMap);
        const current = Object.assign({
            phase: "idle",
            attempt: 0,
            maxAttempts: root.reconnectMaxAttempts,
            startedAt: 0,
            nextRetryAt: 0,
            finishedAt: 0,
            cooldownUntil: 0,
            reason: "auto"
        }, next[address] || {});

        next[address] = Object.assign(current, patch || {});
        root.attemptMap = next;
    }

    function clearAttempt(address) {
        const next = root.copyMap(root.attemptMap);
        delete next[address];
        root.attemptMap = next;
    }

    function clearPendingPair(address) {
        const next = root.copyMap(root.pendingPairMap);
        delete next[address];
        root.pendingPairMap = next;
    }

    function touchDevice(device) {
        const address = root.deviceAddress(device);
        if (!address) return;

        const next = root.copyMap(root.touchMap);
        next[address] = root.nowMs();
        root.touchMap = next;
        root.deviceRevision += 1;
    }

    function lastUpdated(device) {
        const address = root.deviceAddress(device);
        if (!address) return 0;
        return root.touchMap[address] || 0;
    }

    function relativeTime(timestamp) {
        if (!timestamp) return "Just now";

        const elapsedSeconds = Math.max(0, Math.floor((root.nowMs() - timestamp) / 1000));
        if (elapsedSeconds < 10) return "Just now";
        if (elapsedSeconds < 60) return elapsedSeconds + "s ago";

        const elapsedMinutes = Math.floor(elapsedSeconds / 60);
        if (elapsedMinutes < 60) return elapsedMinutes + "m ago";

        const elapsedHours = Math.floor(elapsedMinutes / 60);
        if (elapsedHours < 24) return elapsedHours + "h ago";

        const elapsedDays = Math.floor(elapsedHours / 24);
        return elapsedDays + "d ago";
    }

    function typeKey(device) {
        if (!device) return "unknown";

        const icon = (device.icon || "").toLowerCase();
        const name = root.deviceLabel(device).toLowerCase();

        if (icon.indexOf("mouse") >= 0 || name.indexOf("mouse") >= 0 || name.indexOf("trackpad") >= 0) return "mouse";
        if (icon.indexOf("keyboard") >= 0 || name.indexOf("keyboard") >= 0 || name.indexOf("keychron") >= 0) return "keyboard";
        if (icon.indexOf("headset") >= 0 || icon.indexOf("headphone") >= 0 || name.indexOf("headset") >= 0 || name.indexOf("headphone") >= 0 || name.indexOf("earbud") >= 0 || name.indexOf("buds") >= 0 || name.indexOf("pods") >= 0) return "headset";
        if (icon.indexOf("speaker") >= 0 || icon.indexOf("audio-card") >= 0 || icon.indexOf("audio") >= 0 || name.indexOf("speaker") >= 0) return "speaker";
        if (icon.indexOf("gamepad") >= 0 || icon.indexOf("joystick") >= 0 || name.indexOf("controller") >= 0 || name.indexOf("gamepad") >= 0 || name.indexOf("xbox") >= 0 || name.indexOf("dualshock") >= 0 || name.indexOf("dualsense") >= 0) return "controller";
        if (icon.indexOf("phone") >= 0 || name.indexOf("phone") >= 0) return "peripheral";
        if (device.icon && device.icon.length > 0) return "generic";
        return "unknown";
    }

    function typeLabel(device) {
        switch (root.typeKey(device)) {
        case "mouse": return "Mouse";
        case "keyboard": return "Keyboard";
        case "headset": return "Headset";
        case "speaker": return "Speaker";
        case "controller": return "Game Controller";
        case "peripheral": return "Bluetooth Peripheral";
        case "generic": return "Bluetooth Peripheral";
        default: return "Unknown Bluetooth Device";
        }
    }

    function capabilityRows(device) {
        switch (root.typeKey(device)) {
        case "mouse": return ["Pointing device"];
        case "keyboard": return ["Input device"];
        case "headset": return ["Audio device"];
        case "speaker": return ["Audio output device"];
        case "controller": return ["Input device"];
        default: return [];
        }
    }

    function attemptFor(device) {
        const address = root.deviceAddress(device);
        return address ? root.attemptMap[address] || null : null;
    }

    function statusKind(device) {
        if (!root.bluetoothAvailable) return "unavailable";
        if (!root.bluetoothEnabled) return "disabled";
        if (!device) return "unavailable";

        const attempt = root.attemptFor(device);
        if (attempt) {
            switch (attempt.phase) {
            case "connecting":
            case "retrying":
            case "waiting":
            case "failed":
            case "unavailable":
                return attempt.phase;
            default:
                break;
            }
        }

        if (device.pairing) return "pairing";
        if (device.blocked) return "blocked";
        if (device.state === BluetoothDeviceState.Connecting) return "connecting";
        if (device.state === BluetoothDeviceState.Disconnecting) return "disconnecting";
        if (device.connected || device.state === BluetoothDeviceState.Connected) return "connected";
        if (device.paired) return "paired";
        return "available";
    }

    function statusPriority(device) {
        switch (root.statusKind(device)) {
        case "connected": return 0;
        case "connecting": return 1;
        case "retrying": return 2;
        case "waiting": return 3;
        case "pairing": return 4;
        case "failed": return 5;
        case "paired": return 6;
        case "available": return 7;
        case "unavailable": return 8;
        case "blocked": return 9;
        case "disconnecting": return 10;
        default: return 11;
        }
    }

    function statusColor(device) {
        switch (root.statusKind(device)) {
        case "connected": return "#7BD88F";
        case "connecting":
        case "retrying":
        case "waiting":
        case "pairing":
            return "#8CB4FF";
        case "failed":
        case "unavailable":
        case "blocked":
            return "#FF8E8E";
        default:
            return "#B4B9C4";
        }
    }

    function batteryPercent(device) {
        if (!device || !device.batteryAvailable) return "";
        return Math.max(0, Math.min(100, Math.round(device.battery * 100))) + "%";
    }

    function batterySegment(device) {
        const percent = root.batteryPercent(device);
        return percent.length > 0 ? percent + " Battery" : "";
    }

    function baseStatusText(device, detailed) {
        const attempt = root.attemptFor(device);
        const kind = root.statusKind(device);
        const concise = detailed !== true;

        switch (kind) {
        case "disabled": return "Bluetooth off";
        case "connected": return "Connected";
        case "disconnecting": return "Disconnecting...";
        case "connecting": return concise ? "Connecting..." : "Connecting";
        case "retrying":
            return concise && attempt
                ? "Retry " + attempt.attempt + "/" + attempt.maxAttempts + "..."
                : "Retrying connection";
        case "waiting":
            return concise ? "Retrying connection..." : "Waiting to retry";
        case "failed":
            return attempt && attempt.reason === "auto" ? "Failed to reconnect" : "Connection failed";
        case "unavailable": return "Unavailable";
        case "pairing": return concise ? "Pairing..." : "Pairing";
        case "blocked": return "Blocked";
        case "paired": return "Paired";
        default: return "Ready to pair";
        }
    }

    function listStatusText(device) {
        const parts = [root.baseStatusText(device, false)];
        const battery = root.batterySegment(device);
        if (battery.length > 0) parts.push(battery);
        return parts.join(" • ");
    }

    function sidebarStatusText(device) {
        if (!device) return "";

        const kind = root.statusKind(device);
        const battery = root.batteryPercent(device);
        let label = "";

        switch (kind) {
        case "disabled":
            label = "Bluetooth off";
            break;
        case "connected":
            label = "Connected";
            break;
        case "disconnecting":
            label = "Disconnecting";
            break;
        case "connecting":
            label = "Connecting";
            break;
        case "retrying":
            label = "Retrying";
            break;
        case "waiting":
            label = "Waiting";
            break;
        case "failed":
            label = "Needs attention";
            break;
        case "unavailable":
            label = "Unavailable";
            break;
        case "pairing":
            label = "Pairing";
            break;
        case "blocked":
            label = "Blocked";
            break;
        case "paired":
            label = "Paired";
            break;
        default:
            label = "Nearby";
            break;
        }

        return battery.length > 0 ? label + " • " + battery : label;
    }

    function summaryText(device) {
        if (!device) return "Select a device to see connection details and actions.";

        const kind = root.statusKind(device);
        const stamp = root.relativeTime(root.lastUpdated(device));

        switch (kind) {
        case "connected": return "Connected via Bluetooth • Updated " + stamp;
        case "connecting": return "Connecting via Bluetooth...";
        case "retrying": return "Retrying Bluetooth connection...";
        case "waiting": return "Waiting for the next reconnect attempt...";
        case "failed": return "Reconnect failed • Updated " + stamp;
        case "unavailable": return "Unavailable over Bluetooth • Updated " + stamp;
        case "paired": return "Paired via Bluetooth • Updated " + stamp;
        case "pairing": return "Pairing via Bluetooth...";
        case "blocked": return "Blocked by the Bluetooth stack";
        case "disabled": return "Bluetooth is off";
        default: return "Ready to pair over Bluetooth";
        }
    }

    function detailRows(device) {
        if (!device) return [];

        const rows = [
            { label: "Status", value: root.baseStatusText(device, true) }
        ];

        const battery = root.batteryPercent(device);
        if (battery.length > 0) rows.push({ label: "Battery", value: battery });

        rows.push({ label: "Paired", value: device.paired ? "Yes" : "No" });
        rows.push({ label: "Saved", value: (device.paired || device.bonded || device.trusted) ? "Yes" : "No" });
        rows.push({ label: "Device Type", value: root.typeLabel(device) });
        rows.push({ label: "Connection", value: "Bluetooth" });

        if (device.address && device.address.length > 0) {
            rows.push({ label: "Address", value: device.address });
        }

        const attempt = root.attemptFor(device);
        if (attempt && (attempt.phase === "connecting" || attempt.phase === "retrying" || attempt.phase === "waiting" || attempt.phase === "failed" || attempt.phase === "unavailable")) {
            rows.push({ label: "Connection Attempt", value: root.baseStatusText(device, true) });
            rows.push({ label: "Retry", value: Math.max(1, attempt.attempt) + " of " + attempt.maxAttempts });
        }

        rows.push({ label: "Last Update", value: root.relativeTime(root.lastUpdated(device)) });

        return rows;
    }

    function deviceActions(device) {
        if (!device) return [];

        const kind = root.statusKind(device);

        if (kind === "pairing") {
            return [
                { id: "cancel-pair", label: "Cancel Pairing", variant: "secondary", disabled: false },
                { id: "forget", label: "Forget Device", variant: "ghost", disabled: false }
            ];
        }

        if (!device.paired) {
            return [
                { id: "pair", label: "Pair Device", variant: "primary", disabled: false }
            ];
        }

        if (kind === "connecting" || kind === "retrying" || kind === "waiting") {
            return [
                { id: "connecting", label: "Connecting...", variant: "secondary", disabled: true },
                { id: "forget", label: "Forget Device", variant: "ghost", disabled: false }
            ];
        }

        if (kind === "connected") {
            return [
                { id: "disconnect", label: "Disconnect", variant: "secondary", disabled: false },
                { id: "forget", label: "Forget Device", variant: "ghost", disabled: false }
            ];
        }

        if (kind === "failed" || kind === "unavailable" || kind === "paired") {
            return [
                { id: "connect", label: kind === "paired" ? "Connect" : "Retry Connection", variant: "primary", disabled: false },
                { id: "forget", label: "Forget Device", variant: "ghost", disabled: false }
            ];
        }

        return [
            { id: "connect", label: "Connect", variant: "primary", disabled: false }
        ];
    }

    function performAction(actionId, device) {
        if (!device) return;

        switch (actionId) {
        case "pair":
            root.pairDevice(device);
            break;
        case "connect":
            root.startConnect(device, 1, "manual");
            break;
        case "disconnect":
            root.disconnectDevice(device);
            break;
        case "forget":
            root.forgetDevice(device);
            break;
        case "cancel-pair":
            device.cancelPair();
            break;
        default:
            break;
        }
    }

    function findDevice(address) {
        if (!address || !root.devices) return null;
        for (let index = 0; index < root.devices.length; index += 1) {
            if (root.deviceAddress(root.devices[index]) === address) return root.devices[index];
        }
        return null;
    }

    function ensureSelection() {
        if (root.selectedAddress.length > 0 && root.findDevice(root.selectedAddress)) return;
        root.selectedAddress = "";
    }

    function setSelectedDevice(device) {
        root.selectedAddress = root.deviceAddress(device);
        root.touchDevice(device);
    }

    function canReconnect(device) {
        if (!root.bluetoothEnabled || !device) return false;
        if (device.connected || device.pairing || device.blocked) return false;
        return device.paired;
    }

    function startConnect(device, attemptNumber, reason) {
        if (!device || !root.bluetoothEnabled) return false;
        if (!device.paired) {
            root.pairDevice(device);
            return false;
        }

        const address = root.deviceAddress(device);
        const existing = root.attemptMap[address];
        if (existing && (existing.phase === "connecting" || existing.phase === "retrying" || existing.phase === "waiting")) {
            return false;
        }

        const now = root.nowMs();
        if (existing && reason === "auto" && existing.cooldownUntil > now) return false;

        if (!device.trusted) device.trusted = true;

        root.setAttempt(address, {
            phase: attemptNumber > 1 ? "retrying" : "connecting",
            attempt: attemptNumber,
            maxAttempts: root.reconnectMaxAttempts,
            startedAt: now,
            nextRetryAt: 0,
            finishedAt: 0,
            cooldownUntil: 0,
            reason: reason || "manual"
        });
        root.touchDevice(device);
        device.connect();
        return true;
    }

    function pairDevice(device) {
        if (!device) return;

        if (device.paired) {
            root.startConnect(device, 1, "manual");
            return;
        }

        const address = root.deviceAddress(device);
        root.setMapValue("pendingPairMap", address, true, false);
        root.touchDevice(device);
        device.pair();
    }

    function disconnectDevice(device) {
        if (!device) return;
        root.clearAttempt(root.deviceAddress(device));
        root.clearPendingPair(root.deviceAddress(device));
        root.touchDevice(device);
        if (device.connected) device.disconnect();
    }

    function forgetDevice(device) {
        if (!device) return;
        const address = root.deviceAddress(device);
        root.clearAttempt(address);
        root.clearPendingPair(address);
        device.forget();
        if (root.selectedAddress === address) {
            root.selectedAddress = "";
            Qt.callLater(root.ensureSelection);
        }
    }

    function toggleDiscovery() {
        if (!root.adapter || !root.bluetoothEnabled) return;

        if (root.adapter.discovering) {
            root.adapter.discovering = false;
            discoveryStopTimer.stop();
            return;
        }

        root.adapter.pairable = true;
        root.adapter.discovering = true;
        discoveryStopTimer.restart();
    }

    function scheduleReconnectSweep(force) {
        reconnectKick.force = force === true;
        reconnectKick.restart();
    }

    function runReconnectSweep(force) {
        if (!root.bluetoothEnabled) return;

        const candidates = root.devices ? root.devices.slice() : [];
        for (let index = 0; index < candidates.length; index += 1) {
            const device = candidates[index];
            if (!root.canReconnect(device)) continue;

            const address = root.deviceAddress(device);
            const existing = root.attemptMap[address];
            if (!force && existing && (existing.phase === "connecting" || existing.phase === "retrying" || existing.phase === "waiting")) continue;
            root.startConnect(device, 1, "auto");
        }
    }

    Timer {
        id: reconnectKick
        property bool force: false
        interval: 420
        repeat: false
        onTriggered: root.runReconnectSweep(force)
    }

    Timer {
        id: discoveryStopTimer
        interval: 18000
        repeat: false
        onTriggered: {
            if (root.adapter && root.adapter.discovering) {
                root.adapter.discovering = false;
            }
        }
    }

    Timer {
        id: attemptWatcher
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            const now = root.nowMs();
            const seen = {};

            for (let index = 0; index < root.devices.length; index += 1) {
                const device = root.devices[index];
                const address = root.deviceAddress(device);
                seen[address] = true;
                const attempt = root.attemptMap[address];
                if (!attempt) continue;

                if (device.connected || device.state === BluetoothDeviceState.Connected) {
                    root.clearAttempt(address);
                    root.touchDevice(device);
                    continue;
                }

                if (device.blocked) {
                    root.setAttempt(address, {
                        phase: "failed",
                        finishedAt: now,
                        cooldownUntil: now + root.reconnectCooldownMs
                    });
                    root.touchDevice(device);
                    continue;
                }

                if (attempt.phase === "waiting") {
                    if (now >= attempt.nextRetryAt) {
                        root.startConnect(device, Math.min(attempt.attempt + 1, attempt.maxAttempts), attempt.reason);
                    }
                    continue;
                }

                if (attempt.phase !== "connecting" && attempt.phase !== "retrying") continue;

                if (now - attempt.startedAt < root.reconnectTimeoutMs) continue;

                if (attempt.attempt < attempt.maxAttempts) {
                    root.setAttempt(address, {
                        phase: "waiting",
                        nextRetryAt: now + root.reconnectRetryDelayMs,
                        finishedAt: now
                    });
                } else {
                    root.setAttempt(address, {
                        phase: "failed",
                        finishedAt: now,
                        cooldownUntil: now + root.reconnectCooldownMs
                    });
                }
                root.touchDevice(device);
            }

            const attempts = root.attemptMap;
            for (const address in attempts) {
                if (seen[address]) continue;
                root.setAttempt(address, {
                    phase: "unavailable",
                    finishedAt: now,
                    cooldownUntil: now + root.reconnectCooldownMs
                });
            }
        }
    }

    Timer {
        interval: 15000
        repeat: true
        running: true
        onTriggered: root.deviceRevision += 1
    }

    Connections {
        target: root

        function onPanelVisibleChanged() {
            if (root.panelVisible) {
                root.selectedAddress = "";
                root.ensureSelection();
                root.scheduleReconnectSweep(false);
            }
        }

        function onDevicesChanged() {
            for (let index = 0; index < root.devices.length; index += 1) {
                root.touchDevice(root.devices[index]);
            }
            root.ensureSelection();
            if (root.panelVisible) root.scheduleReconnectSweep(false);
        }

        function onAdapterChanged() {
            root.deviceRevision += 1;
            root.ensureSelection();
            if (root.panelVisible) root.scheduleReconnectSweep(true);
        }
    }

    Connections {
        target: root.adapter
        ignoreUnknownSignals: true

        function onEnabledChanged() {
            root.deviceRevision += 1;
            if (root.bluetoothEnabled) root.scheduleReconnectSweep(true);
            else root.attemptMap = ({});
        }

        function onDiscoveringChanged() {
            root.deviceRevision += 1;
        }
    }

    Instantiator {
        model: root.devices

        delegate: Item {
            required property var modelData
            visible: false

            Component.onCompleted: root.touchDevice(modelData)

            Connections {
                target: modelData
                ignoreUnknownSignals: true

                function onConnectedChanged() {
                    root.touchDevice(modelData);
                }

                function onStateChanged() {
                    root.touchDevice(modelData);
                }

                function onPairedChanged() {
                    root.touchDevice(modelData);
                    const address = root.deviceAddress(modelData);
                    if (modelData.paired && root.pendingPairMap[address]) {
                        root.clearPendingPair(address);
                        root.startConnect(modelData, 1, "manual");
                    } else if (!modelData.paired) {
                        root.clearPendingPair(address);
                    }
                }

                function onPairingChanged() {
                    root.touchDevice(modelData);
                }

                function onBatteryChanged() {
                    root.touchDevice(modelData);
                }

                function onTrustedChanged() {
                    root.touchDevice(modelData);
                }

                function onBlockedChanged() {
                    root.touchDevice(modelData);
                }

                function onNameChanged() {
                    root.touchDevice(modelData);
                }
            }
        }
    }

    Component.onCompleted: {
        root.ensureSelection();
        root.scheduleReconnectSweep(true);
    }
}
