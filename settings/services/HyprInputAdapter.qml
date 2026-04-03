import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string baseConfigPath: Quickshell.env("HOME") + "/.config/hypr/hyprland.conf"
    readonly property string generatedConfigPath: Quickshell.env("HOME") + "/.config/hypr/generated/settings-input.conf"
    readonly property string scriptPath: Qt.resolvedUrl("../scripts/apply_hypr_input.sh").toString().replace("file://", "")

    property var devices: ({ "mice": [], "keyboards": [], "touch": [] })
    property bool followMouse: true
    property bool naturalScroll: false

    readonly property var primaryKeyboard: {
        const keyboards = devices.keyboards ?? [];
        return keyboards.find(device => device.main) ?? keyboards[0] ?? null;
    }

    readonly property string layoutSummary: primaryKeyboard?.active_keymap ?? "Unknown"

    function refresh() {
        configProc.running = true;
        devicesProc.running = true;
    }

    function apply(nextFollowMouse, nextNaturalScroll) {
        followMouse = nextFollowMouse;
        naturalScroll = nextNaturalScroll;
        applyProc.followMouseValue = nextFollowMouse ? "1" : "0";
        applyProc.naturalScrollValue = nextNaturalScroll ? "yes" : "no";
        applyProc.running = true;
    }

    function extractLastMatch(content, regex, fallbackValue) {
        let result = fallbackValue;
        regex.lastIndex = 0;
        let match = regex.exec(content);
        while (match !== null) {
            result = match[1];
            match = regex.exec(content);
        }
        return result;
    }

    Process {
        id: configProc
        command: ["bash", "-lc", `cat "${root.baseConfigPath}" "${root.generatedConfigPath}" 2>/dev/null || true`]
        stdout: StdioCollector {
            onStreamFinished: {
                const merged = text;
                const followMouseValue = root.extractLastMatch(merged, /follow_mouse\s*=\s*([01])/g, "1");
                const naturalScrollValue = root.extractLastMatch(merged, /natural_scroll\s*=\s*(yes|no|true|false|1|0)/g, "no");
                root.followMouse = followMouseValue === "1";
                root.naturalScroll = naturalScrollValue === "yes" || naturalScrollValue === "true" || naturalScrollValue === "1";
            }
        }
    }

    Process {
        id: devicesProc
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                const payload = text.trim();
                if (!payload.startsWith("{")) {
                    root.devices = ({ "mice": [], "keyboards": [], "touch": [] });
                    return;
                }
                try {
                    root.devices = JSON.parse(payload);
                } catch (error) {
                    console.warn("Failed to parse input devices", error);
                }
            }
        }
    }

    Process {
        id: applyProc
        property string followMouseValue: "1"
        property string naturalScrollValue: "no"
        command: [root.scriptPath, followMouseValue, naturalScrollValue]
        onExited: refresh()
    }
}
