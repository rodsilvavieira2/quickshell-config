pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color white: "#ffffff"
    readonly property color black: "#000000"

    readonly property QtObject dark: QtObject {
        readonly property color bgCanvas: "#09090b"
        readonly property color bgSurface: "#111214"
        readonly property color bgElevated: "#17191c"
        readonly property color bgInteractive: "#1f2227"
        readonly property color bgHover: "#262a30"
        readonly property color bgActive: "#30353d"
        readonly property color borderSubtle: "#262a30"
        readonly property color borderStrong: "#393f48"
        readonly property color textPrimary: "#f5f7fa"
        readonly property color textSecondary: "#c2c9d3"
        readonly property color textMuted: "#9098a4"
        readonly property color textInverse: "#09090b"
        readonly property color iconPrimary: "#f5f7fa"
        readonly property color iconSecondary: "#aab2be"
        readonly property color success: "#8fd8a6"
        readonly property color warning: "#f6c177"
        readonly property color error: "#f38ba8"
        readonly property color info: "#89b4fa"
        readonly property color scrim: "#b0000000"
        readonly property color shadow: "#73000000"
    }

    readonly property QtObject light: QtObject {
        readonly property color bgCanvas: "#eff1f5"
        readonly property color bgSurface: "#ffffff"
        readonly property color bgElevated: "#f7f8fa"
        readonly property color bgInteractive: "#eef1f5"
        readonly property color bgHover: "#e5e9f0"
        readonly property color bgActive: "#dce1ea"
        readonly property color borderSubtle: "#d8dde6"
        readonly property color borderStrong: "#bcc4d0"
        readonly property color textPrimary: "#111827"
        readonly property color textSecondary: "#4b5563"
        readonly property color textMuted: "#6b7280"
        readonly property color textInverse: "#ffffff"
        readonly property color iconPrimary: "#111827"
        readonly property color iconSecondary: "#6b7280"
        readonly property color success: "#1f8f57"
        readonly property color warning: "#b7791f"
        readonly property color error: "#c53030"
        readonly property color info: "#2563eb"
        readonly property color scrim: "#660f172a"
        readonly property color shadow: "#220f172a"
    }

    function withAlpha(colorValue, alphaValue) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, alphaValue);
    }

    function mix(firstColor, secondColor, amount) {
        const inverse = 1.0 - amount;
        return Qt.rgba(
            firstColor.r * inverse + secondColor.r * amount,
            firstColor.g * inverse + secondColor.g * amount,
            firstColor.b * inverse + secondColor.b * amount,
            firstColor.a * inverse + secondColor.a * amount
        );
    }
}
