import QtQuick
import "../shared/designsystem" as Design

Canvas {
    id: root
    property var history: [] // Array of percentages [0, 100]
    property int maxPoints: 30
    property color lineColor: Design.Tokens.color.warning
    property real lineWidth: 2

    onHistoryChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        
        if (history.length < 2) return;

        ctx.strokeStyle = root.lineColor;
        ctx.lineWidth = root.lineWidth;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.beginPath();

        let dx = width / (maxPoints - 1);
        
        // Start from right (most recent) to left, or left to right.
        // history[0] is oldest, history[history.length-1] is newest.
        // Left pad with 0s conceptually if not full.
        let startIndex = maxPoints - history.length;
        
        for (let i = 0; i < history.length; i++) {
            let x = (startIndex + i) * dx;
            // history[i] is 0-100, invert Y axis (0 at bottom)
            let y = height - (history[i] / 100 * height);
            
            // Padding top and bottom so lines don't get clipped
            y = Math.max(root.lineWidth, Math.min(height - root.lineWidth, y));
            
            if (i === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
        }
        ctx.stroke();
    }
}
