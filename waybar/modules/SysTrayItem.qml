import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import ".." as Root
import "../shared/ui" as DS
import "../services"

MouseArea {
    id: root
    property var item

    signal menuOpened(qsWindow: var)
    signal menuClosed()

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    implicitWidth: 32
    implicitHeight: 32
    cursorShape: Qt.PointingHandCursor

    onPressed: event => {
        switch (event.button) {
        case Qt.LeftButton:
            root.item.activate();
            break;
        case Qt.RightButton:
            if (root.item.hasMenu) menuLoader.open();
            break;
        case Qt.MiddleButton:
            TrayService.togglePin(root.item.id);
            break;
        }
        event.accepted = true;
    }

    onEntered: {
        tooltip.text = TrayService.getTooltipForItem(root.item);
    }

    Loader {
        id: menuLoader
        function open() {
            menuLoader.active = true;
        }
        active: false
        sourceComponent: SysTrayMenu {
            trayItemMenuHandle: root.item.menu
            anchor {
                window: root.QsWindow.window
                rect.x: root.mapToItem(null, 0, 0).x
                rect.y: root.mapToItem(null, 0, 0).y
                rect.height: root.height
                rect.width: root.width
                edges: Edges.Bottom | Edges.Left
                gravity: Edges.Bottom | Edges.Left
            }
            Component.onCompleted: this.open();
            onMenuOpened: (window) => root.menuOpened(window);
            onMenuClosed: {
                root.menuClosed();
                menuLoader.active = false;
            }
        }
    }

    DS.Surface {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        padding: 0
        radius: 999
        borderWidth: 0
        backgroundColor: root.containsMouse ? Qt.rgba(255/255, 255/255, 255/255, 0.14) : "transparent"

        IconImage {
            anchors.centerIn: parent
            source: root.item ? root.item.icon : ""
            width: 18
            height: 18
        }
    }

    ToolTip {
        id: tooltip
        visible: parent.containsMouse
        delay: 500
    }
}
