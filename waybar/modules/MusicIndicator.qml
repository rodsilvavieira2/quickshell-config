import QtQuick
import QtQuick.Layouts

import Quickshell

import ".." as Root
import "../components"
import "../shared/ui" as DS
import "../services"

Item {
    id: root

    readonly property var musicData: MusicService.data
    readonly property string timeText: musicData.timeStr || ""

    implicitWidth: contentRow.implicitWidth
    implicitHeight: Math.max(contentRow.implicitHeight, Root.Config.iconSize + 4)

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        MouseArea {
            id: infoArea
            Layout.preferredWidth: infoChip.implicitWidth
            Layout.preferredHeight: infoChip.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "settings", "call", "settings", "toggle"])

            DS.Chip {
                id: infoChip
                anchors.centerIn: parent
                clickable: false
                containerColor: infoArea.containsMouse ? Root.Config.surface0 : "transparent"
                hoverContainerColor: containerColor
                pressedContainerColor: containerColor
                borderColor: "transparent"
                horizontalPadding: 8
                verticalPadding: 5
                text: root.musicData.title || "Nothing playing"
                textMaxWidth: 132
                contentColor: Root.Config.text
                leading: Component {
                    DS.Surface {
                        width: 20
                        height: 20
                        padding: 0
                        radius: 6
                        borderWidth: root.musicData.status === "Playing" ? 1 : 0
                        borderColor: Root.Config.mauve
                        backgroundColor: Root.Config.surface1
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: root.musicData.artUrl || ""
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }
                trailing: Component {
                    RowLayout {
                        spacing: 6

                        Rectangle {
                            visible: root.timeText.length > 0
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: 3
                            implicitHeight: 3
                            radius: 1.5
                            color: Root.Config.overlay0
                        }

                        Text {
                            text: root.timeText
                            color: Root.Config.subtext0
                            font.family: Root.Config.textFontFamily
                            font.pixelSize: 9
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }
                }
            }
        }

        IconButton {
            iconSource: Qt.resolvedUrl("../assets/skip-back.svg")
            iconColor: Root.Config.subtext0
            hoverIconColor: Root.Config.text
            hoverColor: Root.Config.surface0
            onClicked: Quickshell.execDetached(["playerctl", "previous"])
        }

        IconButton {
            iconSource: root.musicData.status === "Playing"
                ? Qt.resolvedUrl("../assets/pause.svg")
                : Qt.resolvedUrl("../assets/play.svg")
            iconColor: root.musicData.status === "Playing" ? Root.Config.green : Root.Config.text
            hoverIconColor: root.musicData.status === "Playing" ? Root.Config.green : Root.Config.text
            hoverColor: Root.Config.surface0
            onClicked: Quickshell.execDetached(["playerctl", "play-pause"])
        }

        IconButton {
            iconSource: Qt.resolvedUrl("../assets/skip-forward.svg")
            iconColor: Root.Config.subtext0
            hoverIconColor: Root.Config.text
            hoverColor: Root.Config.surface0
            onClicked: Quickshell.execDetached(["playerctl", "next"])
        }
    }
}
