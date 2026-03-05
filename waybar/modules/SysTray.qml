import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Wayland

import ".." as Root
import "../services"

Item {
    id: root

    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    property list<var> pinnedItems: TrayService.pinnedItems
    property list<var> unpinnedItems: TrayService.unpinnedItems
    property var activeMenu: null
    property bool overflowOpen: false

    onUnpinnedItemsChanged: {
        if (unpinnedItems.length === 0) {
            closeOverflow();
        }
    }

    function grabFocus() {
        focusGrab.active = true;
    }

    function releaseFocus() {
        focusGrab.active = false;
    }

    function setActiveMenuAndGrab(window) {
        activeMenu = window;
        grabFocus();
    }

    function closeOverflow() {
        overflowOpen = false;
        releaseFocus();
    }

    onOverflowOpenChanged: {
        if (overflowOpen) {
            grabFocus();
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: false
        windows: {
            const wins = [];
            if (overflowPopupLoader.item) wins.push(overflowPopupLoader.item);
            if (root.activeMenu) wins.push(root.activeMenu);
            return wins;
        }
        onCleared: {
            root.closeOverflow();
            if (root.activeMenu) {
                root.activeMenu.close();
                root.activeMenu = null;
            }
        }
    }

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        // Overflow button
        Item {
            visible: root.unpinnedItems.length > 0
            width: visible ? overflowButton.width : 0
            height: Root.Config.iconSize + 2

            Rectangle {
                id: overflowButton
                width: Root.Config.iconSize + 2
                height: Root.Config.iconSize + 2
                radius: 4
                color: root.overflowOpen ? Root.Config.surface0 : "transparent"
                border.width: 0

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: parent.containsMouse && !root.overflowOpen ? Root.Config.surface0 : "transparent"
                    }

                    onClicked: {
                        root.overflowOpen = !root.overflowOpen;
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Root.Config.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Root.Config.iconSize
                        rotation: root.overflowOpen ? 180 : 0
                        Behavior on rotation {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }
                    }
                }
            }
        }

        // Pinned items
        Repeater {
            model: ScriptModel {
                values: root.pinnedItems
            }

            delegate: SysTrayItem {
                required property var modelData
                item: modelData
                Layout.fillHeight: true
                Layout.fillWidth: true
                onMenuClosed: root.releaseFocus();
                onMenuOpened: (qsWindow) => root.setActiveMenuAndGrab(qsWindow);
            }
        }
    }

    // Overflow popup (loaded on demand)
    Loader {
        id: overflowPopupLoader
        active: root.unpinnedItems.length > 0
        sourceComponent: PopupWindow {
            id: popupWindow
            visible: root.overflowOpen && root.unpinnedItems.length > 0
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Root.Config.mantle
                radius: 8
                border.width: 1
                border.color: Root.Config.surface0

                GridLayout {
                    anchors {
                        fill: parent
                        margins: 6
                    }
                    columns: Math.max(1, Math.ceil(Math.sqrt(root.unpinnedItems.length)))
                    columnSpacing: 6
                    rowSpacing: 6

                    Repeater {
                        model: ScriptModel {
                            values: root.unpinnedItems
                        }

                        delegate: SysTrayItem {
                            required property var modelData
                            item: modelData
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            onMenuClosed: root.releaseFocus();
                            onMenuOpened: (qsWindow) => root.setActiveMenuAndGrab(qsWindow);
                        }
                    }
                }
            }
        }
    }
}
