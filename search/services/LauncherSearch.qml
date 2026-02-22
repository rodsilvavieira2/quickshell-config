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

    function computeResults() {
        const q = root.query ?? "";
        if (q.length === 0) {
            results = [];
            return;
        }

        const cleaned = StringUtils.trim(q);
        const apps = AppSearch.queryApps(cleaned)
            .slice(0, Config.options.search.maxPerCategory)
            .map(entry => ({
                type: "App",
                name: entry.name,
                comment: entry.genericName || entry.comment,
                iconName: entry.icon,
                iconType: "system",
                execute: () => {
                    if (!entry.runInTerminal) entry.execute();
                    else {
                        const cmd = entry.command?.join(" ") ?? entry.execString ?? "";
                        const safe = StringUtils.shellSingleQuoteEscape(cmd);
                        Quickshell.execDetached(["bash", "-c", `${Config.options.apps.terminal} -e '${safe}'`]);
                    }
                }
            }));

        results = apps.slice(0, Config.options.search.resultLimit);
    }
}
