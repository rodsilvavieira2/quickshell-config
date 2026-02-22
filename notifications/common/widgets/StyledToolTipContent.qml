import QtQuick
import ".."

Item {
    id: root
    required property string text
    property bool shown: false
    property real horizontalPadding: 10
    property real verticalPadding: 5
    implicitWidth: tooltipTextObject.implicitWidth + 2 * root.horizontalPadding
    implicitHeight: tooltipTextObject.implicitHeight + 2 * root.verticalPadding

    Rectangle {
        id: backgroundRectangle
        anchors {
            bottom: root.bottom
            horizontalCenter: root.horizontalCenter
        }
        color: Appearance ? (Appearance.colors.colTooltip !== undefined ? Appearance.colors.colTooltip : "#313244") : "#313244"
        radius: Appearance ? (Appearance.rounding.verysmall !== undefined ? Appearance.rounding.verysmall : 6) : 6
        opacity: shown ? 1 : 0
        implicitWidth: shown ? (tooltipTextObject.implicitWidth + 2 * root.horizontalPadding) : 0
        implicitHeight: shown ? (tooltipTextObject.implicitHeight + 2 * root.verticalPadding) : 0
        clip: true

        Behavior on implicitWidth {
            animation: Appearance ? Appearance.animation.elementMoveFast.numberAnimation.createObject(this) : null
        }
        Behavior on implicitHeight {
            animation: Appearance ? Appearance.animation.elementMoveFast.numberAnimation.createObject(this) : null
        }
        Behavior on opacity {
            animation: Appearance ? Appearance.animation.elementMoveFast.numberAnimation.createObject(this) : null
        }

        StyledText {
            id: tooltipTextObject
            anchors.centerIn: parent
            text: root.text
            font.pixelSize: Appearance ? (Appearance.font.pixelSize.smaller !== undefined ? Appearance.font.pixelSize.smaller : 11) : 11
            font.hintingPreference: Font.PreferNoHinting
            color: Appearance ? (Appearance.colors.colOnTooltip !== undefined ? Appearance.colors.colOnTooltip : "#cdd6f4") : "#cdd6f4"
            wrapMode: Text.Wrap
        }
    }
}
