import QtQuick
import QtQuick.Effects
import Quickshell

import "../shared/designsystem" as Design
import "../shared/ui" as DS

Item {
    id: root

    property var device
    property string typeKey: "generic"
    property int size: 56
    property color containerColor: Design.Tokens.color.secondaryContainer
    property color contentColor: Design.Tokens.color.secondaryContainerForeground

    readonly property string fallbackIconName: {
        switch (root.typeKey) {
        case "mouse": return "input-mouse";
        case "keyboard": return "input-keyboard";
        case "headset": return "audio-headset-bluetooth";
        case "speaker": return "audio-speakers-bluetooth";
        case "controller": return "input-gaming";
        case "peripheral": return "bluetooth";
        case "unknown": return "bluetooth";
        default: return "bluetooth";
        }
    }
    readonly property url systemIconSource: {
        if (root.device && root.device.icon && root.device.icon.length > 0 && Quickshell.hasThemeIcon(root.device.icon)) {
            return Quickshell.iconPath(root.device.icon);
        }
        if (Quickshell.hasThemeIcon(root.fallbackIconName)) {
            return Quickshell.iconPath(root.fallbackIconName);
        }
        return "";
    }
    readonly property bool useLucideGlyph: root.typeKey === "mouse"
        || root.typeKey === "keyboard"
        || root.typeKey === "generic"
        || root.typeKey === "unknown"
        || root.typeKey === "peripheral"
        || root.systemIconSource.toString().length === 0
    readonly property string lucideName: {
        if (root.typeKey === "mouse") return "mouse-pointer-2";
        if (root.typeKey === "keyboard") return "keyboard";
        return "bluetooth";
    }

    implicitWidth: root.size
    implicitHeight: root.size

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.containerColor
        border.width: Design.Tokens.border.width.thin
        border.color: Design.ThemePalette.withAlpha(root.contentColor, 0.18)
    }

    DS.LucideIcon {
        anchors.centerIn: parent
        visible: root.useLucideGlyph
        name: root.lucideName
        iconSize: Math.round(root.size * 0.44)
        color: root.contentColor
    }

    Item {
        anchors.centerIn: parent
        width: Math.round(root.size * 0.5)
        height: width
        visible: !root.useLucideGlyph

        Image {
            id: sourceIcon
            anchors.fill: parent
            source: root.systemIconSource
            sourceSize: Qt.size(width * 2, height * 2)
            fillMode: Image.PreserveAspectFit
            visible: false
            smooth: true
        }

        MultiEffect {
            anchors.fill: parent
            source: sourceIcon
            visible: sourceIcon.status === Image.Ready
            colorization: 1
            colorizationColor: root.contentColor
        }
    }
}
