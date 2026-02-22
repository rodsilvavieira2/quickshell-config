import QtQuick
import QtQuick.Effects
import Quickshell
import ".."

Item {
    id: root
    property int iconSize: Appearance ? (Appearance.font.pixelSize.larger !== undefined ? Appearance.font.pixelSize.larger : 18) : 18
    property bool filled: false
    property string text: ""
    property color color: Appearance ? (Appearance.colors.colOnLayer0 !== undefined ? Appearance.colors.colOnLayer0 : "#cdd6f4") : "#cdd6f4"
    property bool preferLocalIcons: true
    property bool fontAvailable: Qt.fontFamilies().indexOf("Material Symbols Rounded") !== -1
    readonly property string localIconPath: Quickshell.shellPath(`assets/icons/${root.text}.svg`)
    readonly property bool hasText: root.text !== ""
    readonly property bool useFontIcon: root.hasText && !preferLocalIcons && fontAvailable
    readonly property bool localIconReady: root.hasText && localIcon.status === Image.Ready
    readonly property bool localIconFailed: root.hasText && localIcon.status === Image.Error
    readonly property bool useLocalIcon: preferLocalIcons && localIconReady
    readonly property bool useFallbackIcon: root.hasText && (!root.useFontIcon && (!root.preferLocalIcons || root.localIconFailed))
    property string fallbackName: {
        switch (text) {
        case "notifications":
            return "notifications"
        case "notifications_paused":
            return "notifications-disabled"
        case "delete_sweep":
            return "edit-clear-all"
        case "keyboard_arrow_down":
            return "pan-down"
        case "close":
            return "window-close"
        case "content_copy":
            return "edit-copy"
        case "inventory":
            return "emblem-ok"
        case "priority_high":
            return "dialog-warning"
        default:
            return "application-x-executable"
        }
    }

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: iconSize
    height: iconSize

    Text {
        id: fontIcon
        anchors.centerIn: parent
        visible: root.useFontIcon
        text: root.text
        font.family: "Material Symbols Rounded"
        font.styleName: root.filled ? "Filled" : "Regular"
        font.pixelSize: root.iconSize
        color: root.color
        font.weight: root.filled ? Font.Black : Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
    }

    Image {
        id: localIcon
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: root.hasText ? root.localIconPath : ""
        visible: false
        asynchronous: true
        smooth: true
        mipmap: true
    }

    MultiEffect {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: localIcon
        visible: root.useLocalIcon
        colorization: 1
        colorizationColor: root.color
    }

    Image {
        id: fallbackIcon
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: root.useFallbackIcon ? Quickshell.iconPath(root.fallbackName, "image-missing") : ""
        visible: false
        smooth: true
        mipmap: true
        asynchronous: true
    }

    MultiEffect {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        source: fallbackIcon
        visible: root.useFallbackIcon
        colorization: 1
        colorizationColor: root.color
    }
}
