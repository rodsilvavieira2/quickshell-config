pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject options: QtObject {
        property QtObject notifications: QtObject {
            property int timeout: 7000
            property bool showUnreadCount: true
        }
        property QtObject panel: QtObject {
            property int width: 380
        }
    }
}
