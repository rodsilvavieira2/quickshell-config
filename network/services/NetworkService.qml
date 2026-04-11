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
    readonly property bool airplaneModeEnabled: !networkingEnabled
    readonly property bool scanning: rescanProc.running
    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: {
        const activeNetwork = networks.find(function(n) { return n.active; });
        return activeNetwork ? activeNetwork : null;
    }
    property list<string> savedConnections: []
    property list<string> savedConnectionSsids: []
    property list<var> savedWifiProfiles: []

    property var wifiConnectionQueue: []
    property int currentSsidQueryIndex: 0
    property var pendingConnection: null
    signal connectionFailed(string ssid)
    property var wirelessDeviceDetails: null
    property var ethernetDeviceDetails: null
    property list<var> ethernetDevices: []
    readonly property var activeEthernet: {
        const activeDevice = ethernetDevices.find(function(d) { return d.connected; });
        return activeDevice ? activeDevice : null;
    }
    property list<var> vpnProfiles: []
    readonly property var activeVpn: {
        const activeProfile = vpnProfiles.find(function(profile) { return profile.active; });
        return activeProfile ? activeProfile : null;
    }
    property var hotspotState: ({
            enabled: false,
            profileName: "",
            interfaceName: "",
            ssid: "Desktop Hotspot",
            password: "",
            band: "dual",
            clients: -1
        })
    property string proxyMode: "none"
    property string proxyPacUrl: ""
    property string proxyHttpHost: ""
    property int proxyHttpPort: 8080
    property string proxyHttpsHost: ""
    property int proxyHttpsPort: 0
    property string proxySocksHost: ""
    property int proxySocksPort: 0
    property string proxyBypassList: "localhost,127.0.0.1,::1"
    property bool proxyUseSameProxy: true

    property list<var> activeProcesses: []

    // Constants
    readonly property string deviceTypeWifi: "wifi"
    readonly property string deviceTypeEthernet: "ethernet"
    readonly property string connectionTypeWireless: "802-11-wireless"
    readonly property string connectionTypeVpn: "vpn"
    readonly property string nmcliCommandDevice: "device"
    readonly property string nmcliCommandConnection: "connection"
    readonly property string nmcliCommandWifi: "wifi"
    readonly property string nmcliCommandRadio: "radio"
    readonly property string nmcliCommandNetworking: "networking"
    readonly property string deviceStatusFields: "DEVICE,TYPE,STATE,CONNECTION"
    readonly property string connectionListFields: "NAME,TYPE,AUTOCONNECT,TIMESTAMP"
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
    readonly property string proxySchema: "org.gnome.system.proxy"

    function executeProgram(command: list<string>, callback: var): void {
        const proc = commandProc.createObject(root);
        proc.command = command;
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
                ssid: ((net.length > 3 && net[3]) ? net[3].replace(rep2, ":") : "").trim(),
                bssid: ((net.length > 4 && net[4]) ? net[4].replace(rep2, ":") : "").trim(),
                security: (net.length > 5 && net[5] ? net[5] : "").trim()
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
        executeProgram(["nmcli", ...args], callback);
    }

    function executeGsettings(args: list<string>, callback: var): void {
        executeProgram(["gsettings", ...args], callback);
    }

    function activeConnectionKind(): string {
        if (!networkingEnabled) {
            return "disabled";
        }

        if (active && active.ssid) {
            return "wifi";
        }

        if (activeEthernet && activeEthernet.connected) {
            return "ethernet";
        }

        return "offline";
    }

    function signalLabel(strength: int): string {
        if (strength >= 85) return "Excellent";
        if (strength >= 65) return "Strong";
        if (strength >= 45) return "Good";
        if (strength >= 25) return "Fair";
        if (strength > 0) return "Weak";
        return "Unknown";
    }

    function frequencyBandLabel(frequency: int): string {
        if (frequency >= 5925) return "6 GHz";
        if (frequency >= 4900) return "5 GHz";
        if (frequency >= 2400) return "2.4 GHz";
        return "";
    }

    function securityLabel(security: string): string {
        if (!security || security.length === 0) return "Open";
        if (security.indexOf("WPA3") >= 0) return "WPA3";
        if (security.indexOf("WPA2") >= 0) return "WPA2";
        if (security.indexOf("WPA1") >= 0 || security.indexOf("WPA") >= 0) return "WPA/WPA2";
        if (security.indexOf("802.1X") >= 0) return "Enterprise";
        return security;
    }

    function formatTimestamp(timestampSeconds: int): string {
        if (!timestampSeconds || timestampSeconds <= 0) {
            return "Never";
        }

        const deltaSeconds = Math.max(0, Math.floor(Date.now() / 1000) - timestampSeconds);
        if (deltaSeconds < 60) return "Just now";

        const deltaMinutes = Math.floor(deltaSeconds / 60);
        if (deltaMinutes < 60) return deltaMinutes === 1 ? "1 minute ago" : deltaMinutes + " minutes ago";

        const deltaHours = Math.floor(deltaMinutes / 60);
        if (deltaHours < 24) return deltaHours === 1 ? "1 hour ago" : deltaHours + " hours ago";

        const deltaDays = Math.floor(deltaHours / 24);
        if (deltaDays < 30) return deltaDays === 1 ? "1 day ago" : deltaDays + " days ago";

        const deltaMonths = Math.floor(deltaDays / 30);
        if (deltaMonths < 12) return deltaMonths === 1 ? "1 month ago" : deltaMonths + " months ago";

        const deltaYears = Math.floor(deltaMonths / 12);
        return deltaYears === 1 ? "1 year ago" : deltaYears + " years ago";
    }

    function joinedDns(details: var): string {
        if (!details || !details.dns || details.dns.length === 0) {
            return "Automatic";
        }

        return details.dns.join(", ");
    }

    function overviewStatusKind(): string {
        if (!networkingEnabled) return "warning";
        if (active && active.ssid) return "success";
        if (activeEthernet && activeEthernet.connected) return "success";
        if (hotspotState.enabled) return "info";
        return "warning";
    }

    function overviewTitle(): string {
        if (!networkingEnabled) return "Airplane mode is on";
        if (active && active.ssid) return "Network connected";
        if (activeEthernet && activeEthernet.connected) return "Ethernet connected";
        if (hotspotState.enabled) return "Hotspot is active";
        return "No active network connection";
    }

    function overviewMessage(): string {
        if (!networkingEnabled) {
            return "Wireless and wired networking are paused. Turn airplane mode off to reconnect.";
        }

        if (active && active.ssid) {
            return "A managed network connection is active on this system.";
        }

        if (activeEthernet && activeEthernet.connected) {
            const speed = ethernetDeviceDetails && ethernetDeviceDetails.speed ? ethernetDeviceDetails.speed : activeEthernet.speed;
            return speed && speed.length > 0 ? speed + "." : "Wired link ready.";
        }

        if (hotspotState.enabled) {
            return "This desktop is currently sharing its connection through hotspot mode.";
        }

        return "Connect Ethernet or enable hotspot sharing when you need network access.";
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
                callback(interfaces);
        });
    }

    function connectEthernet(connectionName: string, interfaceName: string, callback: var): void {
        if (connectionName && connectionName.length > 0) {
            executeCommand([root.nmcliCommandConnection, "up", connectionName], result => {
                if (result.success) {
                    Qt.callLater(() => {
                        getEthernetInterfaces(() => {});
                        if (interfaceName && interfaceName.length > 0) {
                            Qt.callLater(() => {
                                getEthernetDeviceDetails(interfaceName, () => {});
                            }, 1000);
                        }
                    }, 500);
                }
                if (callback)
                    callback(result);
            });
        } else if (interfaceName && interfaceName.length > 0) {
            executeCommand([root.nmcliCommandDevice, "connect", interfaceName], result => {
                if (result.success) {
                    Qt.callLater(() => {
                        getEthernetInterfaces(() => {});
                        Qt.callLater(() => {
                            getEthernetDeviceDetails(interfaceName, () => {});
                        }, 1000);
                    }, 500);
                }
                if (callback)
                    callback(result);
            });
        } else {
            if (callback)
                callback({
                    success: false,
                    output: "",
                    error: "No connection name or interface specified",
                    exitCode: -1
                });
        }
    }

    function disconnectEthernet(connectionName: string, callback: var): void {
        if (!connectionName || connectionName.length === 0) {
            if (callback)
                callback({
                    success: false,
                    output: "",
                    error: "No connection name specified",
                    exitCode: -1
                });
            return;
        }

        executeCommand([root.nmcliCommandConnection, "down", connectionName], result => {
            if (result.success) {
                root.ethernetDeviceDetails = null;
                Qt.callLater(() => {
                    getEthernetInterfaces(() => {});
                }, 500);
            }
            if (callback)
                callback(result);
        });
    }

    function getAllInterfaces(callback: var): void {
        executeCommand(["-t", "-f", root.deviceStatusFields, root.nmcliCommandDevice, "status"], result => {
            const interfaces = parseDeviceStatusOutput(result.output, "both");
            if (callback)
                callback(interfaces);
        });
    }

    function isInterfaceConnected(interfaceName: string, callback: var): void {
        executeCommand([root.nmcliCommandDevice, "status"], result => {
            const lines = result.output.trim().split("\n");
            for (const line of lines) {
                const parts = line.split(/\s+/);
                if (parts.length >= 3 && parts[0] === interfaceName) {
                    const connected = isConnectedState(parts[2]);
                    if (callback)
                        callback(connected);
                    return;
                }
            }
            if (callback)
                callback(false);
        });
    }

    function connectToNetworkWithPasswordCheck(ssid: string, isSecure: bool, callback: var, bssid: string): void {
        if (isSecure) {
            const hasBssid = bssid !== undefined && bssid !== null && bssid.length > 0;
            connectWireless(ssid, "", bssid, result => {
                if (result.success) {
                    if (callback)
                        callback({
                            success: true,
                            usedSavedPassword: true,
                            output: result.output,
                            error: "",
                            exitCode: 0
                        });
                } else if (result.needsPassword) {
                    if (callback)
                        callback({
                            success: false,
                            needsPassword: true,
                            output: result.output,
                            error: result.error,
                            exitCode: result.exitCode
                        });
                } else {
                    if (callback)
                        callback(result);
                }
            });
        } else {
            connectWireless(ssid, "", bssid, callback);
        }
    }

    function connectToNetwork(ssid: string, password: string, bssid: string, callback: var): void {
        connectWireless(ssid, password, bssid, callback);
    }

    function connectWireless(ssid: string, password: string, bssid: string, callback: var, retryCount: int): void {
        const hasBssid = bssid !== undefined && bssid !== null && bssid.length > 0;
        const retries = retryCount !== undefined ? retryCount : 0;
        const maxRetries = 2;

        if (callback) {
            root.pendingConnection = {
                ssid: ssid,
                bssid: hasBssid ? bssid : "",
                callback: callback,
                retryCount: retries
            };
            connectionCheckTimer.start();
            immediateCheckTimer.checkCount = 0;
            immediateCheckTimer.start();
        }

        if (password && password.length > 0 && hasBssid) {
            const bssidUpper = bssid.toUpperCase();
            createConnectionWithPassword(ssid, bssidUpper, password, callback);
            return;
        }

        let cmd = [root.nmcliCommandDevice, root.nmcliCommandWifi, "connect", ssid];
        if (password && password.length > 0) {
            cmd.push(root.connectionParamPassword, password);
        }
        executeCommand(cmd, result => {
            if (result.needsPassword && callback) {
                if (callback)
                    callback(result);
                return;
            }

            if (!result.success && root.pendingConnection && retries < maxRetries) {
                console.warn("[NMCLI] Connection failed, retrying... (attempt " + (retries + 1) + "/" + maxRetries + ")");
                Qt.callLater(() => {
                    connectWireless(ssid, password, bssid, callback, retries + 1);
                }, 1000);
            } else if (!result.success && root.pendingConnection) {} else if (result.success && callback) {} else if (!result.success && !root.pendingConnection) {
                if (callback)
                    callback(result);
            }
        });
    }

    function createConnectionWithPassword(ssid: string, bssidUpper: string, password: string, callback: var): void {
        checkAndDeleteConnection(ssid, () => {
            const cmd = [root.nmcliCommandConnection, "add", root.connectionParamType, root.deviceTypeWifi, root.connectionParamConName, ssid, root.connectionParamIfname, "*", root.connectionParamSsid, ssid, root.connectionParamBssid, bssidUpper, root.securityKeyMgmt, root.keyMgmtWpaPsk, root.securityPsk, password];

            executeCommand(cmd, result => {
                if (result.success) {
                    loadSavedConnections(() => {});
                    activateConnection(ssid, callback);
                } else {
                    const hasDuplicateWarning = result.error && (result.error.includes("another connection with the name") || result.error.includes("Reference the connection by its uuid"));

                    if (hasDuplicateWarning || (result.exitCode > 0 && result.exitCode < 10)) {
                        loadSavedConnections(() => {});
                        activateConnection(ssid, callback);
                    } else {
                        console.warn("[NMCLI] Connection profile creation failed, trying fallback...");
                        let fallbackCmd = [root.nmcliCommandDevice, root.nmcliCommandWifi, "connect", ssid, root.connectionParamPassword, password];
                        executeCommand(fallbackCmd, fallbackResult => {
                            if (callback)
                                callback(fallbackResult);
                        });
                    }
                }
            });
        });
    }

    function checkAndDeleteConnection(ssid: string, callback: var): void {
        executeCommand([root.nmcliCommandConnection, "show", ssid], result => {
            if (result.success) {
                executeCommand([root.nmcliCommandConnection, "delete", ssid], deleteResult => {
                    Qt.callLater(() => {
                        if (callback)
                            callback();
                    }, 300);
                });
            } else {
                if (callback)
                    callback();
            }
        });
    }

    function activateConnection(connectionName: string, callback: var): void {
        executeCommand([root.nmcliCommandConnection, "up", connectionName], result => {
            if (callback)
                callback(result);
        });
    }

    function loadSavedConnections(callback: var): void {
        executeCommand(["-t", "-f", root.connectionListFields, root.nmcliCommandConnection, "show"], result => {
            if (!result.success) {
                root.savedConnections = [];
                root.savedConnectionSsids = [];
                if (callback)
                    callback([]);
                return;
            }

            parseConnectionList(result.output, callback);
        });
    }

    function parseConnectionList(output: string, callback: var): void {
        const lines = output.trim().split("\n").filter(line => line.length > 0);
        const wifiConnections = [];
        const connections = [];

        for (const line of lines) {
            const parts = line.split(":");
            if (parts.length >= 2) {
                const name = parts[0];
                const type = parts[1];
                const autoConnect = parts.length > 2 ? parts[2] === "yes" : false;
                const timestamp = parts.length > 3 ? parseInt(parts[3] || "0", 10) || 0 : 0;
                connections.push(name);

                if (type === root.connectionTypeWireless) {
                    wifiConnections.push({
                        name: name,
                        type: type,
                        autoConnect: autoConnect,
                        timestamp: timestamp
                    });
                }
            }
        }

        root.savedConnections = connections;

        if (wifiConnections.length > 0) {
            root.wifiConnectionQueue = wifiConnections;
            root.currentSsidQueryIndex = 0;
            root.savedConnectionSsids = [];
            root.savedWifiProfiles = [];
            queryNextSsid(callback);
        } else {
            root.savedConnectionSsids = [];
            root.savedWifiProfiles = [];
            root.wifiConnectionQueue = [];
            if (callback)
                callback(root.savedWifiProfiles);
        }
    }

    function queryNextSsid(callback: var): void {
        if (root.currentSsidQueryIndex < root.wifiConnectionQueue.length) {
            const connectionInfo = root.wifiConnectionQueue[root.currentSsidQueryIndex];
            root.currentSsidQueryIndex++;

            executeCommand(["-t", "-f", root.wirelessSsidField + "," + root.securityKeyMgmt, root.nmcliCommandConnection, "show", connectionInfo.name], result => {
                if (result.success) {
                    processSsidOutput(connectionInfo, result.output);
                }
                queryNextSsid(callback);
            });
        } else {
            root.wifiConnectionQueue = [];
            root.currentSsidQueryIndex = 0;
            if (callback)
                callback(root.savedWifiProfiles);
        }
    }

    function processSsidOutput(connectionInfo: var, output: string): void {
        let ssid = "";
        let security = "";
        const lines = output.trim().split("\n");
        for (const line of lines) {
            if (line.startsWith("802-11-wireless.ssid:")) {
                ssid = line.substring("802-11-wireless.ssid:".length).trim();
            } else if (line.startsWith(root.securityKeyMgmt + ":")) {
                security = line.substring((root.securityKeyMgmt + ":").length).trim();
            }
        }

        if (!ssid || ssid.length === 0) {
            return;
        }

        const ssidLower = ssid.toLowerCase();
        const exists = root.savedConnectionSsids.some(s => s && s.toLowerCase() === ssidLower);
        if (!exists) {
            const newList = root.savedConnectionSsids.slice();
            newList.push(ssid);
            root.savedConnectionSsids = newList;
        }

        const profiles = root.savedWifiProfiles.slice();
        profiles.push({
            name: connectionInfo.name,
            ssid: ssid,
            security: security,
            autoConnect: connectionInfo.autoConnect,
            timestamp: connectionInfo.timestamp,
            lastConnectedLabel: formatTimestamp(connectionInfo.timestamp)
        });
        profiles.sort((left, right) => {
            if (left.timestamp !== right.timestamp) {
                return right.timestamp - left.timestamp;
            }

            return left.ssid.localeCompare(right.ssid);
        });
        root.savedWifiProfiles = profiles;
    }

    function hasSavedProfile(ssid: string): bool {
        if (!ssid || ssid.length === 0) {
            return false;
        }
        const ssidLower = ssid.toLowerCase().trim();

        if (root.active && root.active.ssid) {
            const activeSsidLower = root.active.ssid.toLowerCase().trim();
            if (activeSsidLower === ssidLower) {
                return true;
            }
        }

        const hasSsid = root.savedConnectionSsids.some(savedSsid => savedSsid && savedSsid.toLowerCase().trim() === ssidLower);

        if (hasSsid) {
            return true;
        }

        const hasConnectionName = root.savedConnections.some(connName => connName && connName.toLowerCase().trim() === ssidLower);

        return hasConnectionName;
    }

    function forgetNetwork(ssid: string, callback: var): void {
        if (!ssid || ssid.length === 0) {
            if (callback)
                callback({
                    success: false,
                    output: "",
                    error: "No SSID specified",
                    exitCode: -1
                });
            return;
        }

        const connectionName = root.savedConnections.find(conn => conn && conn.toLowerCase().trim() === ssid.toLowerCase().trim()) || ssid;

        executeCommand([root.nmcliCommandConnection, "delete", connectionName], result => {
            if (result.success) {
                Qt.callLater(() => {
                    loadSavedConnections(() => {});
                }, 500);
            }
            if (callback)
                callback(result);
        });
    }

    function disconnect(interfaceName: string, callback: var): void {
        if (interfaceName && interfaceName.length > 0) {
            executeCommand([root.nmcliCommandDevice, "disconnect", interfaceName], result => {
                if (callback)
                    callback(result.success ? result.output : "");
            });
        } else {
            executeCommand([root.nmcliCommandDevice, "disconnect", root.deviceTypeWifi], result => {
                if (callback)
                    callback(result.success ? result.output : "");
            });
        }
    }

    function disconnectFromNetwork(): void {
        if (active && active.ssid) {
            executeCommand([root.nmcliCommandConnection, "down", active.ssid], result => {
                if (result.success) {
                    getNetworks(() => {});
                }
            });
        } else {
            executeCommand([root.nmcliCommandDevice, "disconnect", root.deviceTypeWifi], result => {
                if (result.success) {
                    getNetworks(() => {});
                }
            });
        }
    }

    function getDeviceDetails(interfaceName: string, callback: var): void {
        executeCommand([root.nmcliCommandDevice, "show", interfaceName], result => {
            if (callback)
                callback(result.output);
        });
    }

    function refreshStatus(callback: var): void {
        getNetworkingStatus(() => {
            getDeviceStatus(output => {
                const lines = output.trim().split("\n");
                let connected = false;
                let activeIf = "";
                let activeConn = "";

                for (const line of lines) {
                    const parts = line.split(":");
                    if (parts.length >= 4) {
                        const state = parts[2] || "";
                        if (isConnectedState(state)) {
                            connected = true;
                            activeIf = parts[0] || "";
                            activeConn = parts[3] || "";
                            break;
                        }
                    }
                }

                root.isConnected = connected;
                root.activeInterface = activeIf;
                root.activeConnection = activeConn;

                if (callback)
                    callback({
                        connected,
                        interface: activeIf,
                        connection: activeConn
                    });
            });
        });
    }

    function bringInterfaceUp(interfaceName: string, callback: var): void {
        if (interfaceName && interfaceName.length > 0) {
            executeCommand([root.nmcliCommandDevice, "connect", interfaceName], result => {
                if (callback) {
                    callback(result);
                }
            });
        } else {
            if (callback)
                callback({
                    success: false,
                    output: "",
                    error: "No interface specified",
                    exitCode: -1
                });
        }
    }

    function bringInterfaceDown(interfaceName: string, callback: var): void {
        if (interfaceName && interfaceName.length > 0) {
            executeCommand([root.nmcliCommandDevice, "disconnect", interfaceName], result => {
                if (callback) {
                    callback(result);
                }
            });
        } else {
            if (callback)
                callback({
                    success: false,
                    output: "",
                    error: "No interface specified",
                    exitCode: -1
                });
        }
    }

    function scanWirelessNetworks(interfaceName: string, callback: var): void {
        let cmd = [root.nmcliCommandDevice, root.nmcliCommandWifi, "rescan"];
        if (interfaceName && interfaceName.length > 0) {
            cmd.push(root.connectionParamIfname, interfaceName);
        }
        executeCommand(cmd, result => {
            if (callback) {
                callback(result);
            }
        });
    }

    function rescanWifi(): void {
        rescanProc.running = true;
    }

    function enableWifi(enabled: bool, callback: var): void {
        const cmd = enabled ? "on" : "off";
        executeCommand([root.nmcliCommandRadio, root.nmcliCommandWifi, cmd], result => {
            if (result.success) {
                getWifiStatus(status => {
                    root.wifiEnabled = status;
                    if (callback)
                        callback(result);
                });
            } else {
                if (callback)
                    callback(result);
            }
        });
    }

    function toggleWifi(callback: var): void {
        const newState = !root.wifiEnabled;
        enableWifi(newState, callback);
    }

    function getWifiStatus(callback: var): void {
        executeCommand([root.nmcliCommandRadio, root.nmcliCommandWifi], result => {
            if (result.success) {
                const enabled = result.output.trim() === "enabled";
                root.wifiEnabled = enabled;
                if (callback)
                    callback(enabled);
            } else {
                if (callback)
                    callback(root.wifiEnabled);
            }
        });
    }

    function getNetworks(callback: var): void {
        executeCommand(["-g", root.networkDetailFields, "d", "w"], result => {
            if (!result.success) {
                if (callback)
                    callback([]);
                return;
            }

            const allNetworks = parseNetworkOutput(result.output);
            const networks = deduplicateNetworks(allNetworks);
            const rNetworks = root.networks;

            const destroyed = rNetworks.filter(rn => !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
            for (const network of destroyed) {
                const index = rNetworks.indexOf(network);
                if (index >= 0) {
                    rNetworks.splice(index, 1);
                    network.destroy();
                }
            }

            for (const network of networks) {
                const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                if (match) {
                    match.lastIpcObject = network;
                } else {
                    rNetworks.push(apComp.createObject(root, {
                        lastIpcObject: network
                    }));
                }
            }

            if (callback)
                callback(root.networks);
            checkPendingConnection();
        });
    }

    function getWirelessSSIDs(interfaceName: string, callback: var): void {
        let cmd = ["-t", "-f", root.networkListFields, root.nmcliCommandDevice, root.nmcliCommandWifi, "list"];
        if (interfaceName && interfaceName.length > 0) {
            cmd.push(root.connectionParamIfname, interfaceName);
        }
        executeCommand(cmd, result => {
            if (!result.success) {
                if (callback)
                    callback([]);
                return;
            }

            const ssids = [];
            const lines = result.output.trim().split("\n");
            const seenSSIDs = new Set();

            for (const line of lines) {
                if (!line || line.length === 0)
                    continue;

                const parts = line.split(":");
                if (parts.length >= 1) {
                    const ssid = parts[0].trim();
                    if (ssid && ssid.length > 0 && !seenSSIDs.has(ssid)) {
                        seenSSIDs.add(ssid);
                        const signalStr = parts.length >= 2 ? parts[1].trim() : "";
                        const signal = signalStr ? parseInt(signalStr, 10) : 0;
                        const security = parts.length >= 3 ? parts[2].trim() : "";
                        ssids.push({
                            ssid: ssid,
                            signal: signalStr,
                            signalValue: isNaN(signal) ? 0 : signal,
                            security: security
                        });
                    }
                }
            }

            ssids.sort((a, b) => {
                return b.signalValue - a.signalValue;
            });

            if (callback)
                callback(ssids);
        });
    }

    function wifiStatusText(): string {
        if (!networkingEnabled) return "Airplane mode on";
        if (!wifiEnabled) return "Wi-Fi off";
        if (active && active.ssid) {
            return "Connected to " + active.ssid + " • " + signalLabel(active.strength);
        }

        return "Wi-Fi on • Not connected";
    }

    function ethernetStatusText(): string {
        if (!networkingEnabled) return "Disabled";
        if (activeEthernet && activeEthernet.connected) {
            const speed = ethernetDeviceDetails && ethernetDeviceDetails.speed ? ethernetDeviceDetails.speed : activeEthernet.speed;
            return speed && speed.length > 0 ? "Connected • " + speed : "Connected";
        }

        return ethernetInterfaces.length > 0 ? "Cable unplugged" : "Ethernet inactive";
    }

    function vpnStatusText(): string {
        if (activeVpn && activeVpn.active) {
            return "Connected to " + activeVpn.name;
        }

        return vpnProfiles.length > 0 ? "VPN off" : "No VPN profiles";
    }

    function hotspotStatusText(): string {
        if (hotspotState.enabled) {
            return hotspotState.clients >= 0
                ? "Hotspot on • " + hotspotState.clients + " devices connected"
                : "Hotspot on";
        }

        return "Hotspot off";
    }

    function proxyStatusText(): string {
        switch (proxyMode) {
        case "auto":
            return proxyPacUrl && proxyPacUrl.length > 0 ? "Automatic • PAC URL configured" : "Automatic";
        case "manual":
            return proxyHttpHost && proxyHttpHost.length > 0
                ? "Manual • " + proxyHttpHost + ":" + proxyHttpPort
                : "Manual";
        default:
            return "Disabled";
        }
    }

    function renewDhcpLease(interfaceName: string, callback: var): void {
        if (!interfaceName || interfaceName.length === 0) {
            if (callback) {
                callback({
                    success: false,
                    output: "",
                    error: "No interface specified",
                    exitCode: -1
                });
            }
            return;
        }

        executeCommand([root.nmcliCommandDevice, "reapply", interfaceName], result => {
            if (result.success) {
                Qt.callLater(() => {
                    getWirelessDeviceDetails(interfaceName, () => {});
                    getEthernetDeviceDetails(interfaceName, () => {});
                });
            }

            if (callback) {
                callback(result);
            }
        });
    }

    function loadVpnProfiles(callback: var): void {
        executeCommand(["-t", "-f", "NAME,TYPE,DEVICE,ACTIVE", root.nmcliCommandConnection, "show"], result => {
            if (!result.success) {
                root.vpnProfiles = [];
                if (callback) {
                    callback([]);
                }
                return;
            }

            const profiles = result.output.trim().split("\n").filter(line => line.length > 0).map(line => {
                const parts = line.split(":");
                return {
                    name: parts[0] || "",
                    type: parts[1] || "",
                    device: parts[2] || "",
                    active: (parts[3] || "") === "yes"
                };
            }).filter(profile => profile.type.indexOf(root.connectionTypeVpn) >= 0 || profile.type.toLowerCase().indexOf("vpn") >= 0);

            root.vpnProfiles = profiles;
            if (callback) {
                callback(profiles);
            }
        });
    }

    function connectVpn(profileName: string, callback: var): void {
        executeCommand([root.nmcliCommandConnection, "up", profileName], result => {
            Qt.callLater(() => {
                loadVpnProfiles(() => {});
            });

            if (callback) {
                callback(result);
            }
        });
    }

    function disconnectVpn(profileName: string, callback: var): void {
        executeCommand([root.nmcliCommandConnection, "down", profileName], result => {
            Qt.callLater(() => {
                loadVpnProfiles(() => {});
            });

            if (callback) {
                callback(result);
            }
        });
    }

    function loadHotspotStatus(callback: var): void {
        executeCommand(["-t", "-f", "NAME,TYPE,DEVICE,ACTIVE", root.nmcliCommandConnection, "show", "--active"], result => {
            if (!result.success || !result.output || result.output.trim().length === 0) {
                root.hotspotState = Object.assign({}, root.hotspotState, {
                    enabled: false,
                    profileName: "",
                    interfaceName: ""
                });
                if (callback) {
                    callback(root.hotspotState);
                }
                return;
            }

            const activeWireless = result.output.trim().split("\n").filter(line => line.length > 0).map(line => {
                const parts = line.split(":");
                return {
                    name: parts[0] || "",
                    type: parts[1] || "",
                    device: parts[2] || "",
                    active: (parts[3] || "") === "yes"
                };
            }).find(profile => profile.type === root.connectionTypeWireless && profile.active);

            if (!activeWireless) {
                root.hotspotState = Object.assign({}, root.hotspotState, {
                    enabled: false,
                    profileName: "",
                    interfaceName: ""
                });
                if (callback) {
                    callback(root.hotspotState);
                }
                return;
            }

            executeCommand(["-t", "-f", "802-11-wireless.mode,802-11-wireless.ssid,802-11-wireless.band", root.nmcliCommandConnection, "show", activeWireless.name], detailResult => {
                let mode = "";
                let ssid = root.hotspotState.ssid;
                let band = root.hotspotState.band;

                if (detailResult.success && detailResult.output) {
                    const lines = detailResult.output.trim().split("\n");
                    for (const line of lines) {
                        if (line.startsWith("802-11-wireless.mode:")) {
                            mode = line.substring("802-11-wireless.mode:".length).trim();
                        } else if (line.startsWith("802-11-wireless.ssid:")) {
                            ssid = line.substring("802-11-wireless.ssid:".length).trim();
                        } else if (line.startsWith("802-11-wireless.band:")) {
                            const rawBand = line.substring("802-11-wireless.band:".length).trim();
                            band = rawBand === "a" ? "5 GHz" : (rawBand === "bg" ? "2.4 GHz" : "dual");
                        }
                    }
                }

                root.hotspotState = {
                    enabled: mode === "ap",
                    profileName: mode === "ap" ? activeWireless.name : "",
                    interfaceName: mode === "ap" ? activeWireless.device : "",
                    ssid: ssid && ssid.length > 0 ? ssid : root.hotspotState.ssid,
                    password: root.hotspotState.password,
                    band: band,
                    clients: root.hotspotState.clients
                };

                if (callback) {
                    callback(root.hotspotState);
                }
            });
        });
    }

    function enableHotspot(config: var, callback: var): void {
        const iface = wirelessInterfaces.length > 0 ? wirelessInterfaces[0].device : "";
        if (!iface || iface.length === 0) {
            if (callback) {
                callback({
                    success: false,
                    output: "",
                    error: "No wireless interface available",
                    exitCode: -1
                });
            }
            return;
        }

        const nextConfig = config || {};
        const ssid = nextConfig.ssid && nextConfig.ssid.length > 0 ? nextConfig.ssid : "Desktop Hotspot";
        const password = nextConfig.password && nextConfig.password.length > 0 ? nextConfig.password : "quickshell123";
        const cmd = [root.nmcliCommandDevice, root.nmcliCommandWifi, "hotspot", root.connectionParamIfname, iface, root.connectionParamSsid, ssid, root.connectionParamPassword, password];

        if (nextConfig.band === "2.4 GHz") {
            cmd.push("band", "bg");
        } else if (nextConfig.band === "5 GHz") {
            cmd.push("band", "a");
        }

        executeCommand(cmd, result => {
            if (result.success) {
                root.hotspotState = Object.assign({}, root.hotspotState, {
                    ssid: ssid,
                    password: password,
                    band: nextConfig.band && nextConfig.band.length > 0 ? nextConfig.band : root.hotspotState.band
                });
                Qt.callLater(() => {
                    loadHotspotStatus(() => {});
                });
            }

            if (callback) {
                callback(result);
            }
        });
    }

    function disableHotspot(callback: var): void {
        if (!hotspotState.profileName || hotspotState.profileName.length === 0) {
            if (callback) {
                callback({
                    success: false,
                    output: "",
                    error: "No active hotspot",
                    exitCode: -1
                });
            }
            return;
        }

        executeCommand([root.nmcliCommandConnection, "down", hotspotState.profileName], result => {
            if (result.success) {
                Qt.callLater(() => {
                    loadHotspotStatus(() => {});
                });
            }

            if (callback) {
                callback(result);
            }
        });
    }

    function parseGsettingsString(raw: string): string {
        const value = (raw || "").trim();
        if (value.length >= 2 && value[0] === "'" && value[value.length - 1] === "'") {
            return value.substring(1, value.length - 1);
        }

        return value;
    }

    function parseGsettingsList(raw: string): string {
        const value = (raw || "").trim();
        if (value.length < 2) {
            return "";
        }

        return value.substring(1, value.length - 1).split(",").map(entry => parseGsettingsString(entry.trim())).filter(entry => entry.length > 0).join(",");
    }

    function loadProxySettings(callback: var): void {
        executeGsettings(["list-recursively", root.proxySchema], result => {
            if (!result.success || !result.output) {
                if (callback) {
                    callback({
                        mode: root.proxyMode
                    });
                }
                return;
            }

            const lines = result.output.trim().split("\n").filter(line => line.length > 0);
            for (const line of lines) {
                const parts = line.trim().split(/\s+/);
                if (parts.length < 3) {
                    continue;
                }

                const key = parts[0] + "." + parts[1];
                const value = line.substring(line.indexOf(parts[2])).trim();
                switch (key) {
                case "org.gnome.system.proxy.mode":
                    root.proxyMode = parseGsettingsString(value);
                    break;
                case "org.gnome.system.proxy.autoconfig-url":
                    root.proxyPacUrl = parseGsettingsString(value);
                    break;
                case "org.gnome.system.proxy.ignore-hosts":
                    root.proxyBypassList = parseGsettingsList(value);
                    break;
                case "org.gnome.system.proxy.use-same-proxy":
                    root.proxyUseSameProxy = value === "true";
                    break;
                case "org.gnome.system.proxy.http.host":
                    root.proxyHttpHost = parseGsettingsString(value);
                    break;
                case "org.gnome.system.proxy.http.port":
                    root.proxyHttpPort = parseInt(value || "0", 10) || 0;
                    break;
                case "org.gnome.system.proxy.https.host":
                    root.proxyHttpsHost = parseGsettingsString(value);
                    break;
                case "org.gnome.system.proxy.https.port":
                    root.proxyHttpsPort = parseInt(value || "0", 10) || 0;
                    break;
                case "org.gnome.system.proxy.socks.host":
                    root.proxySocksHost = parseGsettingsString(value);
                    break;
                case "org.gnome.system.proxy.socks.port":
                    root.proxySocksPort = parseInt(value || "0", 10) || 0;
                    break;
                default:
                    break;
                }
            }

            if (callback) {
                callback({
                    mode: root.proxyMode,
                    pacUrl: root.proxyPacUrl
                });
            }
        });
    }

    function applyProxySettings(settings: var, callback: var): void {
        const next = settings || {};
        const mode = next.mode || root.proxyMode;
        const pacUrl = next.pacUrl !== undefined ? next.pacUrl : root.proxyPacUrl;
        const httpHost = next.httpHost !== undefined ? next.httpHost : root.proxyHttpHost;
        const httpPort = next.httpPort !== undefined ? next.httpPort : root.proxyHttpPort;
        const httpsHost = next.httpsHost !== undefined ? next.httpsHost : root.proxyHttpsHost;
        const httpsPort = next.httpsPort !== undefined ? next.httpsPort : root.proxyHttpsPort;
        const socksHost = next.socksHost !== undefined ? next.socksHost : root.proxySocksHost;
        const socksPort = next.socksPort !== undefined ? next.socksPort : root.proxySocksPort;
        const bypassList = next.bypassList !== undefined ? next.bypassList : root.proxyBypassList;
        const useSameProxy = next.useSameProxy !== undefined ? next.useSameProxy : root.proxyUseSameProxy;
        const bypassArg = "[" + bypassList.split(",").map(entry => "'" + entry.trim() + "'").filter(entry => entry !== "''").join(", ") + "]";

        const commands = [
            ["set", root.proxySchema, "mode", mode],
            ["set", root.proxySchema, "autoconfig-url", pacUrl],
            ["set", root.proxySchema, "ignore-hosts", bypassArg],
            ["set", root.proxySchema, "use-same-proxy", useSameProxy ? "true" : "false"],
            ["set", root.proxySchema + ".http", "host", httpHost],
            ["set", root.proxySchema + ".http", "port", String(httpPort)],
            ["set", root.proxySchema + ".https", "host", httpsHost],
            ["set", root.proxySchema + ".https", "port", String(httpsPort)],
            ["set", root.proxySchema + ".socks", "host", socksHost],
            ["set", root.proxySchema + ".socks", "port", String(socksPort)]
        ];

        function runNext(index) {
            if (index >= commands.length) {
                root.proxyMode = mode;
                root.proxyPacUrl = pacUrl;
                root.proxyHttpHost = httpHost;
                root.proxyHttpPort = httpPort;
                root.proxyHttpsHost = httpsHost;
                root.proxyHttpsPort = httpsPort;
                root.proxySocksHost = socksHost;
                root.proxySocksPort = socksPort;
                root.proxyBypassList = bypassList;
                root.proxyUseSameProxy = useSameProxy;
                if (callback) {
                    callback({
                        success: true,
                        output: "Proxy settings updated",
                        error: "",
                        exitCode: 0
                    });
                }
                return;
            }

            executeGsettings(commands[index], result => {
                if (!result.success) {
                    if (callback) {
                        callback(result);
                    }
                    return;
                }

                runNext(index + 1);
            });
        }

        runNext(0);
    }

    function refreshAll(): void {
        getNetworkingStatus(() => {});
        getWifiStatus(() => {});
        getWirelessInterfaces(() => {
            const activeWireless = root.wirelessInterfaces.find(iface => isConnectedState(iface.state));
            if (activeWireless && activeWireless.device) {
                getWirelessDeviceDetails(activeWireless.device, () => {});
            }
        });
        getEthernetInterfaces(() => {
            const activeWired = root.ethernetInterfaces.find(iface => isConnectedState(iface.state));
            if (activeWired && activeWired.device) {
                getEthernetDeviceDetails(activeWired.device, () => {});
            }
        });
        refreshStatus(() => {});
        getNetworks(() => {});
        loadSavedConnections(() => {});
        loadVpnProfiles(() => {});
        loadHotspotStatus(() => {});
        loadProxySettings(() => {});
    }

    function handlePasswordRequired(proc: var, error: string, output: string, exitCode: int): bool {
        if (!proc || !error || error.length === 0) {
            return false;
        }

        if (!isConnectionCommand(proc.command) || !root.pendingConnection || !root.pendingConnection.callback) {
            return false;
        }

        const needsPassword = detectPasswordRequired(error);

        if (needsPassword && !proc.callbackCalled && root.pendingConnection) {
            connectionCheckTimer.stop();
            immediateCheckTimer.stop();
            immediateCheckTimer.checkCount = 0;
            const pending = root.pendingConnection;
            root.pendingConnection = null;
            proc.callbackCalled = true;
            const result = {
                success: false,
                output: output || "",
                error: error,
                exitCode: exitCode,
                needsPassword: true
            };
            if (pending.callback) {
                pending.callback(result);
            }
            if (proc.callback && proc.callback !== pending.callback) {
                proc.callback(result);
            }
            return true;
        }

        return false;
    }

    component CommandProcess: Process {
        id: proc

        property var callback: null
        property list<string> command: []
        property bool callbackCalled: false
        property int exitCode: 0

        signal processFinished

        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })

        stdout: StdioCollector {
            id: stdoutCollector
        }

        stderr: StdioCollector {
            id: stderrCollector

            onStreamFinished: {
                const error = text.trim();
                if (error && error.length > 0) {
                    const output = (stdoutCollector && stdoutCollector.text) ? stdoutCollector.text : "";
                    root.handlePasswordRequired(proc, error, output, -1);
                }
            }
        }

        onExited: code => {
            exitCode = code;

            Qt.callLater(() => {
                if (callbackCalled) {
                    processFinished();
                    return;
                }

                if (proc.callback) {
                    const output = (stdoutCollector && stdoutCollector.text) ? stdoutCollector.text : "";
                    const error = (stderrCollector && stderrCollector.text) ? stderrCollector.text : "";
                    const success = exitCode === 0;
                    const cmdIsConnection = isConnectionCommand(proc.command);

                    if (root.handlePasswordRequired(proc, error, output, exitCode)) {
                        processFinished();
                        return;
                    }

                    const needsPassword = cmdIsConnection && root.detectPasswordRequired(error);

                    if (!success && cmdIsConnection && root.pendingConnection) {
                        const failedSsid = root.pendingConnection.ssid;
                        root.connectionFailed(failedSsid);
                    }

                    callbackCalled = true;
                    callback({
                        success: success,
                        output: output,
                        error: error,
                        exitCode: proc.exitCode,
                        needsPassword: needsPassword || false
                    });
                    processFinished();
                } else {
                    processFinished();
                }
            });
        }
    }

    Component {
        id: commandProc

        CommandProcess {}
    }

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
    }

    Component {
        id: apComp

        AccessPoint {}
    }

    Timer {
        id: connectionCheckTimer

        interval: 4000
        onTriggered: {
            if (root.pendingConnection) {
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid;

                if (!connected && root.pendingConnection.callback) {
                    let foundPasswordError = false;
                    for (let i = 0; i < root.activeProcesses.length; i++) {
                        const proc = root.activeProcesses[i];
                        if (proc && proc.stderr && proc.stderr.text) {
                            const error = proc.stderr.text.trim();
                            if (error && error.length > 0) {
                                if (root.isConnectionCommand(proc.command)) {
                                    const needsPassword = root.detectPasswordRequired(error);

                                    if (needsPassword && !proc.callbackCalled && root.pendingConnection) {
                                        const pending = root.pendingConnection;
                                        root.pendingConnection = null;
                                        immediateCheckTimer.stop();
                                        immediateCheckTimer.checkCount = 0;
                                        proc.callbackCalled = true;
                                        const result = {
                                            success: false,
                                            output: (proc.stdout && proc.stdout.text) ? proc.stdout.text : "",
                                            error: error,
                                            exitCode: -1,
                                            needsPassword: true
                                        };
                                        if (pending.callback) {
                                            pending.callback(result);
                                        }
                                        if (proc.callback && proc.callback !== pending.callback) {
                                            proc.callback(result);
                                        }
                                        foundPasswordError = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    if (!foundPasswordError) {
                        const pending = root.pendingConnection;
                        const failedSsid = pending.ssid;
                        root.pendingConnection = null;
                        immediateCheckTimer.stop();
                        immediateCheckTimer.checkCount = 0;
                        root.connectionFailed(failedSsid);
                        pending.callback({
                            success: false,
                            output: "",
                            error: "Connection timeout",
                            exitCode: -1,
                            needsPassword: false
                        });
                    }
                } else if (connected) {
                    root.pendingConnection = null;
                    immediateCheckTimer.stop();
                    immediateCheckTimer.checkCount = 0;
                }
            }
        }
    }

    Timer {
        id: immediateCheckTimer

        property int checkCount: 0

        interval: 500
        repeat: true
        triggeredOnStart: false

        onTriggered: {
            if (root.pendingConnection) {
                checkCount++;
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid;

                if (connected) {
                    connectionCheckTimer.stop();
                    immediateCheckTimer.stop();
                    immediateCheckTimer.checkCount = 0;
                    if (root.pendingConnection.callback) {
                        root.pendingConnection.callback({
                            success: true,
                            output: "Connected",
                            error: "",
                            exitCode: 0
                        });
                    }
                    root.pendingConnection = null;
                } else {
                    for (let i = 0; i < root.activeProcesses.length; i++) {
                        const proc = root.activeProcesses[i];
                        if (proc && proc.stderr && proc.stderr.text) {
                            const error = proc.stderr.text.trim();
                            if (error && error.length > 0) {
                                if (root.isConnectionCommand(proc.command)) {
                                    const needsPassword = root.detectPasswordRequired(error);

                                    if (needsPassword && !proc.callbackCalled && root.pendingConnection && root.pendingConnection.callback) {
                                        connectionCheckTimer.stop();
                                        immediateCheckTimer.stop();
                                        immediateCheckTimer.checkCount = 0;
                                        const pending = root.pendingConnection;
                                        root.pendingConnection = null;
                                        proc.callbackCalled = true;
                                        const result = {
                                            success: false,
                                            output: (proc.stdout && proc.stdout.text) ? proc.stdout.text : "",
                                            error: error,
                                            exitCode: -1,
                                            needsPassword: true
                                        };
                                        if (pending.callback) {
                                            pending.callback(result);
                                        }
                                        if (proc.callback && proc.callback !== pending.callback) {
                                            proc.callback(result);
                                        }
                                        return;
                                    }
                                }
                            }
                        }
                    }

                    if (checkCount >= 6) {
                        immediateCheckTimer.stop();
                        immediateCheckTimer.checkCount = 0;
                    }
                }
            } else {
                immediateCheckTimer.stop();
                immediateCheckTimer.checkCount = 0;
            }
        }
    }

    function checkPendingConnection(): void {
        if (root.pendingConnection) {
            Qt.callLater(() => {
                const connected = root.active && root.active.ssid === root.pendingConnection.ssid;
                if (connected) {
                    connectionCheckTimer.stop();
                    immediateCheckTimer.stop();
                    immediateCheckTimer.checkCount = 0;
                    if (root.pendingConnection.callback) {
                        root.pendingConnection.callback({
                            success: true,
                            output: "Connected",
                            error: "",
                            exitCode: 0
                        });
                    }
                    root.pendingConnection = null;
                } else {
                    if (!immediateCheckTimer.running) {
                        immediateCheckTimer.start();
                    }
                }
            });
        }
    }

    function cidrToSubnetMask(cidr: string): string {
        const cidrNum = parseInt(cidr, 10);
        if (isNaN(cidrNum) || cidrNum < 0 || cidrNum > 32) {
            return "";
        }

        const mask = (0xffffffff << (32 - cidrNum)) >>> 0;
        const octet1 = (mask >>> 24) & 0xff;
        const octet2 = (mask >>> 16) & 0xff;
        const octet3 = (mask >>> 8) & 0xff;
        const octet4 = mask & 0xff;

        return `${octet1}.${octet2}.${octet3}.${octet4}`;
    }

    function getWirelessDeviceDetails(interfaceName: string, callback: var): void {
        if (!interfaceName || interfaceName.length === 0) {
            const activeInterface = root.wirelessInterfaces.find(iface => {
                return isConnectedState(iface.state);
            });
            if (activeInterface && activeInterface.device) {
                interfaceName = activeInterface.device;
            } else {
                if (callback)
                    callback(null);
                return;
            }
        }

        executeCommand(["device", "show", interfaceName], result => {
            if (!result.success || !result.output) {
                root.wirelessDeviceDetails = null;
                if (callback)
                    callback(null);
                return;
            }

            const details = parseDeviceDetails(result.output, false);
            root.wirelessDeviceDetails = details;
            if (callback)
                callback(details);
        });
    }

    function getEthernetDeviceDetails(interfaceName: string, callback: var): void {
        if (!interfaceName || interfaceName.length === 0) {
            const activeInterface = root.ethernetInterfaces.find(iface => {
                return isConnectedState(iface.state);
            });
            if (activeInterface && activeInterface.device) {
                interfaceName = activeInterface.device;
            } else {
                if (callback)
                    callback(null);
                return;
            }
        }

        executeCommand(["device", "show", interfaceName], result => {
            if (!result.success || !result.output) {
                root.ethernetDeviceDetails = null;
                if (callback)
                    callback(null);
                return;
            }

            const details = parseDeviceDetails(result.output, true);
            root.ethernetDeviceDetails = details;
            if (callback)
                callback(details);
        });
    }

    function parseDeviceDetails(output: string, isEthernet: bool): var {
        const details = {
            ipAddress: "",
            gateway: "",
            dns: [],
            subnet: "",
            macAddress: "",
            speed: ""
        };

        if (!output || output.length === 0) {
            return details;
        }

        const lines = output.trim().split("\n");

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const parts = line.split(":");
            if (parts.length >= 2) {
                const key = parts[0].trim();
                const value = parts.slice(1).join(":").trim();

                if (key.startsWith("IP4.ADDRESS")) {
                    const ipParts = value.split("/");
                    details.ipAddress = ipParts[0] || "";
                    if (ipParts[1]) {
                        details.subnet = cidrToSubnetMask(ipParts[1]);
                    } else {
                        details.subnet = "";
                    }
                } else if (key === "IP4.GATEWAY") {
                    if (value !== "--") {
                        details.gateway = value;
                    }
                } else if (key.startsWith("IP4.DNS")) {
                    if (value !== "--" && value.length > 0) {
                        details.dns.push(value);
                    }
                } else if (isEthernet && key === "WIRED-PROPERTIES.MAC") {
                    details.macAddress = value;
                } else if (isEthernet && key === "WIRED-PROPERTIES.SPEED") {
                    details.speed = value;
                } else if (!isEthernet && key === "GENERAL.HWADDR") {
                    details.macAddress = value;
                }
            }
        }

        return details;
    }

    Process {
        id: rescanProc

        command: ["nmcli", "dev", root.nmcliCommandWifi, "list", "--rescan", "yes"]
        onExited: root.getNetworks()
    }

    Process {
        id: monitorProc

        running: true
        command: ["nmcli", "monitor"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: SplitParser {
            onRead: root.refreshOnConnectionChange()
        }
        onExited: monitorRestartTimer.start()
    }

    Timer {
        id: monitorRestartTimer
        interval: 2000
        onTriggered: {
            monitorProc.running = true;
        }
    }

    function refreshOnConnectionChange(): void {
        getNetworkingStatus(() => {});
        loadVpnProfiles(() => {});
        loadHotspotStatus(() => {});
        getNetworks(networks => {
            const newActive = root.active;

            if (newActive && newActive.active) {
                Qt.callLater(() => {
                    if (root.wirelessInterfaces.length > 0) {
                        const activeWireless = root.wirelessInterfaces.find(iface => {
                            return isConnectedState(iface.state);
                        });
                        if (activeWireless && activeWireless.device) {
                            getWirelessDeviceDetails(activeWireless.device, () => {});
                        }
                    }

                    if (root.ethernetInterfaces.length > 0) {
                        const activeEthernet = root.ethernetInterfaces.find(iface => {
                            return isConnectedState(iface.state);
                        });
                        if (activeEthernet && activeEthernet.device) {
                            getEthernetDeviceDetails(activeEthernet.device, () => {});
                        }
                    }
                }, 500);
            } else {
                root.wirelessDeviceDetails = null;
                root.ethernetDeviceDetails = null;
            }

            getWirelessInterfaces(() => {});
            getEthernetInterfaces(() => {
                if (root.activeEthernet && root.activeEthernet.connected) {
                    Qt.callLater(() => {
                        getEthernetDeviceDetails(root.activeEthernet.interface, () => {});
                    }, 500);
                }
            });
        });
    }

    Component.onCompleted: {
        refreshAll();
    }
}
