//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray

import "." as Root
import "./services"
import "modules" as Modules

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Root.Config.barHeight + Root.Config.barBottomGap
    color: "transparent"

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Root.Config.barTopMargin
        height: Root.Config.barHeight
        radius: Root.Config.barRadius
        color: Root.Config.barColor
        border.width: 1
        border.color: Root.Config.barBorderColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Root.Config.barPaddingHorizontal
            anchors.rightMargin: Root.Config.barPaddingHorizontal
            anchors.topMargin: Root.Config.barPaddingTop
            anchors.bottomMargin: Root.Config.barPaddingBottom
            spacing: Root.Config.sectionSpacing

            Modules.Workspaces {
                id: workspacesContent
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Modules.Clock {
                id: clockContent
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: Root.Config.sectionSpacing

                Item {
                    Layout.preferredWidth: MusicService.isActive ? musicContent.implicitWidth : 0
                    Layout.preferredHeight: MusicService.isActive ? musicContent.implicitHeight : 0
                    visible: width > 0
                    clip: true

                    Behavior on Layout.preferredWidth {
                        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                    }

                    Modules.MusicIndicator {
                        id: musicContent
                        anchors.centerIn: parent
                    }
                }

                Modules.StatusIcons {
                    id: statusIconsContent
                    Layout.alignment: Qt.AlignVCenter
                }

                RowLayout {
                    id: trayContent
                    visible: TrayService.visibleItems.length > 0
                    spacing: Root.Config.pillSpacing

                    Modules.SysTray {}
                    Modules.StatusTray {}
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 14
                    radius: 1
                    color: Root.Config.dividerColor
                }

                Modules.ControlCenterLauncher {
                    id: launcherContent
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
