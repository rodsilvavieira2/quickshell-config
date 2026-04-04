import QtQuick
import QtQuick.Layouts
import Quickshell

import "../shared/designsystem" as Design
import "../shared/ui" as DS
import "../components"

PageScaffold {
    id: root

    title: "Appearance & Wallpaper"
    description: "Manage shared Material You tokens, shell typography, GTK bridge settings, and desktop wallpaper from one page."

    function fontModels() {
        const entries = Design.FontCatalog.entries || [];
        const models = [];

        for (let index = 0; index < entries.length; index++) {
            const entry = entries[index];
            models.push({
                label: entry.label,
                value: entry.family
            });
        }

        return models;
    }

    function currentFontIndex() {
        const models = fontModels();
        const family = context?.themeAdapter?.draftFontFamily ?? "";

        for (let index = 0; index < models.length; index++) {
            if (models[index].value === family)
                return index;
        }

        return 0;
    }

    Component.onCompleted: {
        context?.themeAdapter?.resetDrafts();
        context?.wallpaperAdapter?.refresh();
    }

    PageSection {
        title: "Theme & identity"
        description: "Use the shared design-system tokens as the source of truth for shell surfaces, typography, and accent color."

        HeroCard {
            iconName: "palette"
            title: "Shell theme"
            subtitle: "Adjust the shell mode, accent seed, font family, and scale without leaving the settings app."

            RowLayout {
                spacing: Design.Tokens.space.s8

                Repeater {
                    model: [
                        { label: "Dark", value: "dark" },
                        { label: "Light", value: "light" }
                    ]

                    DS.SegmentedButton {
                        required property var modelData
                        text: modelData.label
                        selected: context?.themeAdapter?.draftMode === modelData.value
                        onClicked: context.themeAdapter.draftMode = modelData.value
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s8

                Text {
                    text: "Accent seed"
                    color: Design.Tokens.color.text.primary
                    font.family: Design.Tokens.font.family.label
                    font.pixelSize: Design.Tokens.font.size.label
                    font.weight: Design.Tokens.font.weight.semibold
                }

                Flow {
                    Layout.fillWidth: true
                    width: parent.width
                    spacing: Design.Tokens.space.s12

                    Repeater {
                        model: context?.themeAdapter?.accentOptions ?? []

                        Rectangle {
                            required property var modelData

                            width: 76
                            height: 76
                            radius: Design.Tokens.shape.large
                            color: modelData.value
                            border.width: context?.themeAdapter?.draftAccentColor === modelData.value
                                ? Design.Tokens.border.width.strong
                                : Design.Tokens.border.width.thin
                            border.color: context?.themeAdapter?.draftAccentColor === modelData.value
                                ? Design.Tokens.color.text.primary
                                : Design.Tokens.color.outlineVariant

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: Design.Tokens.space.s8
                                text: modelData.name
                                color: "#ffffff"
                                font.family: Design.Tokens.font.family.label
                                font.pixelSize: Design.Tokens.font.size.caption
                                font.weight: Design.Tokens.font.weight.semibold
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: context.themeAdapter.draftAccentColor = parent.modelData.value
                            }
                        }
                    }
                }
            }

            DS.SelectRow {
                Layout.fillWidth: true
                title: "Shell font"
                subtitle: "Keep shell typography centralized in the shared theme settings."
                model: root.fontModels()
                currentIndex: root.currentFontIndex()
                onActivated: index => {
                    const models = root.fontModels();
                    if (models[index]) {
                        context.themeAdapter.draftFontFamily = models[index].value;
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
                        model: context?.themeAdapter?.scaleOptions ?? []

                        DS.SegmentedButton {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.label
                            selected: Math.abs((context?.themeAdapter?.draftUiScale ?? 1) - modelData.value) < 0.001
                            onClicked: context.themeAdapter.draftUiScale = modelData.value
                        }
                    }
                }
            }

            DS.FeedbackBlock {
                Layout.fillWidth: true
                kind: context?.themeAdapter?.hasPendingChanges ? "warning" : "info"
                title: context?.themeAdapter?.hasPendingChanges ? "Pending shell changes" : "Shell theme applied"
                message: context?.themeAdapter?.hasPendingChanges
                    ? "Apply the staged shell changes to update the shared Quickshell modules."
                    : "The shell is currently using the token values shown above."
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Design.Tokens.space.s12

                DS.Button {
                    text: "Reset"
                    variant: "secondary"
                    onClicked: context.themeAdapter.resetDrafts()
                }

                DS.Button {
                    text: "Apply"
                    variant: "primary"
                    disabled: !context?.themeAdapter?.hasPendingChanges
                    onClicked: context.themeAdapter.applyDrafts()
                }
            }
        }

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.HeaderBlock {
                    Layout.fillWidth: true
                    title: "GTK bridge"
                    subtitle: "Keep GTK readable and predictable without allowing external app themes to redefine the shell."
                }

                DS.SwitchRow {
                    Layout.fillWidth: true
                    title: "Prefer dark GTK apps"
                    subtitle: `GTK currently uses ${context?.gtkAdapter?.themeName ?? "Adwaita"} with ${context?.gtkAdapter?.iconThemeName ?? "the current icon theme"}.`
                    checked: context?.gtkAdapter?.preferDark ?? true
                    onToggled: checked => context.gtkAdapter.apply(checked, context.gtkAdapter.gtkFontName)
                }

                DS.NavigationRow {
                    Layout.fillWidth: true
                    title: "GTK font"
                    subtitle: context?.gtkAdapter?.gtkFontName ?? ""
                    valueText: "Sync to shell font"
                    onClicked: context.gtkAdapter.syncFromTheme(context.themeAdapter.draftMode, context.themeAdapter.draftFontFamily)
                }
            }
        }
    }

    PageSection {
        title: "Wallpaper"
        description: "Review the current background and keep using the existing wallpaper picker pipeline inside Settings."

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Current wallpaper"
                    subtitle: "The shell continues to use the existing wallpaper scripts and cache file."
                }

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
        }

        DS.Card {
            Layout.fillWidth: true

            ColumnLayout {
                width: parent.width
                spacing: Design.Tokens.space.s16

                DS.HeaderBlock {
                    Layout.fillWidth: true
                    title: "Wallpaper picker"
                    subtitle: "Embedded existing picker with the current search and thumbnail pipeline."
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 700

                    Loader {
                        id: wallpaperPickerLoader
                        anchors.fill: parent
                        active: true
                        source: Qt.resolvedUrl("../../wallpaper/WallpaperPicker.qml")
                    }

                    Connections {
                        target: wallpaperPickerLoader.item

                        function onCloseRequested() {
                            context?.wallpaperAdapter?.refresh();
                        }
                    }
                }
            }
        }
    }
}
