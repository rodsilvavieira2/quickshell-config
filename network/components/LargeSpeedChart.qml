import QtQuick
import "../services"

Canvas {
    id: root
    
    property var downloadHistory: NetSpeed.downloadHistory
    property var uploadHistory: NetSpeed.uploadHistory
    property real maxSpeed: NetSpeed.maxObservedSpeed
    property int maxPoints: 60
    
    onDownloadHistoryChanged: requestPaint()
    onUploadHistoryChanged: requestPaint()
    onMaxSpeedChanged: requestPaint()
    
    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        
        const histories = [
            { data: downloadHistory, line: "#94e2d5", fill: Qt.rgba(0.580, 0.886, 0.835, 0.1) }, // Teal
            { data: uploadHistory,   line: "#cba6f7", fill: Qt.rgba(0.796, 0.651, 0.969, 0.1) }  // Mauve
        ]
        
        const dx = width / (maxPoints - 1)
        const safeCeil = maxSpeed > 0 ? maxSpeed : 1.0
        
        for (let s = 0; s < histories.length; s++) {
            const hist = histories[s].data
            if (hist.length < 2) continue
            
            const startIndex = maxPoints - hist.length
            const pts = []
            for (let i = 0; i < hist.length; i++) {
                const x = (startIndex + i) * dx
                const rawY = height - (hist[i] / safeCeil * height)
                const y = Math.max(1, Math.min(height - 1, rawY))
                pts.push({ x, y })
            }
            
            // Fill
            ctx.beginPath()
            ctx.moveTo(pts[0].x, height)
            ctx.lineTo(pts[0].x, pts[0].y)
            for (let i = 1; i < pts.length; i++)
                ctx.lineTo(pts[i].x, pts[i].y)
            ctx.lineTo(pts[pts.length - 1].x, height)
            ctx.closePath()
            ctx.fillStyle = histories[s].fill
            ctx.fill()
            
            // Stroke
            ctx.beginPath()
            ctx.moveTo(pts[0].x, pts[0].y)
            for (let i = 1; i < pts.length; i++)
                ctx.lineTo(pts[i].x, pts[i].y)
            ctx.strokeStyle = histories[s].line
            ctx.lineWidth = 2
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            ctx.stroke()
        }
    }
}
