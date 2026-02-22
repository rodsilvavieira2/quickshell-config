pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    function cleanPrefix(text, prefix) {
        if (!text) return "";
        return text.startsWith(prefix) ? text.slice(prefix.length) : text;
    }

    function shellSingleQuoteEscape(text) {
        if (!text) return "";
        return text.replace(/'/g, "'\\''");
    }

    function trim(text) {
        return text ? text.trim() : "";
    }
}
