import QtQuick

import "../shared/designsystem"

QtObject {
    id: root

    property string draftMode: ThemeSettings.mode
    property string draftAccentColor: ThemeSettings.accentColor
    property string draftFontFamily: ThemeSettings.fontFamily
    property real draftUiScale: ThemeSettings.uiScale

    readonly property bool hasPendingChanges:
        draftMode !== ThemeSettings.mode
        || draftAccentColor !== ThemeSettings.accentColor
        || draftFontFamily !== ThemeSettings.fontFamily
        || Math.abs(draftUiScale - ThemeSettings.uiScale) > 0.001

    readonly property var accentOptions: [
        { name: "Blue", value: "#4f8cff" },
        { name: "Cyan", value: "#22c3ee" },
        { name: "Emerald", value: "#2fbf71" },
        { name: "Amber", value: "#f5a524" },
        { name: "Rose", value: "#f25f7a" },
        { name: "Violet", value: "#8b5cf6" }
    ]

    readonly property var scaleOptions: [
        { label: "90%", value: 0.9 },
        { label: "100%", value: 1.0 },
        { label: "110%", value: 1.1 }
    ]

    function resetDrafts() {
        draftMode = ThemeSettings.mode;
        draftAccentColor = ThemeSettings.accentColor;
        draftFontFamily = ThemeSettings.fontFamily;
        draftUiScale = ThemeSettings.uiScale;
    }

    function applyDrafts() {
        ThemeSettings.apply(draftMode, draftAccentColor, draftFontFamily, draftUiScale);
        resetDrafts();
    }
}
