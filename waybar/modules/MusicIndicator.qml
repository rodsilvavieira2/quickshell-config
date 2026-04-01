import QtQuick
import QtQuick.Layouts

import Quickshell

import ".." as Root
import "../services"

Item {
    id: root

    readonly property var musicData: MusicService.data

    implicitWidth: contentRow.implicitWidth
    implicitHeight: Math.max(contentRow.implicitHeight, Root.Config.iconSize + 4)

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 10

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
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
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

                ColumnLayout {
                    spacing: -2
                    Layout.preferredWidth: 180

                    Text {
                        text: root.musicData.title || ""
                        color: Root.Config.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.musicData.timeStr || ""
                        color: Root.Config.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Item {
            Layout.preferredWidth: prevIcon.implicitWidth + 2
            Layout.preferredHeight: prevIcon.implicitHeight + 2

            Text {
                id: prevIcon
                anchors.centerIn: parent
                text: "󰒮"
                color: prevMouse.containsMouse ? Root.Config.text : Root.Config.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Root.Config.iconSize + 2
            }

            MouseArea {
                id: prevMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["playerctl", "previous"])
            }
        }

        Item {
            Layout.preferredWidth: playIcon.implicitWidth + 2
            Layout.preferredHeight: playIcon.implicitHeight + 2

            Text {
                id: playIcon
                anchors.centerIn: parent
                text: root.musicData.status === "Playing" ? "󰏤" : "󰐊"
                color: playMouse.containsMouse ? Root.Config.green : Root.Config.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Root.Config.iconSize + 5
            }

            MouseArea {
                id: playMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["playerctl", "play-pause"])
            }
        }

        Item {
            Layout.preferredWidth: nextIcon.implicitWidth + 2
            Layout.preferredHeight: nextIcon.implicitHeight + 2

            Text {
                id: nextIcon
                anchors.centerIn: parent
                text: "󰒭"
                color: nextMouse.containsMouse ? Root.Config.text : Root.Config.overlay0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Root.Config.iconSize + 2
            }

            MouseArea {
                id: nextMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["playerctl", "next"])
            }
        }
    }
}
