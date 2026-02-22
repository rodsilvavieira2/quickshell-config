import QtQuick
import QtQuick.Controls
import ".."

Control {
    id: root
    signal clicked()
    property real baseHeight: 36
    property real baseWidth: contentItem.implicitWidth + 30
    property real clickedWidth: baseWidth + 6
    property real buttonRadius: baseHeight / 2
    property real buttonRadiusPressed: Appearance.rounding.small
    property color colBackground: Appearance.colors.colLayer2
    property color colBackgroundHover: Appearance.colors.colLayer3
    property color colBackgroundActive: Appearance.colors.colLayer3
    property bool toggled: false

    implicitHeight: baseHeight
    implicitWidth: baseWidth

    background: Rectangle {
        id: bg
        radius: mouseArea.pressed ? root.buttonRadiusPressed : root.buttonRadius
        color: mouseArea.pressed ? root.colBackgroundActive : (mouseArea.containsMouse ? root.colBackgroundHover : root.colBackground)
        Behavior on radius {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
    }

    contentItem: Item {}

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
