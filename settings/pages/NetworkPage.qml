import QtQuick
import QtQuick.Layouts
import Quickshell

import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"

PageScaffold {
    id: root

    property var passwordTarget: null
    property string passwordValue: ""
    property string feedbackKind: "info"
    property string feedbackMessage: ""

    readonly property var networkService: root.context && root.context.networkService ? root.context.networkService : null
    readonly property var activeWifiNetworks: networkService && networkService.networks ? networkService.networks : []
    readonly property var ethernetDevices: networkService && networkService.ethernetDevices ? networkService.ethernetDevices : []
    readonly property bool wifiEnabled: networkService ? networkService.wifiEnabled : false
    readonly property bool networkingEnabled: networkService ? networkService.networkingEnabled : true
    readonly property bool isConnected: networkService ? networkService.isConnected : false
    readonly property string activeInterface: networkService ? networkService.activeInterface : ""
    readonly property string activeConnection: networkService ? networkService.activeConnection : ""

    title: "Network & Internet"
    description: "Manage Wi-Fi, Ethernet, and radio state from one Material You settings page."

    function focusEntry(entryId) {
        if (entryId === "wifi" && networkService && networkService.getNetworks) {
            networkService.getNetworks(() => {});
        } else if (entryId === "ethernet" && networkService && networkService.getEthernetInterfaces) {
            networkService.getEthernetInterfaces(() => {});
        } else if (entryId === "status") {
            refreshData();
        }
    }

    function setFeedback(kind, message) {
        feedbackKind = kind;
        feedbackMessage = message || "";
    }

    function clearPasswordPrompt() {
        passwordTarget = null;
        passwordValue = "";
    }

    function refreshData() {
        if (!networkService) {
            setFeedback("error", "Network service is unavailable in Settings.");
            return;
        }

        if (networkService.getNetworkingStatus)
            networkService.getNetworkingStatus(() => {});
        if (networkService.getWifiStatus)
            networkService.getWifiStatus(() => {});
        if (networkService.refreshStatus)
            networkService.refreshStatus(() => {});
        if (networkService.getNetworks)
            networkService.getNetworks(() => {});
        if (networkService.getEthernetInterfaces)
            networkService.getEthernetInterfaces(() => {});
    }

    function networkLabel(network) {
        return (network && network.ssid) || (network && network.name) || "Unknown network";
    }

    function wifiStateText(network) {
        const parts = [];

        if (network && network.active) {
            parts.push("Connected");
        } else if (networkService && networkService.hasSavedProfile && networkService.hasSavedProfile((network && network.ssid) || "")) {
            parts.push("Saved");
        }

        if (network && network.strength !== undefined)
            parts.push(network.strength + "%");

        return parts.join(" • ");
    }

    function activeStateText() {
        if (!networkingEnabled)
            return "Networking disabled";
        if (isConnected && activeConnection)
            return activeConnection;
        if (isConnected && activeInterface)
            return activeInterface;
        return "Disconnected";
    }

    function requestWifiConnection(network) {
        if (!networkService || !network)
            return;

        const ssid = (network && network.ssid) || "";
        if (!ssid)
            return;

        setFeedback("info", "Connecting to " + ssid + "...");
        networkService.connectToNetworkWithPasswordCheck(ssid, !!network.security, result => {
            if (result && result.success) {
                clearPasswordPrompt();
                setFeedback("success", "Connected to " + ssid + ".");
                refreshData();
                return;
            }

            if (result && result.needsPassword) {
                passwordTarget = network;
                passwordValue = "";
                setFeedback("warning", "Password required for " + ssid + ".");
                return;
            }

            setFeedback("error", (result && result.error) || ("Could not connect to " + ssid + "."));
            refreshData();
        }, (network && network.bssid) || "");
    }

    function submitPasswordConnection() {
        if (!networkService || !passwordTarget || passwordValue.length === 0)
            return;

        const ssid = passwordTarget && passwordTarget.ssid ? passwordTarget.ssid : "";
        const bssid = passwordTarget && passwordTarget.bssid ? passwordTarget.bssid : "";
        setFeedback("info", "Connecting to " + ssid + "...");
        networkService.connectToNetwork(ssid, passwordValue, bssid, result => {
            if (result && result.success) {
                clearPasswordPrompt();
                setFeedback("success", "Connected to " + ssid + ".");
            } else {
                setFeedback("error", (result && result.error) || ("Could not connect to " + ssid + "."));
            }
            refreshData();
        });
    }

    function disconnectWifi(network) {
        if (!networkService)
            return;

        setFeedback("info", "Disconnecting from " + networkLabel(network) + "...");
        networkService.disconnectFromNetwork();
        Qt.callLater(refreshData);
    }

    function toggleNetworkingState(enabled) {
        if (!networkService || !networkService.enableNetworking)
            return;

        networkService.enableNetworking(enabled, result => {
            setFeedback(result && result.success ? "success" : "error", result && result.success ? (enabled ? "Networking enabled." : "Networking disabled.") : ((result && result.error) || "Could not change networking state."));
            refreshData();
        });
    }

    function toggleWifiState(enabled) {
        if (!networkService || !networkService.enableWifi)
            return;

        networkService.enableWifi(enabled, result => {
            setFeedback(result && result.success ? "success" : "error", result && result.success ? (enabled ? "Wi-Fi enabled." : "Wi-Fi disabled.") : ((result && result.error) || "Could not change Wi-Fi state."));
            refreshData();
        });
    }

    function toggleEthernet(device) {
        if (!networkService || !device)
            return;

        const interfaceName = device.interface || device.device || "";
        const connectionName = device.connection || "";

        if (device.connected) {
            setFeedback("info", "Disconnecting " + interfaceName + "...");
            if (connectionName.length > 0 && networkService.disconnectEthernet) {
                networkService.disconnectEthernet(connectionName, result => {
                    setFeedback(result && result.success ? "success" : "error", result && result.success ? (interfaceName + " disconnected.") : ((result && result.error) || ("Could not disconnect " + interfaceName + ".")));
                    refreshData();
                });
            } else if (networkService.bringInterfaceDown) {
                networkService.bringInterfaceDown(interfaceName, result => {
                    setFeedback(result && result.success ? "success" : "error", result && result.success ? (interfaceName + " disconnected.") : ((result && result.error) || ("Could not disconnect " + interfaceName + ".")));
                    refreshData();
                });
            }
            return;
        }

        setFeedback("info", "Connecting " + interfaceName + "...");
        if (networkService.connectEthernet) {
            networkService.connectEthernet(connectionName, interfaceName, result => {
                setFeedback(result && result.success ? "success" : "error", result && result.success ? (interfaceName + " connected.") : ((result && result.error) || ("Could not connect " + interfaceName + ".")));
                refreshData();
            });
        }
    }

    Component.onCompleted: Qt.callLater(refreshData)

    PageSection {
        title: "Connectivity"
        description: "Review the active connection and control the networking radios."

        HeroCard {
            iconName: networkingEnabled ? (isConnected ? "wifi" : "ethernet") : "wifi-off"
            title: activeInterface !== "" ? activeInterface : "No active interface"
            subtitle: activeStateText()

            actionData: [
                DS.Button {
                    text: "Refresh"
                    variant: "secondary"
                    onClicked: root.refreshData()
                }
            ]

            RowLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s12

                DS.ToggleTile {
                    Layout.fillWidth: true
                    iconName: "ethernet"
                    title: "Networking"
                    subtitle: networkingEnabled ? "Enabled" : "Disabled"
                    checked: networkingEnabled
                    disabled: !(networkService && networkService.enableNetworking)
                    onClicked: root.toggleNetworkingState(!networkingEnabled)
                }

                DS.ToggleTile {
                    Layout.fillWidth: true
                    iconName: wifiEnabled ? "wifi" : "wifi-off"
                    title: "Wi-Fi"
                    subtitle: wifiEnabled ? "Radio on" : "Radio off"
                    checked: wifiEnabled
                    disabled: !networkingEnabled || !(networkService && networkService.enableWifi)
                    onClicked: root.toggleWifiState(!wifiEnabled)
                }
            }

            DS.FeedbackBlock {
                Layout.fillWidth: true
                visible: feedbackMessage !== ""
                kind: feedbackKind
                title: feedbackKind === "error" ? "Network action failed" : "Network action"
                message: feedbackMessage
            }
        }

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s12

                DS.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Current connection"
                    subtitle: "Quick summary of the active route and transport."
                }

                DS.ListItem {
                    Layout.fillWidth: true
                    iconName: isConnected ? "wifi" : "wifi-off"
                    title: activeConnection !== "" ? activeConnection : "No active connection"
                    subtitle: activeStateText()
                    valueText: networkingEnabled ? (isConnected ? "Connected" : "Idle") : "Off"
                }
            }
        }
    }

    PageSection {
        title: "Wi-Fi networks"
        description: "Scan nearby networks, connect to saved or secured access points, and enter passwords when required."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Nearby networks"
                    subtitle: wifiEnabled ? "Available wireless access points" : "Turn Wi-Fi on to see nearby networks"

                    DS.Button {
                        text: "Rescan"
                        variant: "secondary"
                        disabled: !networkingEnabled || !wifiEnabled || !networkService
                        onClicked: {
                            if (networkService && networkService.rescanWifi)
                                networkService.rescanWifi();
                            if (networkService && networkService.getNetworks)
                                networkService.getNetworks(() => {});
                        }
                    }
                }

                DS.Card {
                    Layout.fillWidth: true
                    visible: passwordTarget !== null
                    padding: Design.Tokens.space.s16

                    ColumnLayout {
                        width: parent.width
                        spacing: Design.Tokens.space.s12

                        DS.HeaderBlock {
                            Layout.fillWidth: true
                            title: "Secure Wi-Fi"
                            subtitle: "Enter the password for " + networkLabel(passwordTarget)
                        }

                        DS.TextField {
                            Layout.fillWidth: true
                            placeholderText: "Network password"
                            text: passwordValue
                            echoMode: TextInput.Password
                            onTextEdited: passwordValue = text
                            onAccepted: root.submitPasswordConnection()
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Design.Tokens.space.s12

                            DS.Button {
                                Layout.fillWidth: true
                                text: "Connect"
                                disabled: passwordValue.length === 0
                                onClicked: root.submitPasswordConnection()
                            }

                            DS.Button {
                                Layout.fillWidth: true
                                text: "Cancel"
                                variant: "secondary"
                                onClicked: root.clearPasswordPrompt()
                            }
                        }
                    }
                }

                Repeater {
                    model: activeWifiNetworks

                    DS.ListItem {
                        required property var modelData

                        Layout.fillWidth: true
                        iconName: modelData.active ? "wifi" : "wifi-off"
                        title: networkLabel(modelData)
                        subtitle: modelData.security && modelData.security.length > 0 ? modelData.security : "Open network"
                        valueText: wifiStateText(modelData)
                        trailingIconName: modelData.active ? "check" : ""
                        selected: passwordTarget !== null && passwordTarget.ssid === modelData.ssid
                        disabled: !networkingEnabled || !wifiEnabled

                        onClicked: {
                            if (modelData.active)
                                root.disconnectWifi(modelData);
                            else
                                root.requestWifiConnection(modelData);
                        }
                    }
                }

                DS.FeedbackBlock {
                    Layout.fillWidth: true
                    visible: activeWifiNetworks.length === 0
                    kind: "info"
                    title: "No networks shown"
                    message: networkingEnabled && wifiEnabled
                        ? "Use rescan to refresh nearby Wi-Fi networks."
                        : "Enable networking and Wi-Fi to scan for nearby networks."
                }
            }
        }
    }

    PageSection {
        title: "Ethernet"
        description: "Connect and disconnect wired interfaces without editing NetworkManager directly."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                Repeater {
                    model: ethernetDevices

                    DS.ListItem {
                        required property var modelData

                        Layout.fillWidth: true
                        iconName: "ethernet"
                        title: modelData.interface || modelData.device || "Ethernet"
                        subtitle: modelData.state || "Unknown state"
                        valueText: modelData.connected ? "Connected" : "Available"
                        trailingIconName: modelData.connected ? "check" : ""
                        disabled: !networkingEnabled
                        onClicked: root.toggleEthernet(modelData)
                    }
                }

                DS.FeedbackBlock {
                    Layout.fillWidth: true
                    visible: ethernetDevices.length === 0
                    kind: "info"
                    title: "No Ethernet adapters shown"
                    message: "Connect a wired adapter or enable networking to manage Ethernet from Settings."
                }
            }
        }
    }

    PageSection {
        title: "Advanced"
        description: "Fallback tools for complex network changes that are still better handled in dedicated utilities."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.HeaderBlock {
                    Layout.fillWidth: true
                    title: "External tools"
                    subtitle: "Open NetworkManager's connection editor for complex profiles and enterprise credentials."
                }

                DS.Button {
                    text: "Open connection editor"
                    variant: "secondary"
                    onClicked: Quickshell.execDetached(["nm-connection-editor"])
                }
            }
        }
    }
}
