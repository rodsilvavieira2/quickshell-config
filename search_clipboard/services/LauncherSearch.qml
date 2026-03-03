pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../common"
import "../common/functions"
import "./"

Singleton {
    id: root

    property string query: ""
    property var results: []

    Timer {
        id: debounceTimer
        interval: Config.options.search.debounceMs
        repeat: false
        onTriggered: root.computeResults()
    }

    onQueryChanged: debounceTimer.restart()

    // Refresh entries when opened
    Connections {
        target: GlobalStates
        function onSearchOpenChanged() {
            if (GlobalStates.searchOpen) {
                ClipboardSearch.refresh()
            }
        }
    }

    function computeResults() {
        const q = (root.query ?? "").toLowerCase();
        const allEntries = ClipboardSearch.entries;

        if (q.length === 0) {
            results = allEntries.map(entry => formatEntry(entry));
            return;
        }

        results = allEntries
            .filter(entry => entry.toLowerCase().includes(q))
            .map(entry => formatEntry(entry))
            .slice(0, Config.options.search.resultLimit);
    }

    function formatEntry(entry) {
        // cliphist format: "id  content"
        const parts = entry.split(/\s+/);
        const id = parts[0];
        const content = entry.substring(entry.indexOf(parts[1]) || 0);

        return {
            type: "Clipboard",
            name: content,
            comment: "ID: " + id,
            iconName: "../../assets/clipboard.svg",
            iconType: "image",
            execute: () => {
                ClipboardSearch.decode(entry);
                GlobalStates.searchOpen = false;
            }
        };
    }
}
