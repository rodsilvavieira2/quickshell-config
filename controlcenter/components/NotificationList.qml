import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

Item {
    id: root

    required property var notifs
    readonly property var notificationItems: root.notifs && root.notifs.recentNotifications ? root.notifs.recentNotifications : []

    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitHeight: 252

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Design.Tokens.color.surfaceContainerHigh
        border.width: 1
        border.color: Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.68)
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: Design.Tokens.color.surfaceContainerHighest

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "Notification Center"
                        font.family: Appearance.font.family
                        font.pixelSize: 15
                        font.weight: Design.Tokens.font.weight.semibold
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
                        verticalPadding: 3
                        containerColor: Design.Tokens.color.warningContainer
                        hoverContainerColor: containerColor
                        pressedContainerColor: containerColor
                        borderColor: Design.ThemePalette.withAlpha(Appearance.colors.warning, 0.32)
                        contentColor: Design.Tokens.color.text.primary
                        contentFontSize: 10
                    }

                    DS.Button {
                        id: clearAllButton
                        visible: root.notificationItems.length > 0
                        text: "Clear"
                        variant: "secondary"
                        preferredHeight: 30
                        onClicked: root.notifs.clearAll()
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: notifList
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    spacing: 8
                    model: root.notificationItems
                    visible: count > 0

                    delegate: DS.Surface {
                        id: notifCard

                        required property var modelData
                        required property int index

                        width: notifList.width
                        implicitHeight: notifContent.implicitHeight + 20
                        padding: 12
                        radius: 16
                        backgroundColor: notifMouse.containsMouse
                            ? Design.Tokens.color.surfaceContainerHighest
                            : Design.Tokens.color.surfaceContainer
                        borderColor: modelData.urgency >= 2
                            ? Design.ThemePalette.withAlpha(Design.Tokens.color.error, 0.36)
                            : Design.ThemePalette.withAlpha(Design.Tokens.color.outlineVariant, 0.62)
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
                            color: Qt.rgba(
                                1,
                                1,
                                1,
                                notifMouse.pressed ? 0.04 : (notifMouse.containsMouse ? 0.02 : 0)
                            )
                        }

                        ColumnLayout {
                            id: notifContent
                            anchors.fill: parent
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    radius: 16
                                    color: Design.Tokens.color.surfaceContainerHighest

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
                                        iconSize: 15
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
                                        font.pixelSize: 10
                                        font.weight: Design.Tokens.font.weight.medium
                                        color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.76)
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: notifCard.modelData.timeString
                                        font.family: Appearance.font.family
                                        font.pixelSize: 10
                                        color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.54)
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
                                font.weight: Design.Tokens.font.weight.semibold
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
                                color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.70)
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
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        name: root.notifs.dnd ? "bell-off" : "bell"
                        color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.78)
                        iconSize: 24
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: root.notifs.dnd ? "Notifications are silenced" : "No recent notifications"
                        font.family: Appearance.font.family
                        font.pixelSize: 14
                        color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.78)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
