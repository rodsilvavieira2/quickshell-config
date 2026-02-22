pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"
import "../common/functions"

Singleton {
    id: root

    property var emojiList: []
    property bool ready: false

    FileView {
        id: emojiFile
        path: Quickshell.shellPath("assets/emoji.txt")
        watchChanges: false
        onLoaded: {
            emojiList = emojiFile.text.split("\n").map(line => line.trim()).filter(l => l.length > 0);
            root.ready = true;
        }
        onLoadFailed: {
            emojiList = [
                ":) smile",
                ":-( frown",
                ":-/ unsure",
                ":-D laugh",
                "<3 heart",
                "* star",
                "! exclamation",
                "? question",
                "ok okay",
                "sun sun",
                "moon moon",
                "fire fire",
                "sparkle sparkle",
                "note music",
                "check check",
                "cross cross",
                "idea idea",
                "pin pin",
                "clip clip",
                "lock lock",
                "unlock unlock",
                "bell bell",
                "mute mute"
            ];
            root.ready = true;
        }
    }

    function query(search) {
        if (!Config.options.search.enableEmojis) return [];
        if (!root.ready) return [];
        const q = StringUtils.trim(search).toLowerCase();
        if (!q) return emojiList;
        return emojiList.filter(e => e.toLowerCase().includes(q));
    }
}
