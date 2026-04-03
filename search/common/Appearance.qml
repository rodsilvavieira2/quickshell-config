pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../shared/designsystem"

Singleton {
    id: root

    property QtObject colors: QtObject {
        property color colLayer0: Tokens.color.bg.surface
        property color colLayer0Border: Tokens.color.border.subtle
        property color colLayer1: Tokens.color.bg.elevated
        property color colLayer1Hover: Tokens.color.bg.hover
        property color colLayer2: Tokens.color.bg.interactive
        property color colLayer2Hover: Tokens.color.bg.hover
        property color colOnLayer0: Tokens.color.text.primary
        property color colSubtext: Tokens.color.text.secondary
        property color colShadow: Tokens.color.shadow
        property color colAccent: Tokens.color.accent.primary
        property color colAccentSubtle: ThemePalette.withAlpha(Tokens.color.accent.primary, ThemeSettings.isDark ? 0.14 : 0.12)
        property color colSeparator: Tokens.color.border.subtle
    }

    property QtObject font: QtObject {
        property QtObject family: QtObject {
            property string main: Tokens.font.family.body
            property string title: Tokens.font.family.title
            property string expressive: Tokens.font.family.display
            property string icon: Tokens.font.family.icon
        }
        property QtObject pixelSize: QtObject {
            property int smaller: Tokens.font.size.caption
            property int small: Tokens.font.size.label
            property int normal: Tokens.font.size.body
            property int larger: Tokens.font.size.title
            property int huge: Math.round(22 * ThemeSettings.uiScale)
        }
    }

    property QtObject sizes: QtObject {
        property real elevationMargin: Tokens.shadow.md
    }
}
