import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real brightness: 0.5
    property int percentage: Math.round(brightness * 100)
    property int maxValue: 100
    property int currentValue: 50
    property bool available: false

    function refresh() {
        if (!readProc.running) {
            readProc.running = true;
        }
    }

    function setBrightness(value) {
        const clamped = Math.max(0, Math.min(1, value));
        setProc.command = ["brightnessctl", "set", Math.round(clamped * 100) + "%"];
        setProc.running = true;
    }

    function increaseBrightness() {
        setBrightness(brightness + 0.05);
    }

    function decreaseBrightness() {
        setBrightness(brightness - 0.05);
    }

    Process {
        id: readProc
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const line = lines.length > 0 ? lines[0] : "";
                const parts = line.split(",");
                if (parts.length < 4) {
                    root.available = false;
                    return;
                }

                const current = parseInt(parts.length > 2 ? parts[2] : "0", 10);
                const max = parseInt(parts.length > 3 ? parts[3] : "0", 10);
                const percentText = (parts.length > 4 ? parts[4] : "").replace("%", "");
                const parsedPercent = parseInt(percentText, 10);

                if (isNaN(current) || isNaN(max) || max <= 0) {
                    root.available = false;
                    return;
                }

                root.currentValue = current;
                root.maxValue = max;
                root.available = true;

                if (!isNaN(parsedPercent)) {
                    root.brightness = Math.max(0, Math.min(1, parsedPercent / 100));
                } else {
                    root.brightness = Math.max(0, Math.min(1, current / max));
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.available = false;
                }
            }
        }
    }

    Process {
        id: setProc

        onExited: {
            refreshDelay.restart();
        }
    }

    Timer {
        id: pollTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: refreshDelay
        interval: 150
        onTriggered: root.refresh()
    }
}
