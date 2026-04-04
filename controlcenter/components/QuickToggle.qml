import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

Item {
    id: root

    property string icon: ""
    property string iconName: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property string variant: active ? "highlighted" : "neutral"
    property color activeColor: Appearance.colors.cPrimary
    property bool showChevron: false
    property color surfaceColor: Appearance.colors.cSurfaceContainerHigh
    property color textColor: Appearance.colors.cOnSurface
    signal clicked()

    readonly property bool highlighted: variant === "highlighted"
    readonly property bool hovered: mouseArea.containsMouse
    readonly property bool pressed: mouseArea.pressed
    readonly property color accentBase: Design.Tokens.color.primaryContainer
    readonly property color accentEdge: activeColor
    readonly property color cardColor: highlighted
        ? accentBase
        : surfaceColor
    readonly property color iconContainerColor: highlighted
        ? Design.ThemePalette.mix(activeColor, Design.Tokens.color.surfaceContainerHighest, 0.34)
        : Design.Tokens.color.surfaceContainerHighest
    readonly property color titleColor: highlighted ? Design.Tokens.color.primaryContainerForeground : textColor
    readonly property color subtitleColor: highlighted ? Design.ThemePalette.withAlpha(Design.Tokens.color.primaryContainerForeground, 0.76) : Design.ThemePalette.withAlpha(textColor, 0.70)

    Layout.fillWidth: true
    Layout.preferredHeight: 82

    implicitWidth: card.implicitWidth
    implicitHeight: Layout.preferredHeight

    scale: pressed ? 0.985 : 1

    Behavior on scale {
        NumberAnimation {
            duration: Appearance.animation.short4
            easing.type: Appearance.animation.standard
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 20
        color: root.cardColor
        border.width: 1
        border.color: highlighted
            ? Design.ThemePalette.withAlpha(accentEdge, hovered ? 0.44 : 0.30)
            : Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, hovered ? 0.82 : 0.62)

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: highlighted
                ? Qt.rgba(1, 1, 1, pressed ? 0.08 : (hovered ? 0.05 : 0))
                : Qt.rgba(1, 1, 1, pressed ? 0.04 : (hovered ? 0.03 : 0))
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 19
                color: root.iconContainerColor
                border.width: highlighted ? 1 : 0
                border.color: highlighted
                    ? Design.ThemePalette.withAlpha(Design.ThemePalette.tone(root.activeColor, true, 0.22), 0.34)
                    : "transparent"

                DS.LucideIcon {
                    anchors.centerIn: parent
                    visible: root.iconName !== ""
                    name: root.iconName
                    color: highlighted ? root.activeColor : Design.ThemePalette.withAlpha(root.titleColor, 0.82)
                    iconSize: 17
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.iconName === "" && root.icon !== ""
                    text: root.icon
                    color: highlighted ? root.activeColor : Design.ThemePalette.withAlpha(root.titleColor, 0.82)
                    font.family: Design.Tokens.font.family.icon
                    font.pixelSize: 17
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.label
                    color: root.titleColor
                    font.family: Appearance.font.family
                    font.pixelSize: 14
                    font.weight: Design.Tokens.font.weight.semibold
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.subLabel !== ""
                    text: root.subLabel
                    color: root.subtitleColor
                    font.family: Appearance.font.family
                    font.pixelSize: 11
                    font.weight: Design.Tokens.font.weight.regular
                    elide: Text.ElideRight
                }
            }

            DS.LucideIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: root.showChevron
                name: "chevron-right"
                iconSize: 16
                color: Design.ThemePalette.withAlpha(root.titleColor, 0.76)
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
