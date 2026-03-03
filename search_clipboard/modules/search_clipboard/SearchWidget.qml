import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../common"
import "../../common/widgets"
import "../../services"

Item {
    id: root
    property alias searchText: searchBar.text

    function focusInput() {
        searchBar.forceFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            onTextChanged: LauncherSearch.query = text
            onAccepted: {
                const entry = results.currentItem?.entry
                if (entry && entry.execute) {
                    entry.execute()
                }
            }
            onNavigateUp: results.decrementCurrentIndex()
            onNavigateDown: results.incrementCurrentIndex()
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Appearance.colors.colSeparator
            visible: LauncherSearch.results.length > 0
            opacity: 0.6
        }

        SearchResults {
            id: results
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: LauncherSearch.results.length > 0
        }
    }

    Connections {
        target: LauncherSearch
        function onResultsChanged() {
            results.currentIndex = 0
        }
    }

    Keys.onPressed: event => {
        if (!GlobalStates.searchOpen) {
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Up) {
            results.decrementCurrentIndex()
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            results.incrementCurrentIndex()
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            const entry = results.currentItem?.entry
            if (entry && entry.execute) {
                entry.execute()
                GlobalStates.searchOpen = false
            }
            event.accepted = true
        }
    }
}
