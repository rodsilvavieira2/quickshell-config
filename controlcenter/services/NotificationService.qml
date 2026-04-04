import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property var notifications: []
    property bool dnd: false
    property int maxNotifications: 120
    property int maxFloatingNotifications: 2

    readonly property var recentNotifications: notifications
        .filter(notif => (Date.now() - notif.timestamp.getTime()) < 24 * 60 * 60 * 1000)
        .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
    readonly property var floatingNotifications: notifications
        .filter(notif => notif.popupVisible)
        .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
        .slice(0, maxFloatingNotifications)

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
        wrapper.showPopup();
        root.pruneFloatingNotifications();
    }

    function pruneFloatingNotifications() {
        const sorted = root.notifications
            .filter(notif => notif && notif.popupVisible)
            .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());

        sorted.forEach((notif, index) => {
            if (index >= root.maxFloatingNotifications) {
                notif.hidePopup();
            }
        });
    }

    function toggleDnd() {
        dnd = !dnd;
    }

    function clearAll() {
        const current = root.notifications.slice();
        current.forEach(notif => {
            if (notif) {
                notif.remove();
            }
        });
        root.notifications = [];
    }

    function deleteNotification(notif) {
        if (!notif || !root.notifications.includes(notif)) {
            return;
        }

        notif.remove();
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
        property bool serverClosed: false
        property bool popupVisible: false
        property bool popupPaused: false
        property int popupDuration: 6000

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

            const messageLength = (summary + " " + body).trim().length;
            const readingDuration = 9000 + Math.min(9000, messageLength * 55);

            if (urgency >= 2) {
                popupDuration = 0;
            } else if (actions.length > 0) {
                popupDuration = Math.max(14000, readingDuration);
            } else {
                popupDuration = Math.max(12000, readingDuration);
            }
        }

        function invokeAction(actionId) {
            const action = actions.find(item => item.identifier === actionId);
            if (action && action.invoke) {
                action.invoke();
            }
        }

        function showPopup() {
            popupVisible = true;
            popupPaused = false;
            restartPopupTimer();
        }

        function hidePopup() {
            popupVisible = false;
            popupPaused = false;
            popupTimer.stop();
        }

        function pausePopup() {
            popupPaused = true;
            popupTimer.stop();
        }

        function resumePopup() {
            popupPaused = false;
            restartPopupTimer();
        }

        function restartPopupTimer() {
            popupTimer.stop();
            if (popupVisible && !popupPaused && popupDuration > 0) {
                popupTimer.interval = popupDuration;
                popupTimer.start();
            }
        }

        function close() {
            if (closed) {
                return;
            }

            closed = true;
            hidePopup();
            if (notification) {
                notification.dismiss();
            }
        }

        function remove() {
            popupTimer.stop();
            popupVisible = false;
            popupPaused = false;

            const activeNotification = notification;
            notification = null;

            root.notifications = root.notifications.filter(item => item !== notifWrapper);

            if (activeNotification) {
                activeNotification.dismiss();
            }

            notifWrapper.destroy();
        }

        readonly property Timer popupTimer: Timer {
            id: popupTimer
            interval: notifWrapper.popupDuration
            repeat: false
            running: false
            onTriggered: notifWrapper.hidePopup()
        }

        readonly property Connections conn: Connections {
            target: notifWrapper.notification

            function onClosed() {
                notifWrapper.closed = true;
                notifWrapper.serverClosed = true;
                notifWrapper.notification = null;
            }

            function onSummaryChanged() {
                notifWrapper.syncFromNotification();
                notifWrapper.restartPopupTimer();
            }

            function onBodyChanged() {
                notifWrapper.syncFromNotification();
                notifWrapper.restartPopupTimer();
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
                notifWrapper.restartPopupTimer();
            }

            function onActionsChanged() {
                notifWrapper.syncFromNotification();
                notifWrapper.restartPopupTimer();
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
