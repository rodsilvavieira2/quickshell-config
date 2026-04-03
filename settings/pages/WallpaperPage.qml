import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../wallpaper" as WallpaperModule
import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"

PageScaffold {
    id: root

    title: "Wallpaper"
    description: "Review the active wallpaper and reuse the existing picker inside the settings app."

    Component.onCompleted: context?.wallpaperAdapter?.refresh()

    PageSection {
        title: "Current wallpaper"
        description: "The shell still uses the existing wallpaper script and cache file."

        DS.ListItem {
            Layout.fillWidth: true
            iconName: "image"
            title: "Active image"
            subtitle: context?.wallpaperAdapter?.currentWallpaper ?? "No wallpaper cached yet."
            valueText: context?.wallpaperAdapter?.currentWallpaper ? "Cached" : ""
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s12

            DS.Button {
                text: "Refresh"
                variant: "secondary"
                onClicked: context.wallpaperAdapter.refresh()
            }

            DS.Button {
                text: "Open standalone picker"
                variant: "ghost"
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "wallpaper", "call", "wallpaper", "open"])
            }
        }
    }

    PageSection {
        title: "Wallpaper picker"
        description: "Embedded existing picker. It keeps its current search and thumbnail pipeline."

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 720

            WallpaperModule.WallpaperPicker {
                anchors.fill: parent
                onCloseRequested: context?.wallpaperAdapter?.refresh()
            }
        }
    }
}
