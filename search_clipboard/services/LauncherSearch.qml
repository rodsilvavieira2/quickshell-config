pragma Singleton

import QtQuick
import Quickshell
import "../common"
import "../common/functions"
import "."

Singleton {
    id: root

    property string query: ""
    property var results: {
        if (!ClipboardSearch.ready) return [];
        
        let filtered = ClipboardSearch.entries;
        if (query.length > 0) {
            filtered = filtered.filter(entry => 
                entry.toLowerCase().includes(query.toLowerCase())
            );
        }

        return filtered.map(entry => {
            const parts = entry.split(/\t/);
            const id = parts[0] ? parts[0].trim() : "";
            let content = parts[1] ? parts[1].trim() : entry;
            
            let iconType = "image";
            let iconName = "../../assets/clipboard.svg";
            let isImage = content.includes("[[ binary data");

            if (isImage) {
                // Return a placeholder or the actual preview path if available
                iconName = "file:///tmp/quickshell-clipboard-previews/" + id + ".png";
                // Trigger background generation
                ClipboardSearch.generatePreview(entry, (path) => {
                    // This might not trigger a re-render automatically 
                    // since we are mapping in a property, but usually 
                    // image components will reload when file appears.
                });
            }

            return {
                type: "Clipboard",
                name: isImage ? "Image Entry" : content,
                comment: "ID: " + id + (isImage ? " (" + content.split("data ")[1].split(" ]]")[0] + ")" : ""),
                iconName: iconName,
                iconType: "image",
                isImage: isImage,
                execute: () => {
                    ClipboardSearch.decode(entry);
                    GlobalStates.searchOpen = false;
                }
            };
        });
    }
}
