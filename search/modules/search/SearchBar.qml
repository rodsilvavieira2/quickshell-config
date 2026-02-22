import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"
import "../../common/widgets"
import "../../services"

Rectangle {
    id: root
    radius: 12
    color: Appearance.colors.colLayer1
    border.width: 1
    border.color: Appearance.colors.colLayer1Hover
    implicitHeight: 56

    property alias text: searchField.text
    property alias input: searchField
    signal accepted()
    signal navigateUp()
    signal navigateDown()

    function forceFocus() {
        searchField.forceActiveFocus()
    }

    Component.onCompleted: forceFocus()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Image {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            source: "/home/rodrigo/.config/quickshell/search/assets/search.svg"
            sourceSize: Qt.size(18, 18)
        }

        TextField {
            id: searchField
            Layout.fillWidth: true
            background: Item {}
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer0
            placeholderText: "Search apps"
            placeholderTextColor: Appearance.colors.colSubtext
            onAccepted: root.accepted()
            Keys.onEscapePressed: event => {
                GlobalStates.searchOpen = false
                event.accepted = true
            }
            Keys.onUpPressed: event => {
                root.navigateUp()
                event.accepted = true
            }
            Keys.onDownPressed: event => {
                root.navigateDown()
                event.accepted = true
            }
        }
    }
}
