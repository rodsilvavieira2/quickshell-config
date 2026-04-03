pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell

Singleton {
    id: root

    Settings {
        id: persisted
        category: "desktop-ui-theme"

        property string mode: "dark"
        property string accentColor: "#89b4fa"
        property string fontFamily: "Noto Sans"
        property real uiScale: 1.0
    }

    property alias mode: persisted.mode
    property alias accentColor: persisted.accentColor
    property alias fontFamily: persisted.fontFamily
    property alias uiScale: persisted.uiScale

    readonly property bool isDark: mode !== "light"
    readonly property color accent: accentColor
    readonly property string resolvedFontFamily: FontCatalog.resolveTextFamily(fontFamily)
    readonly property string iconFontFamily: FontCatalog.defaultIconFamily

    function clampScale(nextScale) {
        return Math.max(0.9, Math.min(1.15, nextScale));
    }

    function setUiScale(nextScale) {
        uiScale = clampScale(nextScale);
    }
}
