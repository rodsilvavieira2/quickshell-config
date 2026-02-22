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
        spacing: 12

        SearchBar {
            id: searchBar
            Layout.fillWidth: true
            onTextChanged: LauncherSearch.query = text
            onAccepted: {
                const entry = results.currentItem?.entry
                if (entry && entry.execute) {
                    entry.execute()
                    GlobalStates.searchOpen = false
                }
            }
            onNavigateUp: results.decrementCurrentIndex()
            onNavigateDown: results.incrementCurrentIndex()
        }

        SearchResults {
            id: results
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Connections {
        target: LauncherSearch
        function onResultsChanged() {
            results.currentIndex = 0
        }
    }

    Keys.onPressed: event => {
        if (searchBar.input.activeFocus) {
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
