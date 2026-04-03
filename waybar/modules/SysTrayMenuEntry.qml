pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import ".." as Root
import "../shared/ui" as DS

Item {
    id: root
    required property QsMenuEntry menuEntry
    property bool forceIconColumn: false
    property bool forceSpecialInteractionColumn: false
    readonly property bool hasIcon: menuEntry.icon.length > 0
    readonly property bool hasSpecialInteraction: menuEntry.buttonType !== QsMenuButtonType.None

    signal dismiss()
    signal openSubmenu(handle: var)

    implicitWidth: 220
    implicitHeight: menuEntry.isSeparator ? 9 : 40
    Layout.topMargin: menuEntry.isSeparator ? 4 : 0
    Layout.bottomMargin: menuEntry.isSeparator ? 4 : 0
    Layout.fillWidth: true

    Rectangle {
        anchors.fill: parent
        visible: root.menuEntry.isSeparator
        color: "transparent"

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            height: 1
            radius: 0.5
            color: Root.Config.dividerColor
        }
    }

    DS.SearchResultItem {
        anchors.fill: parent
        visible: !root.menuEntry.isSeparator
        clickable: true
        title: root.menuEntry.text
        selected: false
        leading: Component {
            RowLayout {
                spacing: 8

                Item {
                    visible: root.hasSpecialInteraction || root.forceSpecialInteractionColumn
                    implicitWidth: 20
                    implicitHeight: 20

                    Rectangle {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        radius: root.menuEntry.buttonType === QsMenuButtonType.CheckBox ? 3 : 8
                        border.width: 2
                        border.color: root.menuEntry.checkState !== Qt.Unchecked ? Root.Config.activeAccent : Root.Config.surface1
                        color: root.menuEntry.checkState !== Qt.Unchecked ? Root.Config.activeAccent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: root.menuEntry.checkState === Qt.PartiallyChecked ? "−" : "✓"
                            color: Root.Config.base
                            font.pixelSize: 12
                            font.bold: true
                            visible: root.menuEntry.checkState !== Qt.Unchecked && root.menuEntry.buttonType === QsMenuButtonType.CheckBox
                        }
                    }
                }

                Item {
                    visible: root.hasIcon || root.forceIconColumn
                    implicitWidth: 20
                    implicitHeight: 20

                    IconImage {
                        anchors.centerIn: parent
                        source: root.menuEntry.icon
                        width: 18
                        height: 18
                        visible: root.menuEntry.icon.length > 0
                    }
                }
            }
        }
        trailing: Component {
            Text {
                visible: root.menuEntry.hasChildren
                text: "›"
                color: Root.Config.subtext0
                font.pixelSize: 16
            }
        }
        onClicked: {
            if (root.menuEntry.hasChildren) {
                root.openSubmenu(root.menuEntry);
                return;
            }
            root.menuEntry.triggered();
            root.dismiss();
        }
    }
}
