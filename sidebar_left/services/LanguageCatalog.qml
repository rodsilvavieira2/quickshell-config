pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    readonly property var languages: [
        { label: "Auto detect", value: "auto" },
        { label: "Arabic", value: "ar" },
        { label: "Chinese", value: "zh" },
        { label: "Dutch", value: "nl" },
        { label: "English", value: "en" },
        { label: "French", value: "fr" },
        { label: "German", value: "de" },
        { label: "Hindi", value: "hi" },
        { label: "Indonesian", value: "id" },
        { label: "Italian", value: "it" },
        { label: "Japanese", value: "ja" },
        { label: "Korean", value: "ko" },
        { label: "Polish", value: "pl" },
        { label: "Portuguese", value: "pt" },
        { label: "Russian", value: "ru" },
        { label: "Spanish", value: "es" },
        { label: "Turkish", value: "tr" },
        { label: "Ukrainian", value: "uk" },
        { label: "Vietnamese", value: "vi" }
    ]

    function indexForCode(code) {
        const index = languages.findIndex(language => language.value === code);
        return index >= 0 ? index : 0;
    }

    function labelForCode(code) {
        const entry = languages.find(language => language.value === code);
        return entry ? entry.label : String(code ?? "");
    }
}
