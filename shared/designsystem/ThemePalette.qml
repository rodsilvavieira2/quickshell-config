pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color white: "#ffffff"
    readonly property color black: "#000000"

    readonly property QtObject dark: QtObject {
        readonly property color surfaceDim: "#09090b"
        readonly property color surface: "#111214"
        readonly property color surfaceBright: "#1b1d21"
        readonly property color surfaceContainerLowest: "#0d0f12"
        readonly property color surfaceContainerLow: "#13161a"
        readonly property color surfaceContainer: "#17191c"
        readonly property color surfaceContainerHigh: "#1f2227"
        readonly property color surfaceContainerHighest: "#262a30"
        readonly property color surfaceVariant: "#30353d"
        readonly property color outline: "#6d7581"
        readonly property color outlineVariant: "#393f48"
        readonly property color inverseSurface: "#edf1f6"
        readonly property color inverseOnSurface: "#17191c"
        readonly property color inversePrimary: "#205fa9"
        readonly property color textPrimary: "#f5f7fa"
        readonly property color textSecondary: "#d6dde8"
        readonly property color textMuted: "#9ba4b0"
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
        readonly property color surfaceDim: "#dde2e8"
        readonly property color surface: "#f8f9fc"
        readonly property color surfaceBright: "#ffffff"
        readonly property color surfaceContainerLowest: "#ffffff"
        readonly property color surfaceContainerLow: "#f3f5f8"
        readonly property color surfaceContainer: "#edf1f5"
        readonly property color surfaceContainerHigh: "#e7ebf0"
        readonly property color surfaceContainerHighest: "#dce1ea"
        readonly property color surfaceVariant: "#d5dce6"
        readonly property color outline: "#66707d"
        readonly property color outlineVariant: "#bcc4d0"
        readonly property color inverseSurface: "#1f2329"
        readonly property color inverseOnSurface: "#f5f7fa"
        readonly property color inversePrimary: "#a9cbff"
        readonly property color textPrimary: "#111827"
        readonly property color textSecondary: "#334155"
        readonly property color textMuted: "#64748b"
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

    function tone(colorValue, towardLight, amount) {
        return towardLight
            ? root.mix(colorValue, root.white, amount)
            : root.mix(colorValue, root.black, amount);
    }
}
