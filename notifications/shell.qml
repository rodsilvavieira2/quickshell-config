//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma IconTheme "Suru++"
//@ pragma Env QS_ICON_THEME=Suru++

import QtQuick
import Quickshell
import Quickshell.Io

import "./modules/notificationPopup"
import "./modules/history"
import "./services"
import "./common"
import "./common/widgets"

ShellRoot {
    id: shellRoot

    NotificationPopup {}
    NotificationPanel {}

    IpcHandler {
        target: "notifications"

        function toggle() {
            GlobalStates.panelOpen = !GlobalStates.panelOpen
        }
        function open() {
            GlobalStates.panelOpen = true
        }
        function close() {
            GlobalStates.panelOpen = false
        }
        function clear() {
            Notifications.discardAllNotifications()
        }
        function silent() {
            Notifications.silent = true
        }
        function unsilent() {
            Notifications.silent = false
        }
    }
}
