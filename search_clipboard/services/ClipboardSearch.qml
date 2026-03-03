pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"
import "../common/functions"

Singleton {
    id: root

    property var entries: []
    property bool ready: false

    Process {
        id: listProcess
        command: ["bash", "-c", "cliphist list"]
        stdout: StdioCollector {
            id: listCollector
            onStreamFinished: {
                const lines = listCollector.text.split(/\r?\n/).filter(l => l.length > 0);
                root.entries = lines.slice(0, Config.options.clipboard.maxEntries);
                root.ready = true;
            }
        }
    }

    function refresh() {
        listProcess.running = false;
        listProcess.running = true;
    }

    function decode(entry, callback) {
        const decodeProcess = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        const safe = entry.replace(/'/g, "'\\''");
        decodeProcess.command = ["bash", "-c", `cliphist decode <<< '${safe}' | wl-copy`];
        decodeProcess.exited.connect((exitCode) => {
            if (callback) callback();
            decodeProcess.destroy();
        });
        decodeProcess.running = true;
    }
}
