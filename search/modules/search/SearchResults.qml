import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../common"
import "../../common/widgets"
import "../../services"

ListView {
    id: root
    clip: true
    spacing: 4
    topMargin: 2
    bottomMargin: 4
    leftMargin: 0
    rightMargin: 0
    model: LauncherSearch.results
    currentIndex: 0
    boundsBehavior: Flickable.StopAtBounds
    highlightMoveDuration: 0

    delegate: SearchItem {
        required property var modelData
        required property int index
        entry: modelData
        active: ListView.isCurrentItem
        itemIndex: index
        width: ListView.view.width
    }

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        contentItem: Rectangle {
            implicitWidth: 4
            radius: 2
            color: Appearance.colors.colLayer2Hover
            opacity: 0.48
        }
    }
}
