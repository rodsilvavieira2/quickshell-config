//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "./shared/designsystem" as Design
import "./shared/ui" as DS
import "./components"
import "./services"

ShellRoot {
    id: shellRoot

    property bool appOpen: false
    property string selectedCategoryId: "appearance"
    property string searchQuery: ""
    property string pendingEntryId: ""

    readonly property var pageContext: ({
        themeAdapter: themeAdapter,
        gtkAdapter: gtkAdapter,
        wallpaperAdapter: wallpaperAdapter,
        displayAdapter: displayAdapter,
        inputAdapter: inputAdapter
    })
    readonly property var currentCategory: registry.categoryById(selectedCategoryId)
    readonly property var searchResults: registry.search(searchQuery)

    function focusedScreen() {
        const focusedName = Hyprland.focusedMonitor?.name ?? "";
        for (let i = 0; i < Quickshell.screens.values.length; i++) {
            const screen = Quickshell.screens.values[i];
            if (screen.name === focusedName)
                return screen;
        }
        return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
    }

    function centerWindow() {
        const screen = focusedScreen();
        if (!screen)
            return;

        settingsWindow.x = screen.x + Math.round((screen.width - settingsWindow.width) / 2);
        settingsWindow.y = screen.y + Math.round((screen.height - settingsWindow.height) / 2);
    }

    function openPage(categoryId, entryId) {
        selectedCategoryId = categoryId || selectedCategoryId;
        pendingEntryId = entryId || "";
        appOpen = true;
        centerWindow();
        wallpaperAdapter.refresh();
        displayAdapter.refresh();
        inputAdapter.refresh();
        gtkAdapter.refresh();
        Qt.callLater(() => settingsWindow.requestActivate());
    }

    function closeApp() {
        appOpen = false;
        searchQuery = "";
    }

    ThemeAdapter {
        id: themeAdapter
    }

    GtkAppearanceAdapter {
        id: gtkAdapter
        Component.onCompleted: refresh()
    }

    WallpaperAdapter {
        id: wallpaperAdapter
        Component.onCompleted: refresh()
    }

    HyprDisplayAdapter {
        id: displayAdapter
        Component.onCompleted: refresh()
    }

    HyprInputAdapter {
        id: inputAdapter
        Component.onCompleted: refresh()
    }

    SettingsRegistry {
        id: registry
    }

    IpcHandler {
        target: "settings"

        function toggle() {
            if (shellRoot.appOpen) shellRoot.closeApp();
            else shellRoot.openPage(shellRoot.selectedCategoryId, "");
        }

        function open() {
            shellRoot.openPage(shellRoot.selectedCategoryId, "");
        }

        function close() {
            shellRoot.closeApp();
        }
    }

    FloatingWindow {
        id: settingsWindow

        title: "Desktop Settings"
        implicitWidth: 1320
        implicitHeight: 880
        visible: shellRoot.appOpen
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                shellRoot.centerWindow();
                requestActivate();
            }
        }

        FocusScope {
            anchors.fill: parent
            focus: settingsWindow.visible

            Keys.onEscapePressed: event => {
                shellRoot.closeApp();
                event.accepted = true;
            }

            Rectangle {
                anchors.fill: parent
                radius: Design.Tokens.component.panel.radius
                color: Design.Tokens.color.surface
                border.width: Design.Tokens.border.width.thin
                border.color: Design.Tokens.color.outlineVariant
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Design.Tokens.space.s20
                spacing: Design.Tokens.space.s16

                DS.TopAppBar {
                    Layout.fillWidth: true
                    title: "Settings"
                    subtitle: "Material 3 adapted system settings for your Quickshell desktop"

                    DS.SearchBar {
                        id: searchBar
                        implicitWidth: 340
                        text: shellRoot.searchQuery
                        placeholderText: "Search settings"
                        onTextChanged: shellRoot.searchQuery = text
                        onAccepted: {
                            if (shellRoot.searchResults.length > 0) {
                                const firstResult = shellRoot.searchResults[0];
                                shellRoot.selectedCategoryId = firstResult.categoryId;
                                shellRoot.pendingEntryId = firstResult.entryId;
                                shellRoot.searchQuery = "";
                            }
                        }
                    }

                    DS.IconButton {
                        icon: "󰅖"
                        preferredHeight: 40
                        onClicked: shellRoot.closeApp()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Design.Tokens.space.s20

                    DS.Surface {
                        Layout.preferredWidth: Design.Tokens.component.drawer.width
                        Layout.fillHeight: true
                        padding: Design.Tokens.space.s12
                        backgroundColor: Design.Tokens.color.surfaceContainerLow

                        ColumnLayout {
                            width: parent.width
                            spacing: Design.Tokens.component.drawer.sectionGap

                            Repeater {
                                model: registry.categories

                                DS.NavigationDrawerItem {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    icon: modelData.icon
                                    text: modelData.label
                                    selected: shellRoot.selectedCategoryId === modelData.id
                                    onClicked: {
                                        shellRoot.selectedCategoryId = modelData.id;
                                        shellRoot.pendingEntryId = "";
                                        shellRoot.searchQuery = "";
                                    }
                                }
                            }
                        }
                    }

                    DS.Panel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        padding: Design.Tokens.space.s20

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: Design.Tokens.space.s16

                            DS.Card {
                                visible: shellRoot.searchQuery.trim().length > 0
                                Layout.fillWidth: true

                                ColumnLayout {
                                    width: parent.width
                                    spacing: Design.Tokens.space.s8

                                    DS.HeaderBlock {
                                        Layout.fillWidth: true
                                        title: "Search results"
                                        subtitle: shellRoot.searchResults.length > 0
                                            ? `${shellRoot.searchResults.length} matching settings`
                                            : "No matching settings"
                                    }

                                    Repeater {
                                        model: shellRoot.searchResults

                                        DS.ListItem {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            icon: modelData.categoryIcon
                                            title: modelData.title
                                            subtitle: modelData.description
                                            valueText: modelData.categoryLabel
                                            onClicked: {
                                                shellRoot.selectedCategoryId = modelData.categoryId;
                                                shellRoot.pendingEntryId = modelData.entryId;
                                                shellRoot.searchQuery = "";
                                            }
                                        }
                                    }
                                }
                            }

                            Loader {
                                id: pageLoader
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                source: shellRoot.currentCategory?.pageSource ?? ""

                                onLoaded: {
                                    if (item) {
                                        item.context = shellRoot.pageContext;
                                        if (shellRoot.pendingEntryId !== "" && item.focusEntry) {
                                            item.focusEntry(shellRoot.pendingEntryId);
                                            shellRoot.pendingEntryId = "";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
