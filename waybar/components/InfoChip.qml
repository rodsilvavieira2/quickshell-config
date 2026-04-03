import QtQuick
import QtQuick.Layouts

import ".." as Root

Rectangle {
    id: root

    property url iconSource: ""
    property string iconText: ""
    property string valueText: ""
    property color iconColor: Root.Config.text
    property color labelColor: Root.Config.subtext0
    property color hoverIconColor: iconColor
    property color hoverLabelColor: labelColor
    property color backgroundColor: Root.Config.chipColor
    property color hoverColor: backgroundColor === Root.Config.chipColor ? Root.Config.chipHoverColor : Qt.lighter(backgroundColor, 1.15)
    property color activeColor: backgroundColor === Root.Config.chipColor ? Root.Config.chipActiveColor : backgroundColor
    property color borderColor: highlighted ? Root.Config.activeAccent : "transparent"
    property bool clickable: false
    property bool highlighted: false
    property int valueMaxWidth: -1

    signal clicked()

    readonly property bool hovered: chipMouse.containsMouse

    implicitWidth: chipRow.implicitWidth + Root.Config.chipPaddingHorizontal * 2
    implicitHeight: chipRow.implicitHeight + Root.Config.chipPaddingVertical * 2
    radius: Root.Config.chipRadius
    color: highlighted ? activeColor : (hovered ? hoverColor : backgroundColor)
    border.width: highlighted ? 1 : 0
    border.color: root.borderColor

    Behavior on color {
        ColorAnimation { duration: 140 }
    }

    RowLayout {
        id: chipRow
        anchors.centerIn: parent
        spacing: 6

        LucideIcon {
            visible: root.iconSource.toString().length > 0
            source: root.iconSource
            color: root.hovered && root.clickable ? root.hoverIconColor : root.iconColor
            iconSize: Root.Config.iconSize

            Behavior on color {
                ColorAnimation { duration: 140 }
            }
        }

        Text {
            visible: !root.iconSource.toString().length && root.iconText.length > 0
            text: root.iconText
            color: root.hovered && root.clickable ? root.hoverIconColor : root.iconColor
            font.family: Root.Config.iconFontFamily
            font.pixelSize: Root.Config.iconSize
            font.bold: root.highlighted

            Behavior on color {
                ColorAnimation { duration: 140 }
            }
        }

        Text {
            visible: root.valueText.length > 0
            Layout.preferredWidth: root.valueMaxWidth > 0 ? Math.min(implicitWidth, root.valueMaxWidth) : implicitWidth
            text: root.valueText
            color: root.hovered && root.clickable ? root.hoverLabelColor : root.labelColor
            font.family: Root.Config.textFontFamily
            font.pixelSize: Root.Config.iconSize - 3
            font.bold: root.highlighted
            elide: Text.ElideRight

            Behavior on color {
                ColorAnimation { duration: 140 }
            }
        }
    }

    MouseArea {
        id: chipMouse
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
