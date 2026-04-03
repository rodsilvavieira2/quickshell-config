import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"

Rectangle {
    id: root

    required property var notifs

    Layout.fillWidth: true
    Layout.fillHeight: true

    radius: 28
    color: Qt.darker(Appearance.colors.cSurfaceContainer, 1.08)
    border.color: Qt.rgba(1, 1, 1, 0.10)
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Notification Center"
                font.family: Appearance.font.family
                font.pixelSize: 15
                font.bold: true
                color: Appearance.colors.cOnSurface
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                id: dndBadge
                visible: root.notifs.dnd
                radius: 12
                color: Qt.rgba(Appearance.colors.warning.r, Appearance.colors.warning.g, Appearance.colors.warning.b, 0.18)
                border.color: Qt.rgba(Appearance.colors.warning.r, Appearance.colors.warning.g, Appearance.colors.warning.b, 0.32)
                border.width: 1
                implicitWidth: dndText.implicitWidth + 14
                implicitHeight: 22

                Text {
                    id: dndText
                    anchors.centerIn: parent
                    text: "Do Not Disturb"
                    font.family: Appearance.font.family
                    font.pixelSize: 10
                    font.bold: true
                    color: Appearance.colors.warning
                }
            }

            Rectangle {
                id: clearAllButton
                visible: (root.notifs.recentNotifications?.length ?? 0) > 0
                radius: 12
                color: clearAllMouse.containsMouse
                    ? Qt.rgba(1, 1, 1, 0.12)
                    : Qt.rgba(1, 1, 1, 0.06)
                implicitWidth: clearAllText.implicitWidth + 14
                implicitHeight: 22

                Text {
                    id: clearAllText
                    anchors.centerIn: parent
                    text: "Clear"
                    font.family: Appearance.font.family
                    font.pixelSize: 10
                    font.bold: true
                    color: Appearance.colors.cOnSurfaceVariant
                }

                MouseArea {
                    id: clearAllMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.notifs.clearAll()
                }
            }
        }

        ListView {
            id: notifList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: root.notifs.recentNotifications ?? []

            delegate: Rectangle {
                id: notifCard

                required property var modelData
                required property int index

                width: notifList.width
                height: notifContent.implicitHeight + 22
                radius: 18
                color: notifMouse.containsMouse
                    ? Qt.rgba(Appearance.surface0.r, Appearance.surface0.g, Appearance.surface0.b, 0.92)
                    : Qt.rgba(Appearance.surface0.r, Appearance.surface0.g, Appearance.surface0.b, 0.72)
                border.color: modelData.urgency >= 2
                    ? Qt.rgba(Appearance.colors.error.r, Appearance.colors.error.g, Appearance.colors.error.b, 0.45)
                    : Qt.rgba(1, 1, 1, 0.05)
                border.width: 1

                Behavior on color {
                    ColorAnimation {
                        duration: Appearance.animation.short3
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.actions?.length > 0) {
                            modelData.invokeAction(modelData.actions[0].identifier);
                            root.notifs.deleteNotification(modelData);
                        }
                    }
                }

                ColumnLayout {
                    id: notifContent
                    anchors.fill: parent
                    anchors.margins: 11
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 10
                            color: Qt.rgba(Appearance.colors.cPrimary.r, Appearance.colors.cPrimary.g, Appearance.colors.cPrimary.b, 0.16)

                            Image {
                                id: appIcon
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: {
                                    if (!notifCard.modelData.appIcon) {
                                        return "";
                                    }
                                    return notifCard.modelData.appIcon.startsWith("/")
                                        ? notifCard.modelData.appIcon
                                        : "image://icon/" + notifCard.modelData.appIcon;
                                }
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰂚"
                                font.family: Appearance.font.family
                                font.pixelSize: 16
                                color: Appearance.colors.cPrimary
                                visible: !appIcon.visible
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: notifCard.modelData.appName || "Notification"
                                font.family: Appearance.font.family
                                font.pixelSize: 11
                                font.bold: true
                                color: Appearance.colors.cOnSurfaceVariant
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: notifCard.modelData.timeString
                                font.family: Appearance.font.family
                                font.pixelSize: 10
                                color: Appearance.colors.cOnSurfaceDim
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            id: closeButton
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 12
                            color: closeMouse.containsMouse
                                ? Qt.rgba(1, 1, 1, 0.12)
                                : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                font.family: Appearance.font.family
                                font.pixelSize: 14
                                color: Appearance.colors.cOnSurfaceVariant
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: root.notifs.deleteNotification(notifCard.modelData)
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: notifCard.modelData.summary || "Notification"
                        font.family: Appearance.font.family
                        font.pixelSize: 13
                        font.bold: true
                        color: Appearance.colors.cOnSurface
                        elide: Text.ElideRight
                        maximumLineCount: 2
                    }

                    Text {
                        Layout.fillWidth: true
                        text: notifCard.modelData.body || ""
                        visible: text.length > 0
                        font.family: Appearance.font.family
                        font.pixelSize: 11
                        color: Appearance.colors.cOnSurfaceVariant
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: notifCard.modelData.actions?.length > 0
                        spacing: 8

                        Repeater {
                            model: notifCard.modelData.actions ?? []

                            delegate: Rectangle {
                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: 28
                                radius: 14
                                color: actionMouse.containsMouse
                                    ? Qt.rgba(Appearance.colors.cPrimary.r, Appearance.colors.cPrimary.g, Appearance.colors.cPrimary.b, 0.26)
                                    : Qt.rgba(Appearance.colors.cPrimary.r, Appearance.colors.cPrimary.g, Appearance.colors.cPrimary.b, 0.16)

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.text
                                    font.family: Appearance.font.family
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Appearance.colors.cOnSurface
                                }

                                MouseArea {
                                    id: actionMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        notifCard.modelData.invokeAction(modelData.identifier);
                                        root.notifs.deleteNotification(notifCard.modelData);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            add: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Appearance.animation.medium2
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "scale"
                        from: 0.96
                        to: 1
                        duration: Appearance.animation.medium2
                        easing.type: Easing.OutCubic
                    }
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: Appearance.animation.short4
                    easing.type: Easing.OutCubic
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: notifList.count === 0

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.notifs.dnd ? "󰂛" : "󰂚"
                    font.family: Appearance.font.family
                    font.pixelSize: 34
                    color: Appearance.colors.cOnSurfaceDim
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.notifs.dnd ? "Notifications are silenced" : "No recent notifications"
                    font.family: Appearance.font.family
                    font.pixelSize: 12
                    color: Appearance.colors.cOnSurfaceVariant
                }
            }
        }
    }
}
