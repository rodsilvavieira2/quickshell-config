pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string settingsPath: Quickshell.env("HOME") + "/.config/quickshell/theme.ini"
    readonly property url settingsLocation: "file://" + settingsPath

    property string mode: "dark"
    property string accentColor: "#89b4fa"
    property string fontFamily: "Noto Sans"
    property real uiScale: 1.0
    property int revision: 0

    Settings {
        id: persisted
        location: root.settingsLocation
        category: "desktop-ui-theme"
    }

    readonly property bool isDark: mode !== "light"
    readonly property color accent: accentColor
    readonly property color seedColor: accentColor
    readonly property string resolvedFontFamily: FontCatalog.resolveTextFamily(fontFamily)
    readonly property string iconFontFamily: FontCatalog.defaultIconFamily

    FileView {
        id: settingsFile
        path: root.settingsPath
        watchChanges: true

        onLoaded: root.reloadFromDisk()
    }

    Component.onCompleted: reloadFromDisk()

    function clampScale(nextScale) {
        return Math.max(0.9, Math.min(1.15, nextScale));
    }

    function normalizedMode(nextMode) {
        return nextMode === "light" ? "light" : "dark";
    }

    function apply(nextMode, nextAccentColor, nextFontFamily, nextUiScale) {
        const resolvedMode = normalizedMode(nextMode);
        const resolvedAccentColor = nextAccentColor || "#89b4fa";
        const resolvedFontFamily = FontCatalog.resolveTextFamily(nextFontFamily);
        const resolvedUiScale = clampScale(nextUiScale);

        mode = resolvedMode;
        accentColor = resolvedAccentColor;
        fontFamily = resolvedFontFamily;
        uiScale = resolvedUiScale;

        persisted.setValue("mode", resolvedMode);
        persisted.setValue("accentColor", resolvedAccentColor);
        persisted.setValue("fontFamily", resolvedFontFamily);
        persisted.setValue("uiScale", resolvedUiScale);
        persisted.sync();
        revision += 1;
    }

    function reloadFromDisk() {
        persisted.sync();

        mode = normalizedMode(persisted.value("mode", mode));
        accentColor = persisted.value("accentColor", accentColor) || "#89b4fa";
        fontFamily = FontCatalog.resolveTextFamily(persisted.value("fontFamily", fontFamily));
        uiScale = clampScale(Number(persisted.value("uiScale", uiScale)));
        revision += 1;
    }

    function setUiScale(nextScale) {
        uiScale = clampScale(nextScale);
    }
}
