//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma IconTheme "Suru++"
//@ pragma Env QS_ICON_THEME=Suru++

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "./components"
import "./shared/designsystem" as Design

ShellRoot {
    id: shellRoot

    property bool panelOpen: false

    // CPU State
    property real cpuUsage: 0
    property string cpuTemp: "..."
    property var cpuHistory: []

    // RAM State
    property real memUsed: 0
    property real memTotal: 1
    property real memCached: 0
    property real memFree: 0

    // GPU State
    property real gpuUsage: 0
    property string gpuTemp: "..."
    property real gpuMemUsed: 0
    property real gpuMemTotal: 1

    // Process State
    ListModel { id: processModel }
    property string selectedPid: ""
    property int processMaxRows: 50
    property string uiFontFamily: Design.Tokens.font.family.body
    readonly property color panelBackground: Design.Tokens.color.bg.surface
    readonly property color panelBorder: Design.ThemePalette.withAlpha(Design.Tokens.color.accent.primary, Design.ThemeSettings.isDark ? 0.55 : 0.35)
    readonly property color cardBackground: Design.Tokens.color.bg.elevated
    readonly property color cardBorder: Design.Tokens.color.border.subtle
    readonly property color mutedText: Design.Tokens.color.text.secondary
    readonly property color selectedText: Design.Tokens.color.text.inverse
    readonly property color selectedRow: Design.Tokens.color.accent.hover
    readonly property color processAccent: Design.ThemePalette.mix(Design.Tokens.color.error, Design.Tokens.color.accent.primary, 0.35)
    readonly property color cpuAccent: Design.ThemePalette.mix(Design.Tokens.color.accent.primary, Design.ThemePalette.white, Design.ThemeSettings.isDark ? 0.22 : 0.08)
    readonly property color warmColor: Design.Tokens.color.warning
    readonly property color hotColor: Design.Tokens.color.error

    onPanelOpenChanged: {
        if (panelOpen) {
            focusCatcher.forceActiveFocus();
            refreshStats();
            pollTimer.start();
        } else {
            pollTimer.stop();
        }
    }

    function refreshStats() {
        cpuProc.running = true;
        memProc.running = true;
        gpuProc.running = true;
        processProc.running = true;
    }

    function parseProcessLines(rawText) {
        const trimmed = rawText.trim();
        if (trimmed === "") return [];

        const lines = trimmed.split("\n");
        const results = [];

        for (let i = 0; i < lines.length; i++) {
            if (results.length >= shellRoot.processMaxRows) break;

            const line = lines[i].trim();
            if (line === "") continue;

            const tokens = line.split(/\s+/);
            if (tokens.length < 5) continue;

            const user = tokens.pop();
            const rss = tokens.pop();
            const cpu = tokens.pop();
            const pid = tokens.shift();
            const name = tokens.join(" ");

            if (!/^\d+$/.test(pid)) continue;
            if (!/^[\d.]+$/.test(cpu)) continue;
            if (!/^\d+$/.test(rss)) continue;

            const rssMb = parseFloat(rss) / 1024.0;
            results.push({
                pid: pid,
                name: name,
                cpu: cpu,
                ram: rssMb.toFixed(1) + " MB",
                user: user
            });
        }

        return results;
    }

    IpcHandler {
        target: "controlcenter"
        function toggle() {
            shellRoot.panelOpen = !shellRoot.panelOpen;
        }
        function open() {
            shellRoot.panelOpen = true;
        }
        function close() {
            shellRoot.panelOpen = false;
        }
    }

    Timer {
        id: pollTimer
        interval: 2000
        repeat: true
        onTriggered: {
            if (shellRoot.panelOpen) {
                shellRoot.refreshStats();
            }
        }
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; previdle=$idle; prevtotal=$((user+nice+system+idle+iowait+irq+softirq+steal)); sleep 0.2; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; idle=$idle; total=$((user+nice+system+idle+iowait+irq+softirq+steal)); diff_idle=$((idle-previdle)); diff_total=$((total-prevtotal)); usage=$((100*(diff_total-diff_idle)/diff_total)); temp=$(sensors | awk '/Package id 0:/ {print $4; exit} /Tctl:/ {print $2; exit} /Core 0:/ {print $3; exit}'); if [ -z \"$temp\" ]; then temp=$(sensors | grep -Eo '\\+[0-9]+\\.[0-9]°C' | head -n1); fi; echo \"${usage}|${temp//+/}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 2) {
                    shellRoot.cpuUsage = parseFloat(parts[0]) / 100.0;
                    shellRoot.cpuTemp = parts[1];
                    
                    let hist = shellRoot.cpuHistory.slice();
                    hist.push(parseFloat(parts[0]));
                    if (hist.length > 40) hist.shift();
                    shellRoot.cpuHistory = hist;
                }
            }
        }
    }

    Process {
        id: memProc
        command: ["bash", "-c", "free -m | awk 'NR==2{printf \"%.1f|%.1f|%.1f|%.1f\", $3/1024, $2/1024, $6/1024, $4/1024}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 4) {
                    shellRoot.memUsed = parseFloat(parts[0]);
                    shellRoot.memTotal = parseFloat(parts[1]);
                    shellRoot.memCached = parseFloat(parts[2]);
                    shellRoot.memFree = parseFloat(parts[3]);
                }
            }
        }
    }

    Process {
        id: gpuProc
        command: ["bash", "-c", "if command -v nvidia-smi &> /dev/null; then nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits | awk -F', ' '{printf \"%s|%s|%.1f|%.1f\\n\", $1, $2, $3/1024, $4/1024}'; else echo \"0|N/A|0|1\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|");
                if (parts.length === 4) {
                    shellRoot.gpuUsage = parseFloat(parts[0]) / 100.0;
                    shellRoot.gpuTemp = parts[1] + "°C";
                    shellRoot.gpuMemUsed = parseFloat(parts[2]);
                    shellRoot.gpuMemTotal = parseFloat(parts[3]);
                }
            }
        }
    }

    Process {
        id: processProc
        command: ["bash", "-c", "ps -eo pid,comm,%cpu,rss,user --sort=-%cpu --no-headers"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parsed = shellRoot.parseProcessLines(text);
                if (parsed.length > 0) {
                    for (let i = 0; i < parsed.length; i++) {
                        if (i < processModel.count) {
                            processModel.set(i, parsed[i]);
                        } else {
                            processModel.append(parsed[i]);
                        }
                    }
                    while (processModel.count > parsed.length) {
                        processModel.remove(processModel.count - 1, 1);
                    }
                }
            }
        }
    }

    PanelWindow {
        id: window

        property var focusedScreenName: Hyprland.focusedMonitor?.name ?? ""
        screen: {
            for (let i = 0; i < Quickshell.screens.values.length; i++) {
                if (Quickshell.screens.values[i].name === focusedScreenName) {
                    return Quickshell.screens.values[i];
                }
            }
            return Quickshell.screens.values.length > 0 ? Quickshell.screens.values[0] : null;
        }

        visible: shellRoot.panelOpen
        color: "transparent"

        WlrLayershell.namespace: "quickshell:controlcenter"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Invisible background area to catch clicks and close the menu
        MouseArea {
            anchors.fill: parent
            onClicked: shellRoot.panelOpen = false
        }

        Item {
            id: focusCatcher
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: event => {
                shellRoot.panelOpen = false;
                event.accepted = true
            }
        }

        Rectangle {
            id: mainPanel

            property int panelPadding: 20
            property int panelSpacing: 20
            property int topRowMinHeight: 260
            property int topRowMaxHeight: 300
            property real contentWidth: width - (panelPadding * 2)
            property real contentHeight: height - (panelPadding * 2)
            property real topRowHeight: {
                const cardWidth = (contentWidth - (panelSpacing * 2)) / 3;
                const idealHeight = cardWidth * 0.7;
                const cappedHeight = Math.min(idealHeight, topRowMaxHeight);
                const availableHeight = (contentHeight - panelSpacing) * 0.48;
                return Math.max(topRowMinHeight, Math.min(cappedHeight, availableHeight));
            }

            // 80% screen width, 75% height for a spacious dashboard
            width: window.width * 0.8
            height: window.height * 0.75
            anchors.centerIn: parent
            color: shellRoot.panelBackground
            radius: Design.Tokens.radius.xl
            border.color: shellRoot.panelBorder
            border.width: Design.Tokens.border.width.strong

            // Consume clicks inside the main panel
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: mainPanel.panelPadding
                spacing: mainPanel.panelSpacing

                // Top Row: 3 Cards (CPU, RAM, GPU)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainPanel.topRowHeight
                    Layout.maximumHeight: mainPanel.topRowHeight
                    spacing: mainPanel.panelSpacing

                    // CPU CORE
                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "CPU CORE"
                        titleColor: shellRoot.cpuAccent
                        fontFamily: shellRoot.uiFontFamily

                        CircularProgress {
                            width: 140
                            height: 140
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -22
                            value: shellRoot.cpuUsage
                            progressColor: shellRoot.cpuAccent
                            title: Math.round(shellRoot.cpuUsage * 100) + "%"
                            subTitle: "Load"
                            fontFamily: shellRoot.uiFontFamily
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: sparkline.top
                            anchors.bottomMargin: 12
                            text: "Temp: <font color='" + shellRoot.warmColor + "'>" + shellRoot.cpuTemp + "</font>"
                            color: shellRoot.mutedText
                            font.family: shellRoot.uiFontFamily
                            font.pixelSize: 14
                            textFormat: Text.RichText
                        }

                        Sparkline {
                            id: sparkline
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            anchors.bottomMargin: 16
                            height: 40
                            history: shellRoot.cpuHistory
                            lineColor: shellRoot.warmColor
                        }
                    }

                    // MEMORY (RAM)
                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "MEMORY (RAM)"
                        titleColor: Design.Tokens.color.accent.primary
                        fontFamily: shellRoot.uiFontFamily

                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 10
                            width: 320
                            spacing: 16

                            ProgressBar {
                                width: parent.width
                                height: 32
                                cornerRadius: 6
                                value: shellRoot.memTotal > 0 ? (shellRoot.memUsed / shellRoot.memTotal) : 0
                                progressColor: Design.Tokens.color.accent.primary
                                text: "used: " + shellRoot.memUsed.toFixed(1) + " GB / " + shellRoot.memTotal.toFixed(1) + " GB"
                                fontFamily: shellRoot.uiFontFamily
                            }
                        }
                    }

                    // GPU ENGINE
                    Card {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "GPU ENGINE"
                        titleColor: Design.Tokens.color.success
                        fontFamily: shellRoot.uiFontFamily

                        CircularProgress {
                            width: 140
                            height: 140
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -22
                            value: shellRoot.gpuUsage
                            progressColor: Design.Tokens.color.success
                            title: Math.round(shellRoot.gpuUsage * 100) + "%"
                            subTitle: "Load"
                            fontFamily: shellRoot.uiFontFamily
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: gpuBar.top
                            anchors.bottomMargin: 10
                            property bool isHot: parseInt(shellRoot.gpuTemp) > 75
                            text: "Temp: <font color='" + (isHot ? shellRoot.hotColor : shellRoot.warmColor) + "'>" + shellRoot.gpuTemp + "</font>"
                            color: shellRoot.mutedText
                            font.family: shellRoot.uiFontFamily
                            font.pixelSize: 14
                            textFormat: Text.RichText
                        }

                        ProgressBar {
                            id: gpuBar
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: 360
                            height: 28
                            cornerRadius: 6
                            anchors.bottomMargin: 16
                            value: shellRoot.gpuMemTotal > 0 ? (shellRoot.gpuMemUsed / shellRoot.gpuMemTotal) : 0
                            progressColor: Design.Tokens.color.success
                            backgroundColor: Design.Tokens.color.bg.interactive
                            text: "VRAM: " + shellRoot.gpuMemUsed.toFixed(1) + " GB / " + shellRoot.gpuMemTotal.toFixed(1) + " GB"
                            fontFamily: shellRoot.uiFontFamily
                        }
                    }
                }

                // Bottom Row: Process List
                Rectangle {
                    id: processCard

                    property int columnPadding: 16
                    property int columnSpacing: 12
                    property int headerHeight: 32
                    property int rowHeight: 28
                    property int pidWidth: 100
                    property int cpuWidth: 120
                    property int ramWidth: 150
                    property int userWidth: 0
                    property int nameMinWidth: 350
                    property int scrollBarWidth: 12

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: shellRoot.cardBackground
                    radius: Design.Tokens.radius.lg
                    border.color: shellRoot.cardBorder
                    border.width: Design.Tokens.border.width.thin

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "RUNNING PROCESSES"
                            color: shellRoot.processAccent
                            font.family: shellRoot.uiFontFamily
                            font.pixelSize: Design.Tokens.font.size.title
                            font.bold: true
                            font.letterSpacing: 1.1
                        }

                        // Header Row
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: processCard.headerHeight
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: processCard.columnPadding
                                anchors.rightMargin: processCard.columnPadding + processCard.scrollBarWidth + 4
                                spacing: processCard.columnSpacing

                                Text { Layout.preferredWidth: processCard.pidWidth; text: "PID"; color: shellRoot.mutedText; font.family: shellRoot.uiFontFamily; font.pixelSize: 13; font.bold: true }
                                Text { Layout.preferredWidth: processCard.nameMinWidth; text: "Process Name"; color: shellRoot.mutedText; font.family: shellRoot.uiFontFamily; font.pixelSize: 13; font.bold: true }
                                Text { Layout.preferredWidth: processCard.cpuWidth; text: "CPU %"; color: shellRoot.mutedText; font.family: shellRoot.uiFontFamily; font.pixelSize: 13; font.bold: true }
                                Text { Layout.preferredWidth: processCard.ramWidth; text: "RAM (MB)"; color: shellRoot.mutedText; font.family: shellRoot.uiFontFamily; font.pixelSize: 13; font.bold: true }
                                Text { Layout.fillWidth: true; text: "User"; color: shellRoot.mutedText; font.family: shellRoot.uiFontFamily; font.pixelSize: 13; font.bold: true }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: shellRoot.cardBorder
                                anchors.bottom: parent.bottom
                            }
                        }

                        // Process List
                        ListView {
                            id: procList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: processModel
                            boundsBehavior: Flickable.StopAtBounds

                            ScrollBar.vertical: ScrollBar {
                                active: true
                                width: processCard.scrollBarWidth
                                contentItem: Rectangle {
                                    implicitWidth: processCard.scrollBarWidth
                                    implicitHeight: 100
                                    radius: 6
                                    color: Design.Tokens.color.bg.interactive
                                }
                            }

                            delegate: Rectangle {
                                id: rowItem
                                width: ListView.view.width
                                height: processCard.rowHeight
                                color: shellRoot.selectedPid === pid
                                    ? shellRoot.selectedRow
                                    : (index % 2 === 0 ? shellRoot.cardBackground : shellRoot.panelBackground)
                                property color textColor: shellRoot.selectedPid === pid
                                    ? shellRoot.selectedText
                                    : Design.Tokens.color.text.primary

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: shellRoot.selectedPid = pid
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: processCard.columnPadding
                                    anchors.rightMargin: processCard.columnPadding + processCard.scrollBarWidth + 4
                                    spacing: processCard.columnSpacing

                                    Text { Layout.preferredWidth: processCard.pidWidth; text: pid; color: rowItem.textColor; font.family: shellRoot.uiFontFamily; font.pixelSize: 13 }
                                    Text { Layout.preferredWidth: processCard.nameMinWidth; text: name; color: rowItem.textColor; font.family: shellRoot.uiFontFamily; font.pixelSize: 13; elide: Text.ElideRight }
                                    Text { Layout.preferredWidth: processCard.cpuWidth; text: cpu; color: rowItem.textColor; font.family: shellRoot.uiFontFamily; font.pixelSize: 13 }
                                    Text { Layout.preferredWidth: processCard.ramWidth; text: ram; color: rowItem.textColor; font.family: shellRoot.uiFontFamily; font.pixelSize: 13 }
                                    Text { Layout.fillWidth: true; text: user; color: rowItem.textColor; font.family: shellRoot.uiFontFamily; font.pixelSize: 13; elide: Text.ElideRight }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
