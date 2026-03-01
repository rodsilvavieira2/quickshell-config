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
    
    // Live values
    property string liveDownload: "0.00"
    property string liveUpload: "0.00"

    signal testFinished()

    function runTest(interfaceName) {
        if (isTesting) return;
        isTesting = true;
        downloadSpeed = "Testing...";
        uploadSpeed = "Waiting...";
        ping = "Testing...";
        liveDownload = "0.00";
        liveUpload = "0.00";
        
        monitorProc.interfaceName = interfaceName;
        monitorProc.running = true;
        pingProc.running = true;
    }

    function cancelTest() {
        if (!isTesting) return;
        
        pingProc.running = false;
        downloadProc.running = false;
        uploadProc.running = false;
        monitorProc.running = false;
        
        isTesting = false;
        downloadSpeed = "Canceled";
        uploadSpeed = "Canceled";
        ping = "Canceled";
        liveDownload = "0.00";
        liveUpload = "0.00";
        
        // Cleanup temp file if exists
        cleanupProc.running = true;
    }

    Process {
        id: cleanupProc
        command: ["rm", "-f", "/tmp/speedtest.bin"]
    }

    Process {
        id: monitorProc
        property string interfaceName: "eth0"
        command: ["bash", "-c", "
            IFACE='" + interfaceName + "';
            while true; do
                read rx1 tx1 < <(grep \"$IFACE\" /proc/net/dev | awk '{print $2, $10}');
                sleep 0.5;
                read rx2 tx2 < <(grep \"$IFACE\" /proc/net/dev | awk '{print $2, $10}');
                # (Bytes * 8 bits) / (0.5s * 1024 * 1024) = Mbps
                # We multiply by 16 because 0.5s is 1/2 second (8 * 2 = 16)
                # Using bc for float math
                echo \"$(echo \"scale=2; ($rx2-$rx1)*16/1048576\" | bc)|$(echo \"scale=2; ($tx2-$tx1)*16/1048576\" | bc)\";
            done
        "]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("|");
                if (parts.length === 2) {
                    root.liveDownload = parts[0];
                    root.liveUpload = parts[1];
                }
            }
        }
    }

    Process {
        id: pingProc
        command: ["bash", "-c", "ping -c 4 1.1.1.1 | tail -1 | awk '{print $4}' | cut -d '/' -f 2"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isTesting) return;
                root.ping = text.trim() !== "" ? text.trim() + " ms" : "Error";
                downloadProc.running = true;
            }
        }
    }

    Process {
        id: downloadProc
        command: ["bash", "-c", "curl -w '%{speed_download}' -o /dev/null -s http://speedtest.tele2.net/10MB.zip"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isTesting) return;
                let bytesPerSec = parseFloat(text.trim());
                if (isNaN(bytesPerSec)) {
                    root.downloadSpeed = "Error";
                } else {
                    let mbps = (bytesPerSec * 8) / 1048576;
                    root.downloadSpeed = mbps.toFixed(2) + " Mbps";
                }
                uploadProc.running = true;
            }
        }
    }

    Process {
        id: uploadProc
        command: ["bash", "-c", "dd if=/dev/zero bs=1M count=5 of=/tmp/speedtest.bin 2>/dev/null; curl -w '%{speed_upload}' -T /tmp/speedtest.bin -o /dev/null -s https://httpbin.org/post; rm -f /tmp/speedtest.bin"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isTesting) return;
                let bytesPerSec = parseFloat(text.trim());
                if (isNaN(bytesPerSec)) {
                    root.uploadSpeed = "Error";
                } else {
                    let mbps = (bytesPerSec * 8) / 1048576;
                    root.uploadSpeed = mbps.toFixed(2) + " Mbps";
                }
                root.isTesting = false;
                monitorProc.running = false;
                root.testFinished();
            }
        }
    }
}
