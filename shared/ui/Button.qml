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
    property bool selected: false

    readonly property bool isPrimary: variant === "primary"
    readonly property bool isSecondary: variant === "secondary"
    readonly property bool isTonal: variant === "tonal"
    readonly property bool isDanger: variant === "danger"
    readonly property color containerColor: {
        if (isPrimary) return Tokens.color.primary;
        if (isDanger) return Tokens.color.error;
        if (isTonal) return Tokens.color.secondaryContainer;
        if (isSecondary) return Tokens.color.surfaceContainerHigh;
        return "transparent";
    }
    readonly property color contentColor: {
        if (isPrimary) return Tokens.color.primaryForeground;
        if (isDanger) return Tokens.color.errorForeground;
        if (isTonal) return Tokens.color.text.primary;
        return Tokens.color.text.primary;
    }
    readonly property color borderTone: variant === "ghost" ? Tokens.color.outlineVariant : "transparent"
    readonly property color stateLayerColor: isPrimary || isDanger || isTonal ? contentColor : Tokens.color.text.primary

    implicitWidth: Math.max(112, label.implicitWidth + Tokens.component.button.paddingX * 2)
    implicitHeight: preferredHeight
    radius: Tokens.shape.full
    color: root.disabled ? ThemePalette.withAlpha(containerColor, 0.55) : containerColor
    border.width: variant === "ghost" ? Tokens.border.width.thin : 0
    border.color: borderTone
    opacity: disabled ? Tokens.opacities.disabled : 1

    Text {
        id: label
        anchors.centerIn: parent
        text: root.loading ? "Loading..." : root.text
        color: root.contentColor
        font.family: Tokens.font.family.label
        font.pixelSize: Tokens.font.size.label
        font.weight: Tokens.font.weight.semibold
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: ThemePalette.withAlpha(root.stateLayerColor, mouseArea.pressed
            ? Tokens.stateLayer.pressed
            : mouseArea.containsMouse || root.selected
                ? Tokens.stateLayer.hover
                : 0)
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
