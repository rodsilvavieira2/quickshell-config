import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property var notifications: []
    property bool dnd: false
    property int maxNotifications: 120

    readonly property var recentNotifications: notifications
        .filter(notif => (Date.now() - notif.timestamp.getTime()) < 24 * 60 * 60 * 1000)
        .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())

    function addNotification(notification) {
        if (!notification) {
            return;
        }

        if (dnd && notification.urgency < 2) {
            notification.dismiss();
            return;
        }

        notification.tracked = true;
        const wrapper = notifComponent.createObject(root, {
            notification: notification
        });

        root.notifications = [wrapper, ...root.notifications].slice(0, root.maxNotifications);
    }

    function toggleDnd() {
        dnd = !dnd;
    }

    function clearAll() {
        const current = root.notifications.slice();
        current.forEach(notif => {
            if (notif) {
                notif.close();
            }
        });
        root.notifications = [];
    }

    function deleteNotification(notif) {
        if (!notif || !root.notifications.includes(notif)) {
            return;
        }

        root.notifications = root.notifications.filter(item => item !== notif);
        notif.close();
    }

    component Notif: QtObject {
        id: notifWrapper

        property var notification: null
        property date timestamp: new Date()
        property int notifId: -1
        property string summary: ""
        property string body: ""
        property string appName: ""
        property string appIcon: ""
        property string image: ""
        property int urgency: 1
        property var actions: []
        property bool closed: false

        readonly property string timeString: {
            const diffMs = Date.now() - timestamp.getTime();
            const minutes = Math.floor(diffMs / 60000);
            const hours = Math.floor(minutes / 60);
            const days = Math.floor(hours / 24);

            if (days > 0) {
                return days + "d ago";
            }
            if (hours > 0) {
                return hours + "h ago";
            }
            if (minutes > 0) {
                return minutes + "m ago";
            }
            return "Just now";
        }

        function syncFromNotification() {
            if (!notification) {
                return;
            }

            notifId = notification.id !== undefined && notification.id !== null ? notification.id : -1;
            summary = notification.summary !== undefined && notification.summary !== null ? notification.summary : "";
            body = notification.body !== undefined && notification.body !== null ? notification.body : "";
            appName = notification.appName !== undefined && notification.appName !== null ? notification.appName : "";
            appIcon = notification.appIcon !== undefined && notification.appIcon !== null ? notification.appIcon : "";
            image = notification.image !== undefined && notification.image !== null ? notification.image : "";
            urgency = notification.urgency !== undefined && notification.urgency !== null ? notification.urgency : 1;
            const notifActions = notification.actions !== undefined && notification.actions !== null ? notification.actions : [];
            actions = notifActions.map(action => ({
                identifier: action.identifier,
                text: action.text,
                invoke: () => action.invoke()
            }));
        }

        function invokeAction(actionId) {
            const action = actions.find(item => item.identifier === actionId);
            if (action && action.invoke) {
                action.invoke();
            }
        }

        function close() {
            if (closed) {
                return;
            }

            closed = true;
            if (notification) {
                notification.dismiss();
            }
        }

        readonly property Connections conn: Connections {
            target: notifWrapper.notification

            function onClosed() {
                notifWrapper.closed = true;
                root.notifications = root.notifications.filter(item => item !== notifWrapper);
                notifWrapper.destroy();
            }

            function onSummaryChanged() {
                notifWrapper.syncFromNotification();
            }

            function onBodyChanged() {
                notifWrapper.syncFromNotification();
            }

            function onAppNameChanged() {
                notifWrapper.syncFromNotification();
            }

            function onAppIconChanged() {
                notifWrapper.syncFromNotification();
            }

            function onImageChanged() {
                notifWrapper.syncFromNotification();
            }

            function onUrgencyChanged() {
                notifWrapper.syncFromNotification();
            }

            function onActionsChanged() {
                notifWrapper.syncFromNotification();
            }
        }

        Component.onCompleted: {
            syncFromNotification();
        }
    }

    Component {
        id: notifComponent
        Notif {}
    }
}
