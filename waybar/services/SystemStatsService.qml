pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuUsage: 0
    property string cpuTemp: "..."
    property real memUsed: 0
    property real memTotal: 1
    property real gpuUsage: 0
    property string gpuTemp: "..."
    property real gpuMemUsed: 0
    property real gpuMemTotal: 1
    property bool hasGpu: false
    readonly property string statsScriptPath: Qt.resolvedUrl("system_stats.py").toString().replace("file://", "")

    function refresh() {
        statsProc.running = true;
    }

    Process {
        id: statsProc
        command: ["python3", root.statsScriptPath]
        stdout: StdioCollector {
            onStreamFinished: {
                const payload = text.trim();
                if (!payload.length)
                    return;

                try {
                    const data = JSON.parse(payload);
                    root.cpuUsage = typeof data.cpu_usage === "number" ? data.cpu_usage : 0;
                    root.cpuTemp = data.cpu_temp || "...";
                    root.memUsed = typeof data.mem_used === "number" ? data.mem_used : 0;
                    root.memTotal = typeof data.mem_total === "number" && data.mem_total > 0 ? data.mem_total : 1;
                    root.gpuUsage = typeof data.gpu_usage === "number" ? data.gpu_usage : 0;
                    root.gpuTemp = data.gpu_temp || "...";
                    root.gpuMemUsed = typeof data.gpu_mem_used === "number" ? data.gpu_mem_used : 0;
                    root.gpuMemTotal = typeof data.gpu_mem_total === "number" && data.gpu_mem_total > 0 ? data.gpu_mem_total : 1;
                    root.hasGpu = !!data.has_gpu;
                } catch (error) {
                    console.warn("SystemStatsService parse error:", error, payload);
                }
            }
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
