import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Component.onCompleted: {
        console.log("Toplevels length: " + ToplevelManager.toplevels.values.length);
        for (var i = 0; i < ToplevelManager.toplevels.values.length; i++) {
            var tl = ToplevelManager.toplevels.values[i];
            console.log("App id: " + tl.appId + ", Title: " + tl.title);
        }
        Qt.quit();
    }
}
