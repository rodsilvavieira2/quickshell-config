//@ pragma UseQApplication

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray

import "." as Root
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

    // Three-pill bar layout
    Item {
        anchors.fill: parent
        anchors.topMargin: Root.Config.barMargin
        anchors.bottomMargin: Root.Config.barMargin
        anchors.leftMargin: Root.Config.barMargin + 2
        anchors.rightMargin: Root.Config.barMargin + 2

        // ═══════════════════════════
        //  LEFT PILL (anchored left)
        // ═══════════════════════════
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

                // Workspaces
                Modules.Workspaces {}
            }
        }

        // ═══════════════════════════
        //  CENTER PILL (truly centered)
        // ═══════════════════════════
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

        // ═══════════════════════════
        //  RIGHT PILL (anchored right)
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

                // System tray (background apps)
                Modules.SysTray {}

                // Thin separator
                Rectangle {
                    width: 1
                    Layout.preferredHeight: rightPill.height * 0.5
                    Layout.alignment: Qt.AlignVCenter
                    color: Root.Config.overlay0
                    opacity: 0.5
                }

                // Desktop status icons
                Modules.StatusTray {}

                // Thin separator
                Rectangle {
                    width: 1
                    Layout.preferredHeight: rightPill.height * 0.5
                    Layout.alignment: Qt.AlignVCenter
                    color: Root.Config.overlay0
                    opacity: 0.5
                }

                // Power button
                Modules.PowerMenu {}
            }
        }
    }
}
