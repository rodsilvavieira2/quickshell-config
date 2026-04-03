import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "../../shared/designsystem" as Design
import "../../shared/ui" as UI

Item {
    id: root

    property var context: null

    readonly property var bluetoothService: root.context?.bluetoothService ?? Bluetooth
    readonly property var adapter: bluetoothService?.defaultAdapter ?? null
    readonly property var devices: deviceArray()

    implicitWidth: 920
    implicitHeight: column.implicitHeight

    function sortedDevices() {
        return deviceArray().sort((a, b) => {
            return (b.connected - a.connected) || (b.paired - a.paired) || (a.name || "").localeCompare(b.name || "");
        });
    }

    function deviceLabel(device) {
        return device?.name || device?.alias || "Unknown device";
    }

    function deviceArray() {
        const out = [];
        const list = bluetoothService?.devices?.values ?? Bluetooth.devices?.values ?? [];
        for (let i = 0; i < list.length; i++) {
            out.push(list[i]);
        }
        return out;
    }

    ColumnLayout {
        id: column
        width: parent.width
        spacing: Design.Tokens.space.s20

        UI.HeaderBlock {
            Layout.fillWidth: true
            title: "Bluetooth"
            subtitle: "Manage adapter power, discovery, and paired devices"
        }

        UI.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                UI.SwitchRow {
                    Layout.fillWidth: true
                    title: "Bluetooth adapter"
                    subtitle: adapter?.enabled ? "Enabled" : "Disabled"
                    checked: adapter?.enabled ?? false
                    onToggled: checked => {
                        if (adapter) {
                            adapter.enabled = checked;
                        }
                    }
                }

                UI.SwitchRow {
                    Layout.fillWidth: true
                    title: "Discover devices"
                    subtitle: adapter?.discovering ? "Scanning" : "Idle"
                    checked: adapter?.discovering ?? false
                    onToggled: checked => {
                        if (adapter) {
                            adapter.discovering = checked;
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
                    title: "Devices"
                    subtitle: "Paired and discovered devices"
                }

                Repeater {
                    model: sortedDevices()

                    UI.ListItem {
                        required property var modelData

                        Layout.fillWidth: true
                        icon: modelData.connected ? "󰂯" : "󰂲"
                        title: deviceLabel(modelData)
                        subtitle: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "Available")
                        valueText: modelData.address || ""
                        trailingIcon: modelData.connected ? "󰄬" : ""

                        onClicked: {
                            if (modelData.connected) {
                                modelData.connected = false;
                            } else if (modelData.paired) {
                                modelData.connected = true;
                            } else if (modelData.pair) {
                                modelData.pair();
                            }
                        }
                    }
                }

                UI.FeedbackBlock {
                    Layout.fillWidth: true
                    kind: "info"
                    title: "Backend"
                    message: "This page uses the live `Quickshell.Bluetooth` singleton and can later accept an injected adapter through `context`."
                }
            }
        }
    }
}
