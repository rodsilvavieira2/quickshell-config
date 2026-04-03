pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color accentBase: ThemeSettings.accent

    readonly property QtObject color: QtObject {
        readonly property color primary: MaterialRoles.primary
        readonly property color primaryForeground: MaterialRoles.primaryForeground
        readonly property color primaryContainer: MaterialRoles.primaryContainer
        readonly property color primaryContainerForeground: MaterialRoles.primaryContainerForeground
        readonly property color secondary: MaterialRoles.secondary
        readonly property color secondaryForeground: MaterialRoles.secondaryForeground
        readonly property color secondaryContainer: MaterialRoles.secondaryContainer
        readonly property color secondaryContainerForeground: MaterialRoles.secondaryContainerForeground
        readonly property color tertiary: MaterialRoles.tertiary
        readonly property color tertiaryForeground: MaterialRoles.tertiaryForeground
        readonly property color tertiaryContainer: MaterialRoles.tertiaryContainer
        readonly property color tertiaryContainerForeground: MaterialRoles.tertiaryContainerForeground
        readonly property color surface: MaterialRoles.surface
        readonly property color surfaceDim: MaterialRoles.surfaceDim
        readonly property color surfaceBright: MaterialRoles.surfaceBright
        readonly property color surfaceContainerLowest: MaterialRoles.surfaceContainerLowest
        readonly property color surfaceContainerLow: MaterialRoles.surfaceContainerLow
        readonly property color surfaceContainer: MaterialRoles.surfaceContainer
        readonly property color surfaceContainerHigh: MaterialRoles.surfaceContainerHigh
        readonly property color surfaceContainerHighest: MaterialRoles.surfaceContainerHighest
        readonly property color surfaceVariant: MaterialRoles.surfaceVariant
        readonly property color surfaceForeground: MaterialRoles.surfaceForeground
        readonly property color surfaceVariantForeground: MaterialRoles.surfaceVariantForeground
        readonly property color outline: MaterialRoles.outline
        readonly property color outlineVariant: MaterialRoles.outlineVariant
        readonly property color inverseSurface: MaterialRoles.inverseSurface
        readonly property color inverseSurfaceForeground: MaterialRoles.inverseSurfaceForeground
        readonly property color inversePrimary: MaterialRoles.inversePrimary

        readonly property QtObject bg: QtObject {
            readonly property color canvas: MaterialRoles.surfaceDim
            readonly property color surface: MaterialRoles.surface
            readonly property color elevated: MaterialRoles.surfaceContainer
            readonly property color interactive: MaterialRoles.surfaceContainerHigh
            readonly property color hover: ThemePalette.mix(MaterialRoles.surfaceContainerHigh, MaterialRoles.surfaceForeground, ThemeSettings.isDark ? 0.06 : 0.04)
            readonly property color active: ThemePalette.mix(MaterialRoles.surfaceContainerHighest, MaterialRoles.surfaceForeground, ThemeSettings.isDark ? 0.08 : 0.06)
        }

        readonly property QtObject border: QtObject {
            readonly property color subtle: MaterialRoles.outlineVariant
            readonly property color strong: MaterialRoles.outline
        }

        readonly property QtObject text: QtObject {
            readonly property color primary: MaterialRoles.surfaceForeground
            readonly property color secondary: MaterialRoles.surfaceVariantForeground
            readonly property color muted: ThemeSettings.isDark ? ThemePalette.dark.textMuted : ThemePalette.light.textMuted
            readonly property color inverse: ThemeSettings.isDark ? ThemePalette.dark.textInverse : ThemePalette.light.textInverse
        }

        readonly property QtObject icon: QtObject {
            readonly property color primary: ThemeSettings.isDark ? ThemePalette.dark.iconPrimary : ThemePalette.light.iconPrimary
            readonly property color secondary: ThemeSettings.isDark ? ThemePalette.dark.iconSecondary : ThemePalette.light.iconSecondary
        }

        readonly property QtObject accent: QtObject {
            readonly property color primary: MaterialRoles.primary
            readonly property color hover: ThemeSettings.isDark
                ? ThemePalette.mix(MaterialRoles.primary, ThemePalette.white, 0.12)
                : ThemePalette.mix(MaterialRoles.primary, ThemePalette.black, 0.08)
            readonly property color active: ThemeSettings.isDark
                ? ThemePalette.mix(MaterialRoles.primary, ThemePalette.white, 0.22)
                : ThemePalette.mix(MaterialRoles.primary, ThemePalette.black, 0.16)
        }

        readonly property color success: MaterialRoles.success
        readonly property color successContainer: MaterialRoles.successContainer
        readonly property color warning: MaterialRoles.warning
        readonly property color warningContainer: MaterialRoles.warningContainer
        readonly property color error: MaterialRoles.error
        readonly property color errorForeground: MaterialRoles.errorForeground
        readonly property color errorContainer: MaterialRoles.errorContainer
        readonly property color errorContainerForeground: MaterialRoles.errorContainerForeground
        readonly property color info: MaterialRoles.info
        readonly property color infoContainer: MaterialRoles.infoContainer
        readonly property color focusRing: ThemePalette.withAlpha(MaterialRoles.primary, ThemeSettings.isDark ? 0.55 : 0.35)
        readonly property color scrim: MaterialRoles.scrim
        readonly property color shadow: MaterialRoles.shadow
    }

    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string display: ThemeSettings.resolvedFontFamily
            readonly property string headline: ThemeSettings.resolvedFontFamily
            readonly property string title: ThemeSettings.resolvedFontFamily
            readonly property string body: ThemeSettings.resolvedFontFamily
            readonly property string label: ThemeSettings.resolvedFontFamily
            readonly property string caption: ThemeSettings.resolvedFontFamily
            readonly property string icon: ThemeSettings.iconFontFamily
        }

        readonly property QtObject size: QtObject {
            readonly property int display: Math.round(32 * ThemeSettings.uiScale)
            readonly property int headline: Math.round(24 * ThemeSettings.uiScale)
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
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int xxl: 28
        readonly property int pill: 999
    }

    readonly property QtObject shape: QtObject {
        readonly property int extraSmall: root.radius.xs
        readonly property int small: root.radius.sm
        readonly property int medium: root.radius.md
        readonly property int large: root.radius.lg
        readonly property int extraLarge: root.radius.xl
        readonly property int full: root.radius.pill
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

    readonly property QtObject stateLayer: QtObject {
        readonly property real hover: 0.08
        readonly property real focus: 0.12
        readonly property real pressed: 0.12
        readonly property real dragged: 0.16
        readonly property real selected: 0.10
    }

    readonly property QtObject component: QtObject {
        readonly property QtObject panel: QtObject {
            readonly property int padding: root.space.s24
            readonly property int radius: root.radius.xxl
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
            readonly property int iconSize: 18
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

        readonly property QtObject topAppBar: QtObject {
            readonly property int height: 72
            readonly property int paddingX: root.space.s24
            readonly property int paddingY: root.space.s16
        }

        readonly property QtObject drawer: QtObject {
            readonly property int width: 264
            readonly property int railWidth: 84
            readonly property int itemHeight: 48
            readonly property int itemRadius: root.radius.lg
            readonly property int sectionGap: root.space.s8
        }

        readonly property QtObject searchBar: QtObject {
            readonly property int height: 48
            readonly property int radius: root.radius.pill
        }

        readonly property QtObject settingRow: QtObject {
            readonly property int minHeight: 64
            readonly property int paddingX: root.space.s16
            readonly property int paddingY: root.space.s12
            readonly property int radius: root.radius.lg
        }
    }
}
