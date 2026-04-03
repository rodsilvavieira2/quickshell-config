import QtQuick
import Quickshell
import Quickshell.Io

Item {
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

    function refresh() {
        cpuProc.running = true;
        memProc.running = true;
        gpuProc.running = true;
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; previdle=$idle; prevtotal=$((user+nice+system+idle+iowait+irq+softirq+steal)); sleep 0.2; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; idle=$idle; total=$((user+nice+system+idle+iowait+irq+softirq+steal)); diff_idle=$((idle-previdle)); diff_total=$((total-prevtotal)); usage=$((100*(diff_total-diff_idle)/diff_total)); temp=$(sensors | awk '/Package id 0:/ {print $4; exit} /Tctl:/ {print $2; exit} /Core 0:/ {print $3; exit}'); if [ -z \"$temp\" ]; then temp=$(sensors | grep -Eo '\\+[0-9]+\\.[0-9]°C' | head -n1); fi; echo \"${usage}|${temp//+/}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 2) {
                    root.cpuUsage = parseFloat(parts[0]) / 100.0;
                    root.cpuTemp = parts[1];
                }
            }
        }
    }

    Process {
        id: memProc
        command: ["bash", "-c", "free -m | awk 'NR==2{printf \"%.1f|%.1f|%.1f|%.1f\", $3/1024, $2/1024, $6/1024, $4/1024}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 4) {
                    root.memUsed = parseFloat(parts[0]);
                    root.memTotal = parseFloat(parts[1]);
                }
            }
        }
    }

    Process {
        id: gpuProc
        command: ["bash", "-c", "if command -v nvidia-smi &> /dev/null; then nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits | awk -F', ' '{printf \"%s|%s|%.1f|%.1f\\n\", $1, $2, $3/1024, $4/1024}'; else echo \"0|N/A|0|1\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 4) {
                    root.gpuUsage = parseFloat(parts[0]) / 100.0;
                    root.gpuTemp = parts[1] + "°C";
                    root.gpuMemUsed = parseFloat(parts[2]);
                    root.gpuMemTotal = parseFloat(parts[3]);
                    root.hasGpu = parts[1] !== "N/A";
                }
            }
        }
    }

    property Timer pollTimer: Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
