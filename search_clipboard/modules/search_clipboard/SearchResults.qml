import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../common"
import "../../common/widgets"
import "../../services"

ListView {
    id: root
    clip: true
    spacing: 2
    topMargin: 8
    bottomMargin: 8
    leftMargin: 8
    rightMargin: 8
    model: LauncherSearch.results
    currentIndex: 0
    boundsBehavior: Flickable.StopAtBounds
    highlightMoveDuration: 0

    delegate: SearchItem {
        required property var modelData
        required property int index
        entry: modelData
        active: ListView.isCurrentItem
        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        x: ListView.view.leftMargin
    }

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        contentItem: Rectangle {
            implicitWidth: 3
            radius: 1.5
            color: Appearance.colors.colLayer2Hover
            opacity: 0.7
        }
    }
}
