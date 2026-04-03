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

    implicitHeight: Root.Config.barHeight + Root.Config.barMargin * 2
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: Root.Config.barMargin
        anchors.bottomMargin: Root.Config.barMargin
        anchors.leftMargin: Root.Config.barMargin + 2
        anchors.rightMargin: Root.Config.barMargin + 2
        spacing: Root.Config.pillSpacing

        // Group 1: Left
        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: workspacesContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            Modules.Workspaces {
                id: workspacesContent
                anchors.centerIn: parent
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Group 2: Center
        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: clockContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            Modules.Clock {
                id: clockContent
                anchors.centerIn: parent
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Group 3: Right
        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: MusicService.isActive ? musicContent.implicitWidth + Root.Config.pillPadding * 2 : 0
            radius: Root.Config.radius
            color: Root.Config.pillColor
            clip: true
            visible: width > 0

            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            Modules.MusicIndicator {
                id: musicContent
                anchors.centerIn: parent
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: statusIconsContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            Modules.StatusIcons {
                id: statusIconsContent
                anchors.centerIn: parent
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: visible ? trayContent.implicitWidth + Root.Config.pillPadding * 2 : 0
            radius: Root.Config.radius
            color: Root.Config.pillColor
            visible: TrayService.visibleItems.length > 0

            RowLayout {
                id: trayContent
                anchors.centerIn: parent
                spacing: Root.Config.pillSpacing

                Modules.SysTray {}

                Modules.StatusTray {}
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: launcherContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            Modules.ControlCenterLauncher {
                id: launcherContent
                anchors.centerIn: parent
            }
        }
    }
}
