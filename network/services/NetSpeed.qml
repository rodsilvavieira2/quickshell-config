pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Controlled by shell.qml — start/stop polling with panel visibility
    property bool active: false

    // Auto-follows the active ethernet device from Nmcli
    readonly property string interfaceName: Nmcli.activeEthernet?.interface ?? ""

    // Current speeds in Mbps
    property real downloadMbps: 0.0
    property real uploadMbps: 0.0

    // History arrays — last 60 one-second samples (property var = JS array)
    property var downloadHistory: []
    property var uploadHistory: []
    readonly property int historySize: 60

    // Max observed speed across both histories (used to scale charts)
    // Adds 15% headroom so the peaks don't touch the top of the chart
    readonly property real maxObservedSpeed: {
        let max = 1.0
        for (let i = 0; i < downloadHistory.length; i++)
            if (downloadHistory[i] > max) max = downloadHistory[i]
        for (let i = 0; i < uploadHistory.length; i++)
            if (uploadHistory[i] > max) max = uploadHistory[i]
        return max * 1.15
    }

    // Internal state for delta calculation
    property real _prevRxBytes: -1.0
    property real _prevTxBytes: -1.0
    property real _lastPollMs: 0.0

    onActiveChanged: {
        if (active && interfaceName.length > 0) {
            pollTimer.start()
        } else {
            pollTimer.stop()
            downloadMbps = 0.0
            uploadMbps = 0.0
        }
    }

    onInterfaceNameChanged: {
        // Reset accumulated state whenever the monitored interface changes
        _prevRxBytes = -1.0
        _prevTxBytes = -1.0
        downloadMbps = 0.0
        uploadMbps = 0.0
        downloadHistory = []
        uploadHistory = []
        // Restart polling if already active
        if (active && interfaceName.length > 0) {
            pollTimer.restart()
        }
    }

    // Fire every second; skip if previous process is still running (safety guard)
    Timer {
        id: pollTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (!pollProc.running && root.interfaceName.length > 0)
                pollProc.running = true
        }
    }

    // Single-shot awk read of /proc/net/dev — exits instantly, no pipe-buffering issues
    // awk matches the exact interface field ($1 == "eth0:") and prints rx_bytes tx_bytes
    Process {
        id: pollProc
        // command rebuilds whenever interfaceName changes (QML binding)
        command: ["awk", "-v", "iface=" + root.interfaceName + ":",
                  "$1 == iface {print $2, $10}", "/proc/net/dev"]

        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim()
                if (!line) return

                const parts = line.split(/\s+/)
                if (parts.length < 2) return

                const rx = parseFloat(parts[0])
                const tx = parseFloat(parts[1])
                if (isNaN(rx) || isNaN(tx)) return

                const now = Date.now()

                if (root._prevRxBytes >= 0) {
                    const dt = (now - root._lastPollMs) / 1000.0
                    if (dt > 0) {
                        // Convert byte delta → Mbps: Δbytes × 8 bits / dt seconds / 1048576
                        const dl = Math.max(0, (rx - root._prevRxBytes) * 8.0 / dt / 1048576.0)
                        const ul = Math.max(0, (tx - root._prevTxBytes) * 8.0 / dt / 1048576.0)

                        root.downloadMbps = dl
                        root.uploadMbps = ul

                        // Append to history, capped at historySize samples
                        const dlHist = root.downloadHistory.slice()
                        dlHist.push(dl)
                        if (dlHist.length > root.historySize) dlHist.shift()
                        root.downloadHistory = dlHist

                        const ulHist = root.uploadHistory.slice()
                        ulHist.push(ul)
                        if (ulHist.length > root.historySize) ulHist.shift()
                        root.uploadHistory = ulHist
                    }
                }

                root._prevRxBytes = rx
                root._prevTxBytes = tx
                root._lastPollMs = now
            }
        }
    }
}
