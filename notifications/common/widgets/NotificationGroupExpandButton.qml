import QtQuick
import QtQuick.Layouts
import ".."

RippleButton {
    id: root
    required property int count
    required property bool expanded
    property real fontSize: Appearance ? (Appearance.font.pixelSize.small !== undefined ? Appearance.font.pixelSize.small : 13) : 13
    property real iconSize: Appearance ? (Appearance.font.pixelSize.normal !== undefined ? Appearance.font.pixelSize.normal : 16) : 16
    implicitHeight: fontSize + 6
    implicitWidth: Math.max(contentItem.implicitWidth + 10, 30)

    buttonRadius: Appearance.rounding.full
    colBackground: Appearance.colors.colLayer2
    colBackgroundHover: Appearance.colors.colLayer3
    colRipple: Appearance.colors.colLayer4

    contentItem: Item {
        anchors.centerIn: parent
        implicitWidth: contentRow.implicitWidth
        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 4
            StyledText {
                visible: root.count > 1
                text: root.count
                font.pixelSize: root.fontSize
                color: Appearance.colors.colSubtext
            }
            MaterialSymbol {
                text: "keyboard_arrow_down"
                iconSize: root.iconSize
                color: Appearance.colors.colOnLayer0
                rotation: expanded ? 180 : 0
                Behavior on rotation {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
        }
    }
}
