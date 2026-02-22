pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject options: QtObject {
        property QtObject search: QtObject {
            property int resultLimit: 20
            property int maxPerCategory: 6
            property bool showDefaultActionsWithoutPrefix: true
            property int debounceMs: 60
            property string engineBaseUrl: "https://www.google.com/search?q="
            property bool enableApps: true
            property bool enableMath: true
            property bool enableCommands: true
            property bool enableWeb: true
            property bool enableClipboard: true
            property bool enableEmojis: true
            property bool enableActions: true
            property QtObject prefix: QtObject {
                property string action: "/"
                property string app: ">"
                property string clipboard: ";"
                property string emojis: ":"
                property string math: "="
                property string shellCommand: "$"
                property string webSearch: "?"
            }
        }

        property QtObject apps: QtObject {
            property string terminal: "kitty -1"
        }

        property QtObject clipboard: QtObject {
            property int maxEntries: 50
        }
    }
}
