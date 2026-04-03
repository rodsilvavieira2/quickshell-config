import QtQuick
import QtQuick.Layouts
import Quickshell
import "../shared/designsystem" as Design

Rectangle {
    id: root

    required property var notif
    required property bool isPopup

    signal closeClicked()
    signal actionClicked(string actionId)

    width: parent?.width ?? 380
    height: layout.implicitHeight + 24

    color: notif.urgency === "critical"
        ? Design.ThemePalette.withAlpha(Design.Tokens.color.error, Design.ThemeSettings.isDark ? 0.18 : 0.12)
        : (isPopup ? Design.Tokens.color.bg.surface : Design.Tokens.color.bg.elevated)
    radius: Design.Tokens.radius.lg
    border.color: notif.urgency === "critical" ? Design.Tokens.color.error : Design.Tokens.color.border.subtle
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
                color: Design.Tokens.color.bg.interactive

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
                color: Design.Tokens.color.text.muted
                font.pixelSize: Design.Tokens.font.size.small
                font.weight: Design.Tokens.font.weight.semibold
                font.family: Design.Tokens.font.family.label
                elide: Text.ElideRight
            }

            Text {
                text: notif.time || ""
                color: Design.Tokens.color.text.muted
                font.pixelSize: Design.Tokens.font.size.small
                font.family: Design.Tokens.font.family.caption
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
                    color: closeArea.containsMouse ? Design.Tokens.color.error : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: closeArea.containsMouse ? Design.Tokens.color.text.inverse : Design.Tokens.color.text.muted
                        font.pixelSize: 13
                        font.bold: true
                        font.family: Design.Tokens.font.family.label

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
                    color: Design.Tokens.color.text.primary
                    font.pixelSize: Design.Tokens.font.size.body
                    font.weight: Design.Tokens.font.weight.semibold
                    font.family: Design.Tokens.font.family.body
                    wrapMode: Text.Wrap
                    visible: text !== ""
                }

                Text {
                    Layout.fillWidth: true
                    text: notif.body || ""
                    color: Design.Tokens.color.text.secondary
                    font.pixelSize: Design.Tokens.font.size.caption
                    font.family: Design.Tokens.font.family.body
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
                    color: actionArea.containsMouse ? Design.Tokens.color.bg.hover : Design.Tokens.color.bg.interactive
                    radius: 12

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text
                        color: Design.Tokens.color.text.primary
                        font.pixelSize: Design.Tokens.font.size.small
                        font.family: Design.Tokens.font.family.label
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
