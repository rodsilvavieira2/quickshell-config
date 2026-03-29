pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool isTesting: false
    property string downloadSpeed: "0 Mbps"
    property string uploadSpeed: "0 Mbps"
    property string ping: "0 ms"
    property string jitter: "0 ms"
    property string packetLoss: "0.0 %"
    property list<var> testHistory: []

    signal testFinished()

    function runTest(interfaceName) {
        if (isTesting) return
        isTesting = true
        downloadSpeed = "Testing..."
        uploadSpeed = "Waiting..."
        ping = "Testing..."
        jitter = "Testing..."
        packetLoss = "Testing..."
        pingProc.running = true
    }

    function cancelTest() {
        if (!isTesting) return

        pingProc.running = false
        downloadProc.running = false
        uploadProc.running = false

        isTesting = false
        downloadSpeed = "Canceled"
        uploadSpeed = "Canceled"
        ping = "Canceled"
        jitter = "Canceled"
        packetLoss = "Canceled"

        cleanupProc.running = true
    }

    Process {
        id: cleanupProc
        command: ["rm", "-f", "/tmp/speedtest.bin"]
    }

    // Step 1: Ping (10 probes for better jitter/loss stats)
    Process {
        id: pingProc
        command: ["ping", "-c", "10", "1.1.1.1"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isTesting) return
                const lines = text.trim().split("\n")
                if (lines.length < 2) {
                    root.ping = "Error"
                    root.jitter = "Error"
                    root.packetLoss = "Error"
                } else {
                    const statsLine = lines[lines.length - 1]
                    const lossLine = lines[lines.length - 2]
                    
                    // Parse loss: "10 packets transmitted, 10 received, 0% packet loss, time 9013ms"
                    const lossMatch = lossLine.match(/(\d+(\.\d+)?)% packet loss/)
                    root.packetLoss = lossMatch ? parseFloat(lossMatch[1]).toFixed(1) + " %" : "Error"
                    
                    // Parse rtt: "rtt min/avg/max/mdev = 11.842/12.045/12.312/0.178 ms"
                    if (statsLine.includes("rtt")) {
                        const parts = statsLine.split(" = ")[1].split("/")
                        root.ping = parseFloat(parts[1]).toFixed(1) + " ms"
                        root.jitter = parseFloat(parts[3]).toFixed(1) + " ms"
                    } else {
                        root.ping = "Error"
                        root.jitter = "Error"
                    }
                }
                downloadProc.running = true
            }
        }
    }

    // Step 2: Download — Cloudflare speed test endpoint (25 MB)
    Process {
        id: downloadProc
        command: ["bash", "-c",
            "curl -w '%{speed_download}' -o /dev/null -s " +
            "https://speed.cloudflare.com/__down?bytes=25000000"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isTesting) return
                const bytesPerSec = parseFloat(text.trim())
                if (isNaN(bytesPerSec)) {
                    root.downloadSpeed = "Error"
                } else {
                    root.downloadSpeed = (bytesPerSec * 8 / 1048576).toFixed(2) + " Mbps"
                }
                uploadProc.running = true
            }
        }
    }

    // Step 3: Upload — POST 10 MB to Cloudflare speed test endpoint
    Process {
        id: uploadProc
        command: ["bash", "-c",
            "dd if=/dev/zero bs=1M count=10 of=/tmp/speedtest.bin 2>/dev/null && " +
            "curl -w '%{speed_upload}' -X POST -T /tmp/speedtest.bin " +
            "-o /dev/null -s https://speed.cloudflare.com/__up; " +
            "rm -f /tmp/speedtest.bin"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isTesting) return
                const bytesPerSec = parseFloat(text.trim())
                if (isNaN(bytesPerSec)) {
                    root.uploadSpeed = "Error"
                } else {
                    root.uploadSpeed = (bytesPerSec * 8 / 1048576).toFixed(2) + " Mbps"
                }
                
                // Add to history
                const newResult = {
                    timestamp: new Date().toLocaleString(),
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
                root.testFinished()
            }
        }
    }
}
