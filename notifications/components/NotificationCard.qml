import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    required property var notif
    required property bool isPopup

    signal closeClicked()
    signal actionClicked(string actionId)

    width: parent?.width ?? 360
    height: layout.implicitHeight + 20

    color: notif.urgency === "critical" ? "#2d1b25" : (isPopup ? "#1e1e2e" : "#181825")
    radius: 10
    border.color: notif.urgency === "critical" ? "#f38ba8" : "#313244"
    border.width: 1

    // Left accent strip — normal popups only (mirrors search active-item strip)
    Rectangle {
        visible: isPopup && notif.urgency !== "critical"
        width: 3
        height: parent.height - 16
        radius: 1.5
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        color: "#89b4fa"
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 10
        anchors.leftMargin: (isPopup && notif.urgency !== "critical") ? 14 : 10
        spacing: 6

        // Header row: icon · app name · time · ×
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Image {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                source: Quickshell.iconPath(notif.appIcon || "dialog-information")
                sourceSize: Qt.size(18, 18)
            }

            Text {
                Layout.fillWidth: true
                text: notif.appName || "Notification"
                color: "#6c7086"
                font.pixelSize: 12
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                elide: Text.ElideRight
            }

            Text {
                text: notif.time || ""
                color: "#6c7086"
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                id: closeArea
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.closeClicked()

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: closeArea.containsMouse ? "#f38ba8" : "#6c7086"
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"

                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }
        }

        // Body row: thumbnail · summary + body
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Rounded thumbnail
            Rectangle {
                visible: notif.image !== ""
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                Layout.alignment: Qt.AlignTop
                radius: 6
                clip: true
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: notif.image !== ""
                        ? (notif.image.startsWith("/") ? "file://" + notif.image : notif.image)
                        : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(44, 44)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: notif.summary || ""
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: notif.body || ""
                    color: "#a6adc8"
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                    visible: text !== ""
                    maximumLineCount: isPopup ? 2 : 5
                    elide: Text.ElideRight
                }
            }
        }

        // Actions row
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: notif.actions && notif.actions.length > 0

            Repeater {
                model: notif.actions
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 26
                    color: actionArea.containsMouse ? "#45475a" : "#313244"
                    radius: 6

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text
                        color: "#cdd6f4"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    MouseArea {
                        id: actionArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: root.actionClicked(modelData.identifier)
                    }
                }
            }
        }
    }
}
