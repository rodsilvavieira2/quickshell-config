pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import ".." as Root

Item {
    id: root
    required property QsMenuEntry menuEntry
    property bool forceIconColumn: false
    property bool forceSpecialInteractionColumn: false
    readonly property bool hasIcon: menuEntry.icon.length > 0
    readonly property bool hasSpecialInteraction: menuEntry.buttonType !== QsMenuButtonType.None

    signal dismiss()
    signal openSubmenu(handle: var)

    implicitWidth: contentRow.implicitWidth + 24
    implicitHeight: menuEntry.isSeparator ? 1 : 36
    Layout.topMargin: menuEntry.isSeparator ? 4 : 0
    Layout.bottomMargin: menuEntry.isSeparator ? 4 : 0
    Layout.fillWidth: true

    MouseArea {
        anchors.fill: parent
        enabled: !root.menuEntry.isSeparator
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true

        Rectangle {
            anchors.fill: parent
            color: parent.containsMouse ? Root.Config.surface0 : "transparent"
            visible: !root.menuEntry.isSeparator
        }

        Rectangle {
            anchors.fill: parent
            color: Root.Config.surface0
            visible: root.menuEntry.isSeparator
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

    RowLayout {
        id: contentRow
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 8
        visible: !root.menuEntry.isSeparator

        // Checkbox or radio button
        Item {
            visible: root.hasSpecialInteraction || root.forceSpecialInteractionColumn
            implicitWidth: 20
            implicitHeight: 20

            Rectangle {
                anchors.centerIn: parent
                width: 16
                height: 16
                radius: root.menuEntry.buttonType === QsMenuButtonType.CheckBox ? 2 : 8
                border.width: 2
                border.color: root.menuEntry.checkState !== Qt.Unchecked ? Root.Config.mauve : Root.Config.surface1
                color: root.menuEntry.checkState !== Qt.Unchecked ? Root.Config.mauve : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.menuEntry.checkState === Qt.PartiallyChecked ? "−" : "✓"
                    color: Root.Config.mantle
                    font.pixelSize: 12
                    font.bold: true
                    visible: root.menuEntry.checkState !== Qt.Unchecked && root.menuEntry.buttonType === QsMenuButtonType.CheckBox
                }
            }
        }

        // Icon
        Item {
            visible: root.hasIcon || root.forceIconColumn
            implicitWidth: 20
            implicitHeight: 20

            IconImage {
                anchors.centerIn: parent
                source: root.menuEntry.icon
                width: 20
                height: 20
                visible: root.menuEntry.icon.length > 0
            }
        }

        Text {
            text: root.menuEntry.text
            color: Root.Config.text
            font.family: Root.Config.textFontFamily
            font.pixelSize: 12
            Layout.fillWidth: true
        }

        Text {
            text: "›"
            color: Root.Config.subtext0
            font.pixelSize: 16
            visible: root.menuEntry.hasChildren
        }
    }
}
