import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    property bool shown: false
    property string icon: "notifications"
    property string description: ""
    property int iconSize: 48

    visible: shown
    opacity: shown ? 1 : 0
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        MaterialSymbol {
            text: root.icon
            iconSize: root.iconSize
            color: Appearance.colors.colSubtext
        }

        StyledText {
            text: root.description
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.small
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
