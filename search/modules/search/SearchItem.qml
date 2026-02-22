import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../common/widgets"
import "../../services"

Rectangle {
    id: root
    required property var entry
    required property bool active

    height: 56
    radius: 8
    color: active ? Appearance.colors.colLayer1Hover : "transparent"
    border.width: active ? 1 : 0
    border.color: Appearance.colors.colLayer2Hover
    width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
    x: ListView.view.leftMargin

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 14

        Rectangle {
            width: 32
            height: 32
            radius: 6
            color: Appearance.colors.colLayer2

            StyledText {
                anchors.centerIn: parent
                text: root.entry.iconType === "text" ? (root.entry.iconName ?? "") : ""
                font.pixelSize: 16
            }

            Image {
                anchors.centerIn: parent
                width: 22
                height: 22
                visible: root.entry.iconType === "system"
                source: Quickshell.iconPath(root.entry.iconName || "", "application-x-executable")
                sourceSize: Qt.size(22, 22)
            }

            Image {
                anchors.centerIn: parent
                width: 22
                height: 22
                visible: root.entry.iconType === "material"
                source: Quickshell.iconPath(root.entry.iconName || "", "application-x-executable")
                sourceSize: Qt.size(22, 22)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            spacing: 2
            StyledText {
                text: root.entry.name || ""
                font.pixelSize: Appearance.font.pixelSize.normal
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }
            StyledText {
                text: root.entry.comment || ""
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
                elide: Text.ElideRight
                visible: text.length > 0
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.ListView.view.currentIndex = index
        onClicked: {
            if (root.entry && root.entry.execute) {
                root.entry.execute()
                GlobalStates.searchOpen = false
            }
        }
    }
}
