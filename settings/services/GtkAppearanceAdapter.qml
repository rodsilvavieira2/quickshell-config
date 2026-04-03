import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string scriptPath: Qt.resolvedUrl("../scripts/sync_gtk_appearance.sh").toString().replace("file://", "")
    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/gtk-3.0/settings.ini"
    readonly property string xsettingsPath: Quickshell.env("HOME") + "/.config/xsettingsd/xsettingsd.conf"

    property string gtkFontName: "UbuntuMono Nerd Font 12"
    property bool preferDark: true
    property string themeName: "Adwaita"
    property string iconThemeName: "Reversal-purple-dark"

    function refresh() {
        refreshProc.running = true;
    }

    function apply(preferDarkMode, fontName) {
        applyProc.preferDarkMode = preferDarkMode ? "dark" : "light";
        applyProc.fontName = fontName;
        applyProc.running = true;
    }

    function syncFromTheme(mode, fontFamily) {
        apply(mode === "dark", fontFamily + " 12");
    }

    Process {
        id: refreshProc
        command: ["bash", "-lc", `
            SETTINGS_FILE="${root.settingsPath}"
            XSETTINGS_FILE="${root.xsettingsPath}"
            font=$(grep -m1 '^gtk-font-name=' "$SETTINGS_FILE" 2>/dev/null | cut -d= -f2-)
            prefer_dark=$(grep -m1 '^gtk-application-prefer-dark-theme=' "$SETTINGS_FILE" 2>/dev/null | cut -d= -f2-)
            theme=$(grep -m1 '^gtk-theme-name=' "$SETTINGS_FILE" 2>/dev/null | cut -d= -f2-)
            icon=$(grep -m1 '^gtk-icon-theme-name=' "$SETTINGS_FILE" 2>/dev/null | cut -d= -f2-)
            if [ -z "$theme" ]; then
                theme=$(grep -m1 'Net/ThemeName' "$XSETTINGS_FILE" 2>/dev/null | sed 's/.*"//; s/"$//')
            fi
            if [ -z "$icon" ]; then
                icon=$(grep -m1 'Net/IconThemeName' "$XSETTINGS_FILE" 2>/dev/null | sed 's/.*"//; s/"$//')
            fi
            printf 'font=%s\npreferDark=%s\ntheme=%s\nicon=%s\n' "$font" "$prefer_dark" "$theme" "$icon"
        `]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                for (const line of lines) {
                    if (line.startsWith("font=")) root.gtkFontName = line.substring(5) || root.gtkFontName;
                    else if (line.startsWith("preferDark=")) root.preferDark = line.substring(11).trim() === "1";
                    else if (line.startsWith("theme=")) root.themeName = line.substring(6) || root.themeName;
                    else if (line.startsWith("icon=")) root.iconThemeName = line.substring(5) || root.iconThemeName;
                }
            }
        }
    }

    Process {
        id: applyProc
        property string preferDarkMode: "dark"
        property string fontName: ""
        command: [root.scriptPath, preferDarkMode, fontName]
        onExited: refresh()
    }
}
