import QtQuick
import QtQuick.Layouts

import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"

PageScaffold {
    id: root

    title: "Input & About"
    description: "Controlled input overrides plus a summary of the current desktop runtime."

    Component.onCompleted: context?.inputAdapter?.refresh()

    PageSection {
        title: "Input behavior"
        description: "These values are written into ~/.config/hypr/generated/settings-input.conf and reloaded through Hyprland."

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

    PageSection {
        title: "Devices"
        description: "Live device inventory from Hyprland."

        DS.ListItem {
            Layout.fillWidth: true
            iconName: "keyboard"
            title: "Active keyboard layout"
            subtitle: context?.inputAdapter?.layoutSummary ?? "Unknown"
            valueText: `${context?.inputAdapter?.devices?.keyboards?.length ?? 0} keyboards`
        }

        DS.ListItem {
            Layout.fillWidth: true
            iconName: "mouse-pointer-2"
            title: "Pointing devices"
            subtitle: "Mice and touch devices reported by Hyprland"
            valueText: `${context?.inputAdapter?.devices?.mice?.length ?? 0} mice`
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

    PageSection {
        title: "About this desktop"
        description: "Runtime state and the config files now owned by the Settings app."

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
