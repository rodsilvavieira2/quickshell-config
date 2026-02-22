pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../common"
import "../common/functions"

Singleton {
    id: root

    function queryApps(search) {
        const q = StringUtils.trim(search).toLowerCase();
        const apps = DesktopEntries.applications.values;
        if (!q) return apps;

        return apps.map(entry => {
            const name = entry.name ?? "";
            const genericName = entry.genericName ?? "";
            const comment = entry.comment ?? "";
            const keywords = entry.keywords ?? [];
            const execString = entry.execString ?? "";
            const score = Math.max(
                Fuzzy.score(name, q),
                Fuzzy.score(genericName, q),
                Fuzzy.score(comment, q),
                Fuzzy.score(execString, q),
                Math.max(...keywords.map(k => Fuzzy.score(k, q)), 0)
            );
            return { entry, score };
        }).filter(item => item.score > 0)
          .sort((a, b) => b.score - a.score)
          .map(item => item.entry);
    }
}
