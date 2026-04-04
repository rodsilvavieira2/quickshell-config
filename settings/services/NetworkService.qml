pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var deviceStatus: null
    property var wirelessInterfaces: []
    property var ethernetInterfaces: []
    property bool isConnected: false
    property string activeInterface: ""
    property string activeConnection: ""
    property bool networkingEnabled: true
    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running
    property var networks: []
    readonly property var active: networks.find(n => n.active) ?? null
    property list<string> savedConnections: []
    property list<string> savedConnectionSsids: []

    property var wifiConnectionQueue: []
    property int currentSsidQueryIndex: 0
    property var pendingConnection: null
    signal connectionFailed(string ssid)
    property var wirelessDeviceDetails: null
    property var ethernetDeviceDetails: null
    property list<var> ethernetDevices: []
    readonly property var activeEthernet: ethernetDevices.find(d => d.connected) ?? null

    property list<var> activeProcesses: []

    readonly property string deviceTypeWifi: "wifi"
    readonly property string deviceTypeEthernet: "ethernet"
    readonly property string connectionTypeWireless: "802-11-wireless"
    readonly property string nmcliCommandDevice: "device"
    readonly property string nmcliCommandConnection: "connection"
    readonly property string nmcliCommandWifi: "wifi"
    readonly property string nmcliCommandRadio: "radio"
    readonly property string nmcliCommandNetworking: "networking"
    readonly property string deviceStatusFields: "DEVICE,TYPE,STATE,CONNECTION"
    readonly property string connectionListFields: "NAME,TYPE"
    readonly property string wirelessSsidField: "802-11-wireless.ssid"
    readonly property string networkListFields: "SSID,SIGNAL,SECURITY"
    readonly property string networkDetailFields: "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY"
    readonly property string securityKeyMgmt: "802-11-wireless-security.key-mgmt"
    readonly property string securityPsk: "802-11-wireless-security.psk"
    readonly property string keyMgmtWpaPsk: "wpa-psk"
    readonly property string connectionParamType: "type"
    readonly property string connectionParamConName: "con-name"
    readonly property string connectionParamIfname: "ifname"
    readonly property string connectionParamSsid: "ssid"
    readonly property string connectionParamPassword: "password"
    readonly property string connectionParamBssid: "802-11-wireless.bssid"

    function detectPasswordRequired(error: string): bool {
        if (!error || error.length === 0) {
            return false;
        }

        return (error.includes("Secrets were required") || error.includes("Secrets were required, but not provided") || error.includes("No secrets provided") || error.includes("802-11-wireless-security.psk") || error.includes("password for") || (error.includes("password") && !error.includes("Connection activated") && !error.includes("successfully")) || (error.includes("Secrets") && !error.includes("Connection activated") && !error.includes("successfully")) || (error.includes("802.11") && !error.includes("Connection activated") && !error.includes("successfully"))) && !error.includes("Connection activated") && !error.includes("successfully");
    }

    function parseNetworkOutput(output: string): list<var> {
        if (!output || output.length === 0) {
            return [];
        }

        const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
        const rep = new RegExp("\\\\:", "g");
        const rep2 = new RegExp(PLACEHOLDER, "g");

        const allNetworks = output.trim().split("\n").filter(line => line && line.length > 0).map(n => {
            const net = n.replace(rep, PLACEHOLDER).split(":");
            return {
                active: net[0] === "yes",
                strength: parseInt(net[1] || "0", 10) || 0,
                frequency: parseInt(net[2] || "0", 10) || 0,
                ssid: (net[3]?.replace(rep2, ":") ?? "").trim(),
                bssid: (net[4]?.replace(rep2, ":") ?? "").trim(),
                security: (net[5] ?? "").trim()
            };
        }).filter(n => n.ssid && n.ssid.length > 0);

        return allNetworks;
    }

    function deduplicateNetworks(networks: list<var>): list<var> {
        if (!networks || networks.length === 0) {
            return [];
        }

        const networkMap = new Map();
        for (const network of networks) {
            const existing = networkMap.get(network.ssid);
            if (!existing) {
                networkMap.set(network.ssid, network);
            } else {
                if (network.active && !existing.active) {
                    networkMap.set(network.ssid, network);
                } else if (!network.active && !existing.active) {
                    if (network.strength > existing.strength) {
                        networkMap.set(network.ssid, network);
                    }
                }
            }
        }

        return Array.from(networkMap.values());
    }

    function isConnectionCommand(command: list<string>): bool {
        if (!command || command.length === 0) {
            return false;
        }

        return command.includes(root.nmcliCommandWifi) || command.includes(root.nmcliCommandConnection);
    }

    function parseDeviceStatusOutput(output: string, filterType: string): list<var> {
        if (!output || output.length === 0) {
            return [];
        }

        const interfaces = [];
        const lines = output.trim().split("\n");

        for (const line of lines) {
            const parts = line.split(":");
            if (parts.length >= 2) {
                const deviceType = parts[1];
                let shouldInclude = false;

                if (filterType === root.deviceTypeWifi && deviceType === root.deviceTypeWifi) {
                    shouldInclude = true;
                } else if (filterType === root.deviceTypeEthernet && deviceType === root.deviceTypeEthernet) {
                    shouldInclude = true;
                } else if (filterType === "both" && (deviceType === root.deviceTypeWifi || deviceType === root.deviceTypeEthernet)) {
                    shouldInclude = true;
                }

                if (shouldInclude) {
                    interfaces.push({
                        device: parts[0] || "",
                        type: parts[1] || "",
                        state: parts[2] || "",
                        connection: parts[3] || ""
                    });
                }
            }
        }

        return interfaces;
    }

    function isConnectedState(state: string): bool {
        if (!state || state.length === 0) {
            return false;
        }

        return state === "100 (connected)" || state === "connected" || state.startsWith("connected");
    }

    function executeCommand(args: list<string>, callback: var): void {
        const proc = commandProc.createObject(root);
        proc.command = ["nmcli", ...args];
        proc.callback = callback;

        activeProcesses.push(proc);

        proc.processFinished.connect(() => {
            const index = activeProcesses.indexOf(proc);
            if (index >= 0) {
                activeProcesses.splice(index, 1);
            }
        });

        Qt.callLater(() => {
            proc.exec(proc.command);
        });
    }

    function getDeviceStatus(callback: var): void {
        executeCommand(["-t", "-f", root.deviceStatusFields, root.nmcliCommandDevice, "status"], result => {
            if (callback)
                callback(result.output);
        });
    }

    function getNetworkingStatus(callback: var): void {
        executeCommand([root.nmcliCommandNetworking], result => {
            if (result.success) {
                const enabled = result.output.trim() === "enabled";
                root.networkingEnabled = enabled;
                if (callback)
                    callback(enabled);
            } else if (callback) {
                callback(root.networkingEnabled);
            }
        });
    }

    function enableNetworking(enabled: bool, callback: var): void {
        const cmd = enabled ? "on" : "off";
        executeCommand([root.nmcliCommandNetworking, cmd], result => {
            if (result.success) {
                getNetworkingStatus(() => {});
                Qt.callLater(() => {
                    getWifiStatus(() => {});
                    refreshStatus(() => {});
                    getNetworks(() => {});
                    getEthernetInterfaces(() => {});
                });
            }
            if (callback)
                callback(result);
        });
    }

    function toggleNetworking(callback: var): void {
        enableNetworking(!root.networkingEnabled, callback);
    }

    function getWirelessInterfaces(callback: var): void {
        executeCommand(["-t", "-f", root.deviceStatusFields, root.nmcliCommandDevice, "status"], result => {
            const interfaces = parseDeviceStatusOutput(result.output, root.deviceTypeWifi);
            root.wirelessInterfaces = interfaces;
            if (callback)
                callback(interfaces);
        });
    }

    function getEthernetInterfaces(callback: var): void {
        executeCommand(["-t", "-f", root.deviceStatusFields, root.nmcliCommandDevice, "status"], result => {
            const interfaces = parseDeviceStatusOutput(result.output, root.deviceTypeEthernet);
            const devices = [];

            for (const iface of interfaces) {
                const connected = isConnectedState(iface.state);

                devices.push({
                    interface: iface.device,
                    type: iface.type,
                    state: iface.state,
                    connection: iface.connection,
                    connected: connected,
                    ipAddress: "",
                    gateway: "",
                    dns: [],
                    subnet: "",
                    macAddress: "",
                    speed: ""
                });
            }

            root.ethernetInterfaces = interfaces;
            root.ethernetDevices = devices;
            if (callback)
                callback(devices);
        });
    }

    function getWifiStatus(callback: var): void {
        executeCommand([root.nmcliCommandRadio, root.deviceTypeWifi], result => {
            if (result.success) {
                root.wifiEnabled = result.output.trim() === "enabled";
            }
            if (callback)
                callback(root.wifiEnabled);
        });
    }

    function enableWifi(enabled: bool, callback: var): void {
        executeCommand([root.nmcliCommandRadio, root.deviceTypeWifi, enabled ? "on" : "off"], result => {
            if (result.success) {
                getWifiStatus(() => {});
                Qt.callLater(() => {
                    refreshStatus(() => {});
                    getNetworks(() => {});
                });
            }
            if (callback)
                callback(result);
        });
    }

    function getConnectionList(callback: var): void {
        executeCommand(["-t", "-f", root.connectionListFields, root.nmcliCommandConnection, "show"], result => {
            if (callback)
                callback(result.output);
        });
    }

    function getSavedConnections(callback: var): void {
        getConnectionList(output => {
            const connections = [];
            const ssids = [];

            output.trim().split("\n").forEach(line => {
                const parts = line.split(":");
                if (parts.length >= 2 && parts[1] === root.connectionTypeWireless) {
                    connections.push(parts[0]);
                    ssids.push(parts[0]);
                }
            });

            root.savedConnections = connections;
            root.savedConnectionSsids = ssids;
            if (callback)
                callback(connections);
        });
    }

    function hasSavedProfile(ssid: string): bool {
        return root.savedConnectionSsids.includes(ssid);
    }

    function getNetworkDetails(callback: var): void {
        executeCommand(["-t", "-f", root.networkDetailFields, root.nmcliCommandDevice, root.nmcliCommandWifi, "list"], result => {
            const parsed = deduplicateNetworks(parseNetworkOutput(result.output));
            root.networks = parsed;
            if (callback)
                callback(parsed);
        });
    }

    function getNetworks(callback: var): void {
        getSavedConnections(() => {
            getNetworkDetails(callback);
        });
    }

    function rescanWifi(): void {
        rescanProc.running = true;
    }

    function refreshStatus(callback: var): void {
        getDeviceStatus(output => {
            const interfaces = parseDeviceStatusOutput(output, "both");
            root.deviceStatus = interfaces;

            const active = interfaces.find(iface => isConnectedState(iface.state));
            root.isConnected = !!active;
            root.activeInterface = active ? active.device : "";
            root.activeConnection = active ? active.connection : "";

            if (callback)
                callback(interfaces);
        });
    }

    function connectToNetwork(ssid: string, password: string, bssid: string, callback: var): void {
        const args = [root.nmcliCommandDevice, root.nmcliCommandWifi, "connect", ssid];
        if (password && password.length > 0) {
            args.push("password", password);
        }
        if (bssid && bssid.length > 0) {
            args.push(root.connectionParamBssid, bssid);
        }

        executeCommand(args, callback);
    }

    function connectToNetworkWithPasswordCheck(ssid: string, secure: bool, callback: var, bssid: string): void {
        const args = [root.nmcliCommandDevice, root.nmcliCommandWifi, "connect", ssid];
        if (bssid && bssid.length > 0) {
            args.push(root.connectionParamBssid, bssid);
        }

        executeCommand(args, result => {
            if (!result.success && secure && detectPasswordRequired(result.error || result.output || "")) {
                callback({
                    success: false,
                    needsPassword: true,
                    error: result.error || result.output || ""
                });
                return;
            }

            callback(result);
        });
    }

    function disconnectFromNetwork(): void {
        executeCommand([root.nmcliCommandConnection, "down", root.activeConnection], () => {});
    }

    function connectEthernet(connectionName: string, interfaceName: string, callback: var): void {
        if (connectionName && connectionName.length > 0) {
            executeCommand([root.nmcliCommandConnection, "up", connectionName], callback);
        } else {
            callback({
                success: false,
                error: "No Ethernet connection profile found for " + interfaceName + "."
            });
        }
    }

    function disconnectEthernet(connectionName: string, callback: var): void {
        executeCommand([root.nmcliCommandConnection, "down", connectionName], callback);
    }

    function bringInterfaceDown(interfaceName: string, callback: var): void {
        executeCommand([root.nmcliCommandDevice, "disconnect", interfaceName], callback);
    }

    Component.onCompleted: {
        getNetworkingStatus(() => {});
        getWifiStatus(() => {});
        refreshStatus(() => {});
        getNetworks(() => {});
        getEthernetInterfaces(() => {});
    }

    Process {
        id: rescanProc
        running: false
        command: ["nmcli", root.nmcliCommandDevice, root.nmcliCommandWifi, "rescan"]
        onExited: {
            getNetworks(() => {});
        }
    }

    component CommandProcess: Process {
        property var callback: null
        property var command: []
        signal processFinished()

        stdout: StdioCollector {
            id: stdoutCollector
        }

        stderr: StdioCollector {
            id: stderrCollector
        }

        function exec(args) {
            command = args;
            running = true;
        }

        onExited: exitCode => {
            if (callback) {
                callback({
                    success: exitCode === 0,
                    exitCode: exitCode,
                    output: stdoutCollector.text.trim(),
                    error: stderrCollector.text.trim()
                });
            }
            processFinished();
            destroy();
        }
    }

    Component {
        id: commandProc

        CommandProcess {}
    }
}
