pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../common"
import "../common/functions"

Singleton {
    id: root

    function run(commandText) {
        const cleaned = StringUtils.trim(commandText.replace("file://", ""));
        if (!cleaned) return;
        Quickshell.execDetached(["bash", "-c", cleaned]);
    }
}
