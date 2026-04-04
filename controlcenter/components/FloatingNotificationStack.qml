import QtQuick
import QtQuick.Layouts

import "../common"
import "../shared/ui" as DS
import "../shared/designsystem" as Design

Item {
    id: root

    required property var notifs

    readonly property var popupItems: root.notifs && root.notifs.floatingNotifications
        ? root.notifs.floatingNotifications
        : []

    implicitWidth: 312
    implicitHeight: popupColumn.implicitHeight
    width: implicitWidth
    height: implicitHeight
    visible: popupItems.length > 0

    Column {
        id: popupColumn
        anchors.top: parent.top
        anchors.right: parent.right
        width: root.width
        spacing: 8

        Repeater {
            model: root.popupItems

            delegate: DS.Surface {
                id: popupCard

                required property var modelData

                readonly property bool highPriority: modelData.urgency >= 2
                readonly property color accentColor: highPriority
                    ? Design.Tokens.color.error
                    : Design.Tokens.color.primary
                readonly property color accentContainer: highPriority
                    ? Design.Tokens.color.errorContainer
                    : Design.Tokens.color.primaryContainer
                readonly property string appIconSource: {
                    if (!modelData.appIcon) {
                        return "";
                    }

                    return modelData.appIcon.startsWith("/")
                        ? modelData.appIcon
                        : "image://icon/" + modelData.appIcon;
                }
                readonly property bool clickable: modelData.actions && modelData.actions.length > 0

                property bool ready: false

                width: popupColumn.width
                padding: 12
                radius: 18
                shadowLevel: Design.Tokens.shadow.md
                clipContent: true
                backgroundColor: Design.Tokens.color.surfaceContainer
                borderWidth: Design.Tokens.border.width.thin
                borderColor: Design.ThemePalette.withAlpha(accentColor, popupMouse.containsMouse ? 0.28 : 0.18)
                opacity: ready ? 1 : 0
                scale: ready ? 1 : 0.98

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.medium1
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.animation.medium1
                        easing.type: Easing.OutCubic
                    }
                }

                Timer {
                    id: popupReady
                    interval: 1
                    running: true
                    repeat: false
                    onTriggered: popupCard.ready = true
                }

                MouseArea {
                    id: popupMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: popupCard.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onContainsMouseChanged: {
                        if (containsMouse) {
                            popupCard.modelData.pausePopup();
                        } else {
                            popupCard.modelData.resumePopup();
                        }
                    }

                    onClicked: {
                        if (popupCard.clickable) {
                            popupCard.modelData.invokeAction(popupCard.modelData.actions[0].identifier);
                            root.notifs.deleteNotification(popupCard.modelData);
                        }
                    }
                }

                ColumnLayout {
                    width: popupCard.contentItem.width
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: Design.ThemePalette.withAlpha(popupCard.accentContainer, 0.90)

                            Image {
                                id: appIcon
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: popupCard.appIconSource
                                visible: status === Image.Ready
                            }

                            DS.LucideIcon {
                                anchors.centerIn: parent
                                visible: !appIcon.visible
                                name: "bell"
                                iconSize: 15
                                color: popupCard.accentColor
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: popupCard.modelData.appName || "Notification"
                                font.family: Appearance.font.family
                                font.pixelSize: 11
                                font.weight: Design.Tokens.font.weight.medium
                                color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.72)
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: popupCard.modelData.timeString
                                font.family: Appearance.font.family
                                font.pixelSize: 10
                                color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.50)
                                elide: Text.ElideRight
                            }
                        }

                        DS.IconButton {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            iconName: "x"
                            iconPixelSize: 12
                            onClicked: root.notifs.deleteNotification(popupCard.modelData)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: popupCard.modelData.summary || "Notification"
                        font.family: Appearance.font.family
                        font.pixelSize: 13
                        font.weight: Design.Tokens.font.weight.semibold
                        color: Appearance.colors.cOnSurface
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: popupCard.modelData.body || ""
                        visible: text.length > 0
                        font.family: Appearance.font.family
                        font.pixelSize: 11
                        color: Design.ThemePalette.withAlpha(Appearance.colors.cOnSurface, 0.68)
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: popupCard.modelData.actions && popupCard.modelData.actions.length > 0
                        spacing: 6

                        Repeater {
                            model: popupCard.modelData.actions
                                ? popupCard.modelData.actions.slice(0, 2)
                                : []

                            delegate: DS.Button {
                                required property var modelData

                                Layout.fillWidth: true
                                preferredHeight: 28
                                text: modelData.text
                                variant: index === 0 ? "tonal" : "secondary"

                                onClicked: {
                                    popupCard.modelData.invokeAction(modelData.identifier);
                                    root.notifs.deleteNotification(popupCard.modelData);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
