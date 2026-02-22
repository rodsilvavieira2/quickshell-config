pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../common"
import "../common/functions"

Singleton {
    id: root

    function open(query) {
        const cleaned = StringUtils.trim(query);
        if (!cleaned) return;
        const url = Config.options.search.engineBaseUrl + cleaned;
        Qt.openUrlExternally(url);
    }
}
