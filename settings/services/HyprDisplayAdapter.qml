import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string scriptPath: Qt.resolvedUrl("../scripts/apply_hypr_monitors.sh").toString().replace("file://", "")
    property var monitors: []
    property bool busy: false

    function refresh() {
        refreshProc.running = true;
    }

    function currentModeIndex(monitor) {
        if (!monitor || !monitor.availableModes)
            return 0;

        const exactPrefix = `${monitor.width}x${monitor.height}@${Number(monitor.refreshRate).toFixed(2)}Hz`;
        let fallback = 0;

        for (let i = 0; i < monitor.availableModes.length; i++) {
            const mode = monitor.availableModes[i];
            if (mode === exactPrefix)
                return i;
            if (mode.startsWith(`${monitor.width}x${monitor.height}@`))
                fallback = i;
        }

        return fallback;
    }

    function applyMonitorSettings(name, mode, scale) {
        applyProc.targetName = name;
        applyProc.targetMode = mode;
        applyProc.targetScale = String(scale);
        applyProc.running = true;
    }

    Process {
        id: refreshProc
        command: ["hyprctl", "-j", "monitors"]
        stdout: StdioCollector {
            onStreamFinished: {
                const payload = text.trim();
                if (!payload.startsWith("[")) {
                    root.monitors = [];
                    return;
                }
                try {
                    root.monitors = JSON.parse(payload);
                } catch (error) {
                    console.warn("Failed to parse monitor state", error);
                }
            }
        }
    }

    Process {
        id: applyProc
        property string targetName: ""
        property string targetMode: ""
        property string targetScale: "1"
        command: [root.scriptPath, targetName, targetMode, targetScale]
        onRunningChanged: root.busy = running
        onExited: refresh()
    }
}
