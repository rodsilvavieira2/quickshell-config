import QtQuick
import QtQuick.Controls
import "../designsystem"

Rectangle {
    id: root

    signal clicked()

    property string text: ""
    property string variant: "primary"
    property bool disabled: false
    property bool loading: false
    property int preferredHeight: Tokens.component.button.heightMd

    readonly property bool isPrimary: variant === "primary"
    readonly property bool isSecondary: variant === "secondary"
    readonly property bool isDanger: variant === "danger"
    readonly property color baseColor: {
        if (isPrimary) return Tokens.color.accent.primary;
        if (isDanger) return Tokens.color.error;
        if (isSecondary) return Tokens.color.bg.interactive;
        return "transparent";
    }
    readonly property color hoverColor: {
        if (isPrimary) return Tokens.color.accent.hover;
        if (isDanger) return ThemePalette.mix(Tokens.color.error, ThemePalette.white, ThemeSettings.isDark ? 0.08 : 0.0);
        if (isSecondary) return Tokens.color.bg.hover;
        return ThemePalette.withAlpha(Tokens.color.text.primary, ThemeSettings.isDark ? 0.08 : 0.05);
    }
    readonly property color pressedColor: {
        if (isPrimary) return Tokens.color.accent.active;
        if (isDanger) return ThemePalette.mix(Tokens.color.error, ThemePalette.black, ThemeSettings.isDark ? 0.05 : 0.12);
        if (isSecondary) return Tokens.color.bg.active;
        return ThemePalette.withAlpha(Tokens.color.text.primary, ThemeSettings.isDark ? 0.12 : 0.08);
    }
    readonly property color textColor: isPrimary || isDanger ? Tokens.color.text.inverse : Tokens.color.text.primary

    implicitWidth: Math.max(112, label.implicitWidth + Tokens.component.button.paddingX * 2)
    implicitHeight: preferredHeight
    radius: Tokens.radius.pill
    color: root.disabled ? ThemePalette.withAlpha(baseColor, 0.55) : mouseArea.pressed ? pressedColor : mouseArea.containsMouse ? hoverColor : baseColor
    border.width: variant === "ghost" ? Tokens.border.width.thin : 0
    border.color: variant === "ghost" ? Tokens.color.border.subtle : "transparent"
    opacity: disabled ? Tokens.opacities.disabled : 1

    Behavior on color {
        ColorAnimation {
            duration: Tokens.motion.duration.fast
            easing.type: Tokens.motion.easing.standard
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.loading ? "Loading..." : root.text
        color: root.textColor
        font.family: Tokens.font.family.label
        font.pixelSize: Tokens.font.size.label
        font.weight: Tokens.font.weight.semibold
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: !root.disabled && !root.loading
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
