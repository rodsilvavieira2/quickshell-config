import QtQuick
import QtQuick.Layouts
import "../designsystem"

Rectangle {
    id: root

    signal clicked()
    readonly property Item contentItem: rowLayout

    property string text: ""
    property bool selected: false
    property bool clickable: false
    property bool chipEnabled: true
    property color containerColor: "transparent"
    property color hoverContainerColor: Tokens.color.surfaceContainerHigh
    property color pressedContainerColor: Tokens.color.surfaceContainerHighest
    property color selectedContainerColor: ThemePalette.withAlpha(Tokens.color.primary, 0.18)
    property color contentColor: Tokens.color.text.secondary
    property color selectedContentColor: Tokens.color.primary
    property color borderColor: Tokens.color.outlineVariant
    property color selectedBorderColor: ThemePalette.withAlpha(Tokens.color.primary, 0.34)
    property int horizontalPadding: Tokens.space.s12
    property int verticalPadding: Tokens.space.s8
    property int spacing: Tokens.space.s8
    property int contentFontSize: Tokens.font.size.label
    property int contentFontWeight: Tokens.font.weight.semibold
    property int textMaxWidth: -1
    property int chipRadius: Tokens.shape.full
    property Component leading
    property Component trailing

    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed
    readonly property color resolvedContainerColor: {
        if (selected)
            return selectedContainerColor;
        if (pressed)
            return pressedContainerColor;
        if (hovered)
            return hoverContainerColor;
        return containerColor;
    }
    readonly property color resolvedContentColor: selected ? selectedContentColor : contentColor

    implicitWidth: rowLayout.implicitWidth + horizontalPadding * 2
    implicitHeight: Math.max(32, rowLayout.implicitHeight + verticalPadding * 2)
    radius: chipRadius
    color: resolvedContainerColor
    border.width: Tokens.border.width.thin
    border.color: selected ? selectedBorderColor : borderColor
    opacity: chipEnabled ? 1 : Tokens.opacities.disabled

    Behavior on color {
        ColorAnimation {
            duration: Tokens.motion.duration.fast
            easing.type: Tokens.motion.easing.standard
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: ThemePalette.withAlpha(root.resolvedContentColor, pressed
            ? Tokens.stateLayer.pressed
            : hovered
                ? Tokens.stateLayer.hover
                : 0)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.clickable && root.chipEnabled
        hoverEnabled: root.clickable && root.chipEnabled
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: root.spacing

        Loader {
            active: root.leading !== undefined && root.leading !== null
            sourceComponent: root.leading
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: root.text.length > 0
            Layout.preferredWidth: root.textMaxWidth > 0 ? Math.min(implicitWidth, root.textMaxWidth) : implicitWidth
            text: root.text
            color: root.resolvedContentColor
            font.family: Tokens.font.family.label
            font.pixelSize: root.contentFontSize
            font.weight: root.contentFontWeight
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: root.textMaxWidth > 0 ? root.textMaxWidth : -1
            elide: Text.ElideRight
        }

        Loader {
            active: root.trailing !== undefined && root.trailing !== null
            sourceComponent: root.trailing
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
