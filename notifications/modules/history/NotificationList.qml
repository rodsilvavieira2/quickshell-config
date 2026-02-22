import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../../common/widgets"
import "../../services"
import "."

Item {
    id: root

    NotificationListView {
        id: listview
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: statusRow.top
        anchors.bottomMargin: 6
        clip: true
        popup: false
    }

    PagePlaceholder {
        anchors.fill: parent
        shown: Notifications.list.length === 0
        icon: "notifications"
        description: "Nothing here"
    }

    RowLayout {
        id: statusRow
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        
        NotificationStatusButton {
            Layout.fillWidth: false
            buttonIcon: "notifications_paused"
            toggled: Notifications.silent
            onClicked: () => {
                Notifications.silent = !Notifications.silent
            }
        }
        NotificationStatusButton {
            enabled: false
            Layout.fillWidth: true
            buttonText: `${Notifications.list.length} notifications`
        }
        NotificationStatusButton {
            Layout.fillWidth: false
            buttonIcon: "delete_sweep"
            onClicked: () => {
                Notifications.discardAllNotifications()
            }
        }
    }
}
