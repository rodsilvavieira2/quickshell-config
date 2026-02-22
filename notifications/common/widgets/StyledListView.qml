import QtQuick
import QtQuick.Controls
import ".."

ListView {
    id: root
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    spacing: 4

    ScrollBar.vertical: ScrollBar {
        active: true
        width: 6
        contentItem: Rectangle {
            implicitWidth: 6
            radius: 3
            color: Appearance.colors.colLayer3
        }
    }
}
