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

    Item {
        anchors.fill: parent
        anchors.topMargin: Root.Config.barMargin
        anchors.bottomMargin: Root.Config.barMargin
        anchors.leftMargin: Root.Config.barMargin + 2
        anchors.rightMargin: Root.Config.barMargin + 2

        Rectangle {
            id: leftPill
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: leftContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            RowLayout {
                id: leftContent
                anchors.centerIn: parent
                spacing: Root.Config.pillSpacing

                Modules.Workspaces {}
            }
        }

        Rectangle {
            id: centerPill
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: clockContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            Modules.Clock {
                id: clockContent
                anchors.centerIn: parent
            }
        }

        // ═══════════════════════════════════
        //  MUSIC PILL (left of status icons)
        // ═══════════════════════════════════
        Rectangle {
            id: musicPill
            anchors.right: statusIconsPill.left
            anchors.rightMargin: Root.Config.barMargin
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: MusicService.isActive ? musicContent.implicitWidth + Root.Config.pillPadding * 2 : 0
            radius: Root.Config.radius
            color: Root.Config.pillColor
            clip: true
            visible: width > 0

            Behavior on width {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            Modules.MusicIndicator {
                id: musicContent
                anchors.centerIn: parent
            }
        }

        // ═══════════════════════════════════
        //  STATUS ICONS PILL (left of tray)
        // ═══════════════════════════════════
        Rectangle {
            id: statusIconsPill
            anchors.right: rightPill.left
            anchors.rightMargin: Root.Config.barMargin
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: statusIconsContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            Modules.StatusIcons {
                id: statusIconsContent
                anchors.centerIn: parent
            }
        }

        // ═══════════════════════════
        //  RIGHT PILL (tray group)
        // ═══════════════════════════
        Rectangle {
            id: rightPill
            anchors.right: settingsPill.left
            anchors.rightMargin: Root.Config.barMargin
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: visible ? rightContent.implicitWidth + Root.Config.pillPadding * 2 : 0
            radius: Root.Config.radius
            color: Root.Config.pillColor
            visible: TrayService.visibleItems.length > 0

            RowLayout {
                id: rightContent
                anchors.centerIn: parent
                spacing: Root.Config.pillSpacing

                Modules.SysTray {}

                Modules.StatusTray {}
            }
        }

        // ═════════════════════════════
        //  SETTINGS PILL (standalone)
        // ═════════════════════════════
        Rectangle {
            id: settingsPill
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: settingsContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            Modules.ControlCenterLauncher {
                id: settingsContent
                anchors.centerIn: parent
            }
        }
    }
}
