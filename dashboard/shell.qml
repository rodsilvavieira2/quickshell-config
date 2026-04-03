//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "./components"
import "./shared/designsystem" as Design
import "./shared/ui" as DS

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

        Shortcut {
            sequence: "Escape"
            onActivated: shellRoot.panelOpen = false
        }

        Rectangle {
            width: 900
            height: 600
            anchors.centerIn: parent
            color: Design.Tokens.color.bg.surface
            radius: Design.Tokens.radius.lg
            border.color: Design.Tokens.color.border.strong
            border.width: Design.Tokens.border.width.strong

            MouseArea { anchors.fill: parent; preventStealing: true }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 24

                // Header Tab
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    DS.LucideIcon {
                        name: "monitor"
                        iconSize: 32
                        color: Design.Tokens.color.text.primary
                    }

                    Text {
                        text: "Performance Dashboard"
                        font.family: Design.Tokens.font.family.title
                        font.pixelSize: Design.Tokens.font.size.display
                        font.weight: Design.Tokens.font.weight.semibold
                        color: Design.Tokens.color.text.primary
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
                            iconName: "cpu"
                            title: "CPU"
                            mainValue: Math.round(shellRoot.cpuUsage * 100) + "%"
                            mainLabel: "Usage"
                            secondaryValue: shellRoot.cpuTemp + "°C"
                            secondaryLabel: "Temp"
                            usage: shellRoot.cpuUsage
                            tempProgress: Math.min(1, parseFloat(shellRoot.cpuTemp) / 100.0)
                            accentColor: Design.ThemePalette.mix(Design.Tokens.color.accent.primary, Design.ThemePalette.white, 0.18)
                        }

                        HeroCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 160
                            iconName: "microchip"
                            title: "GPU"
                            mainValue: Math.round(shellRoot.gpuUsage * 100) + "%"
                            mainLabel: "Usage"
                            secondaryValue: shellRoot.gpuTemp + "°C"
                            secondaryLabel: "Temp"
                            usage: shellRoot.gpuUsage
                            tempProgress: Math.min(1, parseFloat(shellRoot.gpuTemp) / 100.0)
                            accentColor: Design.Tokens.color.success
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20

                        GaugeCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 240
                            iconName: "memory-stick"
                            title: "Memory"
                            percentage: shellRoot.memTotal > 0 ? (shellRoot.memUsed / shellRoot.memTotal) : 0
                            subtitle: shellRoot.memUsed.toFixed(1) + " GB / " + shellRoot.memTotal.toFixed(1) + " GB"
                            accentColor: Design.Tokens.color.accent.primary
                        }

                        // Placeholder for Storage / Network as seen in caelestia-dots
                        GaugeCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 240
                            iconName: "hard-drive"
                            title: "Storage"
                            percentage: 0.45
                            subtitle: "Free: 55%"
                            accentColor: Design.Tokens.color.error
                        }
                    }
                }
            }
        }
    }
}
