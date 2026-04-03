import QtQuick
import QtQuick.Layouts

import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"

PageScaffold {
    id: root
    property var scaleOptions: [
        { label: "100%", value: 1.0 },
        { label: "125%", value: 1.25 },
        { label: "150%", value: 1.5 }
    ]

    title: "Displays"
    description: "Monitor state comes from live Hyprland data, with settings-managed overrides written into generated config."

    Component.onCompleted: context?.displayAdapter?.refresh()

    Repeater {
        model: context?.displayAdapter?.monitors ?? []

        PageSection {
            id: monitorSection
            required property var modelData
            readonly property var monitorData: modelData

            title: `${monitorData.name} • ${monitorData.description}`
            description: `Focused: ${monitorData.focused ? "yes" : "no"} • DPMS: ${monitorData.dpmsStatus ? "on" : "off"} • Workspace ${monitorData.activeWorkspace?.name ?? "?"}`

            DS.ListItem {
                Layout.fillWidth: true
                icon: "󰍹"
                title: "Current mode"
                subtitle: `${monitorData.width}×${monitorData.height} @ ${Number(monitorData.refreshRate).toFixed(2)}Hz`
                valueText: `${Number(monitorData.scale).toFixed(2)}x`
            }

            DS.SelectRow {
                Layout.fillWidth: true
                title: "Resolution and refresh rate"
                subtitle: "Write a settings-managed monitor override and reload Hyprland."
                model: (monitorData.availableModes ?? []).map(mode => ({ label: mode, value: mode }))
                currentIndex: context?.displayAdapter?.currentModeIndex(monitorData) ?? 0
                onActivated: index => {
                    const modes = (monitorData.availableModes ?? []).map(mode => ({ label: mode, value: mode }));
                    if (modes[index]) {
                        context.displayAdapter.applyMonitorSettings(monitorData.name, modes[index].value, monitorData.scale);
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s8

                Text {
                    text: "Scale"
                    color: Design.Tokens.color.text.primary
                    font.family: Design.Tokens.font.family.label
                    font.pixelSize: Design.Tokens.font.size.label
                    font.weight: Design.Tokens.font.weight.semibold
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Design.Tokens.space.s12

                    Repeater {
                        model: root.scaleOptions

                        DS.SegmentedButton {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.label
                            selected: Math.abs(modelData.value - monitorSection.monitorData.scale) < 0.001
                            onClicked: {
                                const monitor = monitorSection.monitorData;
                                const modeIndex = context?.displayAdapter?.currentModeIndex(monitor) ?? 0;
                                const mode = monitor.availableModes?.[modeIndex] ?? `${monitor.width}x${monitor.height}@${Number(monitor.refreshRate).toFixed(2)}Hz`;
                                context.displayAdapter.applyMonitorSettings(monitor.name, mode, modelData.value);
                            }
                        }
                    }
                }
            }

            DS.FeedbackBlock {
                Layout.fillWidth: true
                kind: "info"
                title: "Generated ownership"
                message: "Display overrides are written into ~/.config/hypr/generated/settings-monitors.conf so the Settings app does not overwrite your hand-maintained Hyprland file."
            }
        }
    }
}
