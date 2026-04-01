pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var data: ({
        "title": "",
        "artist": "",
        "status": "Stopped",
        "timeStr": "--:-- / --:--",
        "artUrl": ""
    })

    readonly property bool isActive: data.status !== "Stopped" && data.title !== ""

    readonly property string scriptPath: Qt.resolvedUrl("../../music/music_info.sh").toString().replace(/^file:\/\//, "")

    function _fallbackData() {
        return {
            "title": "",
            "artist": "",
            "status": "Stopped",
            "timeStr": "--:-- / --:--",
            "artUrl": ""
        };
    }

    Process {
        id: poller
        command: ["bash", "-c", root.scriptPath]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim();
                if (out.length === 0) {
                    return;
                }

                try {
                    const parsed = JSON.parse(out);
                    root.data = {
                        "title": parsed.title ?? "",
                        "artist": parsed.artist ?? "",
                        "status": parsed.status ?? "Stopped",
                        "timeStr": parsed.timeStr ?? "--:-- / --:--",
                        "artUrl": parsed.artUrl ?? ""
                    };
                } catch (e) {
                    root.data = root._fallbackData();
                }
            }
        }
    }

    Timer {
        interval: 700
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!poller.running) {
                poller.running = true;
            }
        }
    }
}
