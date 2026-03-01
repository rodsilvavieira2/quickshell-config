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

    signal testFinished()

    function runTest(interfaceName) {
        if (isTesting) return
        isTesting = true
        downloadSpeed = "Testing..."
        uploadSpeed = "Waiting..."
        ping = "Testing..."
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

        cleanupProc.running = true
    }

    Process {
        id: cleanupProc
        command: ["rm", "-f", "/tmp/speedtest.bin"]
    }

    // Step 1: Ping (4 probes to Cloudflare DNS — fast and reliable)
    Process {
        id: pingProc
        command: ["bash", "-c", "ping -c 4 1.1.1.1 | tail -1 | awk -F '/' '{print $5}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isTesting) return
                const t = text.trim()
                root.ping = t !== "" ? t + " ms" : "Error"
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
                root.isTesting = false
                root.testFinished()
            }
        }
    }
}
