import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

import ".." as Root
import "../services"

PopupWindow {
    id: root
    required property var trayItemMenuHandle
    
    signal menuClosed()
    signal menuOpened(qsWindow: var)

    color: "transparent"
    property real padding: 6

    implicitHeight: {
        let result = 0;
        for (let child of stackView.children) {
            result = Math.max(child.implicitHeight, result);
        }
        return result + menuPanel.padding * 2 + root.padding * 2;
    }
    implicitWidth: {
        let result = 0;
        for (let child of stackView.children) {
            result = Math.max(child.implicitWidth, result);
        }
        return result + menuPanel.padding * 2 + root.padding * 2;
    }

    function open() {
        root.visible = true;
        root.menuOpened(root);
    }

    function close() {
        root.visible = false;
        while (stackView.depth > 1)
            stackView.pop();
        root.menuClosed();
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton | Qt.RightButton

        onPressed: event => {
            if ((event.button === Qt.BackButton || event.button === Qt.RightButton) && stackView.depth > 1)
                stackView.pop();
        }

        Rectangle {
            id: menuPanel
            readonly property real padding: 4
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: root.padding
            }

            color: Root.Config.mantle
            radius: 8
            border.width: 1
            border.color: Root.Config.surface0
            clip: true

            implicitWidth: stackView.implicitWidth + menuPanel.padding * 2
            implicitHeight: stackView.implicitHeight + menuPanel.padding * 2

            StackView {
                id: stackView
                anchors {
                    fill: parent
                    margins: menuPanel.padding
                }
                pushEnter: Transition {}
                pushExit: Transition {}
                popEnter: Transition {}
                popExit: Transition {}

                implicitWidth: currentItem ? currentItem.implicitWidth : 0
                implicitHeight: currentItem ? currentItem.implicitHeight : 0

                initialItem: SubMenu {
                    handle: root.trayItemMenuHandle
                }
            }
        }
    }

    component SubMenu: ColumnLayout {
        id: submenu
        required property var handle
        property bool isSubMenu: false

        QsMenuOpener {
            id: menuOpener
            menu: submenu.handle
        }

        spacing: 0

        Loader {
            Layout.fillWidth: true
            visible: submenu.isSubMenu
            active: visible

            sourceComponent: Rectangle {
                height: 36
                Layout.fillWidth: true
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    Rectangle {
                        anchors.fill: parent
                        color: parent.containsMouse ? Root.Config.surface0 : "transparent"
                    }

                    onClicked: stackView.pop()

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                        }
                        spacing: 8

                        Text {
                            text: "‹"
                            color: Root.Config.text
                            font.pixelSize: 16
                        }

                        Text {
                            text: "Back"
                            color: Root.Config.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        Repeater {
            id: menuEntriesRepeater
            property bool iconColumnNeeded: {
                for (let i = 0; i < menuOpener.children.values.length; i++) {
                    if (menuOpener.children.values[i].icon.length > 0)
                        return true;
                }
                return false;
            }
            property bool specialInteractionColumnNeeded: {
                for (let i = 0; i < menuOpener.children.values.length; i++) {
                    if (menuOpener.children.values[i].buttonType !== QsMenuButtonType.None)
                        return true;
                }
                return false;
            }
            model: menuOpener.children
            delegate: SysTrayMenuEntry {
                required property QsMenuEntry modelData
                forceIconColumn: menuEntriesRepeater.iconColumnNeeded
                forceSpecialInteractionColumn: menuEntriesRepeater.specialInteractionColumnNeeded
                menuEntry: modelData

                onDismiss: root.close()
                onOpenSubmenu: handle => {
                    stackView.push(subMenuComponent.createObject(null, {
                        handle: handle,
                        isSubMenu: true
                    }));
                }
            }
        }
    }

    Component {
        id: subMenuComponent
        SubMenu {}
    }
}
