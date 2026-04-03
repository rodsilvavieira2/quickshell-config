pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property QtObject palette: ThemeSettings.isDark ? ThemePalette.dark : ThemePalette.light
    readonly property color accentBase: ThemeSettings.accent

    readonly property QtObject color: QtObject {
        readonly property QtObject bg: QtObject {
            readonly property color canvas: root.palette.bgCanvas
            readonly property color surface: root.palette.bgSurface
            readonly property color elevated: root.palette.bgElevated
            readonly property color interactive: root.palette.bgInteractive
            readonly property color hover: root.palette.bgHover
            readonly property color active: root.palette.bgActive
        }

        readonly property QtObject border: QtObject {
            readonly property color subtle: root.palette.borderSubtle
            readonly property color strong: root.palette.borderStrong
        }

        readonly property QtObject text: QtObject {
            readonly property color primary: root.palette.textPrimary
            readonly property color secondary: root.palette.textSecondary
            readonly property color muted: root.palette.textMuted
            readonly property color inverse: root.palette.textInverse
        }

        readonly property QtObject icon: QtObject {
            readonly property color primary: root.palette.iconPrimary
            readonly property color secondary: root.palette.iconSecondary
        }

        readonly property QtObject accent: QtObject {
            readonly property color primary: root.accentBase
            readonly property color hover: ThemeSettings.isDark
                ? ThemePalette.mix(root.accentBase, ThemePalette.white, 0.12)
                : ThemePalette.mix(root.accentBase, ThemePalette.black, 0.08)
            readonly property color active: ThemeSettings.isDark
                ? ThemePalette.mix(root.accentBase, ThemePalette.white, 0.22)
                : ThemePalette.mix(root.accentBase, ThemePalette.black, 0.16)
        }

        readonly property color success: root.palette.success
        readonly property color warning: root.palette.warning
        readonly property color error: root.palette.error
        readonly property color info: root.palette.info
        readonly property color focusRing: ThemePalette.withAlpha(root.accentBase, ThemeSettings.isDark ? 0.55 : 0.35)
        readonly property color scrim: root.palette.scrim
        readonly property color shadow: root.palette.shadow
    }

    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string display: ThemeSettings.resolvedFontFamily
            readonly property string title: ThemeSettings.resolvedFontFamily
            readonly property string body: ThemeSettings.resolvedFontFamily
            readonly property string label: ThemeSettings.resolvedFontFamily
            readonly property string caption: ThemeSettings.resolvedFontFamily
            readonly property string icon: ThemeSettings.iconFontFamily
        }

        readonly property QtObject size: QtObject {
            readonly property int display: Math.round(32 * ThemeSettings.uiScale)
            readonly property int title: Math.round(18 * ThemeSettings.uiScale)
            readonly property int body: Math.round(14 * ThemeSettings.uiScale)
            readonly property int label: Math.round(13 * ThemeSettings.uiScale)
            readonly property int caption: Math.round(12 * ThemeSettings.uiScale)
            readonly property int small: Math.round(11 * ThemeSettings.uiScale)
        }

        readonly property QtObject weight: QtObject {
            readonly property int regular: Font.Normal
            readonly property int medium: Font.Medium
            readonly property int semibold: Font.DemiBold
            readonly property int bold: Font.Bold
        }
    }

    readonly property QtObject space: QtObject {
        readonly property int s2: 2
        readonly property int s4: 4
        readonly property int s8: 8
        readonly property int s12: 12
        readonly property int s16: 16
        readonly property int s20: 20
        readonly property int s24: 24
        readonly property int s32: 32
    }

    readonly property QtObject radius: QtObject {
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int pill: 999
    }

    readonly property QtObject shadow: QtObject {
        readonly property int none: 0
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 18
    }

    readonly property QtObject motion: QtObject {
        readonly property QtObject duration: QtObject {
            readonly property int fast: 120
            readonly property int normal: 180
            readonly property int slow: 240
        }

        readonly property QtObject easing: QtObject {
            readonly property var standard: Easing.OutCubic
            readonly property var decelerate: Easing.OutCubic
            readonly property var accelerate: Easing.InCubic
        }
    }

    readonly property QtObject border: QtObject {
        readonly property QtObject width: QtObject {
            readonly property int thin: 1
            readonly property int medium: 1
            readonly property int strong: 2
        }
    }

    readonly property QtObject opacities: QtObject {
        readonly property real disabled: 0.45
        readonly property real muted: 0.68
        readonly property real overlay: 0.72
    }

    readonly property QtObject component: QtObject {
        readonly property QtObject panel: QtObject {
            readonly property int padding: root.space.s24
            readonly property int radius: root.radius.xl
            readonly property int gap: root.space.s16
        }

        readonly property QtObject card: QtObject {
            readonly property int padding: root.space.s16
            readonly property int radius: root.radius.lg
            readonly property int gap: root.space.s12
        }

        readonly property QtObject button: QtObject {
            readonly property int heightMd: 40
            readonly property int heightLg: 48
            readonly property int paddingX: root.space.s16
        }

        readonly property QtObject input: QtObject {
            readonly property int height: 44
            readonly property int paddingX: root.space.s16
            readonly property int radius: root.radius.lg
        }

        readonly property QtObject listItem: QtObject {
            readonly property int minHeight: 52
            readonly property int paddingX: root.space.s16
            readonly property int paddingY: root.space.s12
        }
    }
}
