pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property var connections: []
    property bool active: false
    
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
        command: ["ss", "-ntup"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length <= 1) {
                    root.connections = [];
                    return;
                }
                
                const newConnections = [];
                // Skip header
                for (let i = 1; i < lines.length; i++) {
                    const line = lines[i].trim();
                    if (!line) continue;
                    
                    // ss output can be tricky because columns might be merged or have spaces
                    // A common pattern is: Netid State Recv-Q Send-Q Local Address:Port Peer Address:Port Process
                    const parts = line.split(/\s+/);
                    if (parts.length < 6) continue;
                    
                    const protocol = parts[0];
                    const state = parts[1];
                    const localAddr = parts[4];
                    const foreignAddr = parts[5];
                    
                    let appName = "Unknown";
                    let pid = "N/A";
                    
                    // Process info is usually in the last part: users:(("name",pid=123,fd=4))
                    const processPart = parts.slice(6).join(" ");
                    if (processPart) {
                        const nameMatch = processPart.match(/"([^"]+)"/);
                        const pidMatch = processPart.match(/pid=(\d+)/);
                        
                        if (nameMatch) appName = nameMatch[1];
                        if (pidMatch) pid = pidMatch[1];
                    }
                    
                    newConnections.push({
                        protocol: protocol,
                        state: state,
                        localAddress: localAddr,
                        foreignAddress: foreignAddr,
                        appName: appName,
                        pid: pid
                    });
                }
                
                root.connections = newConnections;
            }
        }
    }
}
