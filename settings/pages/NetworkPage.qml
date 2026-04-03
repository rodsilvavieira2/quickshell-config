import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../network/services" as NetworkServices
import "../../shared/designsystem" as Design
import "../../shared/ui" as UI

Item {
    id: root

    property var context: null

    readonly property var networkService: root.context?.networkService ?? NetworkServices.Nmcli
    readonly property var activeWifiNetworks: networkService?.networks ?? []
    readonly property var ethernetDevices: networkService?.ethernetDevices ?? []
    readonly property bool wifiEnabled: networkService?.wifiEnabled ?? false
    readonly property bool isConnected: networkService?.isConnected ?? false
    readonly property string activeInterface: networkService?.activeInterface ?? ""
    readonly property string activeConnection: networkService?.activeConnection ?? ""

    implicitWidth: 980
    implicitHeight: column.implicitHeight

    function refreshData() {
        if (networkService?.getWifiStatus) {
            networkService.getWifiStatus(() => {});
        }
        if (networkService?.refreshStatus) {
            networkService.refreshStatus(() => {});
        }
        if (networkService?.getNetworks) {
            networkService.getNetworks(() => {});
        }
        if (networkService?.getEthernetInterfaces) {
            networkService.getEthernetInterfaces(() => {});
        }
    }

    function networkLabel(network) {
        return network?.ssid || network?.name || "Unknown network";
    }

    function activeStateText() {
        if (isConnected && activeConnection) return activeConnection;
        if (isConnected && activeInterface) return activeInterface;
        return "Disconnected";
    }

    Component.onCompleted: {
        Qt.callLater(refreshData);
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: Design.Tokens.space.s20

        UI.HeaderBlock {
            Layout.fillWidth: true
            title: "Network"
            subtitle: "Inspect live interfaces and manage wireless state"
        }

        UI.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                UI.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Wireless"
                    subtitle: "Current radio state and network scan results"
                }

                UI.SwitchRow {
                    Layout.fillWidth: true
                    title: "Wi-Fi"
                    subtitle: wifiEnabled ? "Enabled" : "Disabled"
                    checked: wifiEnabled
                    onToggled: checked => {
                        if (networkService?.enableWifi) {
                            networkService.enableWifi(checked, () => {});
                        }
                    }
                }

                UI.Button {
                    Layout.fillWidth: true
                    text: "Rescan networks"
                    variant: "secondary"
                    onClicked: {
                        if (networkService?.rescanWifi) {
                            networkService.rescanWifi();
                        }
                        if (networkService?.getNetworks) {
                            networkService.getNetworks(() => {});
                        }
                    }
                }

                Repeater {
                    model: activeWifiNetworks

                    UI.ListItem {
                        required property var modelData

                        Layout.fillWidth: true
                        icon: "󰤨"
                        title: networkLabel(modelData)
                        subtitle: modelData.security && modelData.security.length > 0 ? modelData.security : "Open network"
                        valueText: (modelData.active ? "Active" : "") + (modelData.strength !== undefined ? (modelData.active ? " " : "") + modelData.strength + "%" : "")
                        trailingIcon: modelData.active ? "󰄬" : ""
                        onClicked: {
                            if (modelData.active && networkService?.disconnectFromNetwork) {
                                networkService.disconnectFromNetwork();
                            } else if ((!modelData.security || modelData.security.length === 0) && networkService?.connectToNetworkWithPasswordCheck) {
                                networkService.connectToNetworkWithPasswordCheck(modelData.ssid, false, () => {}, modelData.bssid ?? "");
                            }
                        }
                    }
                }
            }
        }

        UI.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                UI.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Ethernet"
                    subtitle: "Connected wired interfaces"
                }

                UI.ListItem {
                    Layout.fillWidth: true
                    icon: "󰈀"
                    title: activeInterface !== "" ? activeInterface : "No active interface"
                    subtitle: activeStateText()
                    valueText: isConnected ? "Connected" : "Idle"
                }

                Repeater {
                    model: ethernetDevices

                    UI.ListItem {
                        required property var modelData

                        Layout.fillWidth: true
                        icon: "󰈀"
                        title: modelData.interface || modelData.device || "Ethernet"
                        subtitle: modelData.state || "Unknown state"
                        valueText: modelData.connection || ""
                    }
                }
            }
        }

        UI.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                UI.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Advanced"
                    subtitle: "Fallback tools for complex network management"
                }

                UI.Button {
                    text: "Open connection editor"
                    variant: "secondary"
                    onClicked: Quickshell.execDetached(["nm-connection-editor"])
                }

                UI.FeedbackBlock {
                    Layout.fillWidth: true
                    kind: "info"
                    title: "Backend"
                    message: "This page reuses the existing `Nmcli` service and keeps adapter injection ready through `context`."
                }
            }
        }
    }
}
