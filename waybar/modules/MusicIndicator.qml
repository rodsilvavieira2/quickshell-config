import QtQuick
import QtQuick.Layouts

import Quickshell

import ".." as Root
import "../components"
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
            Layout.preferredWidth: infoRow.implicitWidth
            Layout.preferredHeight: infoRow.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["quickshell", "ipc", "-c", "music", "call", "music", "toggle"])

            RowLayout {
                id: infoRow
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 6
                    color: Root.Config.surface1
                    clip: true
                    border.width: root.musicData.status === "Playing" ? 1 : 0
                    border.color: Root.Config.mauve

                    Image {
                        anchors.fill: parent
                        source: root.musicData.artUrl || ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                RowLayout {
                    spacing: 6
                    Layout.preferredWidth: 188

                    Text {
                        text: root.musicData.title || ""
                        color: Root.Config.text
                        font.family: Root.Config.textFontFamily
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.preferredWidth: 132
                    }

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
