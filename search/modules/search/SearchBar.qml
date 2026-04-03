import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../common/widgets"
import "../../services"

Item {
    id: root
    implicitHeight: 70

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
        anchors.leftMargin: 18
        anchors.rightMargin: 14
        spacing: 12

        Text {
            text: ""
            font.family: Appearance.font.family.icon
            font.pixelSize: 20
            color: Appearance.colors.colAccent
            Layout.alignment: Qt.AlignVCenter
        }

        TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            background: Item {}
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.larger
            color: Appearance.colors.colOnLayer0
            placeholderText: "Search..."
            placeholderTextColor: Appearance.colors.colSubtext
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
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
