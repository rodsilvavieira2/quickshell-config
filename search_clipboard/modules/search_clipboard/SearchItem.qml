import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../common/widgets"
import "../../services"
import "../../shared/ui" as DS

DS.SearchResultItem {
    id: root
    required property var entry
    required property bool active

    title: root.entry.name ?? ""
    subtitle: root.entry.comment ?? ""
    selected: root.active
    leading: Component {
        Rectangle {
            width: 36
            height: 36
            radius: 10
            color: Appearance.colors.colLayer2

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

            Image {
                anchors.centerIn: parent
                width: root.entry.isImage ? parent.width - 4 : 20
                height: root.entry.isImage ? parent.height - 4 : 20
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: root.entry.iconType === "image"
                source: visible ? (root.entry.iconName ? (root.entry.iconName.startsWith("/") ? "file://" + root.entry.iconName : (root.entry.iconName.startsWith("file://") ? root.entry.iconName : Qt.resolvedUrl(root.entry.iconName))) : "") : ""

                onStatusChanged: {
                    if (status === Image.Error && root.entry.isImage)
                        source = "../../assets/clipboard.svg"
                }
            }
        }
    }
    trailing: Component {
        Text {
            text: "↵"
            visible: root.active
            opacity: 0.75
            color: Appearance.colors.colAccent
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.DemiBold
        }
    }
    onClicked: {
        if (root.entry && root.entry.execute) {
            root.entry.execute()
            GlobalStates.searchOpen = false
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: root.ListView.view.currentIndex = index
    }
}
