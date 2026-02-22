pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

Singleton {
    id: root

    property string result: ""
    property string lastExpression: ""

    Process {
        id: mathProcess
        command: ["qalc", "-t", "0"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                root.result = data.trim();
            }
        }
    }

    function calculate(expression) {
        if (!Config.options.search.enableMath) return;
        if (!expression || expression.trim() === "") {
            root.result = "";
            root.lastExpression = "";
            return;
        }
        if (root.lastExpression === expression) return;
        root.lastExpression = expression;
        mathProcess.running = false;
        mathProcess.command = ["qalc", "-t", expression];
        mathProcess.running = true;
    }
}
