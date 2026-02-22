import QtQuick

MouseArea {
    id: root
    property bool dragging: false
    property real dragDiffX: 0
    property real dragDiffY: 0
    property bool interactive: true
    property bool automaticallyReset: true
    signal dragClicked(var mouse)
    signal dragPressed(var mouse)
    property int acceptedButtonsMask: Qt.LeftButton

    signal dragReleased(real diffX, real diffY)

    property real pressX: 0
    property real pressY: 0
    property bool pressedActive: false

    function resetDrag() {
        dragging = false
        dragDiffX = 0
        dragDiffY = 0
    }

    hoverEnabled: true
    acceptedButtons: root.acceptedButtonsMask

    onPressed: {
        if (!root.interactive) return;
        pressX = mouse.x
        pressY = mouse.y
        pressedActive = true
        dragging = (mouse.button === Qt.LeftButton)
        root.dragPressed(mouse)
    }

    onPositionChanged: {
        if (!dragging) return;
        dragDiffX = mouse.x - pressX
        dragDiffY = mouse.y - pressY
    }

    onReleased: {
        if (!pressedActive) return;
        pressedActive = false
        if (dragging) {
            dragging = false
            root.dragReleased(dragDiffX, dragDiffY)
        }
        root.dragClicked(mouse)
        if (automaticallyReset) {
            resetDrag()
        }
    }
}
