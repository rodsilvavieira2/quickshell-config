pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import "../common"
import "../common/functions"

Singleton {
    id: root

    property var actions: []

    FolderListModel {
        id: actionFolder
        folder: Quickshell.shellPath("actions")
        showDirs: false
        showHidden: false
        sortField: FolderListModel.Name
        onCountChanged: root.reloadActions()
    }

    function reloadActions() {
        const list = [];
        for (let i = 0; i < actionFolder.count; i++) {
            const fileName = actionFolder.get(i, "fileName");
            const filePath = actionFolder.get(i, "filePath");
            if (!fileName || !filePath) continue;
            const actionName = fileName.replace(/\.[^/.]+$/, "");
            list.push({
                name: actionName,
                path: filePath.toString()
            });
        }
        actions = list;
    }

    function run(actionName, args) {
        const match = actions.find(a => a.name === actionName);
        if (!match) return;
        const filePath = match.path.replace("file://", "");
        const parts = StringUtils.trim(args || "").split(" ").filter(p => p.length > 0);
        Quickshell.execDetached([filePath].concat(parts));
    }
}
