import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../common"
import "../shared/ui" as DS

Item {
    id: root
    
    property string icon: ""
    property string iconName: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property color activeColor: Appearance.colors.cPrimary
    property color surfaceColor: Appearance.colors.cSurfaceContainerHigh
    property color textColor: Appearance.colors.cOnSurface
    signal clicked()
    
    Layout.fillWidth: true
    Layout.preferredHeight: 88

    implicitWidth: tile.implicitWidth
    implicitHeight: Layout.preferredHeight

    DS.ToggleTile {
        id: tile
        anchors.fill: parent
        icon: root.icon
        iconName: root.iconName
        title: root.label
        subtitle: root.subLabel
        checked: root.active
        accentColor: root.activeColor
        onClicked: root.clicked()
    }
}
