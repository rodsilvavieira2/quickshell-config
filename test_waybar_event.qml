import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    property var windowList: []
    
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            console.log("RawEvent: " + event);
            if (!getClients.running) {
                getClients.running = true;
            }
        }
    }
    
    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            id: clientsCollector
            onStreamFinished: {
                console.log("Stream finished. Length: " + clientsCollector.text.length);
                try {
                    var list = JSON.parse(clientsCollector.text);
                    console.log("Parsed windows count: " + list.length);
                } catch (e) {
                    console.error("Parse error: " + e);
                }
            }
        }
    }
}
