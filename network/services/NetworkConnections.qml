pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    property var connections: []
    property bool active: false
    
    // Internal state for deltas
    property var _prevData: ({}) // pid -> { rx, tx, ts }
    
    Timer {
        id: refreshTimer
        interval: 2000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: ssProc.running = true
    }
    
    Process {
        id: ssProc
        // -n: no DNS, -t: TCP, -u: UDP, -p: process, -i: internal stats
        command: ["ss", "-ntupi"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                const now = Date.now();
                const lines = text.trim().split("\n");
                if (lines.length <= 1) {
                    root.connections = [];
                    return;
                }
                
                const grouped = {}; // appName -> { appName, pids, count, protocols, rx, tx }
                
                let currentConnection = null;
                
                for (let i = 1; i < lines.length; i++) {
                    const line = lines[i].trim();
                    if (!line) continue;
                    
                    if (line.startsWith("tcp") || line.startsWith("udp")) {
                        // Start of a new connection record
                        const parts = line.split(/\s+/);
                        if (parts.length < 6) continue;
                        
                        const protocol = parts[0].toUpperCase();
                        
                        let appName = "Unknown";
                        let pid = "N/A";
                        
                        const processPart = parts.slice(6).join(" ");
                        if (processPart) {
                            const nameMatch = processPart.match(/"([^"]+)"/);
                            const pidMatch = processPart.match(/pid=(\d+)/);
                            if (nameMatch) appName = nameMatch[1];
                            if (pidMatch) pid = pidMatch[1];
                        }
                        
                        if (appName === "Unknown" && pid === "N/A") continue;
                        
                        if (!grouped[appName]) {
                            grouped[appName] = {
                                appName: appName,
                                pids: new Set(),
                                count: 0,
                                protocols: new Set(),
                                rx: 0,
                                tx: 0
                            };
                        }
                        
                        currentConnection = grouped[appName];
                        currentConnection.count++;
                        currentConnection.protocols.add(protocol);
                        if (pid !== "N/A") currentConnection.pids.add(pid);
                        
                    } else if (currentConnection && line.includes("bytes_received")) {
                        // Stats line for the connection just parsed
                        const rxMatch = line.match(/bytes_received:(\d+)/);
                        const txMatch = line.match(/bytes_acked:(\d+)/); // acked = sent
                        
                        if (rxMatch) currentConnection.rx += parseInt(rxMatch[1]);
                        if (txMatch) currentConnection.tx += parseInt(txMatch[1]);
                    }
                }
                
                const finalConnections = [];
                const nextPrevData = {};
                
                for (const appName in grouped) {
                    const data = grouped[appName];
                    let rxSpeed = 0;
                    let txSpeed = 0;
                    
                    if (root._prevData[appName]) {
                        const prev = root._prevData[appName];
                        const dt = (now - prev.ts) / 1000.0;
                        if (dt > 0) {
                            rxSpeed = Math.max(0, (data.rx - prev.rx) * 8.0 / dt / 1048576.0);
                            txSpeed = Math.max(0, (data.tx - prev.tx) * 8.0 / dt / 1048576.0);
                        }
                    }
                    
                    nextPrevData[appName] = { rx: data.rx, tx: data.tx, ts: now };
                    
                    const pidsArr = Array.from(data.pids);
                    
                    finalConnections.push({
                        appName: data.appName,
                        pid: pidsArr.length === 1 ? pidsArr[0] : (pidsArr.length > 1 ? "Grouped" : "N/A"),
                        count: data.count,
                        protocols: Array.from(data.protocols).sort().join("/"),
                        rxSpeed: rxSpeed,
                        txSpeed: txSpeed
                    });
                }
                
                root._prevData = nextPrevData;
                root.connections = finalConnections.sort((a, b) => b.rxSpeed + b.txSpeed - (a.rxSpeed + a.txSpeed));
            }
        }
    }
}
