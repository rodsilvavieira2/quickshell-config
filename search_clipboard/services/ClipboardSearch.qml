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
    readonly property string previewDir: "/tmp/quickshell-clipboard-previews"

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

    function generatePreview(entry, callback) {
        const id = entry.split(/\t/)[0].trim();
        const previewPath = `${previewDir}/${id}.png`;
        
        // Check if it's binary/image
        if (!entry.includes("[[ binary data")) {
            return "";
        }

        const genProcess = Qt.createQmlObject('import Quickshell.Io; Process { }', root);
        const safe = entry.replace(/'/g, "'\\''");
        
        // cliphist decode the specific ID to a file
        genProcess.command = ["bash", "-c", `cliphist decode <<< '${safe}' > '${previewPath}'`];
        genProcess.exited.connect((exitCode) => {
            if (exitCode === 0) {
                callback("file://" + previewPath);
            }
            genProcess.destroy();
        });
        genProcess.running = true;
        return "file://" + previewPath; // Optimistic return or we handle async
    }
}
