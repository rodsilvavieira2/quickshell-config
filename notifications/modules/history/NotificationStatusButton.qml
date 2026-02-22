import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../common/widgets"

GroupButton {
    id: button
    property string buttonIcon: ""
    property string buttonText: ""

    baseHeight: 36
    baseWidth: content.implicitWidth + 46
    clickedWidth: baseWidth + 6

    buttonRadius: baseHeight / 2
    buttonRadiusPressed: Appearance.rounding.small
    colBackground: Appearance.colors.colLayer2
    colBackgroundHover: Appearance.colors.colFlamingo
    colBackgroundActive: Appearance.colors.colFlamingo
    property color displayColor: toggled ? Appearance.colors.colOnPrimary : (button.highlighted ? Appearance.colors.colOnFlamingo : Appearance.colors.colOnLayer0)

    contentItem: Item {
        id: content
        anchors.fill: parent
        implicitWidth: contentRowLayout.implicitWidth
        implicitHeight: contentRowLayout.implicitHeight
        RowLayout {
            id: contentRowLayout
            anchors.centerIn: parent
            spacing: 6
            MaterialSymbol {
                visible: buttonIcon !== ""
                text: buttonIcon
                iconSize: Appearance.font.pixelSize.huge
                color: button.displayColor
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
            StyledText {
                visible: buttonText !== ""
                text: buttonText
                font.pixelSize: Appearance.font.pixelSize.small
                color: button.displayColor
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
        }
    }
}
