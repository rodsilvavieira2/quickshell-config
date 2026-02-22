pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../common"

Singleton {
    id: root
    component Notif: QtObject {
        id: wrapper
        required property int notificationId
        property Notification notification
        property list<var> actions: (notification ? notification.actions : []).map((action) => ({
            "identifier": action.identifier,
            "text": action.text
        }))
        property bool popup: false
        property bool isTransient: notification && notification.hints ? (notification.hints.transient !== undefined ? notification.hints.transient : false) : false
        property string appIcon: notification ? (notification.appIcon !== undefined ? notification.appIcon : "") : ""
        property string appName: notification ? (notification.appName !== undefined ? notification.appName : "") : ""
        property string body: notification ? (notification.body !== undefined ? notification.body : "") : ""
        property string image: notification ? (notification.image !== undefined ? notification.image : "") : ""
        property string summary: notification ? (notification.summary !== undefined ? notification.summary : "") : ""
        property double time
        property string urgency: notification ? (notification.urgency.toString ? (notification.urgency.toString() ? notification.urgency.toString() : "normal") : "normal") : "normal"
        property Timer timer

        onNotificationChanged: {
            if (notification === null) {
                root.discardNotification(notificationId)
            }
        }
    }

    function notifToJSON(notif) {
        return {
            "notificationId": notif.notificationId,
            "actions": notif.actions,
            "appIcon": notif.appIcon,
            "appName": notif.appName,
            "body": notif.body,
            "image": notif.image,
            "summary": notif.summary,
            "time": notif.time,
            "urgency": notif.urgency
        }
    }

    component NotifTimer: Timer {
        required property int notificationId
        interval: 7000
        running: true
        onTriggered: () => {
            const index = root.list.findIndex((notif) => notif.notificationId === notificationId)
            const notifObject = root.list[index]
            if (notifObject && notifObject.isTransient) root.discardNotification(notificationId)
            else root.timeoutNotification(notificationId)
            destroy()
        }
    }

    property bool silent: false
    property int unread: 0
    property string filePath: Directories.notificationsPath
    property list<Notif> list: []
    property var popupList: list.filter((notif) => notif.popup)
    property bool popupInhibited: (GlobalStates ? GlobalStates.panelOpen : false) || silent
    property var latestTimeForApp: ({})
    Component {
        id: notifComponent
        Notif {}
    }
    Component {
        id: notifTimerComponent
        NotifTimer {}
    }

    function stringifyList(list) {
        return JSON.stringify(list.map((notif) => notifToJSON(notif)), null, 2)
    }

    onListChanged: {
        root.list.forEach((notif) => {
            if (!root.latestTimeForApp[notif.appName] || notif.time > root.latestTimeForApp[notif.appName]) {
                root.latestTimeForApp[notif.appName] = Math.max(root.latestTimeForApp[notif.appName] ? root.latestTimeForApp[notif.appName] : 0, notif.time)
            }
        })
        Object.keys(root.latestTimeForApp).forEach((appName) => {
            if (!root.list.some((notif) => notif.appName === appName)) {
                delete root.latestTimeForApp[appName]
            }
        })
    }

    function appNameListForGroups(groups) {
        return Object.keys(groups).sort((a, b) => {
            return groups[b].time - groups[a].time
        })
    }

    function groupsForList(list) {
        const groups = {}
        list.forEach((notif) => {
            if (!groups[notif.appName]) {
                groups[notif.appName] = {
                    appName: notif.appName,
                    appIcon: notif.appIcon,
                    notifications: [],
                    time: 0
                }
            }
            groups[notif.appName].notifications.push(notif)
            groups[notif.appName].time = latestTimeForApp[notif.appName] ? latestTimeForApp[notif.appName] : notif.time
        })
        return groups
    }

    property var groupsByAppName: groupsForList(root.list)
    property var popupGroupsByAppName: groupsForList(root.popupList)
    property list<string> appNameList: appNameListForGroups(root.groupsByAppName)
    property list<string> popupAppNameList: appNameListForGroups(root.popupGroupsByAppName)

    property int idOffset: 0
    signal initDone()
    signal notify(notification: var)
    signal discard(id: int)
    signal discardAll()
    signal timeout(id: var)

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true

        onNotification: (notification) => {
            notification.tracked = true
            const newNotifObject = notifComponent.createObject(root, {
                "notificationId": notification.id + root.idOffset,
                "notification": notification,
                "time": Date.now()
            })
            root.list = [...root.list, newNotifObject]

            if (!root.popupInhibited) {
                newNotifObject.popup = true
                if (notification.expireTimeout != 0) {
                    newNotifObject.timer = notifTimerComponent.createObject(root, {
                        "notificationId": newNotifObject.notificationId,
                        "interval": notification.expireTimeout < 0 ? (Config ? (Config.options.notifications.timeout !== undefined ? Config.options.notifications.timeout : 7000) : 7000) : notification.expireTimeout
                    })
                }
                root.unread++
            }
            root.notify(newNotifObject)
            notifFileView.setText(stringifyList(root.list))
        }
    }

    function markAllRead() {
        root.unread = 0
    }

    function discardNotification(id) {
        const index = root.list.findIndex((notif) => notif.notificationId === id)
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => notif.id + root.idOffset === id)
        if (index !== -1) {
            root.list.splice(index, 1)
            notifFileView.setText(stringifyList(root.list))
            triggerListChange()
        }
        if (notifServerIndex !== -1) {
            notifServer.trackedNotifications.values[notifServerIndex].dismiss()
        }
        root.discard(id)
    }

    function discardAllNotifications() {
        root.list = []
        triggerListChange()
        notifFileView.setText(stringifyList(root.list))
        notifServer.trackedNotifications.values.forEach((notif) => {
            notif.dismiss()
        })
        root.discardAll()
    }

    function cancelTimeout(id) {
        const index = root.list.findIndex((notif) => notif.notificationId === id)
        if (root.list[index] != null)
            root.list[index].timer.stop()
    }

    function timeoutNotification(id) {
        const index = root.list.findIndex((notif) => notif.notificationId === id)
        if (root.list[index] != null)
            root.list[index].popup = false
        root.timeout(id)
    }

    function timeoutAll() {
        root.popupList.forEach((notif) => {
            root.timeout(notif.notificationId)
        })
        root.popupList.forEach((notif) => {
            notif.popup = false
        })
    }

    function attemptInvokeAction(id, notifIdentifier) {
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => notif.id + root.idOffset === id)
        if (notifServerIndex !== -1) {
            const notifServerNotif = notifServer.trackedNotifications.values[notifServerIndex]
            const action = notifServerNotif.actions.find((action) => action.identifier === notifIdentifier)
            if (action) action.invoke()
        }
        root.discardNotification(id)
    }

    function triggerListChange() {
        root.list = root.list.slice(0)
    }

    function refresh() {
        notifFileView.reload()
    }

    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", Directories.notificationsDir])
        refresh()
    }

    FileView {
        id: notifFileView
        path: Qt.resolvedUrl(filePath)
        onLoaded: {
            const fileContents = notifFileView.text()
            root.list = JSON.parse(fileContents).map((notif) => {
                return notifComponent.createObject(root, {
                    "notificationId": notif.notificationId,
                    "actions": [],
                    "appIcon": notif.appIcon,
                    "appName": notif.appName,
                    "body": notif.body,
                    "image": notif.image,
                    "summary": notif.summary,
                    "time": notif.time,
                    "urgency": notif.urgency
                })
            })

            let maxId = 0
            root.list.forEach((notif) => {
                maxId = Math.max(maxId, notif.notificationId)
            })

            root.idOffset = maxId
            root.initDone()
        }
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                root.list = []
                notifFileView.setText(stringifyList(root.list))
            }
        }
    }
}
