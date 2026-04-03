import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string cachePath: Quickshell.env("HOME") + "/.cache/current_wallpaper"
    property string currentWallpaper: ""

    function refresh() {
        refreshProc.running = true;
    }

    Process {
        id: refreshProc
        command: ["bash", "-lc", `cat "${root.cachePath}" 2>/dev/null || true`]
        stdout: StdioCollector {
            onStreamFinished: root.currentWallpaper = text.trim()
        }
    }
}
