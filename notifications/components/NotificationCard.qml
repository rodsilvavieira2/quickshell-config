import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    required property var notif
    required property bool isPopup

    signal closeClicked()
    signal actionClicked(string actionId)

    width: parent?.width ?? 380
    height: layout.implicitHeight + 24

    color: notif.urgency === "critical" ? "#2d1b25" : (isPopup ? "#1e1e2e" : "#181825")
    radius: 14
    border.color: notif.urgency === "critical" ? "#f38ba8" : "#313244"
    border.width: 1

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // ── Header: icon · app name · time · close ─────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            // App icon in a small rounded container
            Rectangle {
                width: 20
                height: 20
                radius: 5
                color: "#313244"

                Image {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    // Resolve app icon; fall back to bundled SVG when the theme
                    // doesn't include the icon (iconPath returns "").
                    source: {
                        const themed = notif.appIcon ? Quickshell.iconPath(notif.appIcon) : "";
                        return themed !== "" ? themed
                            : Qt.resolvedUrl("../assets/notification-default.svg");
                    }
                    sourceSize: Qt.size(14, 14)
                    fillMode: Image.PreserveAspectFit
                }
            }

            Text {
                Layout.fillWidth: true
                text: notif.appName || "Notification"
                color: "#6c7086"
                font.pixelSize: 11
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

            // Close button — circle fills red on hover (macOS traffic-light feel)
            MouseArea {
                id: closeArea
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.closeClicked()

                Rectangle {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    radius: 7
                    color: closeArea.containsMouse ? "#f38ba8" : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeArea.containsMouse ? "#1e1e2e" : "#585b70"
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }

        // ── Body: thumbnail · summary + body ───────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: notif.summary !== "" || notif.body !== "" || notif.image !== ""

            // Rounded thumbnail
            Rectangle {
                visible: notif.image !== ""
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                Layout.alignment: Qt.AlignTop
                radius: 8
                clip: true
                color: "transparent"

                Image {
                    anchors.fill: parent
                    source: notif.image !== ""
                        ? (notif.image.startsWith("/") ? "file://" + notif.image : notif.image)
                        : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(42, 42)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    text: notif.summary || ""
                    color: "#cdd6f4"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    wrapMode: Text.Wrap
                    visible: text !== ""
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
                    maximumLineCount: isPopup ? 3 : 6
                    elide: Text.ElideRight
                }
            }
        }

        // ── Actions ────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: notif.actions && notif.actions.length > 0

            Repeater {
                model: notif.actions
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 24
                    color: actionArea.containsMouse ? "#45475a" : "#313244"
                    radius: 12

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text
                        color: "#cdd6f4"
                        font.pixelSize: 11
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
