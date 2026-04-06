import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../shared/designsystem" as Design

Rectangle {
    id: root

    signal clicked()

    property var device
    property var service
    property bool selected: false

    readonly property string statusKind: root.service ? root.service.statusKind(root.device) : "available"
    readonly property color accentColor: root.service ? root.service.statusColor(root.device) : Design.Tokens.color.primary

    implicitHeight: 88
    radius: 26
    color: root.selected
        ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.16)
        : Design.Tokens.color.surfaceContainerLow
    border.width: Design.Tokens.border.width.thin
    border.color: root.selected
        ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.30)
        : Design.Tokens.color.outlineVariant

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, mouseArea.containsMouse ? Design.Tokens.stateLayer.hover : 0)
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Design.Tokens.space.s16
        anchors.rightMargin: Design.Tokens.space.s16
        anchors.topMargin: Design.Tokens.space.s12
        anchors.bottomMargin: Design.Tokens.space.s12
        spacing: Design.Tokens.space.s16

        DeviceGlyph {
            Layout.alignment: Qt.AlignVCenter
            size: 52
            device: root.device
            typeKey: root.service ? root.service.typeKey(root.device) : "generic"
            containerColor: root.selected
                ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.18)
                : Design.Tokens.color.secondaryContainer
            contentColor: root.selected
                ? Design.Tokens.color.primary
                : Design.Tokens.color.secondaryContainerForeground
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Design.Tokens.space.s4

            Text {
                Layout.fillWidth: true
                text: root.service ? root.service.deviceLabel(root.device) : ""
                color: Design.Tokens.color.text.primary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Design.Tokens.font.size.body + 1
                font.weight: Design.Tokens.font.weight.semibold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.service ? root.service.listStatusText(root.device) : ""
                color: root.selected ? Design.Tokens.color.primary : Design.Tokens.color.text.secondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Design.Tokens.font.size.caption
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                width: 20
                height: 20
                running: visible
                visible: root.statusKind === "connecting"
                    || root.statusKind === "retrying"
                    || root.statusKind === "waiting"
                    || root.statusKind === "pairing"
            }

            Rectangle {
                anchors.centerIn: parent
                visible: !busyIndicator.visible
                width: root.statusKind === "failed" || root.statusKind === "unavailable" ? 12 : 10
                height: width
                radius: width / 2
                color: root.accentColor
                opacity: root.statusKind === "paired" || root.statusKind === "available" ? 0.64 : 1
                border.width: root.statusKind === "available" ? Design.Tokens.border.width.thin : 0
                border.color: Design.ThemePalette.withAlpha(root.accentColor, 0.45)
            }
        }
    }
}
