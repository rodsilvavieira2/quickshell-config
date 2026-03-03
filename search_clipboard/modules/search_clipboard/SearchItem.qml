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

    height: 48
    radius: 8
    color: active ? Appearance.colors.colAccentSubtle : "transparent"

    Behavior on color { ColorAnimation { duration: 120 } }

    // 3-px left accent strip — only on the active item
    Rectangle {
        width: 3
        height: 24
        radius: 1.5
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: Appearance.colors.colAccent
        visible: root.active

        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 12

        // App icon box
        Rectangle {
            width: 34
            height: 34
            radius: 8
            color: Appearance.colors.colLayer2
            Layout.alignment: Qt.AlignVCenter

            StyledText {
                anchors.centerIn: parent
                text: root.entry.iconType === "text" ? (root.entry.iconName ?? "") : ""
                font.pixelSize: 16
                visible: root.entry.iconType === "text"
            }

            Image {
                anchors.centerIn: parent
                width: 22
                height: 22
                visible: root.entry.iconType === "system" || root.entry.iconType === "material"
                source: visible ? Quickshell.iconPath(root.entry.iconName ?? "", "application-x-executable") : ""
                sourceSize: Qt.size(22, 22)
            }
        }

        // Name + comment
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            spacing: 1

            StyledText {
                text: root.entry.name ?? ""
                font.pixelSize: Appearance.font.pixelSize.normal
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }

            StyledText {
                text: root.entry.comment ?? ""
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
                elide: Text.ElideRight
                visible: text.length > 0
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }
        }

        // ↵ hint — only visible on active item
        StyledText {
            text: "↵"
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colAccent
            visible: root.active
            opacity: 0.75
            Layout.alignment: Qt.AlignVCenter
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
