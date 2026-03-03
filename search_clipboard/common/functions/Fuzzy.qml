pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    function score(haystack, needle) {
        if (!needle) return 1.0;
        if (!haystack) return 0.0;
        const h = haystack.toLowerCase();
        const n = needle.toLowerCase();
        if (h.startsWith(n)) return 1.0;
        const idx = h.indexOf(n);
        if (idx >= 0) return 0.7 - Math.min(idx / Math.max(h.length, 1), 0.4);
        return 0.0;
    }
}
