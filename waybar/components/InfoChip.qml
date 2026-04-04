import QtQuick
import QtQuick.Layouts

import ".." as Root
import "../shared/ui" as DS

Item {
    id: root

    property url iconSource: ""
    property string iconText: ""
    property string valueText: ""
    property color iconColor: Qt.rgba(255/255, 255/255, 255/255, 0.90)
    property color labelColor: Qt.rgba(255/255, 255/255, 255/255, 0.90)
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

    readonly property bool hovered: chip.hovered

    implicitWidth: chip.implicitWidth
    implicitHeight: 34

    DS.Chip {
        id: chip
        anchors.fill: parent
        text: root.valueText
        clickable: root.clickable
        selected: root.highlighted
        containerColor: root.backgroundColor
        hoverContainerColor: root.hoverColor
        pressedContainerColor: root.activeColor
        selectedContainerColor: root.activeColor
        contentColor: chip.hovered && root.clickable ? root.hoverLabelColor : root.labelColor
        selectedContentColor: chip.hovered && root.clickable ? root.hoverLabelColor : root.labelColor
        borderColor: "transparent"
        selectedBorderColor: root.borderColor
        horizontalPadding: Root.Config.chipPaddingHorizontal
        verticalPadding: Root.Config.chipPaddingVertical
        spacing: 6
        contentFontSize: Root.Config.iconSize - 3
        textMaxWidth: root.valueMaxWidth
        leading: Component {
            Item {
                implicitWidth: iconLoader.implicitWidth
                implicitHeight: iconLoader.implicitHeight

                Loader {
                    id: iconLoader
                    active: root.iconSource.toString().length > 0 || root.iconText.length > 0
                    sourceComponent: root.iconSource.toString().length > 0 ? iconComponent : textComponent
                }

                Component {
                    id: iconComponent

                    LucideIcon {
                        source: root.iconSource
                        color: chip.hovered && root.clickable ? root.hoverIconColor : root.iconColor
                        iconSize: Root.Config.iconSize
                    }
                }

                Component {
                    id: textComponent

                    Text {
                        visible: root.iconText.length > 0
                        text: root.iconText
                        color: chip.hovered && root.clickable ? root.hoverIconColor : root.iconColor
                        font.family: Root.Config.iconFontFamily
                        font.pixelSize: Root.Config.iconSize
                        font.bold: root.highlighted
                    }
                }
            }
        }
        onClicked: root.clicked()
    }
}
