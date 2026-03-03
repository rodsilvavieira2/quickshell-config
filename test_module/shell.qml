import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Component.onCompleted: {
        var toplevels = Hyprland.toplevels.values;
        console.log("Hyprland toplevels length: " + toplevels.length);
        if (toplevels.length > 0) {
            var tl = toplevels[0];
            console.log("Keys: " + Object.keys(tl));
            console.log("Class: " + tl.windowClass + ", Title: " + tl.title + ", Workspace: " + (tl.workspace ? tl.workspace.id : "null"));
            console.log("Last IPC object keys: " + (tl.lastIpcObject ? Object.keys(tl.lastIpcObject) : "null"));
            if (tl.lastIpcObject) console.log("IPC class: " + tl.lastIpcObject.class);
        }
        Qt.quit();
    }
}
