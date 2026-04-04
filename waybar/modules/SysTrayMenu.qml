import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

import ".." as Root
import "../shared/ui" as DS
import "../services"

PopupWindow {
    id: root
    required property var trayItemMenuHandle
    
    signal menuClosed()
    signal menuOpened(qsWindow: var)

    color: "transparent"
    property real padding: 8
    property int minMenuWidth: 248
    property int maxMenuWidth: 320
    readonly property int maxMenuContentHeight: Math.max(
        180,
        Math.min(520, Math.round((root.screen ? root.screen.height : 900) * 0.62))
    )

    readonly property Item currentMenuItem: stackView.currentItem

    implicitHeight: (currentMenuItem ? currentMenuItem.implicitHeight : 0) + menuPanel.padding * 2 + root.padding * 2
    implicitWidth: Math.min(
        root.maxMenuWidth,
        Math.max(
            root.minMenuWidth,
            (currentMenuItem ? currentMenuItem.implicitWidth : 0) + menuPanel.padding * 2 + root.padding * 2
        )
    )

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

        DS.Surface {
            id: menuPanel
            readonly property real padding: 6
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: root.padding
            }

            backgroundColor: Root.Config.surface1
            radius: 18
            borderWidth: 1
            borderColor: Root.Config.dividerColor
            shadowLevel: 2
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

    component SubMenu: Item {
        id: submenu
        required property var handle
        property bool isSubMenu: false
        readonly property int contentImplicitHeight: menuContent.implicitHeight
        readonly property int viewportHeight: Math.min(contentImplicitHeight, root.maxMenuContentHeight)

        implicitWidth: Math.max(root.minMenuWidth - menuPanel.padding * 2, menuContent.implicitWidth)
        implicitHeight: viewportHeight

        QsMenuOpener {
            id: menuOpener
            menu: submenu.handle
        }

        ScrollView {
            anchors.fill: parent
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Item {
                width: Math.max(parent.width, 1)
                implicitHeight: menuContent.implicitHeight

                ColumnLayout {
                    id: menuContent
                    width: parent.width
                    spacing: 2

                    Loader {
                        Layout.fillWidth: true
                        visible: submenu.isSubMenu
                        active: visible

                        sourceComponent: DS.SearchResultItem {
                            Layout.fillWidth: true
                            minHeight: 38
                            horizontalPadding: 14
                            verticalPadding: 8
                            itemRadius: 12
                            title: "Back"
                            leading: Component {
                                Text {
                                    text: "‹"
                                    color: Root.Config.text
                                    font.pixelSize: 16
                                }
                            }
                            onClicked: stackView.pop()
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
                            Layout.fillWidth: true
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
            }
        }
    }

    Component {
        id: subMenuComponent
        SubMenu {}
    }
}
