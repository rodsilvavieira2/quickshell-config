//@ pragma UseQApplication

import "." as Root
import "./services"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import "modules" as Modules

PanelWindow {
    id: root

    implicitHeight: Root.Config.barTopMargin + Root.Config.barHeight + Root.Config.barBottomGap
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Root.Config.barTopMargin
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        height: Root.Config.barHeight
        radius: Root.Config.barRadius
        color: Root.Config.barColor
        border.width: 1
        border.color: Root.Config.barBorderColor

        Item {
            anchors.fill: parent
            anchors.leftMargin: Root.Config.barPaddingHorizontal
            anchors.rightMargin: Root.Config.barPaddingHorizontal
            anchors.topMargin: Root.Config.barPaddingTop
            anchors.bottomMargin: Root.Config.barPaddingBottom

            Modules.Workspaces {
                id: workspacesContent

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Modules.Clock {
                id: clockContent

                anchors.centerIn: parent
            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Root.Config.sectionSpacing

                Item {
                    Layout.preferredWidth: MusicService.isActive ? musicContent.implicitWidth : 0
                    Layout.preferredHeight: MusicService.isActive ? musicContent.implicitHeight : 0
                    visible: width > 0
                    clip: true

                    Modules.MusicIndicator {
                        id: musicContent

                        anchors.centerIn: parent
                    }

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Modules.StatusIcons {
                    id: statusIconsContent

                    Layout.alignment: Qt.AlignVCenter
                }

                Modules.SystemMetrics {
                    id: systemMetricsContent

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
