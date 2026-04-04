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

    readonly property var monitors: context?.displayAdapter?.monitors ?? []
    readonly property int keyboardCount: context?.inputAdapter?.devices?.keyboards?.length ?? 0
    readonly property int mouseCount: context?.inputAdapter?.devices?.mice?.length ?? 0

    title: "System"
    description: "Manage displays, input behavior, and the runtime files currently owned by the settings app."

    function runtimeSummary() {
        return `${monitors.length} monitors • ${keyboardCount} keyboards • ${mouseCount} pointing devices`;
    }

    Component.onCompleted: {
        context?.displayAdapter?.refresh();
        context?.inputAdapter?.refresh();
        context?.wallpaperAdapter?.refresh();
    }

    PageSection {
        title: "Overview"
        description: "Quick summary of the desktop runtime and the settings-managed configuration blocks."

        HeroCard {
            iconName: "microchip"
            title: "Desktop runtime"
            subtitle: runtimeSummary()

            actionData: [
                DS.Button {
                    text: "Refresh"
                    variant: "secondary"
                    onClicked: {
                        context.displayAdapter.refresh();
                        context.inputAdapter.refresh();
                        context.wallpaperAdapter.refresh();
                    }
                }
            ]

            DS.ListItem {
                Layout.fillWidth: true
                iconName: "monitor"
                title: "Displays"
                subtitle: "Live monitor inventory from Hyprland"
                valueText: `${monitors.length} active`
            }

            DS.ListItem {
                Layout.fillWidth: true
                iconName: "keyboard"
                title: "Input devices"
                subtitle: context?.inputAdapter?.layoutSummary ?? "Unknown keyboard layout"
                valueText: `${keyboardCount + mouseCount} devices`
            }

            DS.ListItem {
                Layout.fillWidth: true
                iconName: "image"
                title: "Wallpaper cache"
                subtitle: context?.wallpaperAdapter?.currentWallpaper ?? "~/.cache/current_wallpaper"
            }
        }
    }

    PageSection {
        title: "Displays"
        description: "Monitor state comes from live Hyprland data, with settings-managed overrides written into generated config."

        DS.FeedbackBlock {
            Layout.fillWidth: true
            visible: monitors.length === 0
            kind: "info"
            title: "No monitors reported"
            message: "Open the page again after Hyprland reports at least one monitor."
        }

        Repeater {
            model: monitors

            DS.Card {
                id: monitorCard
                required property var modelData
                readonly property var monitor: modelData

                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                    spacing: Design.Tokens.space.s16

                    DS.HeaderBlock {
                        Layout.fillWidth: true
                        title: `${monitorCard.monitor.name} • ${monitorCard.monitor.description}`
                        subtitle: `Focused: ${monitorCard.monitor.focused ? "yes" : "no"} • DPMS: ${monitorCard.monitor.dpmsStatus ? "on" : "off"} • Workspace ${monitorCard.monitor.activeWorkspace?.name ?? "?"}`
                    }

                    DS.ListItem {
                        Layout.fillWidth: true
                        iconName: "monitor"
                        title: "Current mode"
                        subtitle: `${monitorCard.monitor.width}×${monitorCard.monitor.height} @ ${Number(monitorCard.monitor.refreshRate).toFixed(2)}Hz`
                        valueText: `${Number(monitorCard.monitor.scale).toFixed(2)}x`
                    }

                    DS.SelectRow {
                        Layout.fillWidth: true
                        title: "Resolution and refresh rate"
                        subtitle: "Write a settings-managed monitor override and reload Hyprland."
                        model: (monitorCard.monitor.availableModes ?? []).map(mode => ({ label: mode, value: mode }))
                        currentIndex: context?.displayAdapter?.currentModeIndex(monitorCard.monitor) ?? 0
                        onActivated: index => {
                            const modes = (monitorCard.monitor.availableModes ?? []).map(mode => ({ label: mode, value: mode }));
                            if (modes[index]) {
                                context.displayAdapter.applyMonitorSettings(monitorCard.monitor.name, modes[index].value, monitorCard.monitor.scale);
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
                                    selected: Math.abs(modelData.value - monitorCard.monitor.scale) < 0.001
                                    onClicked: {
                                        const modeIndex = context?.displayAdapter?.currentModeIndex(monitorCard.monitor) ?? 0;
                                        const mode = monitorCard.monitor.availableModes?.[modeIndex] ?? `${monitorCard.monitor.width}x${monitorCard.monitor.height}@${Number(monitorCard.monitor.refreshRate).toFixed(2)}Hz`;
                                        context.displayAdapter.applyMonitorSettings(monitorCard.monitor.name, mode, modelData.value);
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
    }

    PageSection {
        title: "Input"
        description: "Controlled input overrides plus a live inventory of keyboards and pointing devices."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.SwitchRow {
                    Layout.fillWidth: true
                    title: "Follow mouse"
                    subtitle: "Mirror Hyprland’s follow-mouse behavior without editing the hand-maintained config block directly."
                    checked: context?.inputAdapter?.followMouse ?? true
                    onToggled: checked => context.inputAdapter.apply(checked, context.inputAdapter.naturalScroll)
                }

                DS.SwitchRow {
                    Layout.fillWidth: true
                    title: "Touchpad natural scroll"
                    subtitle: "Applies only to the settings-managed touchpad override block."
                    checked: context?.inputAdapter?.naturalScroll ?? false
                    onToggled: checked => context.inputAdapter.apply(context.inputAdapter.followMouse, checked)
                }
            }
        }

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s12

                DS.ListItem {
                    Layout.fillWidth: true
                    iconName: "keyboard"
                    title: "Active keyboard layout"
                    subtitle: context?.inputAdapter?.layoutSummary ?? "Unknown"
                    valueText: `${keyboardCount} keyboards`
                }

                DS.ListItem {
                    Layout.fillWidth: true
                    iconName: "mouse-pointer-2"
                    title: "Pointing devices"
                    subtitle: "Mice and touch devices reported by Hyprland"
                    valueText: `${mouseCount} mice`
                }

                Repeater {
                    model: context?.inputAdapter?.devices?.keyboards ?? []

                    DS.ListItem {
                        required property var modelData
                        Layout.fillWidth: true
                        title: modelData.name
                        subtitle: modelData.active_keymap ?? "Unknown keymap"
                        valueText: modelData.main ? "Primary" : ""
                    }
                }
            }
        }
    }

    PageSection {
        title: "About this desktop"
        description: "Paths and runtime state for the files currently managed by the Settings app."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s12

                DS.ListItem {
                    Layout.fillWidth: true
                    iconName: "files"
                    title: "Settings-managed Hypr includes"
                    subtitle: "~/.config/hypr/generated/settings-monitors.conf and ~/.config/hypr/generated/settings-input.conf"
                }

                DS.ListItem {
                    Layout.fillWidth: true
                    iconName: "file-text"
                    title: "Theme source of truth"
                    subtitle: "~/.config/quickshell/theme.ini"
                }

                DS.ListItem {
                    Layout.fillWidth: true
                    iconName: "image"
                    title: "Wallpaper cache"
                    subtitle: context?.wallpaperAdapter?.currentWallpaper ?? "~/.cache/current_wallpaper"
                }
            }
        }
    }
}
