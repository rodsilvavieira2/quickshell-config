import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../common"
import "../../common/widgets"
import "../../services"

ListView {
    id: root
    clip: true
    spacing: 6
    leftMargin: 6
    rightMargin: 6
    model: LauncherSearch.results
    currentIndex: 0
    boundsBehavior: Flickable.StopAtBounds
    highlightMoveDuration: 0

    delegate: SearchItem {
        required property var modelData
        required property int index
        entry: modelData
        active: ListView.isCurrentItem
        width: ListView.view.width
    }
}
