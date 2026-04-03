import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import ".." as Root

Item {
    id: root

    Layout.maximumWidth: 250
    implicitWidth: Math.min(windowTitle.implicitWidth, 250)
    implicitHeight: windowTitle.implicitHeight

    property var activeWindow: Hyprland.focusedWorkspace != null ? Hyprland.focusedWorkspace.lastWindow : null
    property string titleText: activeWindow != null ? activeWindow.title : "Desktop"

    Text {
        id: windowTitle
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width

        text: root.titleText
        color: Root.Config.subtext1
        font.family: Root.Config.textFontFamily
        font.pixelSize: 11
        elide: Text.ElideRight
    }
}
