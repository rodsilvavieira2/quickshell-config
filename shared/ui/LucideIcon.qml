import QtQuick
import QtQuick.Effects

Item {
    id: root

    property string name: ""
    property url source: ""
    property color color: "white"
    property int iconSize: 16
    property real opticalScale: 1.14

    function resolvedSource() {
        if (root.source.toString().length > 0)
            return root.source;

        const shared = {
            "x": Qt.resolvedUrl("../assets/lucide/x.svg"),
            "search": Qt.resolvedUrl("../assets/lucide/search.svg"),
            "plus": Qt.resolvedUrl("../assets/lucide/plus.svg"),
            "chevron-left": Qt.resolvedUrl("../assets/lucide/chevron-left.svg"),
            "chevron-right": Qt.resolvedUrl("../assets/lucide/chevron-right.svg"),
            "palette": Qt.resolvedUrl("../assets/lucide/palette.svg"),
            "house": Qt.resolvedUrl("../assets/lucide/house.svg"),
            "image": Qt.resolvedUrl("../assets/lucide/image.svg"),
            "monitor": Qt.resolvedUrl("../assets/lucide/monitor.svg"),
            "wifi": Qt.resolvedUrl("../assets/lucide/wifi.svg"),
            "wifi-off": Qt.resolvedUrl("../assets/lucide/wifi-off.svg"),
            "ethernet": Qt.resolvedUrl("../assets/lucide/ethernet.svg"),
            "network": Qt.resolvedUrl("../assets/lucide/wifi.svg"),
            "volume-1": Qt.resolvedUrl("../assets/lucide/volume-1.svg"),
            "volume-2": Qt.resolvedUrl("../assets/lucide/volume-2.svg"),
            "volume-x": Qt.resolvedUrl("../assets/lucide/volume-x.svg"),
            "bluetooth": Qt.resolvedUrl("../assets/lucide/bluetooth.svg"),
            "bluetooth-off": Qt.resolvedUrl("../assets/lucide/bluetooth-off.svg"),
            "bluetooth-connected": Qt.resolvedUrl("../assets/lucide/bluetooth-connected.svg"),
            "play": Qt.resolvedUrl("../assets/lucide/play.svg"),
            "pause": Qt.resolvedUrl("../assets/lucide/pause.svg"),
            "skip-back": Qt.resolvedUrl("../assets/lucide/skip-back.svg"),
            "skip-forward": Qt.resolvedUrl("../assets/lucide/skip-forward.svg"),
            "chevron-down": Qt.resolvedUrl("../assets/lucide/chevron-down.svg"),
            "settings-2": Qt.resolvedUrl("../assets/lucide/settings-2.svg"),
            "keyboard": Qt.resolvedUrl("../assets/lucide/keyboard.svg"),
            "mouse-pointer-2": Qt.resolvedUrl("../assets/lucide/mouse-pointer-2.svg"),
            "files": Qt.resolvedUrl("../assets/lucide/files.svg"),
            "file-text": Qt.resolvedUrl("../assets/lucide/file-text.svg"),
            "bell": Qt.resolvedUrl("../assets/lucide/bell.svg"),
            "bell-off": Qt.resolvedUrl("../assets/lucide/bell-off.svg"),
            "music-4": Qt.resolvedUrl("../assets/lucide/music-4.svg"),
            "log-out": Qt.resolvedUrl("../assets/lucide/log-out.svg"),
            "lock": Qt.resolvedUrl("../assets/lucide/lock.svg"),
            "power": Qt.resolvedUrl("../assets/lucide/power.svg"),
            "cpu": Qt.resolvedUrl("../assets/lucide/cpu.svg"),
            "memory-stick": Qt.resolvedUrl("../assets/lucide/memory-stick.svg"),
            "microchip": Qt.resolvedUrl("../assets/lucide/microchip.svg"),
            "hard-drive": Qt.resolvedUrl("../assets/lucide/hard-drive.svg"),
            "sun-medium": Qt.resolvedUrl("../assets/lucide/sun-medium.svg"),
            "wind": Qt.resolvedUrl("../assets/lucide/wind.svg"),
            "droplets": Qt.resolvedUrl("../assets/lucide/droplets.svg"),
            "cloud-rain": Qt.resolvedUrl("../assets/lucide/cloud-rain.svg"),
            "check": Qt.resolvedUrl("../assets/lucide/check.svg")
        };

        if (shared[root.name] !== undefined)
            return shared[root.name];
        return "";
    }

    readonly property url effectiveSource: resolvedSource()

    implicitWidth: iconSize
    implicitHeight: iconSize
    visible: effectiveSource.toString().length > 0

    Item {
        id: iconFrame
        anchors.centerIn: parent
        width: root.iconSize * root.opticalScale
        height: root.iconSize * root.opticalScale

        Image {
            id: iconSource
            anchors.fill: parent
            source: root.effectiveSource
            sourceSize: Qt.size(root.iconSize * root.opticalScale * 2, root.iconSize * root.opticalScale * 2)
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: false
        }
    }

    MultiEffect {
        anchors.fill: iconFrame
        source: iconSource
        colorization: 1.0
        colorizationColor: root.color
    }
}
