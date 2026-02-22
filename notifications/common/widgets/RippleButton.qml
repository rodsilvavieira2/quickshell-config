import QtQuick
import QtQuick.Controls
import ".."

Control {
    id: root
    signal clicked()
    property color colBackground: "transparent"
    property color colBackgroundHover: "transparent"
    property color colRipple: "#ffffff"
    property color colText: Appearance.colors.colOnLayer0
    property color colTextHover: Appearance.colors.colOnLayer0
    property real buttonRadius: Appearance.rounding.small
    readonly property bool highlighted: root.enabled && (mouseArea.containsMouse || mouseArea.pressed || root.activeFocus)

    focusPolicy: Qt.StrongFocus

    leftPadding: 10
    rightPadding: 10
    topPadding: 6
    bottomPadding: 6

    implicitHeight: 34
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding

    property alias mouseArea: mouseArea

    background: Rectangle {
        id: bg
        radius: root.buttonRadius
        color: root.highlighted ? root.colBackgroundHover : root.colBackground
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        clip: true

        Rectangle {
            id: ripple
            anchors.centerIn: parent
            width: 0
            height: 0
            radius: width / 2
            color: root.colRipple
            opacity: 0.15
        }
    }

    contentItem: StyledText {
        id: label
        text: ""
        color: root.highlighted ? root.colTextHover : root.colText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            root.forceActiveFocus()
            ripple.width = 0
            ripple.height = 0
            ripple.opacity = 0.2
            rippleAnim.restart()
        }
        onReleased: root.clicked()
    }

    SequentialAnimation {
        id: rippleAnim
        running: false
        NumberAnimation {
            target: ripple
            property: "width"
            to: Math.max(root.width, root.height) * 1.4
            duration: 220
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: ripple
            property: "height"
            to: Math.max(root.width, root.height) * 1.4
            duration: 220
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: ripple
            property: "opacity"
            to: 0
            duration: 180
        }
    }
}
