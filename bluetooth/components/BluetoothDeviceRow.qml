import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../shared/designsystem" as Design

Item {
    id: root

    signal clicked()

    property var device
    property var service
    property bool selected: false
    readonly property string statusKind: root.service ? root.service.statusKind(root.device) : "available"
    readonly property color accentColor: root.service ? root.service.statusColor(root.device) : Design.Tokens.color.primary
    readonly property color rowBackgroundColor: root.selected
        ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.18)
        : mouseArea.containsMouse
            ? Design.ThemePalette.withAlpha(Design.Tokens.color.text.primary, 0.06)
            : "transparent"
    readonly property color rowBorderColor: root.selected
        ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.28)
        : "transparent"

    implicitHeight: 72

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    // ── Selected / hover background pill ──
    Rectangle {
        id: bgPill
        anchors.fill: parent
        radius: 22
        color: root.rowBackgroundColor
        border.width: 1
        border.color: root.rowBorderColor

        Behavior on color {
            ColorAnimation {
                duration: Design.Tokens.motion.duration.fast
                easing.type: Design.Tokens.motion.easing.standard
            }
        }
    }

    // ── Row content ──
    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        DeviceGlyph {
            size: 40
            device: root.device
            typeKey: root.service ? root.service.typeKey(root.device) : "generic"
            containerColor: root.selected
                ? Design.ThemePalette.withAlpha(Design.Tokens.color.primary, 0.18)
                : Design.ThemePalette.withAlpha(Design.Tokens.color.secondaryContainer, 0.72)
            contentColor: root.selected
                ? Design.Tokens.color.primary
                : Design.Tokens.color.secondaryContainerForeground
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.service ? root.service.deviceLabel(root.device) : ""
                color: Design.Tokens.color.text.primary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.service ? root.service.sidebarStatusText(root.device) : ""
                color: root.selected ? Design.Tokens.color.primary : Design.Tokens.color.text.secondary
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            Layout.alignment: Qt.AlignVCenter
            visible: root.statusKind === "connected"
                || root.statusKind === "failed"
                || root.statusKind === "retrying"
                || root.statusKind === "connecting"
                || root.statusKind === "pairing"
                || root.statusKind === "waiting"

            Rectangle {
                anchors.centerIn: parent
                width: root.statusKind === "connecting"
                    || root.statusKind === "retrying"
                    || root.statusKind === "pairing"
                    || root.statusKind === "waiting" ? 8 : 10
                height: width
                radius: width / 2
                color: root.accentColor
                opacity: root.selected ? 1 : 0.92
            }
        }
    }
}
