import QtQuick
import QtCore
import Quickshell
import Quickshell.Bluetooth

Item {
    id: root

    readonly property var bluetoothService: Bluetooth
    readonly property var adapter: bluetoothService.defaultAdapter ?? null
    readonly property string lastConnectedAddress: persisted.lastConnectedAddress
    readonly property string lastConnectedName: persisted.lastConnectedName

    property bool restoreAttempted: false
    property bool reconnectInFlight: false
    property bool fallbackScanUsed: false
    property double reconnectStartedAt: 0
    property string restoreStatus: "Idle"

    readonly property int reconnectTimeoutMs: 7000
    readonly property int fallbackScanDurationMs: 12000
    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/quickshell/bluetooth-session.ini"
    readonly property url settingsLocation: "file://" + settingsPath

    Settings {
        id: persisted
        location: root.settingsLocation
        category: "settings-bluetooth-session"
        property string lastConnectedAddress: ""
        property string lastConnectedName: ""
    }

    function deviceArray() {
        const list = bluetoothService.devices?.values ?? [];
        const devices = [];
        for (let index = 0; index < list.length; index++) {
            devices.push(list[index]);
        }
        return devices;
    }

    function deviceLabel(device) {
        return device?.name || device?.deviceName || device?.address || "Unknown device";
    }

    function findRememberedDevice() {
        if (!persisted.lastConnectedAddress || persisted.lastConnectedAddress.length === 0) {
            return null;
        }

        return deviceArray().find(device => device?.address === persisted.lastConnectedAddress) ?? null;
    }

    function rememberDevice(device) {
        const address = device?.address ?? "";
        if (!address || address.length === 0) {
            return;
        }

        persisted.lastConnectedAddress = address;
        persisted.lastConnectedName = deviceLabel(device);
        restoreStatus = "Remembering " + persisted.lastConnectedName;
    }

    function clearRememberedDevice(address) {
        if (address && persisted.lastConnectedAddress !== address) {
            return;
        }

        persisted.lastConnectedAddress = "";
        persisted.lastConnectedName = "";
        restoreStatus = "Bluetooth idle";
    }

    function connectDevice(device) {
        if (!device) {
            return;
        }

        if (!device.paired && device.pair) {
            device.pair();
        }

        if (device.connect) {
            device.connect();
        } else {
            device.connected = true;
        }
    }

    function stopDiscovery() {
        if (adapter?.discovering) {
            adapter.discovering = false;
        }
        scanStopTimer.stop();
    }

    function startFallbackScan() {
        if (!adapter || !adapter.enabled) {
            return;
        }

        fallbackScanUsed = true;
        reconnectInFlight = false;
        restoreStatus = "Scanning for " + (persisted.lastConnectedName || persisted.lastConnectedAddress);
        adapter.discovering = true;
        scanStopTimer.restart();
    }

    function attemptRestore() {
        if (!adapter) {
            restoreStatus = "Waiting for Bluetooth adapter";
            return;
        }

        if (!restoreAttempted) {
            restoreAttempted = true;
        }

        if (!adapter.enabled) {
            adapter.enabled = true;
            restoreStatus = "Enabling Bluetooth";
            return;
        }

        if (!persisted.lastConnectedAddress || persisted.lastConnectedAddress.length === 0) {
            restoreStatus = "No remembered Bluetooth device";
            return;
        }

        const device = findRememberedDevice();
        if (!device) {
            startFallbackScan();
            return;
        }

        if (device.connected) {
            rememberDevice(device);
            reconnectInFlight = false;
            fallbackScanUsed = false;
            stopDiscovery();
            restoreStatus = "Connected to " + deviceLabel(device);
            return;
        }

        reconnectInFlight = true;
        fallbackScanUsed = false;
        reconnectStartedAt = Date.now();
        restoreStatus = "Reconnecting to " + deviceLabel(device);
        connectDevice(device);
    }

    function captureConnectedDevices() {
        const connectedDevice = deviceArray().find(device => device?.connected) ?? null;

        if (connectedDevice) {
            rememberDevice(connectedDevice);

            if (reconnectInFlight) {
                reconnectInFlight = false;
                fallbackScanUsed = false;
                stopDiscovery();
                restoreStatus = "Connected to " + deviceLabel(connectedDevice);
            }
            return;
        }

        if (reconnectInFlight && Date.now() - reconnectStartedAt >= reconnectTimeoutMs) {
            startFallbackScan();
            return;
        }

        if (fallbackScanUsed && adapter?.discovering) {
            const rememberedDevice = findRememberedDevice();
            if (rememberedDevice && !rememberedDevice.connected) {
                reconnectInFlight = true;
                reconnectStartedAt = Date.now();
                restoreStatus = "Reconnecting to " + deviceLabel(rememberedDevice);
                connectDevice(rememberedDevice);
            }
        }
    }

    Timer {
        id: startupTimer
        interval: 1500
        repeat: false
        onTriggered: root.attemptRestore()
    }

    Timer {
        id: pollTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.captureConnectedDevices();

            if (!root.restoreAttempted && root.adapter) {
                root.attemptRestore();
            }
        }
    }

    Timer {
        id: scanStopTimer
        interval: root.fallbackScanDurationMs
        repeat: false
        onTriggered: {
            root.stopDiscovery();
            const rememberedDevice = root.findRememberedDevice();
            if (!rememberedDevice || !rememberedDevice.connected) {
                root.restoreStatus = "Bluetooth idle";
            }
        }
    }

    Connections {
        target: bluetoothService

        function onDefaultAdapterChanged() {
            if (!root.restoreAttempted) {
                startupTimer.restart();
            }
        }
    }

    Component.onCompleted: startupTimer.start()
}
