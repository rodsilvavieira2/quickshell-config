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
    readonly property color accentColor: root.service ? root.service.statusColor(root.device) : "#7f5ed8"

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
        color: root.selected
            ? "#5e43a7"
            : mouseArea.containsMouse
                ? "#2d2935"
                : "transparent"
        border.width: 1
        border.color: root.selected ? "#7057ba" : "transparent"

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
                ? Design.ThemePalette.withAlpha("#ffffff", 0.12)
                : "#3a3541"
            contentColor: root.selected
                ? "#efe8ff"
                : "#c7c0d7"
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.service ? root.service.deviceLabel(root.device) : ""
                color: root.selected ? "#f4efff" : "#d9d1e5"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.service ? root.service.sidebarStatusText(root.device) : ""
                color: root.selected ? "#d7caf6" : "#9f98ae"
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
