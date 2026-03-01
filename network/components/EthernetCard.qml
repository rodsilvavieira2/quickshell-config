import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../services"

Rectangle {
    id: root

    // Dual-line filled sparkline: download (green) behind, upload (blue) on top.
    // Expects downloadHistory/uploadHistory as arrays of Mbps values (real),
    // and maxSpeed as the Y-axis ceiling (already includes headroom).
    component SpeedChart: Canvas {
        id: chartRoot
        property var downloadHistory: []
        property var uploadHistory: []
        property real maxSpeed: 1.0
        property int maxPoints: 60

        onDownloadHistoryChanged: requestPaint()
        onUploadHistoryChanged: requestPaint()
        onMaxSpeedChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const histories = [
                { data: downloadHistory, line: "#a6e3a1", fill: Qt.rgba(0.651, 0.890, 0.631, 0.15) },
                { data: uploadHistory,   line: "#89b4fa", fill: Qt.rgba(0.537, 0.706, 0.980, 0.15) }
            ]

            const dx = width / (maxPoints - 1)
            const safeCeil = maxSpeed > 0 ? maxSpeed : 1.0

            for (let s = 0; s < histories.length; s++) {
                const hist = histories[s].data
                if (hist.length < 2) continue

                const startIndex = maxPoints - hist.length

                // Build the path points
                const pts = []
                for (let i = 0; i < hist.length; i++) {
                    const x = (startIndex + i) * dx
                    const rawY = height - (hist[i] / safeCeil * height)
                    const y = Math.max(1, Math.min(height - 1, rawY))
                    pts.push({ x, y })
                }

                // Filled area (low opacity)
                ctx.beginPath()
                ctx.moveTo(pts[0].x, height)
                ctx.lineTo(pts[0].x, pts[0].y)
                for (let i = 1; i < pts.length; i++)
                    ctx.lineTo(pts[i].x, pts[i].y)
                ctx.lineTo(pts[pts.length - 1].x, height)
                ctx.closePath()
                ctx.fillStyle = histories[s].fill
                ctx.fill()

                // Stroke line
                ctx.beginPath()
                ctx.moveTo(pts[0].x, pts[0].y)
                for (let i = 1; i < pts.length; i++)
                    ctx.lineTo(pts[i].x, pts[i].y)
                ctx.strokeStyle = histories[s].line
                ctx.lineWidth = 1.5
                ctx.lineJoin = "round"
                ctx.lineCap = "round"
                ctx.stroke()
            }
        }
    }

    required property var device

    // Keyboard-driven selection state
    property bool isSelected: false
    // 0 = Connect/Disconnect, 1 = Reconnect, 2 = Run Test/Cancel
    property int focusedAction: 0

    // Reset focused action whenever this card loses selection
    onIsSelectedChanged: {
        if (!isSelected) focusedAction = 0
    }

    // Number of visible actions depends on device state
    readonly property int actionCount: {
        if (!device.connected) return 1          // Connect only
        return 3                                  // Disconnect + Reconnect + Run Test
    }

    // Cycle focus forward (+1) or backward (-1), wrapping within the card
    function cycleFocus(direction) {
        focusedAction = ((focusedAction + direction) % actionCount + actionCount) % actionCount
    }

    // Activate the currently focused action
    function activateAction() {
        if (focusedAction === 0) {
            if (device.connected)
                Nmcli.bringInterfaceDown(device.interface, null)
            else
                Nmcli.bringInterfaceUp(device.interface, null)
        } else if (focusedAction === 1 && device.connected) {
            Nmcli.bringInterfaceDown(device.interface, () => {
                Nmcli.bringInterfaceUp(device.interface, null)
            })
        } else if (focusedAction === 2 && device.connected) {
            if (SpeedTest.isTesting)
                SpeedTest.cancelTest()
            else
                SpeedTest.runTest(device.interface)
        }
    }

    width: parent ? parent.width : 400
    height: layout.implicitHeight + 24
    color: device.connected ? "#313244" : "#181825"
    radius: 12
    border.color: isSelected ? "#cdd6f4" : (device.connected ? "#89b4fa" : "#313244")
    border.width: isSelected ? 2 : (device.connected ? 2 : 1)

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "󰈀"
                color: device.connected ? "#89b4fa" : "#a6adc8"
                font.pixelSize: 32
                font.family: "JetBrainsMono Nerd Font"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: device.interface || "Ethernet Interface"
                    color: device.connected ? "#89b4fa" : "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                }

                Text {
                    text: device.connected ? "Connected" : "Disconnected"
                    color: "#a6adc8"
                    font.pixelSize: 13
                }
            }

            Button {
                text: device.connected ? "Disconnect" : "Connect"
                font.pixelSize: 13
                background: Rectangle {
                    color: device.connected ? "#f38ba8" : "#89b4fa"
                    radius: 6
                    border.color: (root.isSelected && root.focusedAction === 0) ? "#cdd6f4" : "transparent"
                    border.width: 2
                }
                contentItem: Text {
                    text: parent.text
                    color: "#1e1e2e"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: {
                    if (device.connected) {
                        Nmcli.bringInterfaceDown(device.interface, null);
                    } else {
                        Nmcli.bringInterfaceUp(device.interface, null);
                    }
                }
            }

            Button {
                text: "Reconnect"
                font.pixelSize: 13
                visible: device.connected
                background: Rectangle {
                    color: "#fab387" // Peach
                    radius: 6
                    border.color: (root.isSelected && root.focusedAction === 1) ? "#cdd6f4" : "transparent"
                    border.width: 2
                }
                contentItem: Text {
                    text: parent.text
                    color: "#1e1e2e"
                    font.bold: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                }
                onClicked: {
                    Nmcli.bringInterfaceDown(device.interface, () => {
                        Nmcli.bringInterfaceUp(device.interface, null);
                    });
                }
            }
        }
        
        // Show Details if Connected and Details are available
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#45475a"
            visible: device.connected && Nmcli.ethernetDeviceDetails !== null
        }

        GridLayout {
            columns: 2
            rowSpacing: 10
            columnSpacing: 16
            Layout.fillWidth: true
            visible: device.connected && Nmcli.ethernetDeviceDetails !== null

            // IP Address
            Text { text: "IP Address:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.ipAddress || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // Gateway
            Text { text: "Gateway:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.gateway || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // DNS
            Text { text: "DNS:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails && Nmcli.ethernetDeviceDetails.dns ? Nmcli.ethernetDeviceDetails.dns.join(", ") || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // MAC Address
            Text { text: "MAC Address:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.macAddress || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }

            // Speed
            Text { text: "Speed:"; color: "#a6adc8"; font.pixelSize: 14 }
            Text { 
                text: Nmcli.ethernetDeviceDetails ? Nmcli.ethernetDeviceDetails.speed || "N/A" : "N/A"
                color: "#cdd6f4"; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true 
            }
        }

        // Live Traffic Section — always visible when connected
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#45475a"
            visible: device.connected
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: device.connected
            spacing: 8

            // Labels + current speeds
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "↓ Download"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: NetSpeed.downloadMbps.toFixed(2) + " Mbps"
                        color: "#a6e3a1"
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "↑ Upload"
                        color: "#a6adc8"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: NetSpeed.uploadMbps.toFixed(2) + " Mbps"
                        color: "#89b4fa"
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // Dual-line sparkline chart
            SpeedChart {
                Layout.fillWidth: true
                height: 72
                downloadHistory: NetSpeed.downloadHistory
                uploadHistory: NetSpeed.uploadHistory
                maxSpeed: NetSpeed.maxObservedSpeed
            }

            Text {
                text: "Last 60 seconds"
                color: "#585b70"
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
                Layout.alignment: Qt.AlignRight
            }
        }

        // Speed Test Section
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#45475a"
            visible: device.connected
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: device.connected
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Network Speed Test"
                    color: "#f5e0dc" // Rosewater
                    font.pixelSize: 15
                    font.bold: true
                    Layout.fillWidth: true
                }

                Button {
                    text: SpeedTest.isTesting ? "Cancel" : "󰓅 Run Test"
                    font.pixelSize: 12
                    background: Rectangle {
                        color: SpeedTest.isTesting ? "#f38ba8" : "#b4befe" // Red or Lavender
                        radius: 6
                        border.color: (root.isSelected && root.focusedAction === 2) ? "#cdd6f4" : "transparent"
                        border.width: 2
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#1e1e2e"
                        font.bold: true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                    onClicked: {
                        if (SpeedTest.isTesting) {
                            SpeedTest.cancelTest();
                        } else {
                            SpeedTest.runTest(device.interface);
                        }
                    }
                }
            }

            GridLayout {
                columns: 3
                Layout.fillWidth: true
                columnSpacing: 20
                visible: SpeedTest.ping !== "0 ms" || SpeedTest.isTesting

                ColumnLayout {
                    spacing: 4
                    Text { text: "Ping"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text { text: SpeedTest.ping; color: "#fab387"; font.pixelSize: 16; font.bold: true }
                }

                ColumnLayout {
                    spacing: 4
                    Text { text: "Download"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text {
                        text: SpeedTest.downloadSpeed
                        color: "#a6e3a1"; font.pixelSize: 16; font.bold: true
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Text { text: "Upload"; color: "#a6adc8"; font.pixelSize: 12 }
                    Text {
                        text: SpeedTest.uploadSpeed
                        color: "#89b4fa"; font.pixelSize: 16; font.bold: true
                    }
                }
            }
        }
    }
}
