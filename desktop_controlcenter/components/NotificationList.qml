import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

DS.Card {
    id: root

    required property var notifs
    readonly property var notificationItems: root.notifs && root.notifs.recentNotifications ? root.notifs.recentNotifications : []

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: Design.Tokens.shape.extraLarge
    padding: 18
    clipContent: true
    backgroundColor: Design.Tokens.color.surfaceContainerLow
    borderColor: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.9)
    borderWidth: Design.Tokens.border.width.thin
    shadowLevel: Design.Tokens.shadow.none

    ColumnLayout {
        anchors.fill: parent
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

            DS.Chip {
                id: dndBadge
                visible: root.notifs.dnd
                text: "Do Not Disturb"
                clickable: false
                horizontalPadding: 10
                verticalPadding: 4
                containerColor: Design.ThemePalette.withAlpha(Appearance.colors.warning, 0.18)
                hoverContainerColor: containerColor
                pressedContainerColor: containerColor
                borderColor: Design.ThemePalette.withAlpha(Appearance.colors.warning, 0.32)
                contentColor: Appearance.colors.warning
                contentFontSize: 10
            }

            DS.Button {
                id: clearAllButton
                visible: root.notificationItems.length > 0
                text: "Clear"
                variant: "secondary"
                preferredHeight: 28
                onClicked: root.notifs.clearAll()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: notifList
                anchors.fill: parent
                clip: true
                spacing: 10
                model: root.notificationItems
                visible: count > 0

                delegate: DS.Surface {
                    id: notifCard

                    required property var modelData
                    required property int index

                    width: notifList.width
                    implicitHeight: notifContent.implicitHeight + 24
                    padding: 12
                    radius: Design.Tokens.shape.large
                    backgroundColor: notifMouse.containsMouse
                        ? Design.Tokens.color.surfaceContainerHigh
                        : Design.ThemePalette.withAlpha(Design.Tokens.color.surfaceContainerHigh, 0.88)
                    borderColor: modelData.urgency >= 2
                        ? Design.ThemePalette.withAlpha(Design.Tokens.color.error, 0.42)
                        : Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.72)
                    borderWidth: Design.Tokens.border.width.thin

                    MouseArea {
                        id: notifMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.actions && modelData.actions.length > 0) {
                                modelData.invokeAction(modelData.actions[0].identifier);
                                root.notifs.deleteNotification(modelData);
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: notifCard.radius
                        color: Design.ThemePalette.withAlpha(modelData.urgency >= 2 ? Design.Tokens.color.error : Design.Tokens.color.text.primary,
                            notifMouse.pressed
                                ? Design.Tokens.stateLayer.pressed
                                : notifMouse.containsMouse
                                    ? Design.Tokens.stateLayer.hover
                                    : 0)
                    }

                    ColumnLayout {
                        id: notifContent
                        anchors.fill: parent
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            DS.Surface {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                padding: 0
                                radius: Design.Tokens.shape.medium
                                backgroundColor: Design.ThemePalette.withAlpha(Appearance.colors.cPrimary, 0.16)
                                borderWidth: 0

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

                                DS.LucideIcon {
                                    anchors.centerIn: parent
                                    visible: !appIcon.visible
                                    name: "bell"
                                    iconSize: 16
                                    color: Appearance.colors.cPrimary
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

                            DS.IconButton {
                                id: closeButton
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                iconName: "x"
                                iconPixelSize: 14
                                onClicked: root.notifs.deleteNotification(notifCard.modelData)
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
                            visible: notifCard.modelData.actions && notifCard.modelData.actions.length > 0
                            spacing: 8

                            Repeater {
                                model: notifCard.modelData.actions ? notifCard.modelData.actions : []

                                delegate: DS.Button {
                                    required property var modelData

                                    Layout.fillWidth: true
                                    text: modelData.text
                                    variant: "tonal"
                                    preferredHeight: 30
                                    onClicked: {
                                        notifCard.modelData.invokeAction(modelData.identifier);
                                        root.notifs.deleteNotification(notifCard.modelData);
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

            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - 36, 220)
                spacing: 8
                visible: notifList.count === 0

                DS.LucideIcon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    name: root.notifs.dnd ? "bell-off" : "bell"
                    color: Appearance.colors.cOnSurfaceDim
                    iconSize: 34
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    text: root.notifs.dnd ? "Notifications are silenced" : "No recent notifications"
                    font.family: Appearance.font.family
                    font.pixelSize: 12
                    color: Appearance.colors.cOnSurfaceVariant
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
