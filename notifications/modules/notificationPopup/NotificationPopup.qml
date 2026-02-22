import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../common/widgets"
import "../../services"

Scope {
    id: notificationPopup

    PanelWindow {
        id: root
        visible: Notifications.popupList.length > 0
        screen: {
            const focusedName = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedName) {
                    return Quickshell.screens.values[i]
                }
            }
            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null
        }

        WlrLayershell.namespace: "quickshell:notificationsPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: true
            right: true
            bottom: true
        }

        mask: Region {
            item: listview.contentItem
        }

        color: "transparent"
        implicitWidth: Appearance ? Appearance.sizes.notificationPopupWidth : 360

        NotificationListView {
            id: listview
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                rightMargin: 6
                topMargin: 15
            }
            implicitWidth: parent.width - Appearance.sizes.elevationMargin * 2
            popup: true
            clip: true
        }
    }
}
