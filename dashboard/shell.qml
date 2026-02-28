//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "./components"

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    // System State
    property real cpuUsage: 0
    property string cpuTemp: "0"
    
    property real gpuUsage: 0
    property string gpuTemp: "0"

    property real memUsed: 0
    property real memTotal: 1

    function refreshStats() {
        cpuProc.running = true;
        gpuProc.running = true;
        memProc.running = true;
    }

    IpcHandler {
        target: "dashboard"
        function toggle() { shellRoot.panelOpen = !shellRoot.panelOpen; }
        function open() { shellRoot.panelOpen = true; }
        function close() { shellRoot.panelOpen = false; }
    }

    Timer {
        id: pollTimer
        interval: 2000
        repeat: true
        running: shellRoot.panelOpen
        onTriggered: shellRoot.refreshStats()
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; previdle=$idle; prevtotal=$((user+nice+system+idle+iowait+irq+softirq+steal)); sleep 0.2; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; idle=$idle; total=$((user+nice+system+idle+iowait+irq+softirq+steal)); diff_idle=$((idle-previdle)); diff_total=$((total-prevtotal)); usage=$((100*(diff_total-diff_idle)/diff_total)); temp=$(sensors | awk '/Package id 0:/ {print $4; exit} /Tctl:/ {print $2; exit} /Core 0:/ {print $3; exit}'); if [ -z \"$temp\" ]; then temp=$(sensors | grep -Eo '\\+[0-9]+\\.[0-9]°C' | head -n1); fi; echo \"${usage}|${temp//+/}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 2) {
                    shellRoot.cpuUsage = parseFloat(parts[0]) / 100.0;
                    shellRoot.cpuTemp = parts[1].replace("°C", "");
                }
            }
        }
    }

    Process {
        id: gpuProc
        command: ["bash", "-c", "if command -v nvidia-smi &> /dev/null; then nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F', ' '{printf \"%s|%s\\n\", $1, $2}'; else echo \"0|0\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 2) {
                    shellRoot.gpuUsage = parseFloat(parts[0]) / 100.0;
                    shellRoot.gpuTemp = parts[1];
                }
            }
        }
    }

    Process {
        id: memProc
        command: ["bash", "-c", "free -m | awk 'NR==2{printf \"%.1f|%.1f\", $3/1024, $2/1024}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 2) {
                    shellRoot.memUsed = parseFloat(parts[0]);
                    shellRoot.memTotal = parseFloat(parts[1]);
                }
            }
        }
    }

    PanelWindow {
        id: window
        visible: shellRoot.panelOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:dashboard"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true; bottom: true; left: true; right: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.panelOpen = false
        }

        Item {
            id: focusCatcher
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: event => { shellRoot.panelOpen = false; event.accepted = true; }
        }

        Rectangle {
            width: 900
            height: 600
            anchors.centerIn: parent
            color: "#1e1e2e"
            radius: 16
            border.color: "#313244"
            border.width: 2

            MouseArea { anchors.fill: parent; preventStealing: true }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 24

                // Header Tab
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "󰕮" // Dashboard icon
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 28
                        color: "#cdd6f4"
                    }

                    Text {
                        text: "Performance Dashboard"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#cdd6f4"
                    }
                }

                // Performance Section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 20

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        HeroCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 160
                            icon: ""
                            title: "CPU"
                            mainValue: Math.round(shellRoot.cpuUsage * 100) + "%"
                            mainLabel: "Usage"
                            secondaryValue: shellRoot.cpuTemp + "°C"
                            secondaryLabel: "Temp"
                            usage: shellRoot.cpuUsage
                            tempProgress: Math.min(1, parseFloat(shellRoot.cpuTemp) / 100.0)
                            accentColor: "#b4befe" // Lavender
                        }

                        HeroCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 160
                            icon: "󰢮"
                            title: "GPU"
                            mainValue: Math.round(shellRoot.gpuUsage * 100) + "%"
                            mainLabel: "Usage"
                            secondaryValue: shellRoot.gpuTemp + "°C"
                            secondaryLabel: "Temp"
                            usage: shellRoot.gpuUsage
                            tempProgress: Math.min(1, parseFloat(shellRoot.gpuTemp) / 100.0)
                            accentColor: "#a6e3a1" // Green
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        GaugeCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 240
                            icon: ""
                            title: "Memory"
                            percentage: shellRoot.memTotal > 0 ? (shellRoot.memUsed / shellRoot.memTotal) : 0
                            subtitle: shellRoot.memUsed.toFixed(1) + " GB / " + shellRoot.memTotal.toFixed(1) + " GB"
                            accentColor: "#89b4fa" // Blue
                        }

                        // Placeholder for Storage / Network as seen in caelestia-dots
                        GaugeCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 240
                            icon: "󰋊"
                            title: "Storage"
                            percentage: 0.45
                            subtitle: "Free: 55%"
                            accentColor: "#f38ba8" // Red
                        }
                    }
                }
            }
        }
    }
}
