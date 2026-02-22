pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property string config: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0]
    readonly property string state: StandardPaths.standardLocations(StandardPaths.StateLocation)[0]
    readonly property string cache: StandardPaths.standardLocations(StandardPaths.CacheLocation)[0]

    property string notificationsPath: `${root.cache}/notifications/notifications.json`
    property string notificationsDir: `${root.cache}/notifications`
}
