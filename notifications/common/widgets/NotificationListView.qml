pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import ".."
import "../../services"

StyledListView {
    id: root
    property bool popup: false

    spacing: 4

    model: ScriptModel {
        values: root.popup ? Notifications.popupAppNameList : Notifications.appNameList
    }
    delegate: NotificationGroup {
        required property int index
        required property var modelData
        popup: root.popup
        width: ListView.view.width
        notificationGroup: popup ?
            Notifications.popupGroupsByAppName[modelData] :
            Notifications.groupsByAppName[modelData]
    }
}
