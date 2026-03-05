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
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: rightContent.implicitWidth + Root.Config.pillPadding * 2
            radius: Root.Config.radius
            color: Root.Config.pillColor

            RowLayout {
                id: rightContent
                anchors.centerIn: parent
                spacing: Root.Config.pillSpacing

                Modules.SysTray {}

                Modules.StatusTray {}
            }
        }
    }
}
