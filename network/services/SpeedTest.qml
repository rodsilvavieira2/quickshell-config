pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    property bool isTesting: false
    property string currentStage: "idle" // idle, ping, download, upload, cooldown
    property int stageTimeRemaining: 0
    
    property string downloadSpeed: "0 Mbps"
    property real liveDownloadMbps: 0.0
    property string uploadSpeed: "0 Mbps"
    property real liveUploadMbps: 0.0
    property string ping: "0 ms"
    property string jitter: "0 ms"
    property string packetLoss: "0.0 %"
    property real liveSpeed: 0.0
    
    property list<var> testHistory: []
    
    readonly property string dbPath: Quickshell.shellPath("network/speedtests.db")

    signal testFinished()
    signal pingPulse()

    function runTest() {
        if (isTesting) return
        isTesting = true
        currentStage = "ping"
        stageTimeRemaining = 15
        
        downloadSpeed = "Testing..."
        uploadSpeed = "Waiting..."
        ping = "Testing..."
        jitter = "Testing..."
        packetLoss = "Testing..."
        liveSpeed = 0
        
        pingProc.running = true
        stageTimer.start()
    }

    function cancelTest() {
        stageTimer.stop()
        if (!isTesting) return

        pingProc.running = false
        downloadProc.running = false
        uploadProc.running = false

        isTesting = false
        currentStage = "idle"
        downloadSpeed = "Canceled"
        uploadSpeed = "Canceled"
        ping = "Canceled"
        jitter = "Canceled"
        packetLoss = "Canceled"
        liveSpeed = 0

        cleanupProc.running = true
    }

    Timer {
        id: stageTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.stageTimeRemaining > 0) {
                root.stageTimeRemaining--
            }
        }
    }

    // Live Sampling Timer
    Timer {
        id: samplingTimer
        interval: 100
        repeat: true
        running: isTesting && (currentStage === "download" || currentStage === "upload")
        onTriggered: {
            if (currentStage === "download") {
                root.liveSpeed = NetSpeed.downloadMbps
            } else if (currentStage === "upload") {
                root.liveSpeed = NetSpeed.uploadMbps
            }
        }
    }

    Component.onCompleted: {
        initDbProc.running = true
    }

    Process {
        id: initDbProc
        command: ["sqlite3", root.dbPath, "CREATE TABLE IF NOT EXISTS speed_tests (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp TEXT, download TEXT, upload TEXT, ping TEXT, jitter TEXT, loss TEXT);"]
        onExited: loadDbProc.running = true
    }

    Process {
        id: loadDbProc
        command: ["sqlite3", "-json", root.dbPath, "SELECT timestamp, download, upload, ping, jitter, loss FROM speed_tests ORDER BY id DESC LIMIT 10;"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() === "") {
                    root.testHistory = []
                    return
                }
                try {
                    const data = JSON.parse(text)
                    root.testHistory = data
                } catch (e) {
                    root.testHistory = []
                }
            }
        }
    }

    Process {
        id: saveDbProc
        property string ts
        property string dl
        property string ul
        property string pg
        property string jt
        property string ls
        
        command: [
            "sqlite3", root.dbPath, 
            `INSERT INTO speed_tests (timestamp, download, upload, ping, jitter, loss) VALUES ('${ts}', '${dl}', '${ul}', '${pg}', '${jt}', '${ls}');`
        ]
    }

    Process {
        id: cleanupProc
        command: ["rm", "-f", "/tmp/speedtest.bin"]
    }

    // Step 1: Ping (15 seconds)
    Process {
        id: pingProc
        command: ["ping", "-c", "15", "-i", "1.0", "1.1.1.1"]
        stdout: SplitParser {
            onRead: data => {
                if (!root.isTesting) return
                if (data.includes("from")) {
                    root.pingPulse()
                }
            }
        }
        onExited: {
            if (!root.isTesting) return
            // Final stats from ping
            pingStatsProc.running = true
        }
    }

    Process {
        id: pingStatsProc
        command: ["ping", "-c", "1", "1.1.1.1"] // Get one more to parse stats or just use average
        stdout: StdioCollector {
            onStreamFinished: {
                // Since we can't easily get the summary from SplitParser without buffering,
                // we'll run a quick 3-ping burst for the final display value
                finalPingProc.running = true
            }
        }
    }

    Process {
        id: finalPingProc
        command: ["ping", "-c", "3", "1.1.1.1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const statsLine = lines[lines.length - 1]
                const lossLine = lines[lines.length - 2]
                
                const lossMatch = lossLine.match(/(\d+(\.\d+)?)% packet loss/)
                root.packetLoss = lossMatch ? parseFloat(lossMatch[1]).toFixed(1) + " %" : "0.0 %"
                
                if (statsLine.includes("rtt")) {
                    const parts = statsLine.split(" = ")[1].split("/")
                    root.ping = parseFloat(parts[1]).toFixed(1) + " ms"
                    root.jitter = parseFloat(parts[3]).toFixed(1) + " ms"
                }
                
                root.currentStage = "download"
                root.stageTimeRemaining = 30
                NetSpeed.active = true
                downloadProc.running = true
            }
        }
    }

    // Step 2: Download (30 seconds)
    Process {
        id: downloadProc
        command: ["timeout", "30", "curl", "-o", "/dev/null", "-s", "https://speed.cloudflare.com/__down?bytes=2000000000"]
        onExited: {
            if (!root.isTesting) return
            root.downloadSpeed = root.liveSpeed.toFixed(2) + " Mbps"
            root.currentStage = "upload"
            root.stageTimeRemaining = 30
            uploadProc.running = true
        }
    }

    // Step 3: Upload (30 seconds)
    Process {
        id: uploadProc
        command: ["bash", "-c",
            "dd if=/dev/zero bs=1M count=500 of=/tmp/speedtest.bin 2>/dev/null && " +
            "timeout 30 curl -X POST -T /tmp/speedtest.bin -o /dev/null -s https://speed.cloudflare.com/__up; " +
            "rm -f /tmp/speedtest.bin"]
        onExited: {
            if (!root.isTesting) return
            root.uploadSpeed = root.liveSpeed.toFixed(2) + " Mbps"
            
            const timestamp = new Date().toLocaleString()
            
            // Save to DB
            saveDbProc.ts = timestamp
            saveDbProc.dl = root.downloadSpeed
            saveDbProc.ul = root.uploadSpeed
            saveDbProc.pg = root.ping
            saveDbProc.jt = root.jitter
            saveDbProc.ls = root.packetLoss
            saveDbProc.running = true
            
            // Add to history
            const newResult = {
                timestamp: timestamp,
                download: root.downloadSpeed,
                upload: root.uploadSpeed,
                ping: root.ping,
                jitter: root.jitter,
                loss: root.packetLoss
            }
            const newHistory = root.testHistory.slice()
            newHistory.unshift(newResult)
            if (newHistory.length > 10) newHistory.pop()
            root.testHistory = newHistory
            
            root.isTesting = false
            root.liveSpeed = 0
            root.currentStage = "idle"
            root.testFinished()
            NetSpeed.active = false
        }
    }
}
