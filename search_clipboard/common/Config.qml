pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject options: QtObject {
        property QtObject search: QtObject {
            property int resultLimit: 20
            property int debounceMs: 60
        }

        property QtObject clipboard: QtObject {
            property int maxEntries: 50
        }
    }
}
