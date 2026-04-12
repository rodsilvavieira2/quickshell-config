pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color seed: ThemeSettings.accent

    readonly property color primary: seed
    readonly property color primaryForeground: ThemeSettings.isDark ? ThemePalette.black : ThemePalette.white
    readonly property color primaryContainer: ThemePalette.mix(seed, ThemeSettings.isDark ? ThemePalette.dark.surfaceContainerHigh : ThemePalette.light.surfaceContainerHigh, ThemeSettings.isDark ? 0.62 : 0.78)
    readonly property color primaryContainerForeground: ThemeSettings.isDark
        ? ThemePalette.tone(seed, true, 0.86)
        : ThemePalette.tone(seed, false, 0.68)

    readonly property color secondary: ThemePalette.mix(seed, ThemeSettings.isDark ? ThemePalette.dark.textSecondary : ThemePalette.light.textSecondary, ThemeSettings.isDark ? 0.58 : 0.72)
    readonly property color secondaryForeground: ThemeSettings.isDark ? ThemePalette.black : ThemePalette.white
    readonly property color secondaryContainer: ThemeSettings.isDark
        ? ThemePalette.mix(seed, ThemePalette.dark.surfaceContainerHigh, 0.74)
        : ThemePalette.mix(seed, ThemePalette.light.surfaceContainer, 0.82)
    readonly property color secondaryContainerForeground: ThemeSettings.isDark ? ThemePalette.dark.textPrimary : ThemePalette.light.textPrimary

    readonly property color tertiary: ThemeSettings.isDark
        ? ThemePalette.mix(seed, ThemePalette.white, 0.22)
        : ThemePalette.mix(seed, ThemePalette.light.textPrimary, 0.12)
    readonly property color tertiaryForeground: ThemeSettings.isDark ? ThemePalette.black : ThemePalette.white
    readonly property color tertiaryContainer: ThemeSettings.isDark
        ? ThemePalette.mix(tertiary, ThemePalette.dark.surfaceContainerHighest, 0.72)
        : ThemePalette.mix(tertiary, ThemePalette.light.surfaceContainerLow, 0.8)
    readonly property color tertiaryContainerForeground: ThemeSettings.isDark ? ThemePalette.dark.textPrimary : ThemePalette.light.textPrimary

    readonly property color surface: ThemeSettings.isDark ? ThemePalette.dark.surface : ThemePalette.light.surface
    readonly property color surfaceDim: ThemeSettings.isDark ? ThemePalette.dark.surfaceDim : ThemePalette.light.surfaceDim
    readonly property color surfaceBright: ThemeSettings.isDark ? ThemePalette.dark.surfaceBright : ThemePalette.light.surfaceBright
    readonly property color surfaceContainerLowest: ThemeSettings.isDark ? ThemePalette.dark.surfaceContainerLowest : ThemePalette.light.surfaceContainerLowest
    readonly property color surfaceContainerLow: ThemeSettings.isDark ? ThemePalette.dark.surfaceContainerLow : ThemePalette.light.surfaceContainerLow
    readonly property color surfaceContainer: ThemeSettings.isDark ? ThemePalette.dark.surfaceContainer : ThemePalette.light.surfaceContainer
    readonly property color surfaceContainerHigh: ThemeSettings.isDark ? ThemePalette.dark.surfaceContainerHigh : ThemePalette.light.surfaceContainerHigh
    readonly property color surfaceContainerHighest: ThemeSettings.isDark ? ThemePalette.dark.surfaceContainerHighest : ThemePalette.light.surfaceContainerHighest
    readonly property color surfaceVariant: ThemeSettings.isDark ? ThemePalette.dark.surfaceVariant : ThemePalette.light.surfaceVariant
    readonly property color surfaceForeground: ThemeSettings.isDark ? ThemePalette.dark.textPrimary : ThemePalette.light.textPrimary
    readonly property color surfaceVariantForeground: ThemeSettings.isDark ? ThemePalette.dark.textSecondary : ThemePalette.light.textSecondary
    readonly property color outline: ThemeSettings.isDark ? ThemePalette.dark.outline : ThemePalette.light.outline
    readonly property color outlineVariant: ThemeSettings.isDark ? ThemePalette.dark.outlineVariant : ThemePalette.light.outlineVariant
    readonly property color inverseSurface: ThemeSettings.isDark ? ThemePalette.dark.inverseSurface : ThemePalette.light.inverseSurface
    readonly property color inverseSurfaceForeground: ThemeSettings.isDark ? ThemePalette.dark.inverseOnSurface : ThemePalette.light.inverseOnSurface
    readonly property color inversePrimary: ThemeSettings.isDark ? ThemePalette.dark.inversePrimary : ThemePalette.light.inversePrimary

    readonly property color error: ThemeSettings.isDark ? ThemePalette.dark.error : ThemePalette.light.error
    readonly property color errorForeground: ThemeSettings.isDark ? ThemePalette.black : ThemePalette.white
    readonly property color errorContainer: ThemeSettings.isDark
        ? ThemePalette.mix(ThemePalette.dark.error, ThemePalette.dark.surfaceContainerHigh, 0.74)
        : ThemePalette.mix(ThemePalette.light.error, ThemePalette.light.surfaceContainerLow, 0.82)
    readonly property color errorContainerForeground: ThemeSettings.isDark ? ThemePalette.dark.textPrimary : ThemePalette.light.textPrimary

    readonly property color success: ThemeSettings.isDark ? ThemePalette.dark.success : ThemePalette.light.success
    readonly property color successContainer: ThemeSettings.isDark
        ? ThemePalette.mix(ThemePalette.dark.success, ThemePalette.dark.surfaceContainerHigh, 0.76)
        : ThemePalette.mix(ThemePalette.light.success, ThemePalette.light.surfaceContainerLow, 0.82)
    readonly property color warning: ThemeSettings.isDark ? ThemePalette.dark.warning : ThemePalette.light.warning
    readonly property color warningContainer: ThemeSettings.isDark
        ? ThemePalette.mix(ThemePalette.dark.warning, ThemePalette.dark.surfaceContainerHigh, 0.76)
        : ThemePalette.mix(ThemePalette.light.warning, ThemePalette.light.surfaceContainerLow, 0.82)
    readonly property color info: ThemeSettings.isDark ? ThemePalette.dark.info : ThemePalette.light.info
    readonly property color infoContainer: ThemeSettings.isDark
        ? ThemePalette.mix(ThemePalette.dark.info, ThemePalette.dark.surfaceContainerHigh, 0.76)
        : ThemePalette.mix(ThemePalette.light.info, ThemePalette.light.surfaceContainerLow, 0.82)

    readonly property color scrim: ThemeSettings.isDark ? ThemePalette.dark.scrim : ThemePalette.light.scrim
    readonly property color shadow: ThemeSettings.isDark ? ThemePalette.dark.shadow : ThemePalette.light.shadow
}
