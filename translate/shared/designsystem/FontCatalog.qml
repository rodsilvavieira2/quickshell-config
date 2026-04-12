pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string defaultTextFamily: "Noto Sans"
    readonly property string defaultIconFamily: "JetBrainsMono Nerd Font"

    readonly property var entries: [
        { id: "noto-sans", label: "Noto Sans", family: "Noto Sans", category: "Sans moderna" },
        { id: "inter", label: "Inter", family: "Inter", category: "Sans neutra" },
        { id: "jetbrains-mono", label: "JetBrainsMono Nerd Font", family: "JetBrainsMono Nerd Font", category: "Mono opcional" }
    ]

    function resolveTextFamily(requestedFamily) {
        if (!requestedFamily || requestedFamily.trim() === "") {
            return root.defaultTextFamily;
        }

        for (let i = 0; i < root.entries.length; i++) {
            if (root.entries[i].family === requestedFamily) {
                return root.entries[i].family;
            }
        }

        return root.defaultTextFamily;
    }
}
